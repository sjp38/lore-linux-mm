Subject: Re: [kvm-devel] [RFC/PATCH 01/15] preparation: provide hook to
	enable pgstes	in	user pagetable
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1206124176.30471.27.camel@nimitz.home.sr71.net>
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>
	 <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
	 <47E29EC6.5050403@goop.org> <1206040405.8232.24.camel@nimitz.home.sr71.net>
	 <47E2CAAC.6020903@de.ibm.com>
	 <1206124176.30471.27.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Tue, 25 Mar 2008 16:37:39 +0100
Message-Id: <1206459459.6217.34.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: carsteno@de.ibm.com, Jeremy Fitzhardinge <jeremy@goop.org>, Christian Ehrhardt <EHRHARDT@de.ibm.com>, hollisb@us.ibm.com, arnd@arndb.de, borntrae@linux.vnet.ibm.com, kvm-devel@lists.sourceforge.net, heicars2@linux.vnet.ibm.com, jeroney@us.ibm.com, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, rvdheij@gmail.com, Olaf Schnapper <os@de.ibm.com>, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

Am Freitag, den 21.03.2008, 11:29 -0700 schrieb Dave Hansen:
> What you've done with dup_mm() is probably the brute-force way that I
> would have done it had I just been trying to make a proof of concept or
> something.  I'm worried that there are a bunch of corner cases that
> haven't been considered.
> 
> What if someone else is poking around with ptrace or something similar
> and they bump the mm_users:
> 
> +       if (tsk->mm->context.pgstes)
> +               return 0;
> +       if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||
> +           tsk->mm != tsk->active_mm || tsk->mm->ioctx_list)
> +               return -EINVAL;
> -------->HERE
> +       tsk->mm->context.pgstes = 1;    /* dirty little tricks .. */
> +       mm = dup_mm(tsk);
> 
> It'll race, possibly fault in some other pages, and those faults will be
> lost during the dup_mm().  I think you need to be able to lock out all
> of the users of access_process_vm() before you go and do this.  You also
> need to make sure that anyone who has looked at task->mm doesn't go and
> get a reference to it and get confused later when it isn't the task->mm
> any more.

Good catch, Dave. We intend to get rid of that race via task_lock().
That should lock out ptrace and all others who modify mm_users via get_task_mm.


See patch below:
---

 arch/s390/Kconfig              |    4 ++
 arch/s390/kernel/setup.c       |    4 ++
 arch/s390/mm/pgtable.c         |   65 +++++++++++++++++++++++++++++++++++++++--
 include/asm-s390/mmu.h         |    1 
 include/asm-s390/mmu_context.h |    8 ++++-
 include/asm-s390/pgtable.h     |    1 
 include/linux/sched.h          |    2 +
 kernel/fork.c                  |    2 -
 8 files changed, 82 insertions(+), 5 deletions(-)

Index: linux-host/arch/s390/Kconfig
===================================================================
--- linux-host.orig/arch/s390/Kconfig
+++ linux-host/arch/s390/Kconfig
@@ -55,6 +55,10 @@ config GENERIC_LOCKBREAK
 	default y
 	depends on SMP && PREEMPT
 
+config PGSTE
+	bool
+	default y if KVM
+
 mainmenu "Linux Kernel Configuration"
 
 config S390
Index: linux-host/arch/s390/kernel/setup.c
===================================================================
--- linux-host.orig/arch/s390/kernel/setup.c
+++ linux-host/arch/s390/kernel/setup.c
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
Index: linux-host/arch/s390/mm/pgtable.c
===================================================================
--- linux-host.orig/arch/s390/mm/pgtable.c
+++ linux-host/arch/s390/mm/pgtable.c
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
@@ -228,3 +247,43 @@ void disable_noexec(struct mm_struct *mm
 	mm->context.noexec = 0;
 	update_mm(mm, tsk);
 }
+
+/*
+ * switch on pgstes for its userspace process (for kvm)
+ */
+int s390_enable_sie(void)
+{
+	struct task_struct *tsk = current;
+	struct mm_struct *mm;
+	int rc;
+
+	task_lock(tsk);
+
+	rc = 0;
+	if (tsk->mm->context.pgstes)
+		goto unlock;
+
+	rc = -EINVAL;
+	if (!tsk->mm || atomic_read(&tsk->mm->mm_users) > 1 ||
+	    tsk->mm != tsk->active_mm || tsk->mm->ioctx_list)
+		goto unlock;
+
+	tsk->mm->context.pgstes = 1;	/* dirty little tricks .. */
+	mm = dup_mm(tsk);
+	tsk->mm->context.pgstes = 0;
+
+	rc = -ENOMEM;
+	if (!mm)
+		goto unlock;
+	mmput(tsk->mm);
+	tsk->mm = tsk->active_mm = mm;
+	preempt_disable();
+	update_mm(mm, tsk);
+	cpu_set(smp_processor_id(), mm->cpu_vm_mask);
+	preempt_enable();
+	rc = 0;
+unlock:
+	task_unlock(tsk);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(s390_enable_sie);
Index: linux-host/include/asm-s390/mmu.h
===================================================================
--- linux-host.orig/include/asm-s390/mmu.h
+++ linux-host/include/asm-s390/mmu.h
@@ -7,6 +7,7 @@ typedef struct {
 	unsigned long asce_bits;
 	unsigned long asce_limit;
 	int noexec;
+	int pgstes;
 } mm_context_t;
 
 #endif
Index: linux-host/include/asm-s390/mmu_context.h
===================================================================
--- linux-host.orig/include/asm-s390/mmu_context.h
+++ linux-host/include/asm-s390/mmu_context.h
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
Index: linux-host/include/asm-s390/pgtable.h
===================================================================
--- linux-host.orig/include/asm-s390/pgtable.h
+++ linux-host/include/asm-s390/pgtable.h
@@ -966,6 +966,7 @@ static inline pte_t mk_swap_pte(unsigned
 
 extern int add_shared_memory(unsigned long start, unsigned long size);
 extern int remove_shared_memory(unsigned long start, unsigned long size);
+extern int s390_enable_sie(void);
 
 /*
  * No page table caches to initialise
Index: linux-host/kernel/fork.c
===================================================================
--- linux-host.orig/kernel/fork.c
+++ linux-host/kernel/fork.c
@@ -498,7 +498,7 @@ void mm_release(struct task_struct *tsk,
  * Allocate a new mm structure and copy contents from the
  * mm structure of the passed in task structure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+struct mm_struct *dup_mm(struct task_struct *tsk)
 {
 	struct mm_struct *mm, *oldmm = current->mm;
 	int err;
Index: linux-host/include/linux/sched.h
===================================================================
--- linux-host.orig/include/linux/sched.h
+++ linux-host/include/linux/sched.h
@@ -1758,6 +1758,8 @@ extern void mmput(struct mm_struct *);
 extern struct mm_struct *get_task_mm(struct task_struct *task);
 /* Remove the current tasks stale references to the old mm_struct */
 extern void mm_release(struct task_struct *, struct mm_struct *);
+/* Allocate a new mm structure and copy contents from tsk->mm */
+extern struct mm_struct *dup_mm(struct task_struct *tsk);
 
 extern int  copy_thread(int, unsigned long, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
 extern void flush_thread(void);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
