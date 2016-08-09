Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 473DB6B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 09:56:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so25528972pfd.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 06:56:50 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id g8si42842352pfc.294.2016.08.09.06.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 06:56:49 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id cf3so1000235pad.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 06:56:49 -0700 (PDT)
Date: Tue, 9 Aug 2016 23:57:03 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
Message-ID: <20160809135703.GA11823@350D>
Reply-To: bsingharora@gmail.com
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
 <57A99BCB.6070905@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57A99BCB.6070905@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zefan Li <lizefan@huawei.com>
Cc: Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Aug 09, 2016 at 05:00:59PM +0800, Zefan Li wrote:
> > This almost stalls the system, this patch moves the threadgroup_change_begin
> > from before cgroup_fork() to just before cgroup_canfork(). Ideally we shouldn't
> > have to worry about threadgroup changes till the task is actually added to
> > the threadgroup. This avoids having to call reclaim with cgroup_threadgroup_rwsem
> > held.
> > 
> > There are other theoretical issues with this semaphore
> > 
> > systemd can do
> > 
> > 1. cgroup_mutex (cgroup_kn_lock_live)
> > 2. cgroup_threadgroup_rwsem (W) (__cgroup_procs_write)
> > 
> > and other threads can go
> > 
> > 1. cgroup_threadgroup_rwsem (R) (copy_process)
> > 2. mem_cgroup_iter (as a part of reclaim) (cgroup_mutex -- rcu lock or cgroup_mutex)
> > 
> > However, I've not examined them in too much detail or looked at lockdep
> > wait chains for those paths.
> > 
> > I am sure there is a good reason for placing cgroup_threadgroup_rwsem
> > where it is today and I might be missing something. I am also surprised
> > no-one else has run into it so far.
> > 
> > Comments?
> > 
> 
> We used to use cgroup_threadgroup_rwsem for syncronization between threads
> in the same threadgroup, but now it has evolved to ensure atomic operations
> across multi processes.
> 

Yes and it seems incorrect

> For example, I'm trying to fix a race. See https://lkml.org/lkml/2016/8/8/900
> 
> And the fix kind of relies on the fact that cgroup_post_fork() is placed
> inside the read section of cgroup_threadgroup_rwsem, so that cpuset_fork()
> won't race with cgroup migration.
>

My patch retains that behaviour, before ss->fork() is called we hold
the cgroup_threadgroup_rwsem, in fact it is held prior to ss->can_fork()


Balbir 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
