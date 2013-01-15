Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 582578D0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:55:39 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [BUG Fix Patch 2/6] Bug fix: Do not calculate direct mapping pages when freeing vmemmap pagetables.
Date: Tue, 15 Jan 2013 18:54:23 +0800
Message-Id: <1358247267-18089-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

We only need to update direct_pages_count[level] when we freeing direct mapped
pagetables.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e829113..368cc3f 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -804,14 +804,13 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 		if (IS_ALIGNED(addr, PAGE_SIZE) &&
 		    IS_ALIGNED(next, PAGE_SIZE)) {
-			if (!direct) {
+			if (!direct)
 				free_pagetable(pte_page(*pte), 0);
-				pages++;
-			}
 
 			spin_lock(&init_mm.page_table_lock);
 			pte_clear(&init_mm, addr, pte);
 			spin_unlock(&init_mm.page_table_lock);
+			pages++;
 		} else {
 			/*
 			 * If we are not removing the whole page, it means
@@ -824,11 +823,11 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
 				free_pagetable(pte_page(*pte), 0);
-				pages++;
 
 				spin_lock(&init_mm.page_table_lock);
 				pte_clear(&init_mm, addr, pte);
 				spin_unlock(&init_mm.page_table_lock);
+				pages++;
 			}
 		}
 	}
@@ -857,15 +856,14 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		if (pmd_large(*pmd)) {
 			if (IS_ALIGNED(addr, PMD_SIZE) &&
 			    IS_ALIGNED(next, PMD_SIZE)) {
-				if (!direct) {
+				if (!direct)
 					free_pagetable(pmd_page(*pmd),
 						       get_order(PMD_SIZE));
-					pages++;
-				}
 
 				spin_lock(&init_mm.page_table_lock);
 				pmd_clear(pmd);
 				spin_unlock(&init_mm.page_table_lock);
+				pages++;
 				continue;
 			}
 
@@ -914,15 +912,14 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		if (pud_large(*pud)) {
 			if (IS_ALIGNED(addr, PUD_SIZE) &&
 			    IS_ALIGNED(next, PUD_SIZE)) {
-				if (!direct) {
+				if (!direct)
 					free_pagetable(pud_page(*pud),
 						       get_order(PUD_SIZE));
-					pages++;
-				}
 
 				spin_lock(&init_mm.page_table_lock);
 				pud_clear(pud);
 				spin_unlock(&init_mm.page_table_lock);
+				pages++;
 				continue;
 			}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
