Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id B329C6B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:14:00 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id r2so1642772igi.0
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:14:00 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id ce6si32218823icc.61.2014.06.09.02.13.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:14:00 -0700 (PDT)
Received: by mail-ig0-f174.google.com with SMTP id h3so3593415igd.7
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:13:59 -0700 (PDT)
Date: Mon, 9 Jun 2014 02:13:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
In-Reply-To: <539574F1.2060701@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com>
References: <53902A44.50005@cn.fujitsu.com> <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org> <539192F1.7050308@cn.fujitsu.com> <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com> <539574F1.2060701@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org, Li Zefan <lizefan@huawei.com>

On Mon, 9 Jun 2014, Gu Zheng wrote:

> > I think your patch addresses the problem that you're reporting but misses 
> > the larger problem with cpuset.mems rebinding on fork().  When the 
> > forker's task_struct is duplicated (which includes ->mems_allowed) and it 
> > races with an update to cpuset_being_rebound in update_tasks_nodemask() 
> > then the task's mems_allowed doesn't get updated.
> 
> Yes, you are right, this patch just wants to address the bug reported above.
> The race condition you mentioned above inherently exists there, but it is yet
> another issue, the rcu lock here makes no sense to it, and I think we need
> additional sync-mechanisms if want to fix it.

Yes, the rcu lock is not providing protection for any critical section 
here that requires (1) the forker's cpuset to be stored in 
cpuset_being_rebound or (2) the forked thread's cpuset to be rebound by 
the cpuset nodemask update, and no race involving the two.

> But thinking more, though the current implementation has flaw, but I worry
> about the negative effect if we really want to fix it. Or maybe the fear
> is unnecessary.:) 
> 

It needs to be slightly rewritten to work properly without negatively 
impacting the latency of fork().  Do you have the cycles to do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
