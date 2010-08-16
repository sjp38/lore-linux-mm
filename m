Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D8D56B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 01:54:53 -0400 (EDT)
Date: Mon, 16 Aug 2010 07:52:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 1/2] oom: avoid killing a task if a thread sharing its
	mm cannot be killed
Message-ID: <20100816055204.GA9498@redhat.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <20100815151819.GA3531@redhat.com> <alpine.DEB.2.00.1008151409020.8727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008151409020.8727@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/15, David Rientjes wrote:
>
> On Sun, 15 Aug 2010, Oleg Nesterov wrote:
>
> > Well. I shouldn't try to comment this patch because I do not know
> > the state of the current code (and I do not understand the changelog).
> > Still, it looks a bit strange to me.
> >
>
> You snipped the changelog, so it's unclear what you don't understand about
> it.  The goal is to detect if a task A shares its mm with any other thread
> that cannot be oom killed; if so, we can't free task A's memory when it
> exits.  It's then pointless to kill task A in the first place since it
> will not solve the oom issue.

Yes, this part is clear.

> > > +static bool is_mm_unfreeable(struct mm_struct *mm)
> > > +{
> > > +	struct task_struct *g, *q;
> > > +
> > > +	do_each_thread(g, q) {
> > > +		if (q->mm == mm && !(q->flags & PF_KTHREAD) &&
> > > +		    q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > > +			return true;
> > > +	} while_each_thread(g, q);
> >
> > do_each_thread() doesn't look good. All sub-threads have the same ->mm.
> >
>
> There's no other way to detect threads in other thread groups that share
> the same mm since subthreads of a process can have an oom_score_adj that
> differ from that process, this includes the possibility of
> OOM_SCORE_ADJ_MIN that we're interested in here.

Yes, you are right. Still, at least you can do

	for_each_process(p) {
		if (p->mm != mm)
			continue;
		...

to quickly skip the thread group which doesn't share the same ->mm.

> > > -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > +	if (is_mm_unfreeable(p->mm)) {
> >
> > oom_badness() becomes O(n**2), not good.
> >
>
> No, oom_badness() becomes O(n) from O(1); select_bad_process() becomes
> slower for eligible tasks.

I meant, select_bad_process() becomes O(n^2). oom_badness() is O(n), yes.

> It would be possible to defer this check to oom_kill_process() if
> additional logic were added to its callers to retry if it fails:
>
> [...snip...]
>
> What do you think?

Sorry David, I think nothing ;) Please ignore me, I have no time at all.

> > And, more importantly. This patch makes me think ->oom_score_adj should
> > be moved from ->signal to ->mm.
> >
>
> I did that several months ago but people were unhappy with how a parent's
> oom_score_adj value would change if it did a vfork() and the child's
> oom_score_adj value was changed prior to execve().

I see. But this patch in essence moves OOM_SCORE_ADJ_MIN from ->signal
to ->mm (and btw personally I think this makes sense).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
