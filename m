Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D206D6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 14:28:35 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 23:48:24 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 80BEE1258051
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 23:57:59 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UITXaR28966980
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 23:59:33 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UISREC005688
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:28:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] migrate: make core migration code aware of hugepage
In-Reply-To: <1374728103-17468-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374728103-17468-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1374728103-17468-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 30 Jul 2013 23:58:27 +0530
Message-ID: <87mwp3q4vo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Before enabling each user of page migration to support hugepage,
> this patch enables the list of pages for migration to link not only
> LRU pages, but also hugepages. As a result, putback_movable_pages()
> and migrate_pages() can handle both of LRU pages and hugepages.
>
> ChangeLog v4:
>  - make some macros return 'do {} while(0)'
>  - use more readable variable name
>
> ChangeLog v3:
>  - revert introducing migrate_movable_pages
>  - add isolate_huge_page
>
> ChangeLog v2:
>  - move code removing VM_HUGETLB from vma_migratable check into a
>    separate patch
>  - hold hugetlb_lock in putback_active_hugepage
>  - update comment near the definition of hugetlb_lock
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb.h |  6 ++++++
>  mm/hugetlb.c            | 32 +++++++++++++++++++++++++++++++-
>  mm/migrate.c            | 10 +++++++++-
>  3 files changed, 46 insertions(+), 2 deletions(-)
>
> diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
> index c2b1801..c7a14a4 100644
> --- v3.11-rc1.orig/include/linux/hugetlb.h
> +++ v3.11-rc1/include/linux/hugetlb.h
> @@ -66,6 +66,9 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
>  						vm_flags_t vm_flags);
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  int dequeue_hwpoisoned_huge_page(struct page *page);
> +bool isolate_huge_page(struct page *page, struct list_head *list);
> +void putback_active_hugepage(struct page *page);
> +void putback_active_hugepages(struct list_head *list);

are we using putback_active_hugepages in the patch series ?


>  void copy_huge_page(struct page *dst, struct page *src);
>
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> @@ -134,6 +137,9 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  	return 0;
>  }

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
