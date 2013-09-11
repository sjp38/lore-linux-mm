Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E23596B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 22:12:39 -0400 (EDT)
Date: Tue, 10 Sep 2013 22:12:17 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378865537-a7m9pwpv-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH][mmotm] mm/mempolicy.c: add check to avoid queuing hugepage
 under migration
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

queue_pages_pmd_range() checks pmd_huge() to find hugepage, but this check
assumes the pmd is in the normal format and does not work on migration entry
whoes format is like swap entry. We can distinguish them with present bit,
so we need to check it before cheking pmd_huge(). Otherwise, pmd_huge() can
wrongly return false for hugepage, and the behavior is unpredictable.

This patch is against mmotm-2013-08-27.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 64d00c4..0472964 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -553,6 +553,8 @@ static inline int queue_pages_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (!pmd_present(*pmd))
+			continue;
 		if (pmd_huge(*pmd) && is_vm_hugetlb_page(vma)) {
 			queue_pages_hugetlb_pmd_range(vma, pmd, nodes,
 						flags, private);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
