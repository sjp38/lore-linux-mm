From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/2] migrate: add migrate_entry_wait_huge()
Date: Wed, 29 May 2013 09:11:02 +0800
Message-ID: <45552.0148076632$1369789883@news.gmane.org>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UhUv5-0002qx-F6
	for glkm-linux-mm-2@m.gmane.org; Wed, 29 May 2013 03:11:15 +0200
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 45ED86B0093
	for <linux-mm@kvack.org>; Tue, 28 May 2013 21:11:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 29 May 2013 06:35:52 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9EA91394004D
	for <linux-mm@kvack.org>; Wed, 29 May 2013 06:41:05 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4T1AxZg6816100
	for <linux-mm@kvack.org>; Wed, 29 May 2013 06:40:59 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4T1B3L0007784
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:11:03 +1000
Content-Disposition: inline
In-Reply-To: <1369770771-8447-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Tue, May 28, 2013 at 03:52:51PM -0400, Naoya Horiguchi wrote:
>When we have a page fault for the address which is backed by a hugepage
>under migration, the kernel can't wait correctly and do busy looping on
>hugepage fault until the migration finishes.
>This is because pte_offset_map_lock() can't get a correct migration entry
>or a correct page table lock for hugepage.
>This patch introduces migration_entry_wait_huge() to solve this.
>
>Note that the caller, hugetlb_fault(), gets the pointer to the "leaf"
>entry with huge_pte_offset() inside which all the arch-dependency of
>the page table structure are. So migration_entry_wait_huge() and
>__migration_entry_wait() are free from arch-dependency.
>
>ChangeLog v3:
> - use huge_pte_lockptr
>
>ChangeLog v2:
> - remove dup in migrate_entry_wait_huge()
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Cc: stable@vger.kernel.org # 2.6.35
>---
> include/linux/swapops.h |  3 +++
> mm/hugetlb.c            |  2 +-
> mm/migrate.c            | 23 ++++++++++++++++++-----
> 3 files changed, 22 insertions(+), 6 deletions(-)
>
>diff --git v3.10-rc3.orig/include/linux/swapops.h v3.10-rc3/include/linux/swapops.h
>index 47ead51..c5fd30d 100644
>--- v3.10-rc3.orig/include/linux/swapops.h
>+++ v3.10-rc3/include/linux/swapops.h
>@@ -137,6 +137,7 @@ static inline void make_migration_entry_read(swp_entry_t *entry)
>
> extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
> 					unsigned long address);
>+extern void migration_entry_wait_huge(struct mm_struct *mm, pte_t *pte);
> #else
>
> #define make_migration_entry(page, write) swp_entry(0, 0)
>@@ -148,6 +149,8 @@ static inline int is_migration_entry(swp_entry_t swp)
> static inline void make_migration_entry_read(swp_entry_t *entryp) { }
> static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
> 					 unsigned long address) { }
>+static inline void migration_entry_wait_huge(struct mm_struct *mm,
>+					pte_t *pte) { }
> static inline int is_write_migration_entry(swp_entry_t entry)
> {
> 	return 0;
>diff --git v3.10-rc3.orig/mm/hugetlb.c v3.10-rc3/mm/hugetlb.c
>index 8e1af32..d91a438 100644
>--- v3.10-rc3.orig/mm/hugetlb.c
>+++ v3.10-rc3/mm/hugetlb.c
>@@ -2877,7 +2877,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 	if (ptep) {
> 		entry = huge_ptep_get(ptep);
> 		if (unlikely(is_hugetlb_entry_migration(entry))) {
>-			migration_entry_wait(mm, (pmd_t *)ptep, address);
>+			migration_entry_wait_huge(mm, ptep);
> 			return 0;
> 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
> 			return VM_FAULT_HWPOISON_LARGE |
>diff --git v3.10-rc3.orig/mm/migrate.c v3.10-rc3/mm/migrate.c
>index 6f2df6e..64ff118 100644
>--- v3.10-rc3.orig/mm/migrate.c
>+++ v3.10-rc3/mm/migrate.c
>@@ -204,15 +204,14 @@ static void remove_migration_ptes(struct page *old, struct page *new)
>  * get to the page and wait until migration is finished.
>  * When we return from this function the fault will be retried.
>  */
>-void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
>-				unsigned long address)
>+static void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
>+				spinlock_t *ptl)
> {
>-	pte_t *ptep, pte;
>-	spinlock_t *ptl;
>+	pte_t pte;
> 	swp_entry_t entry;
> 	struct page *page;
>
>-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
>+	spin_lock(ptl);
> 	pte = *ptep;
> 	if (!is_swap_pte(pte))
> 		goto out;
>@@ -240,6 +239,20 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
> 	pte_unmap_unlock(ptep, ptl);
> }
>
>+void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
>+				unsigned long address)
>+{
>+	spinlock_t *ptl = pte_lockptr(mm, pmd);
>+	pte_t *ptep = pte_offset_map(pmd, address);
>+	__migration_entry_wait(mm, ptep, ptl);
>+}
>+
>+void migration_entry_wait_huge(struct mm_struct *mm, pte_t *pte)
>+{
>+	spinlock_t *ptl = huge_pte_lockptr(mm, pte);
>+	__migration_entry_wait(mm, pte, ptl);
>+}
>+
> #ifdef CONFIG_BLOCK
> /* Returns true if all buffers are successfully locked */
> static bool buffer_migrate_lock_buffers(struct buffer_head *head,
>-- 
>1.7.11.7
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
