Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 657416B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 14:42:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id wk8so165494190pab.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:42:44 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 80si13145302pfv.253.2016.09.16.11.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 11:42:43 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id id6so28345950pad.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:42:43 -0700 (PDT)
Date: Fri, 16 Sep 2016 11:42:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] mm: vma_merge: fix race vm_page_prot race condition
 against rmap_walk
In-Reply-To: <1473961304-19370-3-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1609161038340.3672@eggly.anvils>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com> <1473961304-19370-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

On Thu, 15 Sep 2016, Andrea Arcangeli wrote:

> The rmap_walk can access vm_page_prot (and potentially vm_flags in the
> pte/pmd manipulations). So it's not safe to wait the caller to update
> the vm_page_prot/vm_flags after vma_merge returned potentially
> removing the "next" vma and extending the "current" vma over the
> next->vm_start,vm_end range, but still with the "current" vma
> vm_page_prot, after releasing the rmap locks.
> 
> The vm_page_prot/vm_flags must be transferred from the "next" vma to
> the current vma while vma_merge still holds the rmap locks.
> 
> The side effect of this race condition is pte corruption during
> migrate as remove_migration_ptes when run on a address of the "next"
> vma that got removed, used the vm_page_prot of the current vma.
> 
> migrate	     	      	        mprotect
> ------------			-------------
> migrating in "next" vma
> 				vma_merge() # removes "next" vma and
> 			        	    # extends "current" vma
> 					    # current vma is not with
> 					    # vm_page_prot updated
> remove_migration_ptes
> read vm_page_prot of current "vma"
> establish pte with wrong permissions
> 				vm_set_page_prot(vma) # too late!
> 				change_protection in the old vma range
> 				only, next range is not updated
> 
> This caused segmentation faults and potentially memory corruption in
> heavy mprotect loads with some light page migration caused by
> compaction in the background.
> 
> Reported-by: Aditya Mandaleeka <adityam@microsoft.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

This is a great little find, and I certainly approve of the way in
which you're fixing it; but I'm not yet convinced that your actual
patch is correct in all cases.

> ---
>  mm/mmap.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 1abf106..b381978 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -633,9 +633,10 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	bool start_changed = false, end_changed = false;
>  	long adjust_next = 0;
>  	int remove_next = 0;
> +	struct vm_area_struct *importer = NULL;

Okay, fine to use this; but beware that hitherto "importer" was solely
about which vma is growing in size, and so might now be importing some
anon pages, and so may need its anon_vma set if it was not set before.
Which is not necessarily the same issue as where protections need to
be updated.

>  
>  	if (next && !insert) {
> -		struct vm_area_struct *exporter = NULL, *importer = NULL;
> +		struct vm_area_struct *exporter = NULL;
>  
>  		if (end >= next->vm_end) {
>  			/*
> @@ -729,6 +730,17 @@ again:
>  			vma_interval_tree_remove(next, root);
>  	}
>  
> +	if (importer == vma) {
> +		/*
> +		 * vm_page_prot and vm_flags can be read by the
> +		 * rmap_walk, for example in
> +		 * remove_migration_ptes(). Before releasing the rmap
> +		 * locks the current vma must match the next that we
> +		 * merged with for those fields.
> +		 */
> +		importer->vm_page_prot = next->vm_page_prot;
> +		importer->vm_flags = next->vm_flags;
> +	}

To take a concrete example for my doubt, "importer == vma" includes
case 5 (see the diagrams above vma_merge()), but this then copies
protections and flags from N to P ("P" being "vma" here), doesn't it?

Which would not be right, unless I'm confused - which is also very
much possible.

For the moment I'm throwing this back to you without thinking more
carefully about it, and assuming that either you'll come back with
a new patch, or will point out my confusion.  But if you'd prefer
me to take it over, do say so - you have the advantage of youth,
I have the advantage of having written this code a long time ago,
I'm not sure which of us is ahead :)

Is it perhaps just case 8 (see "Odd one out" comment) that's a problem?

But I'm also worried about whether we shall need to try harder in the
"remove_next == 2" case (I think that's case 6 in the diagrams): where
for a moment vma_adjust() drops the locks with overlapping vmas in the
tree, which the "goto again" goes back to clean up.  I don't know if
the interval tree gives any guarantee of which of those overlapping
vmas would be found first in lookup, nor whether it could actually
trigger a problem with page migration.  But I suspect that for safety
we shall need to enforce the same protections on the next->next which
will be removed a moment later.  Ah, no, it must *already* have the
same protections, if it's about to be merged out of existence: so I
think I was making up a problem where there is none, but please check.

Hugh

>  	if (start != vma->vm_start) {
>  		vma->vm_start = start;
>  		start_changed = true;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
