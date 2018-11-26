Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30E036B41D5
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 06:05:28 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so399070plp.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:05:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x4si34869882plv.56.2018.11.26.03.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 03:05:26 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.19 093/118] x86/ldt: Unmap PTEs for the slot before freeing LDT pages
Date: Mon, 26 Nov 2018 11:51:27 +0100
Message-Id: <20181126105105.431465354@linuxfoundation.org>
In-Reply-To: <20181126105059.832485122@linuxfoundation.org>
References: <20181126105059.832485122@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, linux-mm@kvack.org, Sasha Levin <sashal@kernel.org>

4.19-stable review patch.  If anyone has any objections, please let me know.

------------------

commit a0e6e0831c516860fc7f9be1db6c081fe902ebcf upstream

modify_ldt(2) leaves the old LDT mapped after switching over to the new
one. The old LDT gets freed and the pages can be re-used.

Leaving the mapping in place can have security implications. The mapping is
present in the userspace page tables and Meltdown-like attacks can read
these freed and possibly reused pages.

It's relatively simple to fix: unmap the old LDT and flush TLB before
freeing the old LDT memory.

This further allows to avoid flushing the TLB in map_ldt_struct() as the
slot is unmapped and flushed by unmap_ldt_struct() or has never been mapped
at all.

[ tglx: Massaged changelog and removed the needless line breaks ]

Fixes: f55f0501cbf6 ("x86/pti: Put the LDT in its own PGD if PTI is on")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: bp@alien8.de
Cc: hpa@zytor.com
Cc: dave.hansen@linux.intel.com
Cc: luto@kernel.org
Cc: peterz@infradead.org
Cc: boris.ostrovsky@oracle.com
Cc: jgross@suse.com
Cc: bhe@redhat.com
Cc: willy@infradead.org
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181026122856.66224-3-kirill.shutemov@linux.intel.com
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/x86/kernel/ldt.c | 51 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 733e6ace0fa4..2a71ded9b13e 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -199,14 +199,6 @@ static void sanity_check_ldt_mapping(struct mm_struct *mm)
 /*
  * If PTI is enabled, this maps the LDT into the kernelmode and
  * usermode tables for the given mm.
- *
- * There is no corresponding unmap function.  Even if the LDT is freed, we
- * leave the PTEs around until the slot is reused or the mm is destroyed.
- * This is harmless: the LDT is always in ordinary memory, and no one will
- * access the freed slot.
- *
- * If we wanted to unmap freed LDTs, we'd also need to do a flush to make
- * it useful, and the flush would slow down modify_ldt().
  */
 static int
 map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
@@ -214,8 +206,8 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	unsigned long va;
 	bool is_vmalloc;
 	spinlock_t *ptl;
+	int i, nr_pages;
 	pgd_t *pgd;
-	int i;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return 0;
@@ -238,7 +230,9 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 
 	is_vmalloc = is_vmalloc_addr(ldt->entries);
 
-	for (i = 0; i * PAGE_SIZE < ldt->nr_entries * LDT_ENTRY_SIZE; i++) {
+	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
+
+	for (i = 0; i < nr_pages; i++) {
 		unsigned long offset = i << PAGE_SHIFT;
 		const void *src = (char *)ldt->entries + offset;
 		unsigned long pfn;
@@ -272,13 +266,39 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	/* Propagate LDT mapping to the user page-table */
 	map_ldt_struct_to_user(mm);
 
-	va = (unsigned long)ldt_slot_va(slot);
-	flush_tlb_mm_range(mm, va, va + LDT_SLOT_STRIDE, 0);
-
 	ldt->slot = slot;
 	return 0;
 }
 
+static void unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+	unsigned long va;
+	int i, nr_pages;
+
+	if (!ldt)
+		return;
+
+	/* LDT map/unmap is only required for PTI */
+	if (!static_cpu_has(X86_FEATURE_PTI))
+		return;
+
+	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
+
+	for (i = 0; i < nr_pages; i++) {
+		unsigned long offset = i << PAGE_SHIFT;
+		spinlock_t *ptl;
+		pte_t *ptep;
+
+		va = (unsigned long)ldt_slot_va(ldt->slot) + offset;
+		ptep = get_locked_pte(mm, va, &ptl);
+		pte_clear(mm, va, ptep);
+		pte_unmap_unlock(ptep, ptl);
+	}
+
+	va = (unsigned long)ldt_slot_va(ldt->slot);
+	flush_tlb_mm_range(mm, va, va + nr_pages * PAGE_SIZE, 0);
+}
+
 #else /* !CONFIG_PAGE_TABLE_ISOLATION */
 
 static int
@@ -286,6 +306,10 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 {
 	return 0;
 }
+
+static void unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+}
 #endif /* CONFIG_PAGE_TABLE_ISOLATION */
 
 static void free_ldt_pgtables(struct mm_struct *mm)
@@ -524,6 +548,7 @@ static int write_ldt(void __user *ptr, unsigned long bytecount, int oldmode)
 	}
 
 	install_ldt(mm, new_ldt);
+	unmap_ldt_struct(mm, old_ldt);
 	free_ldt_struct(old_ldt);
 	error = 0;
 
-- 
2.17.1
