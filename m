Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0F316B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 02:29:02 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id r91so7279396uar.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:29:02 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id b34si22667845qtb.136.2016.08.08.23.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 23:29:01 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id o1so374915qkd.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:29:01 -0700 (PDT)
Date: Tue, 9 Aug 2016 02:29:00 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
Message-ID: <20160809062900.GD4906@mtj.duckdns.org>
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, Balbir.

On Tue, Aug 09, 2016 at 02:19:01PM +1000, Balbir Singh wrote:
> 
> cgroup_threadgroup_rwsem is acquired in read mode during process exit and fork.
> It is also grabbed in write mode during __cgroups_proc_write
> 
> I've recently run into a scenario with lots of memory pressure and OOM
> and I am beginning to see
> 
> systemd
> 
>  __switch_to+0x1f8/0x350
>  __schedule+0x30c/0x990
>  schedule+0x48/0xc0
>  percpu_down_write+0x114/0x170
>  __cgroup_procs_write.isra.12+0xb8/0x3c0
>  cgroup_file_write+0x74/0x1a0
>  kernfs_fop_write+0x188/0x200
>  __vfs_write+0x6c/0xe0
>  vfs_write+0xc0/0x230
>  SyS_write+0x6c/0x110
>  system_call+0x38/0xb4
> 
> This thread is waiting on the reader of cgroup_threadgroup_rwsem to exit.
> The reader itself is under memory pressure and has gone into reclaim after
> fork. There are times the reader also ends up waiting on oom_lock as well.
> 
...
>  copy_page_range+0x4ec/0x950
>  copy_process.isra.5+0x15a0/0x1870
>  _do_fork+0xa8/0x4b0
>  ppc_clone+0x8/0xc

Yeah, we definitely don't wanna be holding the rwsem during the actual
fork.

...
> There are other theoretical issues with this semaphore
> 
> systemd can do
> 
> 1. cgroup_mutex (cgroup_kn_lock_live)
> 2. cgroup_threadgroup_rwsem (W) (__cgroup_procs_write)
> 
> and other threads can go
> 
> 1. cgroup_threadgroup_rwsem (R) (copy_process)
> 2. mem_cgroup_iter (as a part of reclaim) (cgroup_mutex -- rcu lock or cgroup_mutex)

Hmm? Where does mem_cgroup_iter grab cgroup_mutex?  cgroup_mutex nests
outside cgroup_threadgroup_rwsem or most other mutexes for that matter
and isn't exposed from cgroup core.

> However, I've not examined them in too much detail or looked at lockdep
> wait chains for those paths.
> 
> I am sure there is a good reason for placing cgroup_threadgroup_rwsem
> where it is today and I might be missing something. I am also surprised

I could be missing something too but the positioning is largely
historic.

> no-one else has run into it so far.

Maybe it might matter that much on a system which is already heavily
thrasing, but yeah, we definitely want to tighten down the reader
sections so that it doesn't get in the way of making forward progress.

> Comments?

The change looks good to me on the first glance but I'll think more
about it tomorrow.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
