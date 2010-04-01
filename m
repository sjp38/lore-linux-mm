Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD7136B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 15:03:56 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o31J3nsw016616
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:03:49 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz9.hot.corp.google.com with ESMTP id o31J3gx7029053
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 12:03:43 -0700
Received: by pwi5 with SMTP id 5so1319426pwi.19
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 12:03:42 -0700 (PDT)
Date: Thu, 1 Apr 2010 12:03:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] oom: fix the unsafe usage of badness() in
 proc_oom_score()
In-Reply-To: <20100401131357.GB11291@redhat.com>
Message-ID: <alpine.DEB.2.00.1004011200330.30661@chino.kir.corp.google.com>
References: <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com>
 <alpine.DEB.2.00.1003301331110.5234@chino.kir.corp.google.com> <20100331091628.GA11438@redhat.com> <20100331201746.GC11635@redhat.com> <alpine.DEB.2.00.1004010029260.6285@chino.kir.corp.google.com> <20100401131321.GA11291@redhat.com>
 <20100401131357.GB11291@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> proc_oom_score(task) have a reference to task_struct, but that is all.
> If this task was already released before we take tasklist_lock
> 
> 	- we can't use task->group_leader, it points to nowhere
> 
> 	- it is not safe to call badness() even if this task is
> 	  ->group_leader, has_intersects_mems_allowed() assumes
> 	  it is safe to iterate over ->thread_group list.
> 
> 	- even worse, badness() can hit ->signal == NULL
> 
> Add the pid_alive() check to ensure __unhash_process() was not called.
> 
> Also, use "task" instead of task->group_leader. badness() should return
> the same result for any sub-thread. Currently this is not true, but
> this should be changed anyway.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

Andrew, this is 2.6.34 material and should be backported to stable.  It's 
not introduced by the recent oom killer rewrite pending in -mm, but it 
will require a trivial merge resolution on that work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
