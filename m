Received: from bbf2.mcguire.af.mil (root@localhost)
	by bbf2.mcguire.af.mil with ESMTP id RAA11622
	for <linux-mm@kvack.org>; Mon, 17 Apr 2000 17:46:56 -0400 (EDT)
Received: from CLPTFLW1.mcguire.af.mil ([132.18.178.12])
	by bbf2.mcguire.af.mil with ESMTP id RAA11618
	for <linux-mm@kvack.org>; Mon, 17 Apr 2000 17:46:55 -0400 (EDT)
Message-ID: <3B51127C9576D3119B8300805FA70A8502536B34@clptflw4.mcguire.af.mil>
From: "Espiritu, Civ Kenneth" <EspiritK@mcguire.af.mil>
Subject: Fix to swap_out()
Date: Mon, 17 Apr 2000 17:51:25 -0400
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm taking a little break from Redcode (Corewar) programming and 
decided to look a little at Linux's internals.

>From a BSD guru:
     * To locate pages to swap out, it takes a pass through the task list.
       Ostensibly it locates the task with the largest RSS to then try to
       swap pages out from rather then select pages that are not in use.
       From my read of the code, it also botches this badly.

I also looked at the code and it didn't look too nice. The offending
line is 365, where we pick the largest Resident Size Set (RSS) to swap
first.

A fix would be to pick tasks to page which don't page fault alot by
calculating a page fault rate over the task's lifespan. If the system
inadvertently pages something that it shouldn't there is feedback
from p->maj_flt which will make the task less likely to be swapped
out in future swap attempts.

An optimization to the fix would be to remove the +1 in the denominator
 if p->maj_flt was initialized to 1 when the task is first created (I think
in
/kernel/fork.c).

What are your thoughts on this fix?

Ken Espiritu

from /mm/vmscan.c (2.3.99-pre5)

363                         /* Refresh swap_cnt? */
364                         if (assign == 1)
365                                 mm->swap_cnt = mm->rss;
366                         if (mm->swap_cnt > max_cnt) {
367                                 max_cnt = mm->swap_cnt;
368                                 best = mm;
369                                 pid = p->pid;
370                         }

Fix:
365                                 mm->swap_cnt =
(jiffies-p->start_time)/(p->maj_flt+1);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
