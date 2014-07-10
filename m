Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 731F26B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 18:22:29 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so215847wes.8
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 15:22:25 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [85.214.48.195])
        by mx.google.com with ESMTP id kp1si712228wjb.61.2014.07.10.15.22.13
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 15:22:13 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id C0B2312B282
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 00:22:02 +0200 (CEST)
Date: Fri, 11 Jul 2014 00:22:00 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 28/83] mm: Change timing of notification to IOMMUs about
 a page to be invalidated
Message-ID: <20140710222200.GZ1958@8bytes.org>
References: <1405029208-6703-1-git-send-email-oded.gabbay@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405029208-6703-1-git-send-email-oded.gabbay@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Airlie <airlied@linux.ie>, Alex Deucher <alexander.deucher@amd.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, John Bridgman <John.Bridgman@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, linux-mm <linux-mm@kvack.org>, Oded Gabbay <oded.gabbay@amd.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@openvz.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jianyu Zhan <nasa4836@gmail.com>

On Fri, Jul 11, 2014 at 12:53:26AM +0300, Oded Gabbay wrote:
>  mm/rmap.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 196cd0c..73d4c3d 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1231,13 +1231,17 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	} else
>  		dec_mm_counter(mm, MM_FILEPAGES);
>  
> +	pte_unmap_unlock(pte, ptl);
> +
> +	mmu_notifier_invalidate_page(vma, address, event);
> +
>  	page_remove_rmap(page);
>  	page_cache_release(page);
>  
> +	return ret;
> +
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> -	if (ret != SWAP_FAIL && !(flags & TTU_MUNLOCK))
> -		mmu_notifier_invalidate_page(vma, address, event);
>  out:
>  	return ret;

I think there is no bug. In that function the page is just unmapped,
removed from the rmap (page_remove_rmap), and the LRU list
(page_cache_release). The page itself is not released in this function,
so the call mmu_notifier_invalidate_page() at the end is fine.


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
