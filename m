Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA00839
	for <linux-mm@kvack.org>; Wed, 27 Jan 1999 21:51:29 -0500
Date: Thu, 28 Jan 1999 03:50:39 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
In-Reply-To: <Pine.LNX.3.96.990128001800.399A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.cobaltmicro.com>, gandalf@szene.ch, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.com, djf-lists@ic.net, tomh@taz.ccs.fau.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Do you want to know why last night I added a spinlock around mmget/mmput
without thinking twice?  Simply because mm->count was an atomic_t while it
doesn't need to be an atomic_t in first place.

Obviously if it mm->count need to be an atomic_t, we strictly _need_ also
my new mm_lock spinlock in 2.2.1.

So you don't buy my code, but now, I don't buy both all /proc mmget/mmput
sutff and the mm->count atomic_t.

I also avoided all the mmget/mmput stuff in /proc since it _has_ to run
just serialized by the mmget/mmput semaphore (otherwise we need
my mm_lock).

I also removed the semaphore stuff because it seems to me (and to you btw
;) that _all_ places in the mm that does a down(current->mm->mmap_sem),
does always then a lock_kernel().

I also removed all the memcpy, we only need the read_lock(tasklist_lock)
held in SMP because otherwise wait4() could remove the stack of the
process under our eyes as just pointed out in the last email.

Not doing in 2.2.1 the mm->count s/atomic_t/int/ due worry of races will
mean that array.c in 2.2.1 will be not safe enough without my mm_lock
spinlock. Do you understand my point?

I rediffed everything against clean 2.2.0, and I am now running it without
any problem, seems rock solid from a /proc race point of view.

Index: arch/i386/kernel/ldt.c
===================================================================
RCS file: /var/cvs/linux/arch/i386/kernel/ldt.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 ldt.c
--- ldt.c	1999/01/18 01:28:57	1.1.1.1
+++ ldt.c	1999/01/27 20:09:21
@@ -83,7 +83,7 @@
 			set_ldt_desc(i, ldt, LDT_ENTRIES);
 			current->tss.ldt = _LDT(i);
 			load_ldt(i);
-			if (atomic_read(&mm->count) > 1)
+			if (mm->count > 1)
 				printk(KERN_WARNING
 					"LDT allocated for cloned task!\n");
 		} else {
Index: fs/binfmt_aout.c
===================================================================
RCS file: /var/cvs/linux/fs/binfmt_aout.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 binfmt_aout.c
--- binfmt_aout.c	1999/01/18 01:26:49	1.1.1.1
+++ binfmt_aout.c	1999/01/27 20:09:21
@@ -101,7 +101,7 @@
 #       define START_STACK(u)   (u.start_stack)
 #endif
 
-	if (!current->dumpable || atomic_read(&current->mm->count) != 1)
+	if (!current->dumpable || current->mm->count != 1)
 		return 0;
 	current->dumpable = 0;
 
Index: fs/binfmt_elf.c
===================================================================
RCS file: /var/cvs/linux/fs/binfmt_elf.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 binfmt_elf.c
--- binfmt_elf.c	1999/01/18 01:26:49	1.1.1.1
+++ binfmt_elf.c	1999/01/27 20:09:21
@@ -1067,7 +1067,7 @@
 
 	if (!current->dumpable ||
 	    limit < ELF_EXEC_PAGESIZE ||
-	    atomic_read(&current->mm->count) != 1)
+	    current->mm->count != 1)
 		return 0;
 	current->dumpable = 0;
 
Index: fs/exec.c
===================================================================
RCS file: /var/cvs/linux/fs/exec.c,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 exec.c
--- exec.c	1999/01/23 16:28:07	1.1.1.2
+++ exec.c	1999/01/28 01:47:52
@@ -378,7 +378,7 @@
 	struct mm_struct * mm, * old_mm;
 	int retval, nr;
 
