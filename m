Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A55476B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 16:19:05 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 19/36] autonuma: memory follows CPU algorithm and task/mm_autonuma stats collection
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
	<1345647560-30387-20-git-send-email-aarcange@redhat.com>
Date: Wed, 22 Aug 2012 13:19:04 -0700
In-Reply-To: <1345647560-30387-20-git-send-email-aarcange@redhat.com> (Andrea
	Arcangeli's message of "Wed, 22 Aug 2012 16:59:03 +0200")
Message-ID: <m2sjbe7k93.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Andrea Arcangeli <aarcange@redhat.com> writes:

> +/*
> + * In this function we build a temporal CPU_node<->page relation by
> + * using a two-stage autonuma_last_nid filter to remove short/unlikely
> + * relations.
> + *
> + * Using P(p) ~ n_p / n_t as per frequentest probability, we can
> + * equate a node's CPU usage of a particular page (n_p) per total
> + * usage of this page (n_t) (in a given time-span) to a probability.
> + *
> + * Our periodic faults will then sample this probability and getting
> + * the same result twice in a row, given these samples are fully
> + * independent, is then given by P(n)^2, provided our sample period
> + * is sufficiently short compared to the usage pattern.
> + *
> + * This quadric squishes small probabilities, making it less likely
> + * we act on an unlikely CPU_node<->page relation.
> + */

The code does not seem to do what the comment describes.

> +static inline bool last_nid_set(struct page *page, int this_nid)
> +{
> +	bool ret = true;
> +	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
> +	VM_BUG_ON(this_nid < 0);
> +	VM_BUG_ON(this_nid >= MAX_NUMNODES);
> +	if (autonuma_last_nid >= 0 && autonuma_last_nid != this_nid) {
> +		int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
> +		if (migrate_nid >= 0)
> +			__autonuma_migrate_page_remove(page);
> +		ret = false;
> +	}
> +	if (autonuma_last_nid != this_nid)
> +		ACCESS_ONCE(page->autonuma_last_nid) = this_nid;
> +	return ret;
> +}
> +
> +		/*
> +		 * Take the lock with irqs disabled to avoid a lock
> +		 * inversion with the lru_lock. The lru_lock is taken
> +		 * before the autonuma_migrate_lock in
> +		 * split_huge_page. If we didn't disable irqs, the
> +		 * lru_lock could be taken by interrupts after we have
> +		 * obtained the autonuma_migrate_lock here.
> +		 */

Which interrupt code takes the lru_lock? That sounds like a bug.


-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
