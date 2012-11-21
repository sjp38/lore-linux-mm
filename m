Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A23696B0070
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:25:43 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so5218326eek.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:25:42 -0800 (PST)
Date: Wed, 21 Nov 2012 19:25:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 36/46] mm: numa: Use a two-stage filter to restrict pages
 being migrated for unlikely task<->node relationships
Message-ID: <20121121182537.GB29893@gmail.com>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <1353493312-8069-37-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353493312-8069-37-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> While it is desirable that all threads in a process run on its home
> node, this is not always possible or necessary. There may be more
> threads than exist within the node or the node might over-subscribed
> with unrelated processes.
> 
> This can cause a situation whereby a page gets migrated off its home
> node because the threads clearing pte_numa were running off-node. This
> patch uses page->last_nid to build a two-stage filter before pages get
> migrated to avoid problems with short or unlikely task<->node
> relationships.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/mempolicy.c |   30 +++++++++++++++++++++++++++++-
>  1 file changed, 29 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4c1c8d8..fd20e28 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2317,9 +2317,37 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  	}
>  
>  	/* Migrate the page towards the node whose CPU is referencing it */
> -	if (pol->flags & MPOL_F_MORON)
> +	if (pol->flags & MPOL_F_MORON) {
> +		int last_nid;
> +
>  		polnid = numa_node_id();
>  
> +		/*
> +		 * Multi-stage node selection is used in conjunction
> +		 * with a periodic migration fault to build a temporal
> +		 * task<->page relation. By using a two-stage filter we
> +		 * remove short/unlikely relations.
> +		 *
> +		 * Using P(p) ~ n_p / n_t as per frequentist
> +		 * probability, we can equate a task's usage of a
> +		 * particular page (n_p) per total usage of this
> +		 * page (n_t) (in a given time-span) to a probability.
> +		 *
> +		 * Our periodic faults will sample this probability and
> +		 * getting the same result twice in a row, given these
> +		 * samples are fully independent, is then given by
> +		 * P(n)^2, provided our sample period is sufficiently
> +		 * short compared to the usage pattern.
> +		 *
> +		 * This quadric squishes small probabilities, making
> +		 * it less likely we act on an unlikely task<->page
> +		 * relation.
> +		 */
> +		last_nid = page_xchg_last_nid(page, polnid);
> +		if (last_nid != polnid)
> +			goto out;
> +	}
> +
>  	if (curnid != polnid)
>  		ret = polnid;
>  out:

As mentioned in my other mail, this patch of yours looks very 
similar to the numa/core commit attached below, mostly written 
by Peter:

  30f93abc6cb3 sched, numa, mm: Add the scanning page fault machinery

Thanks,

	Ingo

--------------------->
