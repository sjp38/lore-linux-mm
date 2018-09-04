Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B11DE6B6C6A
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:55:22 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e88-v6so3212318qtb.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:55:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a5-v6si3029807qtp.320.2018.09.04.00.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:55:21 -0700 (PDT)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH] mm: hugepage: mark splitted page dirty when needed
Date: Tue,  4 Sep 2018 15:55:10 +0800
Message-Id: <20180904075510.22338-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterx@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

When splitting a huge page, we should set all small pages as dirty if
the original huge page has the dirty bit set before.  Otherwise we'll
lose the original dirty bit.

CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Michal Hocko <mhocko@suse.com>
CC: Zi Yan <zi.yan@cs.rutgers.edu>
CC: Huang Ying <ying.huang@intel.com>
CC: Dan Williams <dan.j.williams@intel.com>
CC: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
CC: "JA(C)rA'me Glisse" <jglisse@redhat.com>
CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
CC: Souptick Joarder <jrdr.linux@gmail.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
Signed-off-by: Peter Xu <peterx@redhat.com>
---

To the reviewers: I'm new to the mm world so sorry if this patch is
making silly mistakes, however it did solve a problem for me when
testing with a customized Linux tree mostly based on Andrea's userfault
write-protect work.  Without the change, my customized QEMU/tcg tree
will not be able to do correct UFFDIO_WRITEPROTECT and then QEMU will
get a SIGBUS when faulting multiple times.  With the change (or of
course disabling THP) then UFFDIO_WRITEPROTECT will be able to correctly
resolve the write protections then it runs well.  Any comment would be
welcomed.  TIA.
---
 mm/huge_memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c3bc7e9c9a2a..0754a16923d5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2176,6 +2176,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 				entry = pte_mkold(entry);
 			if (soft_dirty)
 				entry = pte_mksoft_dirty(entry);
+			if (dirty)
+				entry = pte_mkdirty(entry);
 		}
 		pte = pte_offset_map(&_pmd, addr);
 		BUG_ON(!pte_none(*pte));
-- 
2.17.1
