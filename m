Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAEB26B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 12:37:30 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id w194so40707947vkw.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 09:37:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i3si13938615vkf.23.2016.11.01.09.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 09:37:28 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/hugetlb: fix huge page reservation leak in private
 mapping error paths
References: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com>
 <1476933077-23091-2-git-send-email-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b9fbc257-bd3b-80e3-ac34-56fe7f325ef0@oracle.com>
Date: Tue, 1 Nov 2016 09:37:14 -0700
MIME-Version: 1.0
In-Reply-To: <1476933077-23091-2-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Stancek <jstancek@redhat.com>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 10/19/2016 08:11 PM, Mike Kravetz wrote:
> Error paths in hugetlb_cow() and hugetlb_no_page() may free a newly
> allocated huge page.  If a reservation was associated with the huge
> page, alloc_huge_page() consumed the reservation while allocating.
> When the newly allocated page is freed in free_huge_page(), it will
> increment the global reservation count.  However, the reservation entry
> in the reserve map will remain.  This is not an issue for shared
> mappings as the entry in the reserve map indicates a reservation exists.
> But, an entry in a private mapping reserve map indicates the reservation
> was consumed and no longer exists.  This results in an inconsistency
> between the reserve map and the global reservation count.  This 'leaks'
> a reserved huge page.
> 
> Create a new routine restore_reserve_on_error() to restore the reserve
> entry in these specific error paths.  This routine makes use of a new
> function vma_add_reservation() which will add a reserve entry for a
> specific address/page.
> 
> In general, these error paths were rarely (if ever) taken on most
> architectures.  However, powerpc contained arch specific code that
> that resulted in an extra fault and execution of these error paths
> on all private mappings.
> 
> Fixes: 67961f9db8c4 ("mm/hugetlb: fix huge page reserve accounting for private mappings)
> 

Any additional comments on this?

It does address a regression with private mappings that appears to only be
visible on powerpc.  Aneesh submitted a patch to workaround the issue on
powerpc that is in mmotm/linux-next (71271479df7e/955f9aa468e0).  Aneesh's
patch makes the symptoms go away.  This patch addresses root cause.

Adding Andrew to Cc as I accidentally left him off originally, and he
may have
sparked additional comments.

-- 
Mike Kravetz

> Cc: stable@vger.kernel.org
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 66 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec49d9e..418bf01 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1826,11 +1826,17 @@ static void return_unused_surplus_pages(struct hstate *h,
>   * is not the case is if a reserve map was changed between calls.  It
>   * is the responsibility of the caller to notice the difference and
>   * take appropriate action.
> + *
> + * vma_add_reservation is used in error paths where a reservation must
> + * be restored when a newly allocated huge page must be freed.  It is
> + * to be called after calling vma_needs_reservation to determine if a
> + * reservation exists.
>   */
>  enum vma_resv_mode {
>  	VMA_NEEDS_RESV,
>  	VMA_COMMIT_RESV,
>  	VMA_END_RESV,
> +	VMA_ADD_RESV,
>  };
>  static long __vma_reservation_common(struct hstate *h,
>  				struct vm_area_struct *vma, unsigned long addr,
> @@ -1856,6 +1862,14 @@ static long __vma_reservation_common(struct hstate *h,
>  		region_abort(resv, idx, idx + 1);
>  		ret = 0;
>  		break;
> +	case VMA_ADD_RESV:
> +		if (vma->vm_flags & VM_MAYSHARE)
> +			ret = region_add(resv, idx, idx + 1);
> +		else {
> +			region_abort(resv, idx, idx + 1);
> +			ret = region_del(resv, idx, idx + 1);
> +		}
> +		break;
>  	default:
>  		BUG();
>  	}
> @@ -1903,6 +1917,56 @@ static void vma_end_reservation(struct hstate *h,
>  	(void)__vma_reservation_common(h, vma, addr, VMA_END_RESV);
>  }
>  
> +static long vma_add_reservation(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long addr)
> +{
> +	return __vma_reservation_common(h, vma, addr, VMA_ADD_RESV);
> +}
> +
> +/*
> + * This routine is called to restore a reservation on error paths.  In the
> + * specific error paths, a huge page was allocated (via alloc_huge_page)
> + * and is about to be freed.  If a reservation for the page existed,
> + * alloc_huge_page would have consumed the reservation and set PagePrivate
> + * in the newly allocated page.  When the page is freed via free_huge_page,
> + * the global reservation count will be incremented if PagePrivate is set.
> + * However, free_huge_page can not adjust the reserve map.  Adjust the
> + * reserve map here to be consistent with global reserve count adjustments
> + * to be made by free_huge_page.
> + */
> +static void restore_reserve_on_error(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long address,
> +			struct page *page)
> +{
> +	if (unlikely(PagePrivate(page))) {
> +		long rc = vma_needs_reservation(h, vma, address);
> +
> +		if (unlikely(rc < 0)) {
> +			/*
> +			 * Rare out of memory condition in reserve map
> +			 * manipulation.  Clear PagePrivate so that
> +			 * global reserve count will not be incremented
> +			 * by free_huge_page.  This will make it appear
> +			 * as though the reservation for this page was
> +			 * consumed.  This may prevent the task from
> +			 * faulting in the page at a later time.  This
> +			 * is better than inconsistent global huge page
> +			 * accounting of reserve counts.
> +			 */
> +			ClearPagePrivate(page);
> +		} else if (rc) {
> +			rc = vma_add_reservation(h, vma, address);
> +			if (unlikely(rc < 0))
> +				/*
> +				 * See above comment about rare out of
> +				 * memory condition.
> +				 */
> +				ClearPagePrivate(page);
> +		} else
> +			vma_end_reservation(h, vma, address);
> +	}
> +}
> +
>  struct page *alloc_huge_page(struct vm_area_struct *vma,
>  				    unsigned long addr, int avoid_reserve)
>  {
> @@ -3498,6 +3562,7 @@ retry_avoidcopy:
>  	spin_unlock(ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  out_release_all:
> +	restore_reserve_on_error(h, vma, address, new_page);
>  	put_page(new_page);
>  out_release_old:
>  	put_page(old_page);
> @@ -3680,6 +3745,7 @@ backout:
>  	spin_unlock(ptl);
>  backout_unlocked:
>  	unlock_page(page);
> +	restore_reserve_on_error(h, vma, address, page);
>  	put_page(page);
>  	goto out;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
