Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C1B426B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:16:55 -0500 (EST)
Date: Thu, 18 Nov 2010 16:16:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 51 of 66] set recommended min free kbytes
Message-ID: <20101118161623.GB8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <e4c3f336872db7bfbf58.1288798106@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e4c3f336872db7bfbf58.1288798106@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:26PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If transparent hugepage is enabled initialize min_free_kbytes to an optimal
> value by default. This moves the hugeadm algorithm in kernel.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -85,6 +85,47 @@ struct khugepaged_scan {
>  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
>  };
>  
> +
> +static int set_recommended_min_free_kbytes(void)
> +{
> +	struct zone *zone;
> +	int nr_zones = 0;
> +	unsigned long recommended_min;
> +	extern int min_free_kbytes;
> +
> +	if (!test_bit(TRANSPARENT_HUGEPAGE_FLAG,
> +		      &transparent_hugepage_flags) &&
> +	    !test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +		      &transparent_hugepage_flags))
> +		return 0;
> +
> +	for_each_populated_zone(zone)
> +		nr_zones++;
> +
> +	/* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
> +	recommended_min = HPAGE_PMD_NR * nr_zones * 2;
> +

The really important value is pageblock_nr_pages here. It'll just happen
to work on x86 and x86-64 but anti-fragmentation is really about
pageblocks, not PMDs.

> +	/*
> +	 * Make sure that on average at least two pageblocks are almost free
> +	 * of another type, one for a migratetype to fall back to and a
> +	 * second to avoid subsequent fallbacks of other types There are 3
> +	 * MIGRATE_TYPES we care about.
> +	 */
> +	recommended_min += HPAGE_PMD_NR * nr_zones * 3 * 3;
> +

Same on the use of pageblock_nr_pages. Also, you can replace 3 with
MIGRATE_PCPTYPES.

> +	/* don't ever allow to reserve more than 5% of the lowmem */
> +	recommended_min = min(recommended_min,
> +			      (unsigned long) nr_free_buffer_pages() / 20);
> +	recommended_min <<= (PAGE_SHIFT-10);
> +
> +	if (recommended_min > min_free_kbytes) {
> +		min_free_kbytes = recommended_min;
> +		setup_per_zone_wmarks();
> +	}


The timing this is called is important. Would you mind doing a quick
debugging check by adding a printk to setup_zone_migrate_reserve() to ensure
MIGRATE_RESERVE is getting set on sensible pageblocks? (see where the comment
Suitable for reserving if this block is movable is) If MIGRATE_RESERVE blocks
are not being created in a sensible fashion, atomic high-order allocations
will suffer in mysterious ways.

SEtting the higher min free kbytes from userspace happens to work because
the system is initialised and MIGRATE_MOVABLE exists but that might not be
the case when automatically set like this patch.

> +	return 0;
> +}
> +late_initcall(set_recommended_min_free_kbytes);
> +
>  static int start_khugepaged(void)
>  {
>  	int err = 0;
> @@ -108,6 +149,8 @@ static int start_khugepaged(void)
>  		mutex_unlock(&khugepaged_mutex);
>  		if (wakeup)
>  			wake_up_interruptible(&khugepaged_wait);
> +
> +		set_recommended_min_free_kbytes();
>  	} else
>  		/* wakeup to exit */
>  		wake_up_interruptible(&khugepaged_wait);
> @@ -177,6 +220,13 @@ static ssize_t enabled_store(struct kobj
>  			ret = err;
>  	}
>  
> +	if (ret > 0 &&
> +	    (test_bit(TRANSPARENT_HUGEPAGE_FLAG,
> +		      &transparent_hugepage_flags) ||
> +	     test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +		      &transparent_hugepage_flags)))
> +		set_recommended_min_free_kbytes();
> +
>  	return ret;
>  }
>  static struct kobj_attribute enabled_attr =
> @@ -464,6 +514,8 @@ static int __init hugepage_init(void)
>  
>  	start_khugepaged();
>  
> +	set_recommended_min_free_kbytes();
> +
>  out:
>  	return err;
>  }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
