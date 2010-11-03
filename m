Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48D0B8D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 16:28:54 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oA3KSoYp005610
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 13:28:50 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz1.hot.corp.google.com with ESMTP id oA3KShUW025536
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 13:28:48 -0700
Received: by pwj6 with SMTP id 6so451923pwj.32
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 13:28:43 -0700 (PDT)
Date: Wed, 3 Nov 2010 13:28:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] oom: fix oom_score_adj consistency with
 oom_disable_count
In-Reply-To: <20101103112324.GA29695@redhat.com>
Message-ID: <alpine.DEB.2.00.1011031312400.15465@chino.kir.corp.google.com>
References: <201010262121.o9QLLNFo016375@imap1.linux-foundation.org> <20101101024949.6074.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011738200.26266@chino.kir.corp.google.com> <alpine.DEB.2.00.1011021741520.21871@chino.kir.corp.google.com>
 <20101103112324.GA29695@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010, Oleg Nesterov wrote:

> Hmm. I did a quick grep trying to understand what ->oom_disable_count
> means, and the whole idea behind this counter looks very wrong to me.
> This patch doesn't look right too...
> 
> IOW. I believe that 3d5992d2ac7dc09aed8ab537cba074589f0f0a52
> "oom: add per-mm oom disable count" should be reverted or fixed.
> 
> Trivial example. A process with 2 threads, T1 and T2.
> ->mm->oom_disable_count = 0.
> 
> oom_score_adj_write() sets OOM_SCORE_ADJ_MIN and increments
> oom_disable_count.
> 
> T2 exits, notices OOM_SCORE_ADJ_MIN and decrements ->oom_disable_count
> back to zero.
> 
> Now, T1 runs with OOM_SCORE_ADJ_MIN, but its ->oom_disable_count == 0.
> 
> No?
> 

The intent of Ying's patch was for mm->oom_disable_count to map the number 
of threads sharing the ->mm that have p->signal->oom_score_adj == 
OOM_SCORE_ADJ_MIN.

> > p->mm->oom_disable_count tracks how many threads sharing p->mm have an
> > oom_score_adj value of OOM_SCORE_ADJ_MIN, which disables the oom killer
> > for that task.
> 
> Another reason to move ->oom_score_adj into ->mm ;)
> 

I would _love_ to move oom_score_adj into struct mm_struct, and I fought 
very strongly to do so, but people complained about its inheritance 
property.  They insist that oom_score_adj be able to be changed after 
vfork() and before exec() without changing the oom_score_adj of the 
parent.  The usual usecase is a job scheduler that is set with 
OOM_SCORE_ADJ_MIN that vforks a child, sets the child's oom_score_adj to 
0, and then execs.

> > This patch introduces the necessary locking to ensure oom_score_adj can
> > be tested and/or changed with consistency.
> 
> Oh. We should avoid abusing ->siglock, but OK, we don't have
> anything else right now.
> 
> David, nothing in this patch needs lock_task_sighand(), ->sighand
> can't go away in copy_process/exec_mmap/unshare. You can just do
> spin_lock_irq(->siglock). This is minor, but personally I dislike
> the fact the code looks as if lock_task_sighand() can fail.
> 

Ok, I thought that lock_task_sighand() was some kind of API to do this, 
but I can certainly change this in a subsequent change.  Thanks!

> > @@ -741,6 +741,7 @@ static int exec_mmap(struct mm_struct *mm)
> >  {
> >  	struct task_struct *tsk;
> >  	struct mm_struct * old_mm, *active_mm;
> > +	unsigned long flags;
> >
> >  	/* Notify parent that we're no longer interested in the old VM */
> >  	tsk = current;
> > @@ -766,9 +767,12 @@ static int exec_mmap(struct mm_struct *mm)
> >  	tsk->mm = mm;
> >  	tsk->active_mm = mm;
> >  	activate_mm(active_mm, mm);
> > -	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > -		atomic_dec(&old_mm->oom_disable_count);
> > -		atomic_inc(&tsk->mm->oom_disable_count);
> > +	if (lock_task_sighand(tsk, &flags)) {
> > +		if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +			atomic_dec(&old_mm->oom_disable_count);
> > +			atomic_inc(&tsk->mm->oom_disable_count);
> > +		}
> 
> Not sure this needs additional locking. exec_mmap() is called when
> there are no other threads, we can rely on task_lock() we hold.
> 

There are no other threads that can share tsk->signal at this point?  I 
was mislead by the de_thread() comment about CLONE_SIGHAND.

> >  static int copy_mm(unsigned long clone_flags, struct task_struct * tsk)
> >  {
> >  	struct mm_struct * mm, *oldmm;
> > +	unsigned long flags;
> >  	int retval;
> >
> >  	tsk->min_flt = tsk->maj_flt = 0;
> > @@ -743,8 +744,11 @@ good_mm:
> >  	/* Initializing for Swap token stuff */
> >  	mm->token_priority = 0;
> >  	mm->last_interval = 0;
> > -	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > -		atomic_inc(&mm->oom_disable_count);
> > +	if (lock_task_sighand(tsk, &flags)) {
> > +		if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +			atomic_inc(&mm->oom_disable_count);
> > +		unlock_task_sighand(tsk, &flags);
> > +	}
> 
> This doesn't need ->siglock too. Nobody can see this new child,
> nobody can access its tsk->signal.
> 

Ok!

> > @@ -1700,13 +1707,19 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
> >  		}
> >
> >  		if (new_mm) {
> > +			unsigned long flags;
> > +
> >  			mm = current->mm;
> >  			active_mm = current->active_mm;
> >  			current->mm = new_mm;
> >  			current->active_mm = new_mm;
> > -			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > -				atomic_dec(&mm->oom_disable_count);
> > -				atomic_inc(&new_mm->oom_disable_count);
> > +			if (lock_task_sighand(current, &flags)) {
> > +				if (current->signal->oom_score_adj ==
> > +							OOM_SCORE_ADJ_MIN) {
> > +					atomic_dec(&mm->oom_disable_count);
> > +					atomic_inc(&new_mm->oom_disable_count);
> > +				}
> 
> This is racy anyway, even if we take ->siglock.
> 
> If we need the protection from oom_score_adj_write(), then we have
> to change ->mm under ->siglock as well. Otherwise, suppose that
> oom_score_adj_write() sets OOM_SCORE_ADJ_MIN right after unshare()
> does current->mm = new_mm.
> 

We're protected by task_lock(current) in unshare, it can't do 
current->mm = new_mm while task_lock() is held in oom_score_adj_write().

> However. Please do not touch this code. It doesn't work anyway,
> I'll resend the patch which removes this crap.
> 

Ok, I'll look forward to that :)

Do you see issues with the mapping of threads attached to an mm being 
counted appropriately in mm->oom_disable_count?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
