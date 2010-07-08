Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 96E5E6B0248
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 06:57:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o68AvgC0025459
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 19:57:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F50F45DE6E
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:57:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0B8645DE6F
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:57:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCCB91DB803B
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:57:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ADE61DB8037
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:57:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <1278586173.1900.50.camel@laptop>
References: <AANLkTimLSnNot2byTWYuIHE8rhGLXbl1zKsQQhmci1Do@mail.gmail.com> <1278586173.1900.50.camel@laptop>
Message-Id: <20100708195421.CD48.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  8 Jul 2010 19:57:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> On Thu, 2010-07-08 at 03:39 -0700, Michel Lespinasse wrote:
> > 
> > 
> >         One way to fix this is to have T4 wake from the oom queue and return an
> >         allocation failure instead of insisting on going oom itself when T1
> >         decides to take down the task.
> > 
> > How would you have T4 figure out the deadlock situation ? T1 is taking down T2, not T4... 
> 
> If T2 and T4 share a mmap_sem they belong to the same process. OOM takes
> down the whole process by sending around signals of sorts (SIGKILL?), so
> if T4 gets a fatal signal while it is waiting to enter the oom thingy,
> have it abort and return an allocation failure.
> 
> That alloc failure (along with a pending fatal signal) will very likely
> lead to the release of its mmap_sem (if not, there's more things to
> cure).
> 
> At which point the cycle is broken an stuff continues as it was
> intended.

Now, I've reread current code. I think mmotm already have this.


T4 call out_of_memory and get TIF_MEMDIE
=========================================================
void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
                int order, nodemask_t *nodemask)
{
(snip)
        /*
         * If current has a pending SIGKILL, then automatically select it.  The
         * goal is to allow it to allocate so that it may quickly exit and free
         * its memory.
         */
        if (fatal_signal_pending(current)) {
                set_thread_flag(TIF_MEMDIE);
                boost_dying_task_prio(current, NULL);
                return;
        }
==================================================================


alloc_pages immediately return if the task have TIF_MEMDIE
==================================================================
static inline struct page *
__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
        struct zonelist *zonelist, enum zone_type high_zoneidx,
        nodemask_t *nodemask, struct zone *preferred_zone,
        int migratetype)
{
(snip)
        /* Avoid allocations with no watermarks from looping endlessly */
        if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
                goto nopage;
==========================================================================


Thought?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
