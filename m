Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 339EF6B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:15:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V2Fsvq002354
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 11:15:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DA5645DE4F
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:15:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F12A45DE4E
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:15:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EDD57E38003
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:15:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 868331DB8014
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:15:53 +0900 (JST)
Date: Wed, 31 Mar 2010 11:12:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
Message-Id: <20100331111202.a94b233a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <z2t28c262361003301857l77db88dbv7d025b5c5947ad72@mail.gmail.com>
References: <20100316170808.GA29400@redhat.com>
	<20100330135634.09e6b045.akpm@linux-foundation.org>
	<20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330173721.cbd442cb.akpm@linux-foundation.org>
	<20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
	<z2t28c262361003301857l77db88dbv7d025b5c5947ad72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010 10:57:18 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 31, 2010 at 9:41 AM, KAMEZAWA Hiroyuki

> > Doesn't make sense ?
> >
> 
> Nitpick.
> How about moving sync_mm_rss into after check !mm of exit_mm?
> 
Hmm.
==
        sync_mm_rss(tsk, tsk->mm);
        group_dead = atomic_dec_and_test(&tsk->signal->live);
        if (group_dead) {
                hrtimer_cancel(&tsk->signal->real_timer);
                exit_itimers(tsk->signal);
                if (tsk->mm)
                        setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm); ---(**)
        }
        acct_collect(code, group_dead);
        if (group_dead)
                tty_audit_exit();
        if (unlikely(tsk->audit_context))
                audit_free(tsk);

        tsk->exit_code = code;
        taskstats_exit(tsk, group_dead); --------(*)
	
        exit_mm(tsk);
==
task_acct routine has to handle mm information (*).
So, we have to sync somewhere before exit_mm() or tsk->mm goes to NULL.

I think taskstat is an only acct hook which gatheres mm's rss information
but I placed sync_mm_rss() before all accounting routine.
Anyway, sync_mm_rss() should be before (**)
setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm);

Thanks,
-Kame 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
