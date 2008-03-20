Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2KGOb6F167788
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 16:24:37 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2KGObta1937520
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 17:24:37 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2KGOaPC013782
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 17:24:37 +0100
Subject: [RFC/PATCH 01/15] preparation: provide hook to enable pgstes in
	user pagetable
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Thu, 20 Mar 2008 17:24:38 +0100
Message-Id: <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Linux Memory Management List <linux-mm@kvack.org>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

The SIE instruction on s390 uses the 2nd half of the page table page to
virtualize the storage keys of a guest. This patch offers the s390_enable_sie
function, which reorganizes the page tables of a single-threaded process to
reserve space in the page table:
s390_enable_sie makes sure that the process is single threaded and then uses
dup_mm to create a new mm with reorganized page tables. The old mm is freed 
and the process has now a page status extended field after every page table.

Code that wants to exploit pgstes should SELECT CONFIG_PGSTE.

This patch has a small common code hit, namely making dup_mm non-static.


Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Carsten Otte <cotte@de.ibm.com>
---

 arch/s390/Kconfig              |    4 ++
 arch/s390/kernel/setup.c       |    4 ++
 arch/s390/mm/pgtable.c         |   55 ++++++++++++++++++++++++++++++++++++++---
 include/asm-s390/mmu.h         |    1 
 include/asm-s390/mmu_context.h |    8 +++++
 include/asm-s390/pgtable.h     |    1 
 kernel/fork.c                  |    2 -
 7 files changed, 70 insertions(+), 5 deletions(-)

Index: kvm/arch/s390/Kconfig
===================================================================
--- kvm.orig/arch/s390/Kconfig
+++ kvm/arch/s390/Kconfig
@@ -55,6 +55,10 @@ config GENERIC_LOCKBREAK
 	default y
 	depends on SMP && PREEMPT
 
+config PGSTE
+	bool
+	default y if KVM
+
 mainmenu "Linux Kernel Configuration"
 
 config S390
Index: kvm/arch/s390/kernel/setup.c
===================================================================
--- kvm.orig/arch/s390/kernel/setup.c
+++ kvm/arch/s390/kernel/setup.c
@@ -315,7 +315,11 @@ static int __init early_parse_ipldelay(c
 early_param("ipldelay", early_parse_ipldelay);
 
 #ifdef CONFIG_S390_SWITCH_AMODE
+#ifdef CONFIG_PGSTE
+unsigned int switch_amode = 1;
+#else
 unsigned int switch_amode = 0;
+#endif
 EXPORT_SYMBOL_GPL(switch_amode);
 
 static void set_amode_and_uaccess(unsigned long user_amode,
Index: kvm/arch/s390/mm/pgtable.c
===================================================================
--- kvm.orig/arch/s390/mm/pgtable.c
+++ kvm/arch/s390/mm/pgtable.c
@@ -30,11 +30,27 @@
 #define TABLES_PER_PAGE	4
 #define FRAG_MASK	15UL
 #define SECOND_HALVES	10UL
+
+void clear_table_pgstes(unsigned long *table)
+{
+	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE/4);
+	memset(table + 256, 0, PAGE_SIZE/4);
+	clear_table(table + 512, _PAGE_TYPE_EMPTY, PAGE_SIZE/4);
+	memset(table + 768, 0, PAGE_SIZE/4);
+}
+
 #else
 #define ALLOC_ORDER	2
 #define TABLES_PER_PAGE	2
 #define FRAG_MASK	3UL
 #define SECOND_HALVES	2UL
+
+void clear_table_pgstes(unsigned long *table)
+{
+	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE/2);
+	memset(table + 256, 0, PAGE_SIZE/2);
+}
+
 #endif
 
 unsigned long *crst_table_alloc(struct mm_struct *mm, int noexec)
