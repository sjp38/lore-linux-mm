Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1606B4403DD
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:51 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id a3so7909443itg.7
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:51 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n22si3064013ita.130.2017.12.14.03.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:43 -0800 (PST)
Message-Id: <20171214113851.847232284@infradead.org>
Date: Thu, 14 Dec 2017 12:27:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 15/17] x86/ldt: Prepare for VMA mapping
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=x86-ldt--Prepare-for-VMA-mapping.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

From: Thomas Gleixner <tglx@linutronix.de>

Implement that infrastructure to manage LDT information with backing
pages. Preparatory patch for VMA based LDT mapping. Split out for ease of
review.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/mmu.h         |    3 +
 arch/x86/include/asm/mmu_context.h |    9 ++-
 arch/x86/kernel/ldt.c              |  107 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 116 insertions(+), 3 deletions(-)

--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -7,6 +7,8 @@
 #include <linux/mutex.h>
 #include <linux/atomic.h>
 
+struct ldt_mapping;
+
 /*
  * x86 has arch-specific MMU state beyond what lives in mm_struct.
  */
@@ -29,6 +31,7 @@ typedef struct {
 
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct rw_semaphore	ldt_usr_sem;
+	struct ldt_mapping	*ldt_mapping;
 	struct ldt_struct	*ldt;
 #endif
 
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -42,6 +42,8 @@ static inline void load_mm_cr4(struct mm
 #include <asm/ldt.h>
 
 #define LDT_ENTRIES_MAP_SIZE	(LDT_ENTRIES * LDT_ENTRY_SIZE)
+#define LDT_ENTRIES_PAGES	(LDT_ENTRIES_MAP_SIZE / PAGE_SIZE)
+#define LDT_ENTRIES_PER_PAGE	(PAGE_SIZE / LDT_ENTRY_SIZE)
 
 /*
  * ldt_structs can be allocated, used, and freed, but they are never
@@ -54,8 +56,10 @@ struct ldt_struct {
 	 * call gates.  On native, we could merge the ldt_struct and LDT
 	 * allocations, but it's not worth trying to optimize.
 	 */
-	struct desc_struct *entries;
-	unsigned int nr_entries;
+	struct desc_struct	*entries;
+	struct page		*pages[LDT_ENTRIES_PAGES];
+	unsigned int		nr_entries;
+	unsigned int		pages_allocated;
 };
 
 /*
@@ -64,6 +68,7 @@ struct ldt_struct {
 static inline void init_new_context_ldt(struct mm_struct *mm)
 {
 	mm->context.ldt = NULL;
+	mm->context.ldt_mapping = NULL;
 	init_rwsem(&mm->context.ldt_usr_sem);
 }
 int ldt_dup_context(struct mm_struct *oldmm, struct mm_struct *mm);
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -28,6 +28,11 @@
 #include <asm/mmu_context.h>
 #include <asm/syscalls.h>
 
+struct ldt_mapping {
+	struct ldt_struct		ldts[2];
+	unsigned int			ldt_index;
+};
+
 /* After calling this, the LDT is immutable. */
 static void finalize_ldt_struct(struct ldt_struct *ldt)
 {
@@ -82,6 +87,97 @@ static void ldt_install_mm(struct mm_str
 	mutex_unlock(&mm->context.lock);
 }
 
+static void ldt_free_pages(struct ldt_struct *ldt)
+{
+	int i;
+
+	for (i = 0; i < ldt->pages_allocated; i++)
+		__free_page(ldt->pages[i]);
+}
+
+static void ldt_free_lmap(struct ldt_mapping *lmap)
+{
+	if (!lmap)
+		return;
+	ldt_free_pages(&lmap->ldts[0]);
+	ldt_free_pages(&lmap->ldts[1]);
+	kfree(lmap);
+}
+
+static int ldt_alloc_pages(struct ldt_struct *ldt, unsigned int nentries)
+{
+	unsigned int npages, idx;
+
+	npages = DIV_ROUND_UP(nentries * LDT_ENTRY_SIZE, PAGE_SIZE);
+
+	for (idx = ldt->pages_allocated; idx < npages; idx++) {
+		if (WARN_ON_ONCE(ldt->pages[idx]))
+			continue;
+
+		ldt->pages[idx] = alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!ldt->pages[idx])
+			return -ENOMEM;
+
+		ldt->pages_allocated++;
+	}
+	return 0;
+}
+
+static struct ldt_mapping *ldt_alloc_lmap(struct mm_struct *mm,
+					  unsigned int nentries)
+{
+	struct ldt_mapping *lmap = kzalloc(sizeof(*lmap), GFP_KERNEL);
+
+	if (!lmap)
+		return ERR_PTR(-ENOMEM);
+
+	if (ldt_alloc_pages(&lmap->ldts[0], nentries)) {
+		ldt_free_lmap(lmap);
+		return ERR_PTR(-ENOMEM);
+	}
+	return lmap;
+}
+
+static void ldt_set_entry(struct ldt_struct *ldt, struct desc_struct *ldtdesc,
+			  unsigned int offs)
+{
+	unsigned int dstidx;
+
+	offs *= LDT_ENTRY_SIZE;
+	dstidx = offs / PAGE_SIZE;
+	offs %= PAGE_SIZE;
+	memcpy(page_address(ldt->pages[dstidx]) + offs, ldtdesc,
+	       sizeof(*ldtdesc));
+}
+
+static void ldt_clone_entries(struct ldt_struct *dst, struct ldt_struct *src,
+			      unsigned int nent)
+{
+	unsigned long tocopy;
+	unsigned int i;
+
+	for (i = 0, tocopy = nent * LDT_ENTRY_SIZE; tocopy; i++) {
+		unsigned long n = min(PAGE_SIZE, tocopy);
+
+		memcpy(page_address(dst->pages[i]),
+		       page_address(src->pages[i]), n);
+		tocopy -= n;
+	}
+}
+
+static void cleanup_ldt_struct(struct ldt_struct *ldt)
+{
+	static struct desc_struct zero_desc;
+	unsigned int i;
+
+	if (!ldt)
+		return;
+	paravirt_free_ldt(ldt->entries, ldt->nr_entries);
+	for (i = 0; i < ldt->nr_entries; i++)
+		ldt_set_entry(ldt, &zero_desc, i);
+	ldt->nr_entries = 0;
+}
+
 /* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
 static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 {
@@ -139,8 +235,17 @@ static void free_ldt_struct(struct ldt_s
  */
 void destroy_context_ldt(struct mm_struct *mm)
 {
-	free_ldt_struct(mm->context.ldt);
+	struct ldt_mapping *lmap = mm->context.ldt_mapping;
+	struct ldt_struct *ldt = mm->context.ldt;
+
+	free_ldt_struct(ldt);
 	mm->context.ldt = NULL;
+
+	if (!lmap)
+		return;
+
+	mm->context.ldt_mapping = NULL;
+	ldt_free_lmap(lmap);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
