Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ABCA59000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 07:38:08 -0400 (EDT)
Date: Tue, 26 Apr 2011 21:37:58 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 02/13] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20110426213758.450f6f49@notabene.brown>
In-Reply-To: <1303803414-5937-3-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 08:36:43 +0100 Mel Gorman <mgorman@suse.de> wrote:

> +		/*
> +		 * If there are full empty slabs and we were not forced to
> +		 * allocate a slab, mark this one !pfmemalloc
> +		 */
> +		l3 = cachep->nodelists[numa_mem_id()];
> +		if (!list_empty(&l3->slabs_free) && force_refill) {
> +			struct slab *slabp = virt_to_slab(objp);
> +			slabp->pfmemalloc = false;
> +			clear_obj_pfmemalloc(&objp);
> +			check_ac_pfmemalloc(cachep, ac);
> +			return objp;
> +		}

The comment doesn't match the code.  I think you need to remove the words
"full" and "not" assuming the code is correct which it probably is...

But the code seems to be much more complex than Peter's original, and I don't
see the gain.

Peter's code had only one 'reserved' flag for each kmem_cache.  You seem to
have one for every slab.  I don't see the point.
It is true that yours is in some sense more fair - but I'm not sure the
complexity is worth it.

Was there some particular reason you made the change?

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