@@ -153,7 +169,7 @@ unsigned long *page_table_alloc(struct m
 	unsigned long *table;
 	unsigned long bits;
 
-	bits = mm->context.noexec ? 3UL : 1UL;
+	bits = (mm->context.noexec || mm->context.pgstes) ? 3UL : 1UL;
 	spin_lock(&mm->page_table_lock);
 	page = NULL;
 	if (!list_empty(&mm->context.pgtable_list)) {
@@ -170,7 +186,10 @@ unsigned long *page_table_alloc(struct m
 		pgtable_page_ctor(page);
 		page->flags &= ~FRAG_MASK;
 		table = (unsigned long *) page_to_phys(page);
-		clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
+		if (mm->context.pgstes)
+			clear_table_pgstes(table);
+		else
+			clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
 		spin_lock(&mm->page_table_lock);
 		list_add(&page->lru, &mm->context.pgtable_list);
 	}
@@ -191,7 +210,7 @@ void page_table_free(struct mm_struct *m
 	struct page *page;
 	unsigned long bits;
 
-	bits = mm->context.noexec ? 3UL : 1UL;
+	bits = (mm->context.noexec || mm->context.pgstes) ? 3UL : 1UL;
 	bits <<= (__pa(table) & (PAGE_SIZE - 1)) / 256 / sizeof(unsigned long);
 	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
 	spin_lock(&mm->page_table_lock);
@@ -228,3 +247,33 @@ void disable_noexec(struct mm_struct *mm
 	mm->context.noexec = 0;
 	update_mm(mm, tsk);
 }
+
+struct mm_struct *dup_mm(struct task_struct *tsk);
+
+/*
+ * switch on pgstes for its userspace process (for kvm)
+ */
+int s390_enable_sie(void)
+{
+	struct task_struct *tsk = current;
+	struct mm_struct *mm;
+
+	if (tsk->mm->context.pgstes)
+		return 0;
+	if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||
+	    tsk->mm != tsk->active_mm || tsk->mm->ioctx_list)
+		return -EINVAL;
+	tsk->mm->context.pgstes = 1;	/* dirty little tricks .. */
+	mm = dup_mm(tsk);
+	tsk->mm->context.pgstes = 0;
+	if (!mm)
+		return -ENOMEM;
+	mmput(tsk->mm);
+	tsk->mm = tsk->active_mm = mm;
+	preempt_disable();
+	update_mm(mm, tsk);
+	cpu_set(smp_processor_id(), mm->cpu_vm_mask);
+	preempt_enable();
+	return 0;
+}
+EXPORT_SYMBOL_GPL(s390_enable_sie);
Index: kvm/include/asm-s390/mmu.h
===================================================================
--- kvm.orig/include/asm-s390/mmu.h
+++ kvm/include/asm-s390/mmu.h
@@ -7,6 +7,7 @@ typedef struct {
 	unsigned long asce_bits;
 	unsigned long asce_limit;
 	int noexec;
+	int pgstes;
 } mm_context_t;
 
 #endif
Index: kvm/include/asm-s390/mmu_context.h
===================================================================
--- kvm.orig/include/asm-s390/mmu_context.h
+++ kvm/include/asm-s390/mmu_context.h
@@ -20,7 +20,13 @@ static inline int init_new_context(struc
 #ifdef CONFIG_64BIT
 	mm->context.asce_bits |= _ASCE_TYPE_REGION3;
 #endif
-	mm->context.noexec = s390_noexec;
+	if (current->mm->context.pgstes) {
+		mm->context.noexec = 0;
+		mm->context.pgstes = 1;
+	} else {
+		mm->context.noexec = s390_noexec;
+		mm->context.pgstes = 0;
+	}
 	mm->context.asce_limit = STACK_TOP_MAX;
 	crst_table_init((unsigned long *) mm->pgd, pgd_entry_type(mm));
 	return 0;
Index: kvm/include/asm-s390/pgtable.h
===================================================================
--- kvm.orig/include/asm-s390/pgtable.h
+++ kvm/include/asm-s390/pgtable.h
@@ -966,6 +966,7 @@ static inline pte_t mk_swap_pte(unsigned
 
 extern int add_shared_memory(unsigned long start, unsigned long size);
 extern int remove_shared_memory(unsigned long start, unsigned long size);
+extern int s390_enable_sie(void);
 
 /*
  * No page table caches to initialise
Index: kvm/kernel/fork.c
===================================================================
--- kvm.orig/kernel/fork.c
+++ kvm/kernel/fork.c
@@ -498,7 +498,7 @@ void mm_release(struct task_struct *tsk,
  * Allocate a new mm structure and copy contents from the
  * mm structure of the passed in task structure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+struct mm_struct *dup_mm(struct task_struct *tsk)
 {
 	struct mm_struct *mm, *oldmm = current->mm;
 	int err;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
