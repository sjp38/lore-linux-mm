Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 007B06B026A
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:39 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v184so1295057wmf.1
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t18si3812811wra.535.2017.11.30.14.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:37 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:35 -0800
From: akpm@linux-foundation.org
Subject: [patch 08/15] mm/madvise: enable soft offline of HugeTLB pages at PUD level
Message-ID: <5a208307.bMlHlT43SCRrZUH1%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, 00moses.alexander00@gmail.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, khandual@linux.vnet.ibm.com, kirill@shutemov.name, mhocko@suse.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, punit.agrawal@arm.com

From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level

Since 94310cbcaa3c2 ("mm/madvise: enable (soft|hard) offline of HugeTLB
pages at PGD level") we've been able to soft offline 1G hugepages at the
PGD level, however x86_64 gigantic hugepages are at the PUD level so we
should add an extra check to account for hstate order at PUD level.

It allows migration of 1G pages in general.  It also makes these pages
allocated with GFP_HIGHUSER_MOVABLE instead of GFP_HIGHUSER.

There's nothing changed in this regard in 5-level paging mode.  PUD is
still one gig and there are no new page sizes.

Tested with 4 level pagetable.

Link: http://lkml.kernel.org/r/20170913101047.GA13026@gmail.com
Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/hugetlb.h |    1 +
 1 file changed, 1 insertion(+)

diff -puN include/linux/hugetlb.h~mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level include/linux/hugetlb.h
--- a/include/linux/hugetlb.h~mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level
+++ a/include/linux/hugetlb.h
@@ -473,6 +473,7 @@ static inline bool hugepage_migration_su
 {
 #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
 	if ((huge_page_shift(h) == PMD_SHIFT) ||
+		(huge_page_shift(h) == PUD_SHIFT) ||
 		(huge_page_shift(h) == PGDIR_SHIFT))
 		return true;
 	else
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
