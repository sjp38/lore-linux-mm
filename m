Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 49E5D6B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:32:29 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [10.3.21.14])
	by smtp-out.google.com with ESMTP id o2UKWQZt008135
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:32:27 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq14.eem.corp.google.com with ESMTP id o2UKWOOr011114
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:32:25 +0200
Received: by pwi10 with SMTP id 10so7936598pwi.17
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:32:24 -0700 (PDT)
Date: Tue, 30 Mar 2010 13:32:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: fix the unsafe proc_oom_score()->badness() call
In-Reply-To: <20100330163909.GA16884@redhat.com>
Message-ID: <alpine.DEB.2.00.1003301331110.5234@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Oleg Nesterov wrote:

> proc_oom_score(task) have a reference to task_struct, but that is all.
> If this task was already released before we take tasklist_lock
> 
> 	- we can't use task->group_leader, it points to nowhere
> 
> 	- it is not safe to call badness() even if this task is
> 	  ->group_leader, has_intersects_mems_allowed() assumes
> 	  it is safe to iterate over ->thread_group list.
> 
> Add the pid_alive() check to ensure __unhash_process() was not called.
> 
> Note: I think we shouldn't use ->group_leader, badness() should return
> the same result for any sub-thread. However this is not true currently,
> and I think that ->mm check and list_for_each_entry(p->children) in
> badness are not right.
> 

I think it would be better to just use task and not task->group_leader.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
