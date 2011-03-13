Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8EF8D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 04:53:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D8FE13EE0B6
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:53:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C294245DE4E
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:53:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1FDA45DD73
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:53:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 951B5E08001
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:53:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C58C1DB8038
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 17:53:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] oom: TIF_MEMDIE/PF_EXITING fixes
In-Reply-To: <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
References: <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
Message-Id: <20110313173210.4110.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sun, 13 Mar 2011 17:53:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

> I've spent much of the week building up to join in, but the more I
> look around, the more I find to say or investigate, and therefore
> never quite get to write the mail.  Let this be a placeholder, that I
> probably disagree (in an amicable way!) with all of you, and maybe
> I'll finally manage to collect my thoughts into mail later today.
> 
> I guess my main point will be that TIF_MEMDIE serves a number of
> slightly different, even conflicting, purposes; and one of those
> purposes, which present company seems to ignore repeatedly, is to
> serialize access to final reserves of memory - as a comment by Nick in
> select_bad_process() makes clear. (This is distinct from the
> serialization to avoid OOM-killing rampage.)
>
> We _might_ choose to abandon that, but if so, it should be a decision,
> not an oversight.  So I cannot blindly agree with just setting
> TIF_MEMDIE on more and more tasks, even if they share the same mm.  I
> wonder if use of your find_lock_task_mm() in   select_bad_process()
> might bring together my wish to continue serialization, David's wish
> to avoid stupid panics, and your wish to avoid deadlocks.
> 
> Though any serialization has a risk of deadlock: we probably need to
> weigh up how realistic different cases are.   Which brings me neatly
> to your little pthread_create, ptrace proggy... I dare say you and
> Kosaki and David know exactly what it's doing and why it's a problem,
> but even after repeated skims of the ptrace manpage,  I'll admit to
> not having a clue, nor the inclination to run and then debug it to
> find out the answer.  Please, Oleg, would you mind very much
> explaining it to me? I don't even know if the double pthread_create is
> a vital part of the scheme, or just a typo.  I see it doesn't even
> allocate any special memory, so I assume it leaves a PF_EXITING around
> forever, but I couldn't quite see how (with PF_EXITING being set after
> the tracehook_report_exit).  And I wonder if a similar case can be
> constructed to deadlock the for_each_process version of
> select_bad_process().
> 
> I worry more about someone holding a reference to the mm via /proc (I
> see memory allocations after getting the mm).
> 
> Thanks; until later,
> Hugh

Hi Hugh,

Andrew Vagin showed us actual deadlock case in "[PATCH] mm: check 
zone->all_unreclaimable in all_unreclaimable()" thread. and I'm
now digging it. Unfortunatelly the cause is not single. then, I
couln't explained how exact event was occur and what should we do.

However, I can say, at least, TIF_MEMDIE is one of root cause of the
andrey's deadlock. I could observed TIF_MEMDIE process never die and
all other process continue to wait. then, the system become hang up.

I'm still continue to investigate and I wish I find minimum negative 
impact solution, but I'm not wonder I finally decide to abandon both 
TIF_MEMDIE and boost_dying_task_prio. The hang-up can be reproduced 
too easily.

Unfortunatelly, my country is under slightly rare natural disaster
and I don't think I'm going to concentrate a debug activity awhile.
I'm sorry for the lazy activity.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
