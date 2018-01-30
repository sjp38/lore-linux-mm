Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E628D6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 22:54:15 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 199so9044514pfy.18
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:54:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor128109pln.117.2018.01.29.19.54.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 19:54:14 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
Date: Tue, 30 Jan 2018 12:54:04 +0900
Message-Id: <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Recently the following BUG was reported:

    Injecting memory failure for pfn 0x3c0000 at process virtual address 0x7fe300000000
    Memory failure: 0x3c0000: recovery action for huge page: Recovered
    BUG: unable to handle kernel paging request at ffff8dfcc0003000
    IP: gup_pgd_range+0x1f0/0xc20
    PGD 17ae72067 P4D 17ae72067 PUD 0
    Oops: 0000 [#1] SMP PTI
    ...
    CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc+ #3
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014

You can easily reproduce this by calling madvise(MADV_HWPOISON) twice on
a 1GB hugepage. This happens because get_user_pages_fast() is not aware
of a migration entry on pud that was created in the 1st madvise() event.

I think that conversion to pud-aligned migration entry is working,
but other MM code walking over page table isn't prepared for it.
We need some time and effort to make all this work properly, so
this patch avoids the reported bug by just disabling error handling
for 1GB hugepage.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Michal Hocko <mhocko@suse.com> // for v1
Cc: <stable@vger.kernel.org>
---
ChangeLog v1 -> v2:
- add comment about what we need to support hwpoision for pud-sized hugetlb
- use "page size > PMD_SIZE" condition instead of hstate_is_gigantic()
---
 include/linux/mm.h  |  1 +
 mm/memory-failure.c | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h v4.15-rc8-mmotm-2018-01-18-16-31_patched/include/linux/mm.h
index 63f7ba1..6b3df81 100644
--- v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h
+++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/include/linux/mm.h
@@ -2607,6 +2607,7 @@ enum mf_action_page_type {
 	MF_MSG_POISONED_HUGE,
 	MF_MSG_HUGE,
 	MF_MSG_FREE_HUGE,
+	MF_MSG_NON_PMD_HUGE,
 	MF_MSG_UNMAP_FAILED,
 	MF_MSG_DIRTY_SWAPCACHE,
 	MF_MSG_CLEAN_SWAPCACHE,
diff --git v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c v4.15-rc8-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
index d530ac1..264e020 100644
--- v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c
+++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
@@ -508,6 +508,7 @@ static const char * const action_page_types[] = {
 	[MF_MSG_POISONED_HUGE]		= "huge page already hardware poisoned",
 	[MF_MSG_HUGE]			= "huge page",
 	[MF_MSG_FREE_HUGE]		= "free huge page",
+	[MF_MSG_NON_PMD_HUGE]		= "non-pmd-sized huge page",
 	[MF_MSG_UNMAP_FAILED]		= "unmapping failed page",
 	[MF_MSG_DIRTY_SWAPCACHE]	= "dirty swapcache page",
 	[MF_MSG_CLEAN_SWAPCACHE]	= "clean swapcache page",
@@ -1090,6 +1091,21 @@ static int memory_failure_hugetlb(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
+	/*
+	 * TODO: hwpoison for pud-sized hugetlb doesn't work right now, so
+	 * simply disable it. In order to make it work properly, we need
+	 * make sure that:
+	 *  - conversion of a pud that maps an error hugetlb into hwpoison
+	 *    entry properly works, and
+	 *  - other mm code walking over page table is aware of pud-aligned
+	 *    hwpoison entries.
+	 */
+	if (huge_page_size(page_hstate(head)) > PMD_SIZE) {
+		action_result(pfn, MF_MSG_NON_PMD_HUGE, MF_IGNORED);
+		res = -EBUSY;
+		goto out;
+	}
+
 	if (!hwpoison_user_mappings(p, pfn, trapno, flags, &head)) {
 		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
 		res = -EBUSY;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
