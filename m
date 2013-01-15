Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7C1188D0003
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:55:44 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [BUG Fix Patch 3/6] Bug fix: Do not free direct mapping pages twice.
Date: Tue, 15 Jan 2013 18:54:24 +0800
Message-Id: <1358247267-18089-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Direct mapped pages were freed when they were offlined, or they were
not allocated. So we only need to free vmemmap pages, no need to free
direct mapped pages.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 368cc3f..e77d312 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -804,6 +804,10 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 		if (IS_ALIGNED(addr, PAGE_SIZE) &&
 		    IS_ALIGNED(next, PAGE_SIZE)) {
+			/*
+			 * Do not free direct mapping pages since they were
+			 * freed when offlining.
+			 */
 			if (!direct)
 				free_pagetable(pte_page(*pte), 0);
 
@@ -819,10 +823,11 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			 * remove the page when it is wholly filled with 0xFD.
 			 */
 			memset((void *)addr, PAGE_INUSE, next - addr);
-			page_addr = page_address(pte_page(*pte));
 
+			page_addr = page_address(pte_page(*pte));
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
-				free_pagetable(pte_page(*pte), 0);
+				if (!direct)
+					free_pagetable(pte_page(*pte), 0);
 
 				spin_lock(&init_mm.page_table_lock);
 				pte_clear(&init_mm, addr, pte);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
