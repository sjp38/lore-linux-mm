Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 790666B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:18:34 -0400 (EDT)
Received: by wiyy7 with SMTP id y7so387642wiy.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 07:18:34 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id ev15si11442331wjd.117.2015.08.28.07.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 07:18:32 -0700 (PDT)
Received: by wieo17 with SMTP id o17so17384205wie.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 07:18:32 -0700 (PDT)
Date: Fri, 28 Aug 2015 16:18:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150828141829.GD5301@dhcp22.suse.cz>
References: <1440613465-30393-1-git-send-email-emunson@akamai.com>
 <1440613465-30393-4-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440613465-30393-4-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed 26-08-15 14:24:22, Eric B Munson wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
> 
> For the example of a large file, this is the usage pattern for a large
> statical language model (probably applies to other statical or graphical
> models as well).  For the security example, any application transacting
> in data that cannot be swapped out (credit card data, medical records,
> etc).
> 
> This patch introduces the ability to request that pages are not
> pre-faulted, but are placed on the unevictable LRU when they are finally
> faulted in.  The VM_LOCKONFAULT flag will be used together with
> VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> be added to the unevictable LRU when they are faulted or if they are
> already present, but will not cause any missing pages to be faulted in.

OK, I can live with this. Thank you for removing the part which exports
the flag to the userspace.
 
> Exposing this new lock state means that we cannot overload the meaning
> of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> to mean that the VMA for a fault was locked.  This means we need the
> new FOLL_MLOCK flag to communicate the locked state of a VMA.
> FOLL_POPULATE will now only control if the VMA should be populated and
> in the case of VM_LOCKONFAULT, it will not be set.

I thinking that this part is really unnecessary. populate_vma_page_range
could have simply returned without calling gup for VM_LOCKONFAULT
vmas. You would save the pte walk and the currently mapped pages would
be still protected from the reclaim. The side effect would be that they
would litter the regular LRUs and mlock/unevictable counters wouldn't be
updated until those pages are encountered during the reclaim and culled
to unevictable list.

I would expect that mlock with this flag would be typically called
on mostly unpopulated mappings so the side effects would be barely
noticeable while the lack of pte walk would be really nice (especially
for the large mappings).

This would be a nice optimization and minor code reduction but I am not
going to insist on it. I will leave the decision to you.

> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-api@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

One note below:

> ---
> Changes from v7:
> *Drop entries in smaps and dri code to avoid exposing VM_LOCKONFAULT to
>  userspace.  VM_LOCKONFAULT is still exposed via mm/debug.c
> *Create VM_LOCKED_CLEAR_MASK to be used anywhere we want to clear all
>  flags relating to locked VMAs
> 
>  include/linux/mm.h |  5 +++++
>  kernel/fork.c      |  2 +-
>  mm/debug.c         |  1 +
>  mm/gup.c           | 10 ++++++++--
>  mm/huge_memory.c   |  2 +-
>  mm/hugetlb.c       |  4 ++--
>  mm/mlock.c         |  2 +-
>  mm/mmap.c          |  2 +-
>  mm/rmap.c          |  6 ++++--
>  9 files changed, 24 insertions(+), 10 deletions(-)
[...]
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 171b687..14ce002 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -744,7 +744,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  
>  		if (vma->vm_flags & VM_LOCKED) {
>  			spin_unlock(ptl);
> -			pra->vm_flags |= VM_LOCKED;
> +			pra->vm_flags |=
> +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
>  			return SWAP_FAIL; /* To break the loop */
>  		}
>  
> @@ -765,7 +766,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  
>  		if (vma->vm_flags & VM_LOCKED) {
>  			pte_unmap_unlock(pte, ptl);
> -			pra->vm_flags |= VM_LOCKED;
> +			pra->vm_flags |=
> +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
>  			return SWAP_FAIL; /* To break the loop */
>  		}

Why do we need to export this? Neither of the consumers care and should
care. VM_LOCKONFAULT should never be set without VM_LOCKED which is the
only thing that we should care about.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
