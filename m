Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF6D36B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:48:42 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o2VNma7d024133
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 01:48:37 +0200
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by wpaz5.hot.corp.google.com with ESMTP id o2VNmZdp026702
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:48:35 -0700
Received: by pwi10 with SMTP id 10so636482pwi.31
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:48:35 -0700 (PDT)
Date: Wed, 31 Mar 2010 16:48:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100331233058.GA6081@redhat.com>
Message-ID: <alpine.DEB.2.00.1003311641470.2150@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com>
 <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com>
 <20100331233058.GA6081@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> > Why? You ignored this part:
> >
> > 	Say, right after exit_mm() we are doing acct_process(), and f_op->write()
> > 	needs a page. So, you are saying that in this case __page_cache_alloc()
> > 	can never trigger out_of_memory() ?
> >
> > why this is not possible?
> >
> > David, I am not arguing, I am asking.
> 
> In case I wasn't clear...
> 
> Yes, currently __oom_kill_task(p) is not possible if p->mm == NULL.
> 
> But your patch adds
> 
> 	if (fatal_signal_pending(current))
> 		__oom_kill_task(current);
> 
> into out_of_memory().
> 

Ok, and it's possible during the tasklist scan if current is PF_EXITING 
and that gets passed to oom_kill_process(), so we need the following 
patch.  Can I have your acked-by and then I'll propose it to Andrew with a 
follow-up that merges __oom_kill_task() into oom_kill_task() since it only 
has one caller now anyway?

 [ Both of these situations will be current since the oom killer is a 
   no-op whenever another task is found to be PF_EXITING and
   oom_kill_process() wouldn't get called with any other thread unless
   oom_kill_quick is enabled or its VM_FAULT_OOM in which cases we kill 
   current as well. ]

Thanks Oleg.
---
 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -459,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
-		__oom_kill_task(p);
+		set_tsk_thread_flag(p, TIF_MEMDIE);
 		return 0;
 	}
 
@@ -686,7 +686,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * its memory.
 	 */
 	if (fatal_signal_pending(current)) {
-		__oom_kill_task(current);
+		set_tsk_thread_flag(current, TIF_MEMDIE);
 		return;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
