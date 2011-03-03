Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EEAC88D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 04:18:37 -0500 (EST)
Date: Thu, 3 Mar 2011 10:18:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110303091827.GC2245@cmpxchg.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
 <1299113128-11349-9-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299113128-11349-9-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed, Mar 02, 2011 at 04:45:28PM -0800, Andi Kleen wrote:
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -58,6 +58,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
>  		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
>  		UNEVICTABLE_MLOCKFREED,
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	        THP_FAULT_ALLOC,
> +		THP_COLLAPSE_ALLOC,	
> +		THP_FAULT_FALLBACK,	

Wouldn't this better be named THP_FAULT_ALLOC_FAIL?  After all, it
counts allocation failures, not what results from them.

Secondly, the order does not match the strings, it will report the
THP_COLLAPSE_ALLOC item as "thp_fault_fallback" and vice versa.

There are also odd spaces after the lines defining THP_COLLAPSE_ALLOC
and this one.

> +		THP_COLLAPSE_ALLOC_FAILED,
> +		THP_SPLIT,
> +#endif
>  		NR_VM_EVENT_ITEMS
>  };

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 2b461ed..a23f2d2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -946,6 +946,14 @@ static const char * const vmstat_text[] = {
>  	"unevictable_pgs_stranded",
>  	"unevictable_pgs_mlockfreed",
>  #endif
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	"thp_fault_alloc",
> +	"thp_fault_fallback",
> +	"thp_collapse_alloc",
> +	"thp_collapse_alloc_failure",

Can you make this "_failed" instead, to match the enum symbol?  Andrea
wasn't sure which was better, "failure" or "failed".  Right now, we
have two instances of "fail" and two instances of "failed" in
/proc/vmstat, it's probably best not to introduce a third one.

Thanks.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
