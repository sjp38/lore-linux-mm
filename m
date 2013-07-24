From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/8] migrate: add hugepage migration code to move_pages()
Date: Wed, 24 Jul 2013 11:41:10 +0800
Message-ID: <25993.044631514$1374637291@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1px4-0008Au-Om
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 05:41:23 +0200
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 70DF36B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:41:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 13:38:16 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0BED82BB0054
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:41:14 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O3PoO759506718
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:25:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O3fCRC007766
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:41:13 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:28PM -0400, Naoya Horiguchi wrote:
>This patch extends move_pages() to handle vma with VM_HUGETLB set.
>We will be able to migrate hugepage with move_pages(2) after
>applying the enablement patch which comes later in this series.
>
>We avoid getting refcount on tail pages of hugepage, because unlike thp,
>hugepage is not split and we need not care about races with splitting.
>
>And migration of larger (1GB for x86_64) hugepage are not enabled.
>
>ChangeLog v3:
> - revert introducing migrate_movable_pages
> - follow_page_mask(FOLL_GET) returns NULL for tail pages
> - use isolate_huge_page
>
>ChangeLog v2:
> - updated description and renamed patch title
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> mm/memory.c  | 12 ++++++++++--
> mm/migrate.c | 13 +++++++++++--
> 2 files changed, 21 insertions(+), 4 deletions(-)
>
>diff --git v3.11-rc1.orig/mm/memory.c v3.11-rc1/mm/memory.c
>index 1ce2e2a..8c9a2cb 100644
>--- v3.11-rc1.orig/mm/memory.c
>+++ v3.11-rc1/mm/memory.c
>@@ -1496,7 +1496,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> 	if (pud_none(*pud))
> 		goto no_page_table;
> 	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
>-		BUG_ON(flags & FOLL_GET);
>+		if (flags & FOLL_GET)
>+			goto out;
> 		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
> 		goto out;
> 	}
>@@ -1507,8 +1508,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> 	if (pmd_none(*pmd))
> 		goto no_page_table;
> 	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
>-		BUG_ON(flags & FOLL_GET);
> 		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
>+		if (flags & FOLL_GET) {
>+			if (PageHead(page))
>+				get_page_foll(page);
>+			else {
>+				page = NULL;
>+				goto out;
>+			}
>+		}
> 		goto out;
> 	}
> 	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
>diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
>index 3ec47d3..d313737 100644
>--- v3.11-rc1.orig/mm/migrate.c
>+++ v3.11-rc1/mm/migrate.c
>@@ -1092,7 +1092,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>
> 	*result = &pm->status;
>
>-	return alloc_pages_exact_node(pm->node,
>+	if (PageHuge(p))
>+		return alloc_huge_page_node(page_hstate(compound_head(p)),
>+					pm->node);
>+	else
>+		return alloc_pages_exact_node(pm->node,
> 				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
> }
>
>@@ -1152,6 +1156,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> 				!migrate_all)
> 			goto put_and_set;
>
>+		if (PageHuge(page)) {
>+			isolate_huge_page(page, &pagelist);
>+			goto put_and_set;
>+		}
>+
> 		err = isolate_lru_page(page);
> 		if (!err) {
> 			list_add_tail(&page->lru, &pagelist);
>@@ -1174,7 +1183,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> 		err = migrate_pages(&pagelist, new_page_node,
> 				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
> 		if (err)
>-			putback_lru_pages(&pagelist);
>+			putback_movable_pages(&pagelist);
> 	}
>
> 	up_read(&mm->mmap_sem);
>-- 
>1.8.3.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
