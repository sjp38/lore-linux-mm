Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB5D6B00A2
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:41:06 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so4777076qgd.33
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:41:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w106si4543187qgd.98.2014.09.15.15.41.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 15:41:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 4/5] mm/hugetlb: add migration/hwpoisoned entry check in hugetlb_change_protection
Date: Mon, 15 Sep 2014 18:39:58 -0400
Message-Id: <1410820799-27278-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1410820799-27278-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, stable@vger.kernel.org

There is a race condition between hugepage migration and change_protection(),
where hugetlb_change_protection() doesn't care about migration entries and
wrongly overwrites them. That causes unexpected results like kernel crash.
HWPoison entries also can cause the same problem.

This patch adds is_hugetlb_entry_(migration|hwpoisoned) check in this
function to do proper actions.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org> # [2.6.36+]
---
ChangeLog v4:
- s/set_pte_at/set_huge_pte_at/

ChangeLog v3:
- handle migration entry correctly (instead of just skipping)
---
 mm/hugetlb.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git mmotm-2014-09-09-14-42.orig/mm/hugetlb.c mmotm-2014-09-09-14-42/mm/hugetlb.c
index 52f001943169..461ee1e10067 100644
--- mmotm-2014-09-09-14-42.orig/mm/hugetlb.c
+++ mmotm-2014-09-09-14-42/mm/hugetlb.c
@@ -3372,7 +3372,26 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			spin_unlock(ptl);
 			continue;
 		}
-		if (!huge_pte_none(huge_ptep_get(ptep))) {
+		pte = huge_ptep_get(ptep);
+		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
+			spin_unlock(ptl);
+			continue;
+		}
+		if (unlikely(is_hugetlb_entry_migration(pte))) {
+			swp_entry_t entry = pte_to_swp_entry(pte);
+
+			if (is_write_migration_entry(entry)) {
+				pte_t newpte;
+
+				make_migration_entry_read(&entry);
+				newpte = swp_entry_to_pte(entry);
+				set_huge_pte_at(mm, address, ptep, newpte);
+				pages++;
+			}
+			spin_unlock(ptl);
+			continue;
+		}
+		if (!huge_pte_none(pte)) {
 			pte = huge_ptep_get_and_clear(mm, address, ptep);
 			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
 			pte = arch_make_huge_pte(pte, vma, NULL, 0);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
