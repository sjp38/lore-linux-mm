Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A59E86B0394
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:35:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l66so284952734pfl.6
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 23:35:07 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id n188si10552855pga.361.2017.03.12.23.35.05
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 23:35:06 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org> <1489365353-28205-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-3-git-send-email-minchan@kernel.org>
Subject: Re: [PATCH v1 02/10] mm: remove SWAP_DIRTY in ttu
Date: Mon, 13 Mar 2017 14:34:37 +0800
Message-ID: <099201d29bc3$e3ab2d60$ab018820$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@suse.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>


On March 13, 2017 8:36 AM Minchan Kim wrote: 
> 
> If we found lazyfree page is dirty, try_to_unmap_one can just
> SetPageSwapBakced in there like PG_mlocked page and just return
> with SWAP_FAIL which is very natural because the page is not
> swappable right now so that vmscan can activate it.
> There is no point to introduce new return value SWAP_DIRTY
> in ttu at the moment.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/rmap.h | 1 -
>  mm/rmap.c            | 6 +++---
>  mm/vmscan.c          | 3 ---
>  3 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index fee10d7..b556eef 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -298,6 +298,5 @@ static inline int page_mkclean(struct page *page)
>  #define SWAP_AGAIN	1
>  #define SWAP_FAIL	2
>  #define SWAP_MLOCK	3
> -#define SWAP_DIRTY	4
> 
>  #endif	/* _LINUX_RMAP_H */
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9dbfa6f..d47af09 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1414,7 +1414,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			 */
>  			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
>  				WARN_ON_ONCE(1);
> -				ret = SWAP_FAIL;
> +				ret = false;
Nit:
Hm looks like stray merge.
Not sure it's really needed. 

>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
>  			}
> @@ -1431,7 +1431,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				 * discarded. Remap the page to page table.
>  				 */
>  				set_pte_at(mm, address, pvmw.pte, pteval);
> -				ret = SWAP_DIRTY;
> +				SetPageSwapBacked(page);
> +				ret = SWAP_FAIL;
>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
>  			}
> @@ -1501,7 +1502,6 @@ static int page_mapcount_is_zero(struct page *page)
>   * SWAP_AGAIN	- we missed a mapping, try again later
>   * SWAP_FAIL	- the page is unswappable
>   * SWAP_MLOCK	- page is mlocked.
> - * SWAP_DIRTY	- page is dirty MADV_FREE page
>   */
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a3656f9..b8fd656 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1142,9 +1142,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (page_mapped(page)) {
>  			switch (ret = try_to_unmap(page,
>  				ttu_flags | TTU_BATCH_FLUSH)) {
> -			case SWAP_DIRTY:
> -				SetPageSwapBacked(page);
> -				/* fall through */
>  			case SWAP_FAIL:
>  				nr_unmap_fail++;
>  				goto activate_locked;
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