-	if (atomic_read(&current->mm->count) == 1) {
+	if (current->mm->count == 1) {
 		flush_cache_mm(current->mm);
 		mm_release();
 		release_segments(current->mm);
Index: fs/proc/array.c
===================================================================
RCS file: /var/cvs/linux/fs/proc/array.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 array.c
--- array.c	1999/01/26 18:30:44	1.1.1.4
+++ array.c	1999/01/28 02:32:48
@@ -388,31 +388,6 @@
 	return sprintf(buffer, "%s\n", saved_command_line);
 }
 
-/*
- * Caller must release_mm the mm_struct later.
- * You don't get any access to init_mm.
- */
-static struct mm_struct *get_mm_and_lock(int pid)
-{
-	struct mm_struct *mm = NULL;
-	struct task_struct *tsk;
-
-	read_lock(&tasklist_lock);
-	tsk = find_task_by_pid(pid);
-	if (tsk && tsk->mm && tsk->mm != &init_mm)
-		mmget(mm = tsk->mm);
-	read_unlock(&tasklist_lock);
-	if (mm != NULL)
-		down(&mm->mmap_sem);
-	return mm;
-}
-
-static void release_mm(struct mm_struct *mm)
-{
-	up(&mm->mmap_sem);
-	mmput(mm);
-}
-
 static unsigned long get_phys_addr(struct mm_struct *mm, unsigned long ptr)
 {
 	pgd_t *page_dir;
@@ -480,27 +455,35 @@
 
 static int get_env(int pid, char * buffer)
 {
-	struct mm_struct *mm;
+	struct task_struct * tsk;
 	int res = 0;
 
-	mm = get_mm_and_lock(pid);
-	if (mm) {
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
+	if (tsk)
+	{
+		struct mm_struct * mm = tsk->mm;
 		res = get_array(mm, mm->env_start, mm->env_end, buffer);
-		release_mm(mm);
 	}
+	read_unlock(&tasklist_lock);
+
 	return res;
 }
 
 static int get_arg(int pid, char * buffer)
 {
-	struct mm_struct *mm;
+	struct task_struct * tsk;
 	int res = 0;
 
-	mm = get_mm_and_lock(pid);
-	if (mm) {
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
+	if (tsk)
+	{
+		struct mm_struct * mm = tsk->mm;
 		res = get_array(mm, mm->arg_start, mm->arg_end, buffer);
-		release_mm(mm);
 	}
+	read_unlock(&tasklist_lock);
+
 	return res;
 }
 
@@ -849,39 +832,22 @@
 			    cap_t(p->cap_effective));
 }
 
-static struct task_struct *grab_task(int pid)
-{
-	struct task_struct *tsk = current;
-	if (pid != tsk->pid) {
-		read_lock(&tasklist_lock);
-		tsk = find_task_by_pid(pid);
-		if (tsk && tsk->mm && tsk->mm != &init_mm)
-			mmget(tsk->mm);
-		read_unlock(&tasklist_lock);
-	}	
-	return tsk;
-}
-
-static void release_task(struct task_struct *tsk)
-{
-	if (tsk != current && tsk->mm && tsk->mm != &init_mm)
-		mmput(tsk->mm);
-}
-
 static int get_status(int pid, char * buffer)
 {
 	char * orig = buffer;
-	struct task_struct *tsk;
+	struct task_struct * tsk;
 	
-	tsk = grab_task(pid);
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
 	if (!tsk)
-		return 0;
+		goto unlock;
 	buffer = task_name(tsk, buffer);
 	buffer = task_state(tsk, buffer);
 	buffer = task_mem(tsk, buffer);
 	buffer = task_sig(tsk, buffer);
 	buffer = task_cap(tsk, buffer);
-	release_task(tsk);
+ unlock:
+	read_unlock(&tasklist_lock);
 	return buffer - orig;
 }
 
@@ -893,21 +859,20 @@
 	int tty_pgrp;
 	sigset_t sigign, sigcatch;
 	char state;
-	int res;
+	int res = 0;
 
-	tsk = grab_task(pid);
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
 	if (!tsk)
-		return 0;
+		goto unlock;
 	state = *get_task_state(tsk);
 	vsize = eip = esp = 0;
 	if (tsk->mm && tsk->mm != &init_mm) {
 		struct vm_area_struct *vma;
 
-		down(&tsk->mm->mmap_sem);
 		for (vma = tsk->mm->mmap; vma; vma = vma->vm_next) {
 			vsize += vma->vm_end - vma->vm_start;
 		}
-		up(&tsk->mm->mmap_sem);
 		
 		eip = KSTK_EIP(tsk);
 		esp = KSTK_ESP(tsk);
@@ -975,7 +940,8 @@
 		tsk->cnswap,
 		tsk->exit_signal);
 
-	release_task(tsk);
+ unlock:
+	read_unlock(&tasklist_lock);
 	return res;
 }
 		
@@ -1054,11 +1020,14 @@
 
 static int get_statm(int pid, char * buffer)
 {
+	struct task_struct * tsk;
 	int size=0, resident=0, share=0, trs=0, lrs=0, drs=0, dt=0;
-	struct mm_struct *mm;
 
-	mm = get_mm_and_lock(pid);
-	if (mm) {
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
+	if (tsk)
+	{
+		struct mm_struct * mm = tsk->mm;
 		struct vm_area_struct * vma = mm->mmap;
 
 		while (vma) {
@@ -1080,8 +1049,8 @@
 				drs += pages;
 			vma = vma->vm_next;
 		}
-		release_mm(mm);
 	}
+	read_unlock(&tasklist_lock);
 	return sprintf(buffer,"%d %d %d %d %d %d %d\n",
 		       size, resident, share, trs, lrs, drs, dt);
 }
@@ -1149,7 +1118,7 @@
 		goto getlen_out;
 
 	/* Check whether the mmaps could change if we sleep */
-	volatile_task = (p != current || atomic_read(&p->mm->count) > 1);
+	volatile_task = (p != current || p->mm->count > 1);
 
 	/* decode f_pos */
 	lineno = *ppos >> MAPS_LINE_SHIFT;
@@ -1251,11 +1220,12 @@
 static int get_pidcpu(int pid, char * buffer)
 {
 	struct task_struct * tsk;
-	int i, len;
+	int i, len = 0;
 
-	tsk = grab_task(pid);
+	read_lock(&tasklist_lock);
+	tsk = find_task_by_pid(pid);
 	if (!tsk)
-		return 0;
+		goto unlock;
 
 	len = sprintf(buffer,
 		"cpu  %lu %lu\n",
@@ -1267,8 +1237,9 @@
 			i,
 			tsk->per_cpu_utime[cpu_logical_map(i)],
 			tsk->per_cpu_stime[cpu_logical_map(i)]);
+ unlock:
+	read_unlock(&tasklist_lock);
 
-	release_task(tsk);
 	return len;
 }
 #endif
Index: include/asm-i386/pgtable.h
===================================================================
RCS file: /var/cvs/linux/include/asm-i386/pgtable.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 pgtable.h
--- pgtable.h	1999/01/18 01:27:15	1.1.1.1
+++ pgtable.h	1999/01/27 20:09:21
@@ -101,7 +101,7 @@
 static inline void flush_tlb_current_task(void)
 {
 	/* just one copy of this mm? */
-	if (atomic_read(&current->mm->count) == 1)
+	if (current->mm->count == 1)
 		local_flush_tlb();	/* and that's us, so.. */
 	else
 		smp_flush_tlb();
@@ -113,7 +113,7 @@
 
 static inline void flush_tlb_mm(struct mm_struct * mm)
 {
-	if (mm == current->mm && atomic_read(&mm->count) == 1)
+	if (mm == current->mm && mm->count == 1)
 		local_flush_tlb();
 	else
 		smp_flush_tlb();
@@ -122,7 +122,7 @@
 static inline void flush_tlb_page(struct vm_area_struct * vma,
 	unsigned long va)
 {
-	if (vma->vm_mm == current->mm && atomic_read(&current->mm->count) == 1)
+	if (vma->vm_mm == current->mm && current->mm->count == 1)
 		__flush_tlb_one(va);
 	else
 		smp_flush_tlb();
Index: include/linux/sched.h
===================================================================
RCS file: /var/cvs/linux/include/linux/sched.h,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 sched.h
--- sched.h	1999/01/23 16:29:58	1.1.1.3
+++ sched.h	1999/01/28 02:33:01
@@ -164,7 +164,7 @@
 	struct vm_area_struct *mmap_avl;	/* tree of VMAs */
 	struct vm_area_struct *mmap_cache;	/* last find_vma result */
 	pgd_t * pgd;
-	atomic_t count;
+	int count;
 	int map_count;				/* number of VMAs */
 	struct semaphore mmap_sem;
 	unsigned long context;
@@ -184,7 +184,7 @@
 #define INIT_MM {					\
 		&init_mmap, NULL, NULL,			\
 		swapper_pg_dir, 			\
-		ATOMIC_INIT(1), 1,			\
+		1, 1,					\
 		MUTEX,					\
 		0,					\
 		0, 0, 0, 0,				\
@@ -609,11 +609,11 @@
  * Routines for handling mm_structs
  */
 extern struct mm_struct * mm_alloc(void);
-static inline void mmget(struct mm_struct * mm)
+extern inline void mmget(struct mm_struct * mm)
 {
-	atomic_inc(&mm->count);
+	mm->count++;
 }
-extern void mmput(struct mm_struct *);
+extern void FASTCALL(mmput(struct mm_struct *));
 /* Remove the current tasks stale references to the old mm_struct */
 extern void mm_release(void);
 
Index: kernel/fork.c
===================================================================
RCS file: /var/cvs/linux/kernel/fork.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 fork.c
--- fork.c	1999/01/23 16:30:27	1.1.1.3
+++ fork.c	1999/01/28 01:52:53
@@ -261,7 +261,7 @@
 	if (mm) {
 		*mm = *current->mm;
 		init_new_context(mm);
-		atomic_set(&mm->count, 1);
+		mm->count = 1;
 		mm->map_count = 0;
 		mm->def_flags = 0;
 		mm->mmap_sem = MUTEX_LOCKED;
@@ -308,7 +308,7 @@
  */
 void mmput(struct mm_struct *mm)
 {
-	if (atomic_dec_and_test(&mm->count)) {
+	if (!--mm->count) {
 		release_segments(mm);
 		exit_mmap(mm);
 		free_page_tables(mm);


If you see a race in this my new patch, please let me know and probably
you'll give me a good reason to reinsert mm_lock ;) 

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
