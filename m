Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7557D6B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 02:33:07 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id n12so3355032oag.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 23:33:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374728103-17468-6-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1374728103-17468-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Thu, 25 Jul 2013 14:33:06 +0800
Message-ID: <CAJd=RBCzdiV1gDY_ySjNqZkyUMuG54grqtZqrOEcjvocRu2uuQ@mail.gmail.com>
Subject: Re: [PATCH 5/8] mbind: add hugepage migration code to mbind()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 25, 2013 at 12:55 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This patch extends do_mbind() to handle vma with VM_HUGETLB set.
> We will be able to migrate hugepage with mbind(2) after
> applying the enablement patch which comes later in this series.
>
> ChangeLog v3:
>  - revert introducing migrate_movable_pages
>  - added alloc_huge_page_noerr free from ERR_VALUE
>
> ChangeLog v2:
>  - updated description and renamed patch title
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
Acked-by: Hillf Danton <dhillf@gmail.com>

>  include/linux/hugetlb.h |  3 +++
>  mm/hugetlb.c            | 14 ++++++++++++++
>  mm/mempolicy.c          |  4 +++-
>  3 files changed, 20 insertions(+), 1 deletion(-)
>
> diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
> index c7a14a4..cae5539 100644
> --- v3.11-rc1.orig/include/linux/hugetlb.h
> +++ v3.11-rc1/include/linux/hugetlb.h
> @@ -267,6 +267,8 @@ struct huge_bootmem_page {
>  };
>
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
> +struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> +                               unsigned long addr, int avoid_reserve);
>
>  /* arch callback */
>  int __init alloc_bootmem_huge_page(struct hstate *h);
> @@ -380,6 +382,7 @@ static inline pgoff_t basepage_index(struct page *page)
>  #else  /* CONFIG_HUGETLB_PAGE */
>  struct hstate {};
>  #define alloc_huge_page_node(h, nid) NULL
> +#define alloc_huge_page_noerr(v, a, r) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
>  #define hstate_sizelog(s) NULL
> diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
> index 506d195..f6d8d67 100644
> --- v3.11-rc1.orig/mm/hugetlb.c
> +++ v3.11-rc1/mm/hugetlb.c
> @@ -1195,6 +1195,20 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>         return page;
>  }
>
> +/*
> + * alloc_huge_page()'s wrapper which simply returns the page if allocation
> + * succeeds, otherwise NULL. This function is called from new_vma_page(),
> + * where no ERR_VALUE is expected to be returned.
> + */
> +struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> +                               unsigned long addr, int avoid_reserve)
> +{
> +       struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
> +       if (IS_ERR(page))
> +               page = NULL;
> +       return page;
> +}
> +
>  int __weak alloc_bootmem_huge_page(struct hstate *h)
>  {
>         struct huge_bootmem_page *m;
> diff --git v3.11-rc1.orig/mm/mempolicy.c v3.11-rc1/mm/mempolicy.c
> index d96afc1..4a03c14 100644
> --- v3.11-rc1.orig/mm/mempolicy.c
> +++ v3.11-rc1/mm/mempolicy.c
> @@ -1183,6 +1183,8 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
>                 vma = vma->vm_next;
>         }
>
> +       if (PageHuge(page))
> +               return alloc_huge_page_noerr(vma, address, 1);
>         /*
>          * if !vma, alloc_page_vma() will use task or system default policy
>          */
> @@ -1293,7 +1295,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>                                         (unsigned long)vma,
>                                         MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
>                         if (nr_failed)
> -                               putback_lru_pages(&pagelist);
> +                               putback_movable_pages(&pagelist);
>                 }
>
>                 if (nr_failed && (flags & MPOL_MF_STRICT))
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
