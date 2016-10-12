Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0E4F6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:49:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b201so3186385wmb.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:49:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si981408wmg.126.2016.10.11.22.49.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 22:49:37 -0700 (PDT)
Date: Wed, 12 Oct 2016 06:49:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Don't touch single threaded PTEs which are on the right
 node
Message-ID: <20161012054933.GB20573@suse.de>
References: <1476217738-10451-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1476217738-10451-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: peterz@infradead.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Tue, Oct 11, 2016 at 01:28:58PM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> We had some problems with pages getting unmapped in single threaded
> affinitized processes. It was tracked down to NUMA scanning.
> 
> In this case it doesn't make any sense to unmap pages if the
> process is single threaded and the page is already on the
> node the process is running on.
> 
> Add a check for this case into the numa protection code,
> and skip unmapping if true.
> 
> In theory the process could be migrated later, but we
> will eventually rescan and unmap and migrate then.
> 
> In theory this could be made more fancy: remembering this
> state per process or even whole mm. However that would
> need extra tracking and be more complicated, and the
> simple check seems to work fine so far.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/mprotect.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a4830f0325fe..e8028658e817 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -94,6 +94,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				/* Avoid TLB flush if possible */
>  				if (pte_protnone(oldpte))
>  					continue;
> +
> +				/*
> +				 * Don't mess with PTEs if page is already on the node
> +				 * a single-threaded process is running on.
> +				 */
> +				if (atomic_read(&vma->vm_mm->mm_users) == 1 &&
> +				    cpu_to_node(raw_smp_processor_id()) == page_to_nid(page))
> +					continue;
>  			}

You shouldn't need to check the number of mm_users and the node the task
is running on for every PTE being scanned.

A more important corner case is if the VMA is shared with a task running on
another node. By avoiding the NUMA hinting faults here, the hinting faults
trapped by the remote process will appear exclusive and allow migration of
the page. This will happen even if the single-threade task is continually
using the pages.

When you said "we had some problems", you didn't describe the workload or
what the problems were (I'm assuming latency/jitter). Would restricting
this check to private VMAs be sufficient?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
