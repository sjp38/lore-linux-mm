Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA28200
	for <linux-mm@kvack.org>; Sat, 6 Feb 1999 12:04:37 -0500
Date: Sat, 6 Feb 1999 17:24:30 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] kpiod fixes and improvements
Message-ID: <Pine.LNX.3.96.990206165047.209A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stephen.

I applyed 2.2.2-pre2 and I seen your kpiod. I tried it and it was working
bad (as anticipated by your email ;).

The main problem is that you forget to set PF_MEMALLOC in kpiod, so it was
recursing and was making pio request to itself and was stalling completly
in try_to_free_pages and shrink_mmap(). At least that was happening with
my VM (never tried clean 2.2.2-pre2, but it should make no differences).

Fixed this bug kpiod was working rasonable well but the number of pio
request had too high numbers.

So I've changed make_pio_request() to do a schedule_yield() to allow kpiod
to run in the meantime. This doesn't assure that the pio request queue 
gets too big, but it's a good and safe barrier to avoid too high
peaks.

Now if I lauch a proggy like this:

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

/* file size, should be half of the size of the physical memory  */
#define FILESIZE (160 * 1024 * 1024)

int main(void)
{
	char *ptr;
	int fd, i;
	char c = 'A';
	pid_t pid;

	if ((fd = open("foo", O_RDWR | O_CREAT | O_EXCL, 0666)) == -1) {
		perror("open");
		exit(1);
	}
	lseek(fd, FILESIZE - 1, SEEK_SET);
	/* write one byte to extend the file */
	write(fd, &fd, 1);
	ptr = mmap(0, FILESIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (ptr == NULL) {
		perror("mmap");
		exit(1);
	}

	for (;;)
	{
		for (i = 0; i < FILESIZE; i += 4096)
			ptr[i] = c;
		/* dirty every page in the mapping */
		msync(ptr, FILESIZE, MS_SYNC);
	}
}

the HD continue to work all the time and the system is still enough
responsive. Without my patch once I started the proggy above I get
everything stalled completly (with a very little I/O) until I killed the
proggy.

Here my changes against pre-2.2.2-2, you'll have some offset error but
no rejectes:

Index: arch/i386/mm/init.c
===================================================================
RCS file: /var/cvs/linux/arch/i386/mm/init.c,v
retrieving revision 1.1.2.2
diff -u -r1.1.2.2 init.c
--- init.c	1999/01/26 19:03:54	1.1.2.2
+++ linux/arch/i386/mm/init.c	1999/02/06 14:57:03
@@ -175,6 +175,7 @@
 #ifdef CONFIG_NET
 	show_net_buffers();
 #endif
+	show_pio_request();
 }
 
 extern unsigned long free_area_init(unsigned long, unsigned long);
Index: drivers/scsi/scsi_error.c
===================================================================
RCS file: /var/cvs/linux/drivers/scsi/scsi_error.c,v
retrieving revision 1.1.2.2
diff -u -r1.1.2.2 scsi_error.c
--- scsi_error.c	1999/02/04 14:50:38	1.1.2.2
+++ linux/drivers/scsi/scsi_error.c	1999/02/06 14:31:21
@@ -1972,7 +1972,6 @@
 	     */
             SCSI_LOG_ERROR_RECOVERY(1,printk("Error handler sleeping\n"));
 	    down_interruptible (&sem);
-	    sem.owner = 0;
 
 	    if (signal_pending(current) )
 	      break;
Index: include/asm-i386/semaphore.h
===================================================================
RCS file: /var/cvs/linux/include/asm-i386/semaphore.h,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 semaphore.h
--- semaphore.h	1999/01/18 13:39:43	1.1.1.2
+++ linux/include/asm-i386/semaphore.h	1999/02/06 14:24:25
@@ -23,49 +23,14 @@
 #include <asm/atomic.h>
 #include <asm/spinlock.h>
 
-/*
- * Semaphores are recursive: we allow the holder process
- * to recursively do down() operations on a semaphore that
- * the process already owns. In order to do that, we need
- * to keep a semaphore-local copy of the owner and the
- * "depth of ownership".
- *
- * NOTE! Nasty memory ordering rules:
- *  - "owner" and "owner_count" may only be modified once you hold the
- *    lock. 
- *  - "owner_count" must be written _after_ modifying owner, and
- *    must be read _before_ reading owner. There must be appropriate
- *    write and read barriers to enforce this.
- *
- * On an x86, writes are always ordered, so the only enformcement
- * necessary is to make sure that the owner_depth is written after
- * the owner value in program order.
- *
- * For read ordering guarantees, the semaphore wake_lock spinlock
- * is already giving us ordering guarantees.
- *
- * Other (saner) architectures would use "wmb()" and "rmb()" to
- * do this in a more obvious manner.
- */
 struct semaphore {
 	atomic_t count;
-	unsigned long owner, owner_depth;
 	int waking;
 	struct wait_queue * wait;
 };
