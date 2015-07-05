Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6719E280291
	for <linux-mm@kvack.org>; Sun,  5 Jul 2015 11:15:25 -0400 (EDT)
Received: by wiga1 with SMTP id a1so209809122wig.0
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 08:15:24 -0700 (PDT)
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id bb4si26090826wib.124.2015.07.05.08.15.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jul 2015 08:15:23 -0700 (PDT)
Received: by wgjx7 with SMTP id x7so120922232wgj.2
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 08:15:22 -0700 (PDT)
Message-ID: <55994A08.3030308@plexistor.com>
Date: Sun, 05 Jul 2015 18:15:20 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: avoid setting up anonymous pages into file mapping
References: <1435932447-84377-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435932447-84377-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 07/03/2015 05:07 PM, Kirill A. Shutemov wrote:
> Reading page fault handler code I've noticed that under right
> circumstances kernel would map anonymous pages into file mappings:
> if the VMA doesn't have vm_ops->fault() and the VMA wasn't fully
> populated on ->mmap(), kernel would handle page fault to not populated
> pte with do_anonymous_page().
> 
> There's chance that it was done intentionally, but I don't see good
> justification for this. We just hide bugs in broken drivers.
> 

Have you done a preliminary audit for these broken drivers? If they actually
exist in-tree then this patch is a regression for them.

We need to look for vm_ops without an .fault = . Perhaps define a
map_annonimous() for those to revert to the old behavior, if any
actually exist.

> Let's change page fault handler to use do_anonymous_page() only on
> anonymous VMA (->vm_ops == NULL).
> 
> For file mappings without vm_ops->fault() page fault on pte_none() entry
> would lead to SIGBUS.
> 

Again that could mean a theoretical regression for some in-tree driver,
do you know of any such driver?

Thanks
Boaz

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/memory.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 8a2fc9945b46..f3ee782059e3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3115,6 +3115,9 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
>  
>  	pte_unmap(page_table);
> +
> +	if (unlikely(!vma->vm_ops->fault))
> +		return VM_FAULT_SIGBUS;
>  	if (!(flags & FAULT_FLAG_WRITE))
>  		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
>  				orig_pte);
> @@ -3260,13 +3263,13 @@ static int handle_pte_fault(struct mm_struct *mm,
>  	barrier();
>  	if (!pte_present(entry)) {
>  		if (pte_none(entry)) {
> -			if (vma->vm_ops) {
> -				if (likely(vma->vm_ops->fault))
> -					return do_fault(mm, vma, address, pte,
> -							pmd, flags, entry);
> +			if (!vma->vm_ops) {
> +				return do_anonymous_page(mm, vma, address, pte,
> +						pmd, flags);
> +			} else {
> +				return do_fault(mm, vma, address, pte, pmd,
> +						flags, entry);
>  			}
> -			return do_anonymous_page(mm, vma, address,
> -						 pte, pmd, flags);
>  		}
>  		return do_swap_page(mm, vma, address,
>  					pte, pmd, flags, entry);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
