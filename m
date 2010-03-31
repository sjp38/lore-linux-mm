Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 499136B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:05:18 -0400 (EDT)
Date: Tue, 30 Mar 2010 20:03:36 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
Message-Id: <20100330200336.dd0ff9fd.akpm@linux-foundation.org>
In-Reply-To: <n2m28c262361003301953iea82f541u227e7227a23702e@mail.gmail.com>
References: <20100316170808.GA29400@redhat.com>
	<20100330135634.09e6b045.akpm@linux-foundation.org>
	<20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330173721.cbd442cb.akpm@linux-foundation.org>
	<20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330182258.59813fe6.akpm@linux-foundation.org>
	<20100331102755.92a89ca5.kamezawa.hiroyu@jp.fujitsu.com>
	<n2m28c262361003301953iea82f541u227e7227a23702e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010 11:53:00 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> >> I think we should do this too:
> >>
> >> --- a/mm/memory.c~exit-fix-oops-in-sync_mm_rss-fix
> >> +++ a/mm/memory.c
> >> @@ -131,7 +131,6 @@ static void __sync_task_rss_stat(struct
> >>
> >> __ __ __ for (i = 0; i < NR_MM_COUNTERS; i++) {
> >> __ __ __ __ __ __ __ if (task->rss_stat.count[i]) {
> >> - __ __ __ __ __ __ __ __ __ __ BUG_ON(!mm);
> >> __ __ __ __ __ __ __ __ __ __ __ add_mm_counter(mm, i, task->rss_stat.count[i]);
> >> __ __ __ __ __ __ __ __ __ __ __ task->rss_stat.count[i] = 0;
> >> __ __ __ __ __ __ __ }

^^ gargh, gmail.

> >>
> >> Because we just made sure it can't happen, and if it _does_ happen, the
> >> oops will tell us the samme thing that the BUG_ON() would have.
> >>
> >
> > Hmm, then, finaly..
> > ==
> >
> > task->rss_stat wasn't initialized to 0 at copy_process().
> > And __sync_task_rss_stat() should be static.
> > removed BUG_ON(!mm) in __sync_task_rss_stat() for avoiding to show
> > wrong information to code readers. Anyway, if !mm && task->rss_stat
> > has some value, panic will happen.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I think we should keep the

--- a/kernel/exit.c~exit-fix-oops-in-sync_mm_rss
+++ a/kernel/exit.c
@@ -953,7 +953,8 @@ NORET_TYPE void do_exit(long code)
 
 	acct_update_integrals(tsk);
 	/* sync mm's RSS info before statistics gathering */
-	sync_mm_rss(tsk, tsk->mm);
+	if (tsk->mm)
+		sync_mm_rss(tsk, tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);

really.  Apart from the fact that we'll otherwise perform an empty
NR_MM_COUNTERS loop in __sync_task_rss_stat(), sync_mm_rss() just isn't
set up to handle kernel threads.  Given that the function of
sync_task_mm(from, to) is to move stuff from "from" and into "to", it's
daft to call it with a NULL value of `to'!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
