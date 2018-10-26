Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C34256B0309
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:29:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d8-v6so478522pgq.3
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:29:03 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i4-v6si11087247pgk.564.2018.10.26.05.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 05:29:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 3/3] x86/ldt: Remove unused variable in map_ldt_struct()
Date: Fri, 26 Oct 2018 15:28:56 +0300
Message-Id: <20181026122856.66224-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Commit

  9bae3197e15d ("x86/ldt: Split out sanity check in map_ldt_struct()")

moved page table syncing into a separate funtion. pgd variable is now
unsed in map_ldt_struct().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/ldt.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index e32f3427438a..5dc8ed202fa8 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -206,7 +206,6 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	unsigned long va;
 	bool is_vmalloc;
 	spinlock_t *ptl;
-	pgd_t *pgd;
 	int i, nr_pages;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
@@ -221,13 +220,6 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	/* Check if the current mappings are sane */
 	sanity_check_ldt_mapping(mm);
 
-	/*
-	 * Did we already have the top level entry allocated?  We can't
-	 * use pgd_none() for this because it doens't do anything on
-	 * 4-level page table kernels.
-	 */
-	pgd = pgd_offset(mm, LDT_BASE_ADDR);
-
 	is_vmalloc = is_vmalloc_addr(ldt->entries);
 
 	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
-- 
2.19.1