-
-/*
- * Because we want the non-contention case to be
- * fast, we save the stack pointer into the "owner"
- * field, and to get the true task pointer we have
- * to do the bit masking. That moves the masking
- * operation into the slow path.
- */
-#define semaphore_owner(sem) \
-	((struct task_struct *)((2*PAGE_MASK) & (sem)->owner))
 
-#define MUTEX ((struct semaphore) { ATOMIC_INIT(1), 0, 0, 0, NULL })
-#define MUTEX_LOCKED ((struct semaphore) { ATOMIC_INIT(0), 0, 1, 0, NULL })
+#define MUTEX ((struct semaphore) { ATOMIC_INIT(1), 0, NULL })
+#define MUTEX_LOCKED ((struct semaphore) { ATOMIC_INIT(0), 0, NULL })
 
 asmlinkage void __down_failed(void /* special register calling convention */);
 asmlinkage int  __down_failed_interruptible(void  /* params in registers */);
@@ -94,53 +59,13 @@
 	spin_unlock_irqrestore(&semaphore_wake_lock, flags);
 }
 
-/*
- * NOTE NOTE NOTE!
- *
- * We read owner-count _before_ getting the semaphore. This
- * is important, because the semaphore also acts as a memory
- * ordering point between reading owner_depth and reading
- * the owner.
- *
- * Why is this necessary? The "owner_depth" essentially protects
- * us from using stale owner information - in the case that this
- * process was the previous owner but somebody else is racing to
- * aquire the semaphore, the only way we can see ourselves as an
- * owner is with "owner_depth" of zero (so that we know to avoid
- * the stale value).
- *
- * In the non-race case (where we really _are_ the owner), there
- * is not going to be any question about what owner_depth is.
- *
- * In the race case, the race winner will not even get here, because
- * it will have successfully gotten the semaphore with the locked
- * decrement operation.
- *
- * Basically, we have two values, and we cannot guarantee that either
- * is really up-to-date until we have aquired the semaphore. But we
- * _can_ depend on a ordering between the two values, so we can use
- * one of them to determine whether we can trust the other:
- *
- * Cases:
- *  - owner_depth == zero: ignore the semaphore owner, because it
- *    cannot possibly be us. Somebody else may be in the process
- *    of modifying it and the zero may be "stale", but it sure isn't
- *    going to say that "we" are the owner anyway, so who cares?
- *  - owner_depth is non-zero. That means that even if somebody
- *    else wrote the non-zero count value, the write ordering requriement
- *    means that they will have written themselves as the owner, so
- *    if we now see ourselves as an owner we can trust it to be true.
- */
-static inline int waking_non_zero(struct semaphore *sem, struct task_struct *tsk)
+static inline int waking_non_zero(struct semaphore *sem)
 {
 	unsigned long flags;
-	unsigned long owner_depth = sem->owner_depth;
 	int ret = 0;
 
 	spin_lock_irqsave(&semaphore_wake_lock, flags);
-	if (sem->waking > 0 || (owner_depth && semaphore_owner(sem) == tsk)) {
-		sem->owner = (unsigned long) tsk;
-		sem->owner_depth++;	/* Don't use the possibly stale value */
+	if (sem->waking > 0) {
 		sem->waking--;
 		ret = 1;
 	}
@@ -161,9 +86,7 @@
 		"lock ; "
 #endif
 		"decl 0(%0)\n\t"
-		"js 2f\n\t"
-		"movl %%esp,4(%0)\n"
-		"movl $1,8(%0)\n\t"
+		"js 2f\n"
 		"1:\n"
 		".section .text.lock,\"ax\"\n"
 		"2:\tpushl $1b\n\t"
@@ -185,8 +108,6 @@
 #endif
 		"decl 0(%1)\n\t"
 		"js 2f\n\t"
-		"movl %%esp,4(%1)\n\t"
-		"movl $1,8(%1)\n\t"
 		"xorl %0,%0\n"
 		"1:\n"
 		".section .text.lock,\"ax\"\n"
@@ -210,7 +131,6 @@
 {
 	__asm__ __volatile__(
 		"# atomic up operation\n\t"
-		"decl 8(%0)\n\t"
 #ifdef __SMP__
 		"lock ; "
 #endif
Index: include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.2.9
diff -u -r1.1.2.9 mm.h
--- mm.h	1999/01/29 14:22:35	1.1.2.9
+++ linux/include/linux/mm.h	1999/02/06 15:34:39
@@ -12,6 +12,7 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
+extern int max_pio_request;
 
 #include <asm/page.h>
 #include <asm/atomic.h>
@@ -306,6 +307,7 @@
 extern void truncate_inode_pages(struct inode *, unsigned long);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
+extern void show_pio_request(void);
 
 /*
  * GFP bitmasks..
Index: include/linux/sysctl.h
===================================================================
RCS file: /var/cvs/linux/include/linux/sysctl.h,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 sysctl.h
--- sysctl.h	1999/01/18 01:33:05	1.1.2.1
+++ linux/include/linux/sysctl.h	1999/02/06 15:08:59
@@ -112,7 +112,8 @@
 	VM_PAGECACHE=7,		/* struct: Set cache memory thresholds */
 	VM_PAGERDAEMON=8,	/* struct: Control kswapd behaviour */
 	VM_PGT_CACHE=9,		/* struct: Set page table cache parameters */
-	VM_PAGE_CLUSTER=10	/* int: set number of pages to swap together */
+	VM_PAGE_CLUSTER=10,	/* int: set number of pages to swap together */
+	VM_PIO_REQUEST=11	/* int: limit of kpiod request */
 };
 
 
Index: kernel/sched.c
===================================================================
RCS file: /var/cvs/linux/kernel/sched.c,v
retrieving revision 1.1.2.10
diff -u -r1.1.2.10 sched.c
--- sched.c	1999/02/06 13:36:49	1.1.2.10
+++ linux/kernel/sched.c	1999/02/06 14:23:59
@@ -888,7 +888,7 @@
 	 * who gets to gate through and who has to wait some more.	 \
 	 */								 \
 	for (;;) {							 \
-		if (waking_non_zero(sem, tsk))	/* are we waking up?  */ \
+		if (waking_non_zero(sem))	/* are we waking up?  */ \
 			break;			/* yes, exit loop */
 
 #define DOWN_TAIL(task_state)			\
Index: kernel/sysctl.c
===================================================================
RCS file: /var/cvs/linux/kernel/sysctl.c,v
retrieving revision 1.1.2.2
diff -u -r1.1.2.2 sysctl.c
--- sysctl.c	1999/01/24 02:46:31	1.1.2.2
+++ linux/kernel/sysctl.c	1999/02/06 15:06:59
@@ -229,6 +229,8 @@
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
 	{VM_PAGE_CLUSTER, "page-cluster", 
 	 &page_cluster, sizeof(int), 0600, NULL, &proc_dointvec},
+	{VM_PIO_REQUEST, "max-pio-request", 
+	 &max_pio_request, sizeof(int), 0600, NULL, &proc_dointvec},
 	{0}
 };
 
Index: mm/filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.2.14
diff -u -r1.1.2.14 filemap.c
--- filemap.c	1999/02/06 13:36:49	1.1.2.14
+++ linux/mm/filemap.c	1999/02/06 15:44:21
@@ -59,6 +59,8 @@
 static struct pio_request *pio_first = NULL, **pio_last = &pio_first;
 static kmem_cache_t *pio_request_cache;
 static struct wait_queue *pio_wait = NULL;
+static int nr_pio_request = 0;
+int max_pio_request = 500;
 
 static inline void 
 make_pio_request(struct file *, unsigned long, unsigned long);
@@ -1682,6 +1684,7 @@
 	pio_first = p->next;
 	if (!pio_first)
 		pio_last = &pio_first;
+	nr_pio_request--;
 	return p;
 }
 
@@ -1694,6 +1697,7 @@
 	struct pio_request *p;
 
 	atomic_inc(&mem_map[MAP_NR(page)].count);
+	nr_pio_request++;
 
 	/* 
 	 * We need to allocate without causing any recursive IO in the
@@ -1720,8 +1724,19 @@
 
 	put_pio_request(p);
 	wake_up(&pio_wait);
+
+	/* can't loop because we could hold a lock needed by kpiod -arca */
+	if (nr_pio_request > max_pio_request)
+	{
+		current->policy |= SCHED_YIELD;
+		schedule();
+	}
 }
 
+void show_pio_request(void)
+{
+	printk("%d request in kpiod queue\n", nr_pio_request);
+}
 
 /*
  * This is the only thread which is allowed to write out filemap pages
@@ -1756,7 +1771,9 @@
 					      NULL, NULL);
 	if (!pio_request_cache)
 		panic ("Could not create pio_request slab cache");
-	
+
+	current->flags |= PF_MEMALLOC;
+
 	while (1) {
 		current->state = TASK_INTERRUPTIBLE;
 		add_wait_queue(&pio_wait, &wait);



Ah and I removed the recursive semaphores, because I don't need them
anymore now, and my kernel looks safer to me with them removed because I
don't have time now to check every piece of my kernel that uses a
MUTEX_LOCKED and that starts with a down() and then to think if it should
be converted to a down_norecurse().

When I'll need recursive mutex I'll only need to open semaphore.h and
sched.c of 2.2.1 and cut-and-paste them after a s/semahore/mutex/.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
