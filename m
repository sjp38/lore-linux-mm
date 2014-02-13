Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 31F786B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:09:27 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i17so19172958qcy.11
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:09:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y3si2306570qas.12.2014.02.13.14.09.26
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 14:09:26 -0800 (PST)
Date: Thu, 13 Feb 2014 17:09:05 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52fd4296.c383e00a.50b5.02e4SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <52FC22DA.9010002@huawei.com>
References: <52FC22DA.9010002@huawei.com>
Subject: Re: [3.10.x-stable] process accidentally killed by mce because of
 huge page migration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kirill.shutemov@linux.intel.com, hughd@google.com, Linux MM <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

Hi Xishi,

On Thu, Feb 13, 2014 at 09:41:46AM +0800, Xishi Qiu wrote:
> Hi Naoya or Greg,
> 
> We found a bug in 3.10.x.
> 1) use sysfs interface soft_offline_page() to migrate a huge page.
> 2) the hpage become free after migrate_huge_page().
> 3) the free hpage is alloced and used by process A.
> 4) hwpoison flag is set by set_page_hwpoison_huge_page()
> 5) mce find this poisoned page.
> 6) process A was killed.
> 7) other processes which use this page will be killed too.
> 
> I tested this bug, one process keeps allocating huge page, and I 
> use sysfs interface to soft offline a huge page, then received:
> "MCE: Killing UCP:2717 due to hardware memory corruption fault at 8200034"
> 
> Upstream kernel is free from this bug because of these two commits:
> 
> f15bdfa802bfa5eb6b4b5a241b97ec9fa1204a35
> mm/memory-failure.c: fix memory leak in successful soft offlining

Correct. Although this problem is not about memory leak, this patch
moves unset_migratetype_isolate(), which is important to avoid the race.

> c8721bbbdd36382de51cd6b7a56322e0acca2414
> mm: memory-hotplug: enable memory hotplug to handle hugepage

The problem is that we accidentally have a hwpoisoned hugepage in free
hugepage list. It could happend in the the following scenario:

        process A                           process B

  migrate_huge_page
  put_page (old hugepage)
    linked to free hugepage list
                                     hugetlb_fault
                                       hugetlb_no_page
                                         alloc_huge_page
                                           dequeue_huge_page_vma
                                             dequeue_huge_page_node
                                               (steal hwpoisoned hugepage)
  set_page_hwpoison_huge_page
  dequeue_hwpoisoned_huge_page
    (fail to dequeue)

In upstream, we avoid the race by making dequeue_huge_page_node refuse
to use hugepages with MIGRATE_ISOLATE set. But this depends on the fact
that we set MIGRATE_ISOLATE on hugepage under migration. This is not
the case in current stable-3.10.

> The latter is not a bug fix and it's too big, the following patch
> can fix this bug.
> 
> What do you think? Use the simple fix or backport the big patch?

I definitely agree to your suggestion. Please feel free to add the above
explanation in the patch description with
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

> Thanks,
> Xishi Qiu
> 
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/hugetlb.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7c5eb85..6cb5b3b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -21,6 +21,7 @@
>  #include <linux/rmap.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/page-isolation.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -517,9 +518,15 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  {
>  	struct page *page;
>  
> -	if (list_empty(&h->hugepage_freelists[nid]))
> +	list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
> +		if (!is_migrate_isolate_page(page))
> +			break;
> +	/*
> +	 * if 'non-isolated free hugepage' not found on the list,
> +	 * the allocation fails.
> +	 */
> +	if (&h->hugepage_freelists[nid] == &page->lru)
>  		return NULL;
> -	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
>  	list_move(&page->lru, &h->hugepage_activelist);
>  	set_page_refcounted(page);
>  	h->free_huge_pages--;
> -- 
> 1.7.1 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
