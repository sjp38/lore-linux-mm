Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA7076B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 00:34:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so179814893pfa.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 21:34:18 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m29si6171613pgn.56.2017.02.07.21.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 21:34:17 -0800 (PST)
Subject: [-mm PATCH] mm: fix get_user_pages() vs device-dax pud mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 07 Feb 2017 21:30:11 -0800
Message-ID: <148653181153.38226.9605457830505509385.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dave Jiang <dave.jiang@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-nvdimm@lists.01.org, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

A new unit test for the device-dax 1GB enabling currently fails with
this warning before hanging the test thread:

 WARNING: CPU: 0 PID: 21 at lib/percpu-refcount.c:155 percpu_ref_switch_to_atomic_rcu+0x1e3/0x1f0
 percpu ref (dax_pmem_percpu_release [dax_pmem]) <= 0 (0) after switching to atomic
 [..]
 CPU: 0 PID: 21 Comm: rcuos/1 Tainted: G           O    4.10.0-rc7-next-20170207+ #944
 [..]
 Call Trace:
  dump_stack+0x86/0xc3
  __warn+0xcb/0xf0
  warn_slowpath_fmt+0x5f/0x80
  ? rcu_nocb_kthread+0x27a/0x510
  ? dax_pmem_percpu_exit+0x50/0x50 [dax_pmem]
  percpu_ref_switch_to_atomic_rcu+0x1e3/0x1f0
  ? percpu_ref_exit+0x60/0x60
  rcu_nocb_kthread+0x339/0x510
  ? rcu_nocb_kthread+0x27a/0x510
  kthread+0x101/0x140

The get_user_pages() path needs to arrange for references to be taken
against the dev_pagemap instance backing the pud mapping. Refactor the
existing __gup_device_huge_pmd() to also account for the pud case.

Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Nilesh Choudhury <nilesh.choudhury@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/gup.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 0d4fb3ebbbac..99c7805a9693 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -154,14 +154,12 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 	SetPageReferenced(page);
 }
 
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
 	int nr_start = *nr;
-	unsigned long pfn = pmd_pfn(pmd);
 	struct dev_pagemap *pgmap = NULL;
 
-	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
 	do {
 		struct page *page = pfn_to_page(pfn);
 
@@ -180,6 +178,24 @@ static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
 	return 1;
 }
 
+static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	unsigned long fault_pfn;
+
+	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+}
+
+static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
+{
+	unsigned long fault_pfn;
+
+	fault_pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
+}
+
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
@@ -251,9 +267,13 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 
 	if (!pte_allows_gup(pud_val(pud), write))
 		return 0;
+
+	VM_BUG_ON(!pfn_valid(pud_pfn(pud)));
+	if (pud_devmap(pud))
+		return __gup_device_huge_pud(pud, addr, end, pages, nr);
+
 	/* hugepages are never "special" */
 	VM_BUG_ON(pud_flags(pud) & _PAGE_SPECIAL);
-	VM_BUG_ON(!pfn_valid(pud_pfn(pud)));
 
 	refs = 0;
 	head = pud_page(pud);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
