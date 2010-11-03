Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5E4936B00A4
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 07:29:27 -0400 (EDT)
Date: Wed, 3 Nov 2010 12:23:24 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch v2] oom: fix oom_score_adj consistency with
	oom_disable_count
Message-ID: <20101103112324.GA29695@redhat.com>
References: <201010262121.o9QLLNFo016375@imap1.linux-foundation.org> <20101101024949.6074.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011738200.26266@chino.kir.corp.google.com> <alpine.DEB.2.00.1011021741520.21871@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011021741520.21871@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm. I did a quick grep trying to understand what ->oom_disable_count
means, and the whole idea behind this counter looks very wrong to me.
This patch doesn't look right too...

IOW. I believe that 3d5992d2ac7dc09aed8ab537cba074589f0f0a52
"oom: add per-mm oom disable count" should be reverted or fixed.

Trivial example. A process with 2 threads, T1 and T2.
->mm->oom_disable_count = 0.

oom_score_adj_write() sets OOM_SCORE_ADJ_MIN and increments
oom_disable_count.

T2 exits, notices OOM_SCORE_ADJ_MIN and decrements ->oom_disable_count
back to zero.

Now, T1 runs with OOM_SCORE_ADJ_MIN, but its ->oom_disable_count == 0.

No?


On 11/02, David Rientjes wrote:
>
> p->mm->oom_disable_count tracks how many threads sharing p->mm have an
> oom_score_adj value of OOM_SCORE_ADJ_MIN, which disables the oom killer
> for that task.

Another reason to move ->oom_score_adj into ->mm ;)

> This patch introduces the necessary locking to ensure oom_score_adj can
> be tested and/or changed with consistency.

Oh. We should avoid abusing ->siglock, but OK, we don't have
anything else right now.

David, nothing in this patch needs lock_task_sighand(), ->sighand
can't go away in copy_process/exec_mmap/unshare. You can just do
spin_lock_irq(->siglock). This is minor, but personally I dislike
the fact the code looks as if lock_task_sighand() can fail.

> @@ -741,6 +741,7 @@ static int exec_mmap(struct mm_struct *mm)
>  {
>  	struct task_struct *tsk;
>  	struct mm_struct * old_mm, *active_mm;
> +	unsigned long flags;
>
>  	/* Notify parent that we're no longer interested in the old VM */
>  	tsk = current;
> @@ -766,9 +767,12 @@ static int exec_mmap(struct mm_struct *mm)
>  	tsk->mm = mm;
>  	tsk->active_mm = mm;
>  	activate_mm(active_mm, mm);
> -	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> -		atomic_dec(&old_mm->oom_disable_count);
> -		atomic_inc(&tsk->mm->oom_disable_count);
> +	if (lock_task_sighand(tsk, &flags)) {
> +		if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +			atomic_dec(&old_mm->oom_disable_count);
> +			atomic_inc(&tsk->mm->oom_disable_count);
> +		}

Not sure this needs additional locking. exec_mmap() is called when
there are no other threads, we can rely on task_lock() we hold.

>  static int copy_mm(unsigned long clone_flags, struct task_struct * tsk)
>  {
>  	struct mm_struct * mm, *oldmm;
> +	unsigned long flags;
>  	int retval;
>
>  	tsk->min_flt = tsk->maj_flt = 0;
> @@ -743,8 +744,11 @@ good_mm:
>  	/* Initializing for Swap token stuff */
>  	mm->token_priority = 0;
>  	mm->last_interval = 0;
> -	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> -		atomic_inc(&mm->oom_disable_count);
> +	if (lock_task_sighand(tsk, &flags)) {
> +		if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +			atomic_inc(&mm->oom_disable_count);
> +		unlock_task_sighand(tsk, &flags);
> +	}

This doesn't need ->siglock too. Nobody can see this new child,
nobody can access its tsk->signal.

> @@ -1700,13 +1707,19 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
>  		}
>
>  		if (new_mm) {
> +			unsigned long flags;
> +
>  			mm = current->mm;
>  			active_mm = current->active_mm;
>  			current->mm = new_mm;
>  			current->active_mm = new_mm;
> -			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> -				atomic_dec(&mm->oom_disable_count);
> -				atomic_inc(&new_mm->oom_disable_count);
> +			if (lock_task_sighand(current, &flags)) {
> +				if (current->signal->oom_score_adj ==
> +							OOM_SCORE_ADJ_MIN) {
> +					atomic_dec(&mm->oom_disable_count);
> +					atomic_inc(&new_mm->oom_disable_count);
> +				}

This is racy anyway, even if we take ->siglock.

If we need the protection from oom_score_adj_write(), then we have
to change ->mm under ->siglock as well. Otherwise, suppose that
oom_score_adj_write() sets OOM_SCORE_ADJ_MIN right after unshare()
does current->mm = new_mm.

However. Please do not touch this code. It doesn't work anyway,
I'll resend the patch which removes this crap.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
