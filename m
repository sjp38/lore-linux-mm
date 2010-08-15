Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F2BEE6B01F5
	for <linux-mm@kvack.org>; Sun, 15 Aug 2010 11:21:06 -0400 (EDT)
Date: Sun, 15 Aug 2010 17:18:19 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 1/2] oom: avoid killing a task if a thread sharing its
	mm cannot be killed
Message-ID: <20100815151819.GA3531@redhat.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Well. I shouldn't try to comment this patch because I do not know
the state of the current code (and I do not understand the changelog).
Still, it looks a bit strange to me.

On 08/14, David Rientjes wrote:
>
> + * Determines whether an mm is unfreeable since a user thread attached to
> + * it cannot be killed.  Kthreads only temporarily assume a thread's mm,
> + * so they are not considered.
> + *
> + * mm need not be protected by task_lock() since it will not be
> + * dereferened.
> + */
> +static bool is_mm_unfreeable(struct mm_struct *mm)
> +{
> +	struct task_struct *g, *q;
> +
> +	do_each_thread(g, q) {
> +		if (q->mm == mm && !(q->flags & PF_KTHREAD) &&
> +		    q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +			return true;
> +	} while_each_thread(g, q);

do_each_thread() doesn't look good. All sub-threads have the same ->mm.

	for_each_process(p) {
		if (p->flags && PF_KTHREAD)
			continue;
		do {
			if (!t->mm)
				continue;
			if (t->mm != mm)
				break;
			if (t->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
				return true;
		} while_each_thread(p, t);
	}

	return false;

However, even if is_mm_unfreeable() uses for_each_process(),

> @@ -160,12 +181,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 0;
> -
> -	/*
> -	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
> -	 * need to be executed for something that cannot be killed.
> -	 */
> -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +	if (is_mm_unfreeable(p->mm)) {

oom_badness() becomes O(n**2), not good.

And, more importantly. This patch makes me think ->oom_score_adj should
be moved from ->signal to ->mm.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
