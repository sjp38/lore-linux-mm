Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C846C6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 11:39:41 -0400 (EDT)
Date: Thu, 1 Apr 2010 17:37:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -mm] proc: don't take ->siglock for /proc/pid/oom_adj
Message-ID: <20100401153756.GD14603@redhat.com>
References: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <20100330174337.GA21663@redhat.com> <alpine.DEB.2.00.1003301329420.5234@chino.kir.corp.google.com> <20100331185950.GB11635@redhat.com> <alpine.DEB.2.00.1003311408520.31252@chino.kir.corp.google.com> <20100331230032.GB4025@redhat.com> <alpine.DEB.2.00.1004010128050.6285@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004010128050.6285@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> On Thu, 1 Apr 2010, Oleg Nesterov wrote:
>
> > > That doesn't work for depraceted_mode (sic), you'd need to test for
> > > OOM_ADJUST_MIN and OOM_ADJUST_MAX in that case.
> >
> > Yes, probably "if (depraceted_mode)" should do more checks, I didn't try
> > to verify that MIN/MAX are correctly converted. I showed this code to explain
> > what I mean.
> >
>
> Ok, please cc me on the patch, it will be good to get rid of the duplicate 
> code and remove oom_adj from struct signal_struct.

OK, great, will do tomorrow.

> Do we need ->siglock?  Why can't we just do
>
> 	struct sighand_struct *sighand;
> 	struct signal_struct *sig;
>
> 	rcu_read_lock();
> 	sighand = rcu_dereference(task->sighand);
> 	if (!sighand) {
> 		rcu_read_unlock();
> 		return;
> 	}
> 	sig = task->signal;
>
> 	... load/store to sig ...
>
> 	rcu_read_unlock();

No.

Before signals-make-task_struct-signal-immutable-refcountable.patch (actually,
series of patches), this can't work. ->signal is not protected by rcu, and
->sighand != NULL doesn't mean ->signal != NULL.

(yes, thread_group_cputime() is wrong too, but currently it is never called
 lockless).

After signals-make-task_struct-signal-immutable-refcountable.patch, we do not
need any checks at all, it is always safe to use ->signal.


But. Unless we kill signal->oom_adj, we have another reason for ->siglock,
we can't update both oom_adj and oom_score_adj atomically, and if we race
with another thread they can be inconsistent wrt each other. Yes, oom_adj
is not actually used, except we report it back to user-space, but still.

So, I am going to send 2 patches. The first one factors out the code
in base.c and kills signal->oom_adj, the next one removes ->siglock.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
