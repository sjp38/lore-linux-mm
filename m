Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 03B4D6B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 18:02:44 -0400 (EDT)
Message-ID: <5075F042.2030206@redhat.com>
Date: Wed, 10 Oct 2012 18:01:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 19/33] autonuma: memory follows CPU algorithm and task/mm_autonuma
 stats collection
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <1349308275-2174-20-git-send-email-aarcange@redhat.com>
In-Reply-To: <1349308275-2174-20-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 10/03/2012 07:51 PM, Andrea Arcangeli wrote:

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
> +static inline bool last_nid_set(struct page *page, int this_nid)
> +{

Could be nice to rename this function to should_migrate_page()...

> +	bool ret = true;
> +	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
> +	VM_BUG_ON(this_nid < 0);
> +	VM_BUG_ON(this_nid >= MAX_NUMNODES);
> +	if (autonuma_last_nid != this_nid) {
> +		if (autonuma_last_nid >= 0)
> +			ret = false;
> +		ACCESS_ONCE(page->autonuma_last_nid) = this_nid;
> +	}
> +	return ret;
> +}

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
