Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1BBD16B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:33:50 -0400 (EDT)
Date: Wed, 3 Jul 2013 16:33:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/13] sched: Check current->mm before allocating NUMA
 faults
Message-ID: <20130703153346.GH1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-12-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1372861300-9973-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:38PM +0100, Mel Gorman wrote:
> @@ -1072,16 +1076,18 @@ void task_numa_work(struct callback_head *work)
>  			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
>  			end = min(end, vma->vm_end);
>  			nr_pte_updates += change_prot_numa(vma, start, end);
> -			pages -= (end - start) >> PAGE_SHIFT;
> -
> -			start = end;
>  
>  			/*
>  			 * Scan sysctl_numa_balancing_scan_size but ensure that
> -			 * least one PTE is updated so that unused virtual
> -			 * address space is quickly skipped
> +			 * at least one PTE is updated so that unused virtual
> +			 * address space is quickly skipped.
>  			 */
> -			if (pages <= 0 && nr_pte_updates)
> +			if (nr_pte_updates)
> +				pages -= (end - start) >> PAGE_SHIFT;
> +
> +			start = end;
> +
> +			if (pages <= 0)
>  				goto out;
>  		} while (end != vma->vm_end);

This hunk is a rebasing error that should have been in the previous
patch. Fixed now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
