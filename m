Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA4A6B03A8
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:15:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h188so15935126wma.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:15:09 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 10/13] mm: Introduce first class virtual address spaces
Date: Mon, 13 Mar 2017 15:14:12 -0700
Message-Id: <20170313221415.9375-11-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Introduce a different type of address spaces which are first class citizens
in the OS. That means that the kernel now handles two types of AS, those
which are closely coupled with a process and those which aren't. While the
former ones are created and destroyed together with the process by the
kernel and are the default type of AS in the Linux kernel, the latter ones
have to be managed explicitly by the user and are the newly introduced
type.

Accordingly, a first class AS (also called VAS == virtual address space)
can exist in the OS independently from any process. A user has to
explicitly create and destroy them in the system. Processes and VAS can be
combined by attaching a previously created VAS to a process which basically
adds an additional AS to the process that the process' threads are able to
execute in. Hence, VAS allow a process to have different views onto the
main memory of the system (its original AS and the attached VAS) between
which its threads can switch arbitrarily during their lifetime.

The functionality made available through first class virtual address spaces
can be used in various different ways. One possible way to utilize VAS is
to compartmentalize a process for security reasons. Another possible usage
is to improve the performance of data-centric applications by being able to
manage different sets of data in memory without the need to map or unmap
them.

Furthermore, first class virtual address spaces can be attached to
different processes at the same time if the underlying memory is only
readable. This mechanism allows sharing of whole address spaces between
multiple processes that can both execute in them using the contained
memory.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
---
 MAINTAINERS                            |   10 +
 arch/x86/entry/syscalls/syscall_32.tbl |    9 +
 arch/x86/entry/syscalls/syscall_64.tbl |    9 +
 fs/exec.c                              |    3 +
 include/linux/mm_types.h               |    8 +
 include/linux/sched.h                  |   17 +
 include/linux/syscalls.h               |   11 +
 include/linux/vas.h                    |  182 +++
 include/linux/vas_types.h              |   88 ++
 include/uapi/asm-generic/unistd.h      |   20 +-
 include/uapi/linux/Kbuild              |    1 +
 include/uapi/linux/vas.h               |   16 +
 init/main.c                            |    2 +
 kernel/exit.c                          |    2 +
 kernel/fork.c                          |   28 +-
 kernel/sys_ni.c                        |   11 +
 mm/Kconfig                             |   20 +
 mm/Makefile                            |    1 +
 mm/internal.h                          |    8 +
 mm/memory.c                            |    3 +
 mm/mmap.c                              |   22 +
 mm/vas.c                               | 2188 ++++++++++++++++++++++++++++++++
 22 files changed, 2657 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/vas.h
 create mode 100644 include/linux/vas_types.h
 create mode 100644 include/uapi/linux/vas.h
 create mode 100644 mm/vas.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 527d13759ecc..060b1c64e67a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5040,6 +5040,16 @@ F:	Documentation/firmware_class/
 F:	drivers/base/firmware*.c
 F:	include/linux/firmware.h
 
+FIRST CLASS VIRTUAL ADDRESS SPACES
+M:	Till Smejkal <till.smejkal@gmail.com>
+L:	linux-kernel@vger.kernel.org
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	include/linux/vas_types.h
+F:	include/linux/vas.h
+F:	include/uapi/linux/vas.h
+F:	mm/vas.c
+
 FLASH ADAPTER DRIVER (IBM Flash Adapter 900GB Full Height PCI Flash Card)
 M:	Joshua Morris <josh.h.morris@us.ibm.com>
 M:	Philip Kelleher <pjk1939@linux.vnet.ibm.com>
diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 2b3618542544..8c553eef8c44 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -389,3 +389,12 @@
 380	i386	pkey_mprotect		sys_pkey_mprotect
 381	i386	pkey_alloc		sys_pkey_alloc
 382	i386	pkey_free		sys_pkey_free
+383	i386	vas_create		sys_vas_create
+384	i386	vas_delete		sys_vas_delete
+385	i386	vas_find		sys_vas_find
+386	i386	vas_attach		sys_vas_attach
+387	i386	vas_detach		sys_vas_detach
+388	i386	vas_switch		sys_vas_switch
+389	i386	active_vas		sys_active_vas
+390	i386	vas_getattr		sys_vas_getattr
+391	i386	vas_setattr		sys_vas_setattr
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index e93ef0b38db8..72f1f0495710 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -338,6 +338,15 @@
 329	common	pkey_mprotect		sys_pkey_mprotect
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
+332	common	vas_create		sys_vas_create
+333	common	vas_delete		sys_vas_delete
+334	common	vas_find		sys_vas_find
+335	common	vas_attach		sys_vas_attach
+336	common	vas_detach		sys_vas_detach
+337	common	vas_switch		sys_vas_switch
+338	common	active_vas		sys_active_vas
+339	common	vas_getattr		sys_vas_getattr
+340	common	vas_setattr		sys_vas_setattr
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/exec.c b/fs/exec.c
index 68d7908a1e5a..e1ac0a8c76bf 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1020,6 +1020,9 @@ static int exec_mmap(struct mm_struct *mm)
 	active_mm = tsk->active_mm;
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+#ifdef CONFIG_VAS
+	tsk->original_mm = mm;
+#endif
 	activate_mm(active_mm, mm);
 	tsk->mm->vmacache_seqnum = 0;
 	vmacache_flush(tsk);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6aa03e88dcff..82bf78ea83ee 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/workqueue.h>
+#include <linux/ktime.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -358,6 +359,10 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+#ifdef CONFIG_VAS
+	struct mm_struct *vas_reference;
+	ktime_t vas_last_update;
+#endif
 };
 
 struct core_thread {
@@ -514,6 +519,9 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#ifdef CONFIG_VAS
+	ktime_t vas_last_update;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7955adc00397..216876912e77 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1508,6 +1508,18 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+/* Shared information of attached VASes between processes */
+#ifdef CONFIG_VAS
+struct vas_context {
+	spinlock_t lock;
+	u16 refcount;			// < the number of tasks using this
+					//   VAS context.
+
+	struct list_head vases;		// < the list of attached-VASes which
+					//   are handled by this VAS context.
+};
+#endif
+
 struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/*
@@ -1583,6 +1595,11 @@ struct task_struct {
 #endif
 
 	struct mm_struct *mm, *active_mm;
+#ifdef CONFIG_VAS
+	struct mm_struct *original_mm;
+	struct vas_context *vas_ctx;
+	int active_vas;
+#endif
 	/* per-thread vma caching */
 	u32 vmacache_seqnum;
 	struct vm_area_struct *vmacache[VMACACHE_SIZE];
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 91a740f6b884..fdea27d37c96 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -65,6 +65,7 @@ struct old_linux_dirent;
 struct perf_event_attr;
 struct file_handle;
 struct sigaltstack;
+struct vas_attr;
 union bpf_attr;
 
 #include <linux/types.h>
@@ -903,4 +904,14 @@ asmlinkage long sys_pkey_mprotect(unsigned long start, size_t len,
 asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
 asmlinkage long sys_pkey_free(int pkey);
 
+asmlinkage long sys_vas_create(const char __user *name, umode_t mode);
+asmlinkage long sys_vas_delete(int vid);
+asmlinkage long sys_vas_find(const char __user *name);
+asmlinkage long sys_vas_attach(pid_t pid, int vid, int type);
+asmlinkage long sys_vas_detach(pid_t pid, int vid);
+asmlinkage long sys_vas_switch(int vid);
+asmlinkage long sys_active_vas(void);
+asmlinkage long sys_vas_getattr(int vid, struct vas_attr __user *attr);
+asmlinkage long sys_vas_setattr(int vid, struct vas_attr __user *attr);
+
 #endif
diff --git a/include/linux/vas.h b/include/linux/vas.h
new file mode 100644
index 000000000000..6a72e42f96d2
--- /dev/null
+++ b/include/linux/vas.h
@@ -0,0 +1,182 @@
+#ifndef _LINUX_VAS_H
+#define _LINUX_VAS_H
+
+
+#include <linux/sched.h>
+#include <linux/vas_types.h>
+
+
+/***
+ * General management of the VAS subsystem
+ ***/
+
+#ifdef CONFIG_VAS
+
+/***
+ * Management of VASes
+ ***/
+
+/**
+ * Lock and unlock helper for VAS.
+ **/
+#define vas_lock(vas) mutex_lock(&(vas)->mtx)
+#define vas_unlock(vas) mutex_unlock(&(vas)->mtx)
+
+/**
+ * Create a new VAS.
+ *
+ * @param[in] name:		The name of the new VAS.
+ * @param[in] mode:		The access rights for the VAS.
+ *
+ * @returns:			The VAS ID on success, -ERRNO otherwise.
+ **/
+extern int vas_create(const char *name, umode_t mode);
+
+/**
+ * Get a pointer to a VAS data structure.
+ *
+ * @param[in] vid:		The ID of the VAS whose data structure should be
+ *				returned.
+ *
+ * @returns:			The pointer to the VAS data structure on
+ *				success, or NULL otherwise.
+ **/
+extern struct vas *vas_get(int vid);
+
+/**
+ * Return a pointer to a VAS data structure again.
+ *
+ * @param[in] vas:		The pointer to the VAS data structure that
+ *				should be returned.
+ **/
+extern void vas_put(struct vas *vas);
+
+/**
+ * Get the ID of the VAS belonging to the given name.
+ *
+ * @param[in] name:		The name of the VAS for which the ID should be
+ *				returned.
+ *
+ * @returns:			The VAS ID on success, -ERRNO otherwise.
+ **/
+extern int vas_find(const char *name);
+
+/**
+ * Delete the given VAS structure again.
+ *
+ * @param[in] vid:		The ID of the VAS which should be deleted.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_delete(int vid);
+
+/**
+ * Attach a VAS to a process.
+ *
+ * @param[in] tsk:		The task to which the VAS should be attached to.
+ * @param[in] vid:		The ID of the VAS which should be attached.
+ * @param[in] type:		The type how the VAS should be attached.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_attach(struct task_struct *tsk, int vid, int type);
+
+/**
+ * Detach a VAS from a process.
+ *
+ * @param[in] tsk:		The task from which the VAS should be detached.
+ * @param[in] vid:		The ID of the VAS which should be detached.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_detach(struct task_struct *tsk, int vid);
+
+/**
+ * Switch to a different VAS.
+ *
+ * @param[in] tsk:		The task for which the VAS should be switched.
+ * @param[in] vid:		The ID of the VAS which should be activated.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_switch(struct task_struct *tsk, int vid);
+
+/**
+ * Get attributes of a VAS.
+ *
+ * @param[in] vid:		The ID of the VAS for which the attributes
+ *				should be returned.
+ * @param[out] attr:		The pointer to the struct where the attributes
+ *				should be saved.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_getattr(int vid, struct vas_attr *attr);
+
+/**
+ * Set attributes of a VAS.
+ *
+ * @param[in] vid:		The ID of the VAS for which the attributes
+ *				should be updated.
+ * @param[in] attr:		The pointer to the struct containing the new
+ *				attributes.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_setattr(int vid, struct vas_attr *attr);
+
+
+/***
+ * Management of VAS contexts
+ ***/
+
+/**
+ * Lock and unlock helper for VAS contexts.
+ **/
+#define vas_context_lock(ctx) spin_lock(&(ctx)->lock)
+#define vas_context_unlock(ctx) spin_unlock(&(ctx)->lock)
+
+
+/***
+ * Management of the VAS subsystem
+ ***/
+
+/**
+ * Initialize the VAS subsystem
+ **/
+extern void vas_init(void);
+
+
+/***
+ * Management of the VAS subsystem during fork and exit
+ ***/
+
+/**
+ * Initialize the task-specific VAS data structures during the clone system
+ * call.
+ *
+ * @param[in] clone_flags:	The flags which were given to the system call by
+ *				the user.
+ * @param[in] tsk:		The new task which should be initialized.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_clone(int clone_flags, struct task_struct *tsk);
+
+/**
+ * Destroy the task-specific VAS data structures during the exit system call.
+ *
+ * @param[in] tsk:		The task for which data structures should be
+ *				destructed.
+ **/
+extern void vas_exit(struct task_struct *tsk);
+
+#else /* CONFIG_VAS */
+
+static inline void __init vas_init(void) {}
+static inline int vas_clone(int cf, struct task_struct *tsk) { return 0; }
+static inline int vas_exit(struct task_struct *tsk) { return 0; }
+
+#endif /* CONFIG_VAS */
+
+#endif
diff --git a/include/linux/vas_types.h b/include/linux/vas_types.h
new file mode 100644
index 000000000000..f06bfa9ef729
--- /dev/null
+++ b/include/linux/vas_types.h
@@ -0,0 +1,88 @@
+#ifndef _LINUX_VAS_TYPES_H
+#define _LINUX_VAS_TYPES_H
+
+#include <uapi/linux/vas.h>
+
+#include <linux/kobject.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/spinlock_types.h>
+#include <linux/types.h>
+
+
+#define VAS_MAX_NAME_LENGTH 256
+
+#define VAS_IS_ERROR(id) ((id) < 0)
+
+/**
+ * Forward declare various important shared data structures.
+ **/
+struct mm_struct;
+struct task_struct;
+
+/**
+ * The struct representing a Virtual Address Space (VAS).
+ *
+ * This data structure contains all the necessary information of a VAS such as
+ * its name, ID. It also contains access rights and other management
+ * information.
+ **/
+struct vas {
+	struct kobject kobj;		/* < the internal kobject that we use *
+					 *   for reference counting and sysfs *
+					 *   handling.                        */
+
+	int id;				/* < ID                               */
+	char name[VAS_MAX_NAME_LENGTH];	/* < name                             */
+
+	struct mutex mtx;		/* < lock for parallel access.        */
+
+	struct mm_struct *mm;		/* < a partial memory map containing  *
+					 *   all mappings of this VAS.        */
+
+	struct list_head link;		/* < the link in the global VAS list. */
+	struct rcu_head rcu;		/* < the RCU helper used for          *
+					 *   asynchronous VAS deletion.       */
+
+	u16 refcount;			/* < how often is the VAS attached.   */
+	struct list_head attaches;	/* < the list of tasks which have     *
+					 *   this VAS attached.               */
+
+	spinlock_t share_lock;		/* < lock for protecting sharing      *
+					 *   state.                           */
+	u32 sharing;			/* < the variable used to keep track  *
+					 *   of the current sharing state of  *
+					 *   the VAS.                         */
+
+	umode_t mode;			/* < the access rights to this VAS.   */
+	kuid_t uid;			/* < the UID of the owning user of    *
+					 *   this VAS.                        */
+	kgid_t gid;			/* < the GID of the owning group of   *
+					 *   this VAS.                        */
+};
+
+/**
+ * The struct representing a VAS being attached to a process.
+ *
+ * Once a VAS is attached to a process additional information are necessary.
+ * This data structure contains all these information which makes using a VAS
+ * fast and easy.
+ **/
+struct att_vas {
+	struct vas *vas;		/* < the reference to the actual VAS  *
+					 *   containing all the information.  */
+
+	struct task_struct *tsk;	/* < the reference to the task to     *
+					 *   which the VAS is attached to.    */
+
+	struct mm_struct *mm;		/* < the backing memory map.          */
+
+	struct list_head tsk_link;	/* < the link in the list managed     *
+					 *   inside the task.                 */
+	struct list_head vas_link;	/* < the link in the list managed     *
+					 *   inside the VAS.                  */
+
+	int type;			/* < the type of attaching (RO/RW).   */
+};
+
+#endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 9b1462e38b82..35df7d40a443 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -730,9 +730,27 @@ __SYSCALL(__NR_pkey_mprotect, sys_pkey_mprotect)
 __SYSCALL(__NR_pkey_alloc,    sys_pkey_alloc)
 #define __NR_pkey_free 290
 __SYSCALL(__NR_pkey_free,     sys_pkey_free)
+#define __NR_vas_create 291
+__SYSCALL(__NR_vas_create, sys_vas_create)
+#define __NR_vas_delete 292
+__SYSCALL(__NR_vas_delete, sys_vas_delete)
+#define __NR_vas_find 293
+__SYSCALL(__NR_vas_find, sys_vas_find)
+#define __NR_vas_attach 294
+__SYSCALL(__NR_vas_attach, sys_vas_attach)
+#define __NR_vas_detach 295
+__SYSCALL(__NR_vas_detach, sys_vas_detach)
+#define __NR_vas_switch 296
+__SYSCALL(__NR_vas_switch, sys_vas_switch)
+#define __NR_active_vas 297
+__SYSCALL(__NR_active_vas, sys_active_vas)
+#define __NR_vas_getattr 298
+__SYSCALL(__NR_vas_getattr, sys_vas_getattr)
+#define __NR_vas_setattr 299
+__SYSCALL(__NR_vas_setattr, sys_vas_setattr)
 
 #undef __NR_syscalls
-#define __NR_syscalls 291
+#define __NR_syscalls 300
 
 /*
  * All syscalls below here should go away really,
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index f330ba4547cf..5666900bdf06 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -446,6 +446,7 @@ header-y += v4l2-controls.h
 header-y += v4l2-dv-timings.h
 header-y += v4l2-mediabus.h
 header-y += v4l2-subdev.h
+header-y += vas.h
 header-y += veth.h
 header-y += vfio.h
 header-y += vhost.h
diff --git a/include/uapi/linux/vas.h b/include/uapi/linux/vas.h
new file mode 100644
index 000000000000..02f70f88bdcb
--- /dev/null
+++ b/include/uapi/linux/vas.h
@@ -0,0 +1,16 @@
+#ifndef _UAPI_LINUX_VAS_H
+#define _UAPI_LINUX_VAS_H
+
+#include <linux/types.h>
+
+
+/**
+ * The struct containing attributes of a VAS.
+ **/
+struct vas_attr {
+	__kernel_mode_t mode;		/* < the access rights to the VAS.    */
+	__kernel_uid_t user;		/* < the owning user of the VAS.      */
+	__kernel_gid_t group;		/* < the owning group of the VAS.     */
+};
+
+#endif
diff --git a/init/main.c b/init/main.c
index b0c9d6facef9..16f33b04f8ea 100644
--- a/init/main.c
+++ b/init/main.c
@@ -82,6 +82,7 @@
 #include <linux/proc_ns.h>
 #include <linux/io.h>
 #include <linux/cache.h>
+#include <linux/vas.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -538,6 +539,7 @@ asmlinkage __visible void __init start_kernel(void)
 	sort_main_extable();
 	trap_init();
 	mm_init();
+	vas_init();
 
 	/*
 	 * Set up the scheduler prior starting any interrupts (such as the
diff --git a/kernel/exit.c b/kernel/exit.c
index 8f14b866f9f6..b9687ea70a5b 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -55,6 +55,7 @@
 #include <linux/shm.h>
 #include <linux/kcov.h>
 #include <linux/random.h>
+#include <linux/vas.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -823,6 +824,7 @@ void __noreturn do_exit(long code)
 	tsk->exit_code = code;
 	taskstats_exit(tsk, group_dead);
 
+	vas_exit(tsk);
 	exit_mm(tsk);
 
 	if (group_dead)
diff --git a/kernel/fork.c b/kernel/fork.c
index d3087d870855..292299c7995e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -76,6 +76,8 @@
 #include <linux/compiler.h>
 #include <linux/sysctl.h>
 #include <linux/kcov.h>
+#include <linux/vas.h>
+#include <linux/timekeeping.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -781,6 +783,10 @@ struct mm_struct *mm_setup(struct mm_struct *mm)
 	if (mm_alloc_pgd(mm))
 		goto fail_nopgd;
 
+#ifdef CONFIG_VAS
+	mm->vas_last_update = ktime_get();
+#endif
+
 	return mm;
 
 fail_nopgd:
@@ -1207,6 +1213,9 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 
 	tsk->mm = NULL;
 	tsk->active_mm = NULL;
+#ifdef CONFIG_VAS
+	tsk->original_mm = NULL;
+#endif
 
 	/*
 	 * Are we cloning a kernel thread?
@@ -1217,6 +1226,15 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	if (!oldmm)
 		return 0;
 
+#ifdef CONFIG_VAS
+	/*
+	 * Never fork the address space of a VAS but use the process'
+	 * original one.
+	 */
+	if (oldmm != current->original_mm)
+		oldmm = current->original_mm;
+#endif
+
 	/* initialize the new vmacache entries */
 	vmacache_flush(tsk);
 
@@ -1234,6 +1252,9 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 good_mm:
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+#ifdef CONFIG_VAS
+	tsk->original_mm = mm;
+#endif
 	return 0;
 
 fail_nomem:
@@ -1700,9 +1721,12 @@ static __latent_entropy struct task_struct *copy_process(
 	retval = copy_mm(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_signal;
-	retval = copy_namespaces(clone_flags, p);
+	retval = vas_clone(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_mm;
+	retval = copy_namespaces(clone_flags, p);
+	if (retval)
+		goto bad_fork_cleanup_vas;
 	retval = copy_io(clone_flags, p);
 	if (retval)
 		goto bad_fork_cleanup_namespaces;
@@ -1885,6 +1909,8 @@ static __latent_entropy struct task_struct *copy_process(
 		exit_io_context(p);
 bad_fork_cleanup_namespaces:
 	exit_task_namespaces(p);
+bad_fork_cleanup_vas:
+	vas_exit(p);
 bad_fork_cleanup_mm:
 	if (p->mm)
 		mmput(p->mm);
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 8acef8576ce9..f6f83c5ec1a1 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -258,3 +258,14 @@ cond_syscall(sys_membarrier);
 cond_syscall(sys_pkey_mprotect);
 cond_syscall(sys_pkey_alloc);
 cond_syscall(sys_pkey_free);
+
+/* first class virtual address spaces */
+cond_syscall(sys_vas_create);
+cond_syscall(sys_vas_delete);
+cond_syscall(sys_vas_find);
+cond_syscall(sys_vas_attach);
+cond_syscall(sys_vas_detach);
+cond_syscall(sys_vas_switch);
+cond_syscall(sys_active_vas);
+cond_syscall(sys_vas_getattr);
+cond_syscall(sys_vas_setattr);
diff --git a/mm/Kconfig b/mm/Kconfig
index 9b8fccb969dc..9a80877f3536 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -707,3 +707,23 @@ config ARCH_USES_HIGH_VMA_FLAGS
 	bool
 config ARCH_HAS_PKEYS
 	bool
+
+config VAS
+	bool "Support for First Class Virtual Address Spaces"
+	default n
+	help
+	  Support for First Class Virtual Address Spaces which are address space
+	  that are not bound to the lifetime of any process but can exist
+	  independently in the system. With this feature processes are allowed
+	  to have multiple different address spaces between which their threads
+	  can switch arbitrarily.
+
+	  If not sure, then say N.
+
+config VAS_DEBUG
+	bool "Debugging output for First Class Virtual Address Spaces"
+	depends on VAS
+	default n
+	help
+	  Enable extensive debugging output for the First Class Virtual Address
+	  Spaces feature.
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a9f76b..ba8995e944d7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -100,3 +100,4 @@ obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
+obj-$(CONFIG_VAS)	+= vas.o
diff --git a/mm/internal.h b/mm/internal.h
index e22cb031b45b..f947e8c50bae 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -499,4 +499,12 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+#ifdef CONFIG_VAS
+void mm_updated(struct mm_struct *mm);
+void vm_area_updated(struct vm_area_struct *vma);
+#else
+static inline void mm_updated(struct mm_struct *mm) {}
+static inline void vm_area_updated(struct vm_area_struct *vma) {}
+#endif
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory.c b/mm/memory.c
index 7026f2146fcd..e4747b3fd5b9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4042,6 +4042,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
 		ret = VM_FAULT_SIGBUS;
 
+	if (ret)
+		vm_area_updated(vma);
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
diff --git a/mm/mmap.c b/mm/mmap.c
index d35c6b51cadf..1d82b2260448 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -44,6 +44,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
+#include <linux/timekeeping.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -942,6 +943,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		uprobe_mmap(insert);
 
 	validate_mm(mm);
+	vm_area_updated(vma);
 
 	return 0;
 }
@@ -1135,6 +1137,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 		if (err)
 			return NULL;
 		khugepaged_enter_vma_merge(prev, vm_flags);
+		vm_area_updated(prev);
 		return prev;
 	}
 
@@ -1162,6 +1165,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 		if (err)
 			return NULL;
 		khugepaged_enter_vma_merge(area, vm_flags);
+		vm_area_updated(area);
 		return area;
 	}
 
@@ -1719,6 +1723,7 @@ unsigned long mmap_region(struct mm_struct *mm, struct file *file,
 	vma->vm_flags |= VM_SOFTDIRTY;
 
 	vma_set_page_prot(vma);
+	vm_area_updated(vma);
 
 	return addr;
 
@@ -2263,6 +2268,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 	anon_vma_unlock_write(vma->anon_vma);
 	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(mm);
+	vm_area_updated(vma);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -2332,6 +2338,7 @@ int expand_downwards(struct vm_area_struct *vma,
 	anon_vma_unlock_write(vma->anon_vma);
 	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(mm);
+	vm_area_updated(vma);
 	return error;
 }
 
@@ -2457,6 +2464,7 @@ void munmap_region(struct mm_struct *mm, struct vm_area_struct *vma,
 	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
 				 next ? next->vm_start : USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, start, end);
+	mm_updated(mm);
 }
 
 /*
@@ -2656,6 +2664,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 
 	/* Fix up all other VM information */
 	remove_vma_list(mm, vma);
+	mm_updated(mm);
 
 	return 0;
 }
@@ -2882,6 +2891,7 @@ static int do_brk(unsigned long addr, unsigned long request)
 	if (flags & VM_LOCKED)
 		mm->locked_vm += (len >> PAGE_SHIFT);
 	vma->vm_flags |= VM_SOFTDIRTY;
+	vm_area_updated(vma);
 	return 0;
 }
 
@@ -3058,6 +3068,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		vma_link(mm, new_vma, prev, rb_link, rb_parent);
 		*need_rmap_locks = false;
 	}
+	vm_area_updated(new_vma);
 	return new_vma;
 
 out_free_mempol:
@@ -3204,6 +3215,7 @@ static struct vm_area_struct *__install_special_mapping(
 	vm_stat_account(mm, vma->vm_flags, len >> PAGE_SHIFT);
 
 	perf_event_mmap(vma);
+	vm_area_updated(vma);
 
 	return vma;
 
@@ -3550,3 +3562,13 @@ static int __meminit init_reserve_notifier(void)
 	return 0;
 }
 subsys_initcall(init_reserve_notifier);
+
+void mm_updated(struct mm_struct *mm)
+{
+	mm->vas_last_update = ktime_get();
+}
+
+void vm_area_updated(struct vm_area_struct *vma)
+{
+	vma->vas_last_update = vma->vm_mm->vas_last_update = ktime_get();
+}
diff --git a/mm/vas.c b/mm/vas.c
new file mode 100644
index 000000000000..447d61e1da79
--- /dev/null
+++ b/mm/vas.c
@@ -0,0 +1,2188 @@
+/*
+ *  First Class Virtual Address Spaces
+ *  Copyright (c) 2016-2017, Hewlett Packard Enterprise
+ *
+ *  Code Authors:
+ *     Marco A Benatto <marco.antonio.780@gmail.com>
+ *     Till Smejkal <till.smejkal@gmail.com>
+ */
+
+
+#include <linux/vas.h>
+
+#include <linux/atomic.h>
+#include <linux/cred.h>
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/fcntl.h>
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/kobject.h>
+#include <linux/ktime.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/mempolicy.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/mmu_context.h>
+#include <linux/mmu_notifier.h>
+#include <linux/mutex.h>
+#include <linux/printk.h>
+#include <linux/rbtree.h>
+#include <linux/rcupdate.h>
+#include <linux/rmap.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/string.h>
+#include <linux/syscalls.h>
+#include <linux/uidgid.h>
+#include <linux/uaccess.h>
+#include <linux/vmacache.h>
+
+#include <asm/mman.h>
+#include <asm/processor.h>
+
+#include "internal.h"
+
+
+/***
+ * Internally used defines
+ ***/
+
+/**
+ * Make sure we are not overflowing the VAS sharing variable.
+ **/
+#define VAS_MAX_SHARES U16_MAX
+
+#define VAS_MAX_ID INT_MAX
+
+/**
+ * Masks and bits to implement sharing of VAS.
+ **/
+#define VAS_SHARE_READABLE (1 << 0)
+#define VAS_SHARE_WRITABLE (1 << 16)
+#define VAS_SHARE_READ_MASK 0xffff
+#define VAS_SHARE_WRITE_MASK 0xffff0000
+#define VAS_SHARE_READ_WRITE_MASK (VAS_SHARE_READ_MASK | VAS_SHARE_WRITE_MASK)
+
+/**
+ * Get the next vm_area_struct of the VMA list in the memory map but safely.
+ **/
+#define next_vma_safe(vma) ((vma) ? (vma)->vm_next : NULL)
+
+/**
+ * Get a string representation of the access type to a VAS.
+ **/
+#define access_type_str(type) ((type) & MAY_WRITE ?			\
+			       ((type) & MAY_READ ? "rw" : "wo") : "ro")
+
+
+/***
+ * Debugging functions
+ ***/
+
+#ifdef CONFIG_VAS_DEBUG
+
+/**
+ * Dump the content of the given memory map.
+ *
+ * @param mm:		The memory map which should be dumped.
+ **/
+static void __dump_memory_map(const char *title, struct mm_struct *mm)
+{
+	int count;
+	struct vm_area_struct *vma;
+
+	down_read(&mm->mmap_sem);
+
+	/* Dump some general information. */
+	pr_info("-- %s [%p] --\n"
+		"> General information <\n"
+		"  PGD value: %#lx\n"
+		"  Task size: %#lx\n"
+		"  Map count: %d\n"
+		"  Last update: %lld\n"
+		"  Code:  %#lx - %#lx\n"
+		"  Data:  %#lx - %#lx\n"
+		"  Heap:  %#lx - %#lx\n"
+		"  Stack: %#lx\n"
+		"  Args:  %#lx - %#lx\n"
+		"  Env:   %#lx - %#lx\n",
+		title, mm, pgd_val(*mm->pgd), mm->task_size, mm->map_count,
+		mm->vas_last_update, mm->start_code, mm->end_code,
+		mm->start_data, mm->end_data, mm->start_brk, mm->brk,
+		mm->start_stack, mm->arg_start, mm->arg_end, mm->env_start,
+		mm->env_end);
+
+	/* Dump current RSS state counters of the memory map. */
+	pr_cont("> RSS Counter <\n");
+	for (count = 0; count < NR_MM_COUNTERS; ++count)
+		pr_cont(" %d: %lu\n", count, get_mm_counter(mm, count));
+
+	/* Dump the information for each region. */
+	pr_cont("> Mapped Regions <\n");
+	for (vma = mm->mmap, count = 0; vma; vma = vma->vm_next, ++count) {
+		pr_cont("  VMA %3d: %#14lx - %#-14lx", count, vma->vm_start,
+			vma->vm_end);
+
+		if (is_exec_mapping(vma->vm_flags))
+			pr_cont(" EXEC  ");
+		else if (is_data_mapping(vma->vm_flags))
+			pr_cont(" DATA  ");
+		else if (is_stack_mapping(vma->vm_flags))
+			pr_cont(" STACK ");
+		else
+			pr_cont(" OTHER ");
+
+		pr_cont("%c%c%c%c [%c]",
+			vma->vm_flags & VM_READ ? 'r' : '-',
+			vma->vm_flags & VM_WRITE ? 'w' : '-',
+			vma->vm_flags & VM_EXEC ? 'x' : '-',
+			vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
+			vma->vas_reference ? 'v' : '-');
+
+		if (vma->vm_file) {
+			struct file *f = vma->vm_file;
+			char *buf;
+
+			buf = kmalloc(PATH_MAX, GFP_TEMPORARY);
+			if (buf) {
+				char *p;
+
+				p = file_path(f, buf, PATH_MAX);
+				if (IS_ERR(p))
+					p = "?";
+
+				pr_cont(" --> %s @%lu\n", p, vma->vm_pgoff);
+				kfree(buf);
+			} else {
+				pr_cont(" --> NA @%lu\n", vma->vm_pgoff);
+			}
+		} else if (vma->vm_ops && vma->vm_ops->name) {
+			pr_cont(" --> %s\n", vma->vm_ops->name(vma));
+		} else {
+			pr_cont(" ANON\n");
+		}
+	}
+	if (count == 0)
+		pr_cont("  EMPTY\n");
+
+	up_read(&mm->mmap_sem);
+}
+
+#define pr_vas_debug(fmt, args...) pr_info("[VAS] %s - " fmt, __func__, ##args)
+#define dump_memory_map(title, mm) __dump_memory_map(title, mm)
+
+#else /* CONFIG_VAS_DEBUG */
+
+#define pr_vas_debug(...) do {} while (0)
+#define dump_memory_map(...) do {} while (0)
+
+#endif /* CONFIG_VAS_DEBUG */
+
+/***
+ * Internally used variables
+ ***/
+
+/**
+ * All SLAB caches used to improve allocation performance.
+ **/
+static struct kmem_cache *vas_cachep;
+static struct kmem_cache *att_vas_cachep;
+static struct kmem_cache *vas_context_cachep;
+
+/**
+ * Global management data structures and their associated locks.
+ **/
+static struct idr vases;
+static spinlock_t vases_lock;
+
+/**
+ * The place holder variables that are used to identify to-be-deleted items in
+ * our global management data structures.
+ **/
+static struct vas *INVALID_VAS;
+
+/**
+ * Kernel 'ksets' where all objects will be managed.
+ **/
+static struct kset *vases_kset;
+
+
+/***
+ * Constructors and destructors for the data structures.
+ ***/
+static inline struct vm_area_struct *__new_vm_area(void)
+{
+	return kmem_cache_zalloc(vm_area_cachep, GFP_ATOMIC);
+}
+
+static inline void __delete_vm_area(struct vm_area_struct *vma)
+{
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+static inline struct vas *__new_vas(void)
+{
+	return kmem_cache_zalloc(vas_cachep, GFP_KERNEL);
+}
+
+static inline void __delete_vas(struct vas *vas)
+{
+	WARN_ON(vas->refcount != 0);
+
+	mutex_destroy(&vas->mtx);
+
+	if (vas->mm)
+		mmput_async(vas->mm);
+	kmem_cache_free(vas_cachep, vas);
+}
+
+static inline void __delete_vas_rcu(struct rcu_head *rp)
+{
+	struct vas *vas = container_of(rp, struct vas, rcu);
+
+	__delete_vas(vas);
+}
+
+static inline struct att_vas *__new_att_vas(void)
+{
+	return kmem_cache_zalloc(att_vas_cachep, GFP_ATOMIC);
+}
+
+static inline void __delete_att_vas(struct att_vas *avas)
+{
+	if (avas->mm)
+		mmput_async(avas->mm);
+	kmem_cache_free(att_vas_cachep, avas);
+}
+
+static inline struct vas_context *__new_vas_context(void)
+{
+	return kmem_cache_zalloc(vas_context_cachep, GFP_KERNEL);
+}
+
+static inline void __delete_vas_context(struct vas_context *ctx)
+{
+	WARN_ON(ctx->refcount != 0);
+
+	kmem_cache_free(vas_context_cachep, ctx);
+}
+
+/***
+ * Kobject management of data structures
+ ***/
+
+/**
+ * Correctly take and put VAS.
+ **/
+static inline struct vas *__vas_get(struct vas *vas)
+{
+	return container_of(kobject_get(&vas->kobj), struct vas, kobj);
+}
+
+static inline void __vas_put(struct vas *vas)
+{
+	kobject_put(&vas->kobj);
+}
+
+/**
+ * The sysfs structure we need to handle attributes of a VAS.
+ **/
+struct vas_sysfs_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct vas *vas, struct vas_sysfs_attr *vsattr,
+			char *buf);
+	ssize_t (*store)(struct vas *vas, struct vas_sysfs_attr *vsattr,
+			 const char *buf, size_t count);
+};
+
+#define VAS_SYSFS_ATTR(NAME, MODE, SHOW, STORE)				\
+static struct vas_sysfs_attr vas_sysfs_attr_##NAME =			\
+	__ATTR(NAME, MODE, SHOW, STORE)
+
+/**
+ * Functions for all the sysfs operations.
+ **/
+static ssize_t __vas_sysfs_attr_show(struct kobject *kobj,
+				     struct attribute *attr,
+				     char *buf)
+{
+	struct vas *vas;
+	struct vas_sysfs_attr *vsattr;
+
+	vas = container_of(kobj, struct vas, kobj);
+	vsattr = container_of(attr, struct vas_sysfs_attr, attr);
+
+	if (!vsattr->show)
+		return -EIO;
+
+	return vsattr->show(vas, vsattr, buf);
+}
+
+static ssize_t __vas_sysfs_attr_store(struct kobject *kobj,
+				      struct attribute *attr,
+				      const char *buf, size_t count)
+{
+	struct vas *vas;
+	struct vas_sysfs_attr *vsattr;
+
+	vas = container_of(kobj, struct vas, kobj);
+	vsattr = container_of(attr, struct vas_sysfs_attr, attr);
+
+	if (!vsattr->store)
+		return -EIO;
+
+	return vsattr->store(vas, vsattr, buf, count);
+}
+
+/**
+ * The sysfs operations structure for a VAS.
+ **/
+static const struct sysfs_ops vas_sysfs_ops = {
+	.show = __vas_sysfs_attr_show,
+	.store = __vas_sysfs_attr_store,
+};
+
+/**
+ * Default attributes of a VAS.
+ **/
+static ssize_t __show_vas_name(struct vas *vas, struct vas_sysfs_attr *vsattr,
+			       char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%s", vas->name);
+}
+VAS_SYSFS_ATTR(name, 0444, __show_vas_name, NULL);
+
+static ssize_t __show_vas_mode(struct vas *vas, struct vas_sysfs_attr *vsattr,
+			       char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%#03o", vas->mode);
+}
+VAS_SYSFS_ATTR(mode, 0444, __show_vas_mode, NULL);
+
+static ssize_t __show_vas_user(struct vas *vas, struct vas_sysfs_attr *vsattr,
+			       char *buf)
+{
+	struct user_namespace *ns = current_user_ns();
+
+	return scnprintf(buf, PAGE_SIZE, "%d", from_kuid(ns, vas->uid));
+}
+VAS_SYSFS_ATTR(user, 0444, __show_vas_user, NULL);
+
+static ssize_t __show_vas_group(struct vas *vas, struct vas_sysfs_attr *vsattr,
+				char *buf)
+{
+	struct user_namespace *ns = current_user_ns();
+
+	return scnprintf(buf, PAGE_SIZE, "%d", from_kgid(ns, vas->gid));
+}
+VAS_SYSFS_ATTR(group, 0444, __show_vas_group, NULL);
+
+static struct attribute *vas_default_attr[] = {
+	&vas_sysfs_attr_name.attr,
+	&vas_sysfs_attr_mode.attr,
+	&vas_sysfs_attr_user.attr,
+	&vas_sysfs_attr_group.attr,
+	NULL
+};
+
+/**
+ * Function to release the VAS after its kobject is gone.
+ **/
+static void __vas_release(struct kobject *kobj)
+{
+	struct vas *vas = container_of(kobj, struct vas, kobj);
+
+	spin_lock(&vases_lock);
+	idr_remove(&vases, vas->id);
+	spin_unlock(&vases_lock);
+
+	/*
+	 * Wait for the full RCU grace period before actually deleting the VAS
+	 * data structure since we haven't done it earlier.
+	 */
+	call_rcu(&vas->rcu, __delete_vas_rcu);
+}
+
+/**
+ * The ktype data structure representing a VAS.
+ **/
+static struct kobj_type vas_ktype = {
+	.sysfs_ops = &vas_sysfs_ops,
+	.release = __vas_release,
+	.default_attrs = vas_default_attr,
+};
+
+
+/***
+ * Internally visible functions
+ ***/
+
+/**
+ * Working with the global VAS list.
+ **/
+static inline void vas_remove(struct vas *vas)
+{
+	spin_lock(&vases_lock);
+
+	/*
+	 * Only put the to-be-deleted place holder in the IDR, the actual remove
+	 * in the IDR and the freeing of the object  will be done when we
+	 * release the kobject. We need to do it this way, to keep the ID
+	 * reserved. Otherwise it can happen, that we try to create a new VAS
+	 * with a reused ID in the sysfs before the current VAS is removed from
+	 * the sysfs.
+	 */
+	idr_replace(&vases, INVALID_VAS, vas->id);
+	spin_unlock(&vases_lock);
+
+	/*
+	 * No need to wait for the RCU period here, we will do it before
+	 * actually deleting the VAS in the 'vas_release' function.
+	 */
+	__vas_put(vas);
+}
+
+static inline int vas_insert(struct vas *vas)
+{
+	int ret;
+
+	/* Add the VAS in the IDR cache. */
+	spin_lock(&vases_lock);
+
+	ret = idr_alloc(&vases, vas, 1, VAS_MAX_ID, GFP_KERNEL);
+
+	spin_unlock(&vases_lock);
+
+	if (ret < 0) {
+		__delete_vas(vas);
+		return ret;
+	}
+
+	/* Add the last data to the VAS' data structure. */
+	vas->id = ret;
+	vas->kobj.kset = vases_kset;
+
+	/* Initialize the kobject and add it to the sysfs. */
+	ret = kobject_init_and_add(&vas->kobj, &vas_ktype, NULL, "%d", vas->id);
+	if (ret != 0) {
+		vas_remove(vas);
+		return ret;
+	}
+
+	/* The VAS is ready, trigger the corresponding UEVENT. */
+	kobject_uevent(&vas->kobj, KOBJ_ADD);
+
+	/*
+	 * We don't put or get the VAS again, because its reference count will
+	 * be initialized with '1'. This will be reduced to 0 when we remove the
+	 * VAS again from the internal global management list.
+	 */
+	return 0;
+}
+
+static inline struct vas *vas_lookup(int id)
+{
+	struct vas *vas;
+
+	rcu_read_lock();
+
+	vas = idr_find(&vases, id);
+	if (vas == INVALID_VAS)
+		vas = NULL;
+	if (vas)
+		vas = __vas_get(vas);
+
+	rcu_read_unlock();
+
+	return vas;
+}
+
+static inline struct vas *vas_lookup_by_name(const char *name)
+{
+	struct vas *vas;
+	int id;
+
+	rcu_read_lock();
+
+	idr_for_each_entry(&vases, vas, id) {
+		if (vas == INVALID_VAS)
+			continue;
+
+		if (strcmp(vas->name, name) == 0)
+			break;
+	}
+
+	if (vas)
+		vas = __vas_get(vas);
+
+	rcu_read_unlock();
+
+	return vas;
+}
+
+ /**
+  * Management of the sharing of VAS.
+  **/
+static inline int vas_take_share(int type, struct vas *vas)
+{
+	int ret;
+
+	spin_lock(&vas->share_lock);
+	if (type & MAY_WRITE) {
+		if ((vas->sharing & VAS_SHARE_READ_WRITE_MASK) == 0) {
+			vas->sharing += VAS_SHARE_WRITABLE;
+			ret = 1;
+		} else
+			ret = 0;
+	} else {
+		if ((vas->sharing & VAS_SHARE_WRITE_MASK) == 0) {
+			vas->sharing += VAS_SHARE_READABLE;
+			ret = 1;
+		} else
+			ret = 0;
+	}
+	spin_unlock(&vas->share_lock);
+
+	return ret;
+}
+
+static inline void vas_put_share(int type, struct vas *vas)
+{
+	spin_lock(&vas->share_lock);
+	if (type & MAY_WRITE)
+		vas->sharing -= VAS_SHARE_WRITABLE;
+	else
+		vas->sharing -= VAS_SHARE_READABLE;
+	spin_unlock(&vas->share_lock);
+}
+
+/**
+ * Management of the memory maps.
+ **/
+static int init_vas_mm(struct vas *vas)
+{
+	struct mm_struct *mm;
+
+	mm = mm_alloc();
+	if (!mm)
+		return -ENOMEM;
+
+	mm = mm_setup(mm);
+	if (!mm)
+		return -ENOMEM;
+
+	arch_pick_mmap_layout(mm);
+
+	vas->mm = mm;
+	return 0;
+}
+
+static int init_att_vas_mm(struct att_vas *avas, struct task_struct *owner)
+{
+	struct mm_struct *mm, *orig_mm = owner->original_mm;
+
+	mm = mm_alloc();
+	if (!mm)
+		return -ENOMEM;
+
+	mm = mm_setup(mm);
+	if (!mm)
+		return -ENOMEM;
+
+	mm = mm_set_task(mm, owner, orig_mm->user_ns);
+	if (!mm)
+		return -ENOMEM;
+
+	arch_pick_mmap_layout(mm);
+
+	/* Additional setup of the memory map. */
+	set_mm_exe_file(mm, get_mm_exe_file(orig_mm));
+	mm->vas_last_update = orig_mm->vas_last_update;
+
+	avas->mm = mm;
+	return 0;
+}
+
+/**
+ * Lookup the corresponding vm_area in the referenced memory map.
+ *
+ * The function is very similar to 'find_exact_vma'. However, it can also handle
+ * cases where a VMA was resized while the referenced one wasn't or visa-versa.
+ **/
+static struct vm_area_struct *vas_find_reference(struct mm_struct *mm,
+						 struct vm_area_struct *vma)
+{
+	struct vm_area_struct *ref;
+
+	ref = find_vma(mm, vma->vm_start);
+	if (ref) {
+		/*
+		 * Ok we found VMA in the other memory map. So lets check
+		 * whether this is really the VMA we are referencing to.
+		 */
+		if (ref->vm_start == vma->vm_start &&
+		    ref->vm_end == vma->vm_end)
+			/* This is an exact match. */
+			return ref;
+
+		if (ref->vm_start != vma->vm_start &&
+		    ref->vm_end == vma->vm_end &&
+		    vma->vm_flags & VM_GROWSDOWN)
+			/* This might be the stack VMA. */
+			return ref;
+	}
+
+	return NULL;
+}
+
+/**
+ * Translate a bit field with O_* bits into fs-like bit field with MAY_* bits.
+ **/
+static inline int __build_vas_access_type(int acc_type)
+{
+	/* We are only interested in access modes. */
+	acc_type &= O_ACCMODE;
+
+	if (acc_type == O_RDONLY)
+		return MAY_READ;
+	else if (acc_type == O_WRONLY)
+		return MAY_WRITE;
+	else if (acc_type == O_RDWR)
+		return MAY_READ | MAY_WRITE;
+
+	return -1;
+}
+
+static inline int __check_permission(kuid_t uid, kgid_t gid, umode_t mode,
+				     int type)
+{
+	kuid_t cur_uid = current_uid();
+
+	/* root can do anything with a VAS. */
+	if (unlikely(uid_eq(cur_uid, GLOBAL_ROOT_UID)))
+		return 0;
+
+	if (likely(uid_eq(cur_uid, uid)))
+		mode >>= 6;
+	else if (in_group_p(gid))
+		mode >>= 3;
+
+	if ((type & ~mode & (MAY_READ | MAY_WRITE)) == 0)
+		return 0;
+	return -EACCES;
+}
+
+/**
+ * Copy a vm_area from one memory map into another one.
+ *
+ * Requires that the semaphores of the destination memory maps is taken in
+ * write-mode and the one of the source memory map at least in read-mode.
+ *
+ * @param[in] src_mm:	The memory map to which the vm_area belongs that should
+ *			be copied.
+ * @param[in] src_vma:	The vm_area that should be copied.
+ * @param[in] dst_mm:	The memory map to which the vm_area should be copied.
+ * @param[in] vm_flags:	The vm_flags that should be used for the new vm_area.
+ *
+ * @returns:		A pointer to the new vm_area on success, NULL
+ *			otherwise.
+ **/
+static inline
+struct vm_area_struct *__copy_vm_area(struct mm_struct *src_mm,
+				      struct vm_area_struct *src_vma,
+				      struct mm_struct *dst_mm,
+				      unsigned long vm_flags)
+{
+	struct vm_area_struct *vma, *prev;
+	struct rb_node **rb_link, *rb_parent;
+	int ret;
+
+	pr_vas_debug("Copying VMA - addr: %#lx - %#lx - to %p\n",
+		     src_vma->vm_start, src_vma->vm_end, dst_mm);
+
+	ret = find_vma_links(dst_mm, src_vma->vm_start, src_vma->vm_end,
+			     &prev, &rb_link, &rb_parent);
+	if (ret != 0) {
+		pr_vas_debug("Could not map VMA in the new memory map because of a conflict with a different mapping\n");
+		return NULL;
+	}
+
+	vma = __new_vm_area();
+	*vma = *src_vma;
+
+	INIT_LIST_HEAD(&vma->anon_vma_chain);
+	ret = vma_dup_policy(src_vma, vma);
+	if (ret != 0)
+		goto out_free_vma;
+	ret = anon_vma_clone(vma, src_vma);
+	if (ret != 0)
+		goto out_free_vma;
+	vma->vm_mm = dst_mm;
+	vma->vm_flags = vm_flags;
+	vma_set_page_prot(vma);
+	vma->vm_next = vma->vm_prev = NULL;
+	if (vma->vm_file)
+		get_file(vma->vm_file);
+	if (vma->vm_ops && vma->vm_ops->open)
+		vma->vm_ops->open(vma);
+	vma->vas_last_update = src_vma->vas_last_update;
+
+	vma_link(dst_mm, vma, prev, rb_link, rb_parent);
+
+	vm_stat_account(dst_mm, vma->vm_flags, vma_pages(vma));
+	if (unlikely(dup_page_range(dst_mm, vma, src_mm, src_vma)))
+		pr_vas_debug("Failed to copy page table for VMA %p from %p\n",
+			     vma, src_vma);
+
+	return vma;
+
+out_free_vma:
+	__delete_vm_area(vma);
+	return NULL;
+}
+
+/**
+ * Remove a vm_area from a given memory map.
+ *
+ * Requires that the semaphores of the memory map is taken in write-mode.
+ *
+ * @param mm:		The memory map from which the vm_area should be
+ *			removed.
+ * @param vma:		The vm_area that should be removed.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static inline int __remove_vm_area(struct mm_struct *mm,
+				   struct vm_area_struct *vma)
+{
+	pr_vas_debug("Removing VMA - addr: %#lx - %#lx - from %p\n",
+		     vma->vm_start, vma->vm_end, mm);
+
+	return do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
+}
+
+/**
+ * Update the information of a vm_area in one particular memory map with the
+ * information of the corresponding one in another memory map.
+ *
+ * Requires that the semaphores of both memory maps are taken in write-mode.
+ *
+ * @param[in] src_mm:	The memory map to which the vm_area belongs from which
+ *			the information should be copied.
+ * @param[in] src_vma:	The vm_area from which the information should be
+ *			copied.
+ * @param[in] dst_mm:	The memory map to which the vm_area belongs to which
+ *			the information should be copied.
+ * @param[in] dst_vma:	The vm_area that should be updated if already known,
+ *			otherwise this can be NULL and will be looked up in the
+ *			destination memory map.
+ *
+ * @returns:		A pointer to the updated vm_area on success, NULL
+ *			otherwise.
+ **/
+static inline
+struct vm_area_struct *__update_vm_area(struct mm_struct *src_mm,
+					struct vm_area_struct *src_vma,
+					struct mm_struct *dst_mm,
+					struct vm_area_struct *dst_vma)
+{
+	pr_vas_debug("Updating VMA - addr: %#lx - %#lx - in %p\n",
+		     src_vma->vm_start, src_vma->vm_end, dst_mm);
+
+	/* Lookup the destination vm_area if not yet known. */
+	if (!dst_vma)
+		dst_vma = vas_find_reference(dst_mm, src_vma);
+
+	if (!dst_vma) {
+		pr_vas_debug("Cannot find corresponding memory region in destination memory map -- Abort\n");
+		dst_vma = NULL;
+	} else if (ktime_compare(src_vma->vas_last_update,
+				 dst_vma->vas_last_update) == 0) {
+		pr_vas_debug("Memory region is unchanged -- Skip\n");
+	} else if (ktime_compare(src_vma->vas_last_update,
+				 dst_vma->vas_last_update) == -1) {
+		pr_vas_debug("Memory region is stale (%lld vs %lld)-- Abort\n",
+			     src_vma->vas_last_update,
+			     dst_vma->vas_last_update);
+		dst_vma = NULL;
+	} else if (src_vma->vm_start != dst_vma->vm_start ||
+		   src_vma->vm_end != dst_vma->vm_end) {
+		/*
+		 * The VMA changed completely. We have to represent this change
+		 * in the destination memory region.
+		 */
+		struct mm_struct *orig_vas_ref = dst_vma->vas_reference;
+		unsigned long orig_vm_flags = dst_vma->vm_flags;
+
+		if (__remove_vm_area(dst_mm, dst_vma) != 0) {
+			dst_vma = NULL;
+			goto out;
+		}
+
+		dst_vma = __copy_vm_area(src_mm, src_vma, dst_mm,
+					 orig_vm_flags);
+		if (!dst_vma)
+			goto out;
+
+		dst_vma->vas_reference = orig_vas_ref;
+	} else {
+		/*
+		 * The VMA itself did not change. However, mappings might have
+		 * changed. So at least update the page table entries belonging
+		 * to the VMA in the destination memory region.
+		 */
+		if (unlikely(dup_page_range(dst_mm, dst_vma, src_mm, src_vma)))
+			pr_vas_debug("Cannot update page table entries\n");
+
+		dst_vma->vas_last_update = src_vma->vas_last_update;
+	}
+
+out:
+	return dst_vma;
+}
+
+/**
+ * Merge the VAS' parts of the memory map into the attached-VAS memory map.
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure that
+ *			contains all the information for this attachment.
+ * @param[in] vas:	The pointer to the VAS of which the memory map should
+ *			be merged.
+ * @param[in] type:	The type of attaching (see vas_attach for more
+ *			information).
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int vas_merge(struct att_vas *avas, struct vas *vas, int type)
+{
+	struct vm_area_struct *vma, *new_vma;
+	struct mm_struct *vas_mm, *avas_mm;
+	int ret;
+
+	vas_mm = vas->mm;
+	avas_mm = avas->mm;
+
+	dump_memory_map("Before VAS MM", vas_mm);
+
+	if (down_write_killable(&avas_mm->mmap_sem))
+		return -EINTR;
+	down_read_nested(&vas_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	/* Try to copy all VMAs of the VAS into the AS of the attached-VAS. */
+	for (vma = vas_mm->mmap; vma; vma = vma->vm_next) {
+		unsigned long merged_vm_flags = vma->vm_flags;
+
+		pr_vas_debug("Merging a VAS memory region (%#lx - %#lx)\n",
+			     vma->vm_start, vma->vm_end);
+
+		/*
+		 * Remove the writable bit from the vm_flags if the VAS is
+		 * attached only readable.
+		 */
+		if (!(type & MAY_WRITE))
+			merged_vm_flags &= ~(VM_WRITE | VM_MAYWRITE);
+
+		new_vma = __copy_vm_area(vas_mm, vma, avas_mm,
+					 merged_vm_flags);
+		if (!new_vma) {
+			pr_vas_debug("Failed to merge a VAS memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+			ret = -EFAULT;
+			goto out_unlock;
+		}
+
+		/*
+		 * Remember for the VMA that we just added it to the
+		 * attached-VAS that it actually belongs to the VAS.
+		 */
+		new_vma->vas_reference = vas_mm;
+	}
+
+	ret = 0;
+
+out_unlock:
+	up_read(&vas_mm->mmap_sem);
+	up_write(&avas_mm->mmap_sem);
+
+	dump_memory_map("After VAS MM", vas_mm);
+	dump_memory_map("After Attached-VAS MM", avas_mm);
+
+	return ret;
+}
+
+/**
+ * Unmerge the VAS-related parts of an attached-VAS memory map back into the
+ * VAS' memory map.
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure that
+ *			contains all the information for this attachment.
+ * @param[in] vas:	The pointer to the VAS for which the memory map should
+ *			be updated again.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int vas_unmerge(struct att_vas *avas, struct vas *vas)
+{
+	struct vm_area_struct *vma, *next;
+	struct mm_struct *vas_mm, *avas_mm;
+	int ret;
+
+	vas_mm = vas->mm;
+	avas_mm = avas->mm;
+
+	dump_memory_map("Before Attached-VAS MM", avas_mm);
+	dump_memory_map("Before VAS MM", vas_mm);
+
+	if (down_write_killable(&avas_mm->mmap_sem))
+		return -EINTR;
+	down_write_nested(&vas_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	/* Update all VMAs of the VAS if they changed in the attached-VAS. */
+	for (vma = avas_mm->mmap, next = next_vma_safe(vma); vma;
+	     vma = next, next = next_vma_safe(next)) {
+		struct mm_struct *ref_mm = vma->vas_reference;
+
+		if (!ref_mm) {
+			struct vm_area_struct *new_vma;
+
+			/*
+			 * This is a VMA which was created while the VAS was
+			 * attached to the process and which is not yet existent
+			 * in the VAS. Copy it into the VAS' mm_struct.
+			 */
+			pr_vas_debug("Unmerging a new VAS memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+
+			new_vma = __copy_vm_area(avas_mm, vma, vas_mm,
+						 vma->vm_flags);
+			if (!new_vma) {
+				pr_vas_debug("Failed to unmerge a new VAS memory region (%#lx - %#lx)\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				goto out_unlock;
+			}
+
+			new_vma->vas_reference = NULL;
+		} else {
+			struct vm_area_struct *upd_vma;
+
+			/*
+			 * This VMA was previously copied into the memory map
+			 * when the VAS was attached to the process. So check if
+			 * we need to update the corresponding VMA in the VAS'
+			 * memory map.
+			 */
+			pr_vas_debug("Unmerging an existing VAS memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+
+			upd_vma = __update_vm_area(avas_mm, vma, vas_mm, NULL);
+			if (!upd_vma) {
+				pr_vas_debug("Failed to unmerge a VAS memory region (%#lx - %#lx)\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				goto out_unlock;
+			}
+		}
+
+		/* Remove the current VMA from the attached-VAS memory map. */
+		__remove_vm_area(avas_mm, vma);
+	}
+
+	ret = 0;
+
+out_unlock:
+	up_write(&vas_mm->mmap_sem);
+	up_write(&avas_mm->mmap_sem);
+
+	dump_memory_map("After VAS MM", vas_mm);
+
+	return ret;
+}
+
+/**
+ * Merge the task's parts of the memory map into the attached-VAS memory map.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure that
+ *			contains all the information for this attachment.
+ * @param[in] tsk:	The pointer to the task of which the memory map
+ *			should be merged.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int task_merge(struct att_vas *avas, struct task_struct *tsk)
+{
+	struct vm_area_struct *vma, *new_vma;
+	struct mm_struct *avas_mm, *tsk_mm;
+	int ret;
+
+	tsk_mm = tsk->original_mm;
+	avas_mm = avas->mm;
+
+	dump_memory_map("Before Task MM", tsk_mm);
+	dump_memory_map("Before Attached-VAS MM", avas_mm);
+
+	if (down_write_killable(&avas_mm->mmap_sem))
+		return -EINTR;
+	down_read_nested(&tsk_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	/*
+	 * Try to copy all necessary memory regions from the task's memory
+	 * map to the attached-VAS memory map.
+	 */
+	for (vma = tsk_mm->mmap; vma; vma = vma->vm_next) {
+		pr_vas_debug("Merging a task memory region (%#lx - %#lx)\n",
+			     vma->vm_start, vma->vm_end);
+
+		new_vma = __copy_vm_area(tsk_mm, vma, avas_mm, vma->vm_flags);
+		if (!new_vma) {
+			pr_vas_debug("Failed to merge a task memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+			ret = -EFAULT;
+			goto out_unlock;
+		}
+
+		/*
+		 * Remember for the VMA that we just added it to the
+		 * attached-VAS that it actually belongs to the task.
+		 */
+		new_vma->vas_reference = tsk_mm;
+	}
+
+	ret = 0;
+
+out_unlock:
+	up_read(&tsk_mm->mmap_sem);
+	up_write(&avas_mm->mmap_sem);
+
+	dump_memory_map("After Task MM", tsk_mm);
+	dump_memory_map("After Attached-VAS MM", avas_mm);
+
+	return ret;
+}
+
+/**
+ * Unmerge task-related parts of an attached-VAS memory map back into the
+ * task's memory map.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure that
+ *			contains all the information for this attachment.
+ * @param[in] tsk:	The pointer to the task for which the memory map
+ *			should be updated again.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int task_unmerge(struct att_vas *avas, struct task_struct *tsk)
+{
+	struct vm_area_struct *vma, *next;
+	struct mm_struct *avas_mm, *tsk_mm;
+
+	tsk_mm = tsk->original_mm;
+	avas_mm = avas->mm;
+
+	dump_memory_map("Before Task MM", tsk_mm);
+	dump_memory_map("Before Attached-VAS MM", avas_mm);
+
+	if (down_write_killable(&avas_mm->mmap_sem))
+		return -EINTR;
+
+	/*
+	 * Since we are always syncing with the task's memory map at every
+	 * switch, unmerging the task's memory regions basically just means
+	 * removing them.
+	 */
+	for (vma = avas_mm->mmap, next = next_vma_safe(vma); vma;
+	     vma = next, next = next_vma_safe(next)) {
+		struct mm_struct *ref_mm = vma->vas_reference;
+
+		if (ref_mm != tsk_mm) {
+			pr_vas_debug("Skipping memory region (%#lx - %#lx) during task unmerging\n",
+				     vma->vm_start, vma->vm_end);
+			continue;
+		}
+
+		pr_vas_debug("Unmerging a task memory region (%#lx - %#lx)\n",
+			     vma->vm_start, vma->vm_end);
+
+		/* Remove the current VMA from the attached-VAS memory map. */
+		__remove_vm_area(avas_mm, vma);
+	}
+
+	up_write(&avas_mm->mmap_sem);
+
+	dump_memory_map("After Task MM", tsk_mm);
+	dump_memory_map("After Attached-VAS MM", avas_mm);
+
+	return 0;
+}
+
+/**
+ * Attach a VAS to a task -- update internal information ONLY
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure
+ *			containing all the information of this attaching.
+ * @param[in] tsk:	The pointer to the task to which the VAS should be
+ *			attached.
+ * @param[in] vas:	The pointer to the VAS which should be attached.
+ *
+ * @returns:		0 on succes, -ERRNO otherwise.
+ **/
+static int __vas_attach(struct att_vas *avas, struct task_struct *tsk,
+			struct vas *vas)
+{
+	int ret;
+
+	/* Before doing anything, synchronize the RSS-stat of the task. */
+	sync_mm_rss(tsk->mm);
+
+	/*
+	 * Try to acquire the VAS share with the proper type. This will ensure
+	 * that the different sharing possibilities of VAS are respected.
+	 */
+	if (!vas_take_share(avas->type, vas)) {
+		pr_vas_debug("VAS is already attached exclusively\n");
+		return -EBUSY;
+	}
+
+	ret = vas_merge(avas, vas, avas->type);
+	if (ret != 0)
+		goto out_put_share;
+
+	ret = task_merge(avas, tsk);
+	if (ret != 0)
+		goto out_put_share;
+
+	vas->refcount++;
+
+	return 0;
+
+out_put_share:
+	vas_put_share(avas->type, vas);
+	return ret;
+}
+
+/**
+ * Detach a VAS from a task -- update internal information ONLY
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure
+ *			containing all the information of this attaching.
+ * @param[in] tsk:	The pointer to the task from which the VAS should be
+ *			detached.
+ * @param[in] vas:	The pointer to the VAS which should be detached.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int __vas_detach(struct att_vas *avas, struct task_struct *tsk,
+			struct vas *vas)
+{
+	int ret;
+
+	/* Before detaching the VAS, synchronize the RSS-stat of the task. */
+	sync_mm_rss(tsk->mm);
+
+	ret = task_unmerge(avas, tsk);
+	if (ret != 0)
+		return ret;
+
+	ret = vas_unmerge(avas, vas);
+	if (ret != 0)
+		return ret;
+
+	vas->refcount--;
+
+	/* We unlock the VAS here to ensure our sharing properties. */
+	vas_put_share(avas->type, vas);
+
+	return 0;
+}
+
+static int __sync_from_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
+{
+	struct vm_area_struct *vma;
+	int ret;
+
+	ret = 0;
+	for (vma = tsk_mm->mmap; vma; vma = vma->vm_next) {
+		struct vm_area_struct *ref;
+
+		ref = vas_find_reference(avas_mm, vma);
+		if (!ref) {
+			ref = __copy_vm_area(tsk_mm, vma, avas_mm,
+					     vma->vm_flags);
+
+			if (!ref) {
+				pr_vas_debug("Failed to copy memory region (%#lx - %#lx) during task sync\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				break;
+			}
+
+			/*
+			 * Remember for the newly added memory region where we
+			 * copied it from.
+			 */
+			ref->vas_reference = tsk_mm;
+		} else {
+			ref = __update_vm_area(tsk_mm, vma, avas_mm, ref);
+			if (!ref) {
+				pr_vas_debug("Failed to update memory region (%#lx - %#lx) during task sync\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				break;
+			}
+		}
+	}
+
+	return ret;
+}
+
+static int __sync_to_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
+{
+	struct vm_area_struct *vma;
+	int ret;
+
+	ret = 0;
+	for (vma = avas_mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vas_reference != tsk_mm) {
+			pr_vas_debug("Skip unrelated memory region (%#lx - %#lx) during task resync\n",
+				     vma->vm_start, vma->vm_end);
+		} else {
+			struct vm_area_struct *ref;
+
+			ref = __update_vm_area(avas_mm, vma, tsk_mm, NULL);
+			if (!ref) {
+				pr_vas_debug("Failed to update memory region (%#lx - %#lx) during task resync\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				break;
+			}
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * Synchronize all task related parts of the memory maps to reflect the latest
+ * state.
+ *
+ * @param[in] avas_mm:	The memory map of the attached-VAS.
+ * @param[in] tsk_mm:	The memory map of the task.
+ * @param[in] dir:	The direction in which the sync should happen:
+ *				1 => tsk -> avas
+ *			       -1 => avas -> tsk
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int synchronize_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm,
+			    int dir)
+{
+	struct mm_struct *src_mm, *dst_mm;
+	int ret;
+
+	src_mm = dir == 1 ? tsk_mm : avas_mm;
+	dst_mm = dir == 1 ? avas_mm : tsk_mm;
+
+	/*
+	 * We have nothing to do if nothing has changed the memory maps since
+	 * the last sync.
+	 */
+	if (ktime_compare(src_mm->vas_last_update,
+			  dst_mm->vas_last_update) == 0) {
+		pr_vas_debug("Nothing to do during switch, memory map is up-to-date\n");
+		return 0;
+	}
+
+	pr_vas_debug("Synchronize memory map from %s to %s\n",
+		     dir == 1 ? "Task" : "Attached-VAS",
+		     dir == 1 ? "Attached-VAS" : "Task");
+
+	dump_memory_map("Before Task MM", tsk_mm);
+	dump_memory_map("Before Attached-VAS MM", avas_mm);
+
+	if (down_write_killable(&dst_mm->mmap_sem))
+		return -EINTR;
+	down_read_nested(&src_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	if (dir == 1)
+		ret = __sync_from_task(avas_mm, tsk_mm);
+	else
+		ret = __sync_to_task(avas_mm, tsk_mm);
+
+	if (ret != 0)
+		goto out_unlock;
+
+	/*
+	 * Also update all the information where the different memory regions
+	 * such as code, data and stack start and end.
+	 */
+	dst_mm->start_code = src_mm->start_code;
+	dst_mm->end_code = src_mm->end_code;
+	dst_mm->start_data = src_mm->start_data;
+	dst_mm->end_data = src_mm->end_data;
+	dst_mm->start_brk = src_mm->start_brk;
+	dst_mm->brk = src_mm->brk;
+	dst_mm->start_stack = src_mm->start_stack;
+	dst_mm->arg_start = src_mm->arg_start;
+	dst_mm->arg_end = src_mm->arg_end;
+	dst_mm->env_start = src_mm->env_end;
+	dst_mm->env_end = src_mm->env_end;
+	dst_mm->task_size = src_mm->task_size;
+
+	dst_mm->vas_last_update = src_mm->vas_last_update;
+
+	ret = 0;
+
+out_unlock:
+	up_read(&src_mm->mmap_sem);
+	up_write(&dst_mm->mmap_sem);
+
+	dump_memory_map("After Task MM", tsk_mm);
+	dump_memory_map("After Attached-VAS MM", avas_mm);
+
+	return ret;
+}
+
+/**
+ * Properly update and setup the memory maps before performing the actual
+ * switch to a different address space.
+ *
+ * @param[in] from:	The attached-VAS that we are switching away from, or
+ *			NULL if we are switching away from the task's original
+ *			AS.
+ * @param[in] to:	The attached-VAS that we are switching to, or NULL if
+ *			we are switching to the task's original AS.
+ * @param[in] tsk:	The pointer to the task for which the switch should
+ *			happen.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int vas_prepare_switch(struct att_vas *from, struct att_vas *to,
+			      struct task_struct *tsk)
+{
+	int ret;
+
+	/* Before doing anything, synchronize the RSS-stat of the task. */
+	sync_mm_rss(tsk->mm);
+
+	/*
+	 * When switching away from a VAS we have to first update the task's
+	 * memory map so that it is always up-to-date
+	 */
+	if (from) {
+		ret = synchronize_task(from->mm, tsk->original_mm, -1);
+		if (ret != 0)
+			return ret;
+	}
+
+	/*
+	 * When switching to a VAS we have to update the VAS' memory map so that
+	 * it contains all the up to date information of the task.
+	 */
+	if (to) {
+		ret = synchronize_task(to->mm, tsk->original_mm, 1);
+		if (ret != 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+/**
+ * Switch a task's address space to the given one.
+ *
+ * @param[in] tsk:	The pointer to the task for which the AS should be
+ *			switched.
+ * @param[in] vid:	The ID of the VAS to which the task should switch, or
+ *			0 if the task should switch to its original AS.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int __vas_switch(struct task_struct *tsk, int vid)
+{
+	struct vas_context *ctx = tsk->vas_ctx;
+	struct att_vas *next_avas, *old_avas;
+	struct mm_struct *nextmm, *oldmm;
+	bool is_attached;
+	int ret;
+
+	vas_context_lock(ctx);
+
+	if (vid == 0) {
+		pr_vas_debug("Switching to original mm\n");
+		next_avas = NULL;
+		nextmm = tsk->original_mm;
+	} else {
+		is_attached = false;
+		list_for_each_entry(next_avas, &ctx->vases, tsk_link) {
+			if (next_avas->vas->id == vid) {
+				is_attached = true;
+				break;
+			}
+		}
+		if (!is_attached) {
+			ret = -EINVAL;
+			goto out_unlock;
+		}
+
+		pr_vas_debug("Switching to VAS - name: %s\n",
+			     next_avas->vas->name);
+		nextmm = next_avas->mm;
+	}
+
+	if (tsk->active_vas == 0) {
+		pr_vas_debug("Switching from original mm\n");
+		old_avas = NULL;
+		oldmm = tsk->active_mm;
+	} else {
+		is_attached = false;
+		list_for_each_entry(old_avas, &ctx->vases, tsk_link) {
+			if (old_avas->vas->id == tsk->active_vas) {
+				is_attached = true;
+				break;
+			}
+		}
+		if (!is_attached) {
+			WARN(!is_attached, "Could not find the task's active VAS.\n");
+			old_avas = NULL;
+			oldmm = tsk->mm;
+		} else {
+			pr_vas_debug("Switching from VAS - name: %s\n",
+				     old_avas->vas->name);
+			oldmm = old_avas->mm;
+		}
+	}
+
+	vas_context_unlock(ctx);
+
+	/* Check if we are already running on the specified mm. */
+	if (oldmm == nextmm)
+		return 0;
+
+	/*
+	 * Prepare the mm_struct data structure we are switching to. Update the
+	 * mappings for stack, code, data and other recent changes.
+	 */
+	ret = vas_prepare_switch(old_avas, next_avas, tsk);
+	if (ret != 0) {
+		pr_vas_debug("Failed to prepare memory maps for switch\n");
+		return ret;
+	}
+
+	task_lock(tsk);
+
+	/* Perform the actual switch in the new address space. */
+	vmacache_flush(tsk);
+	switch_mm(oldmm, nextmm, tsk);
+
+	tsk->mm = nextmm;
+	tsk->active_mm = nextmm;
+	tsk->active_vas = vid;
+
+	task_unlock(tsk);
+
+	return 0;
+
+out_unlock:
+	vas_context_unlock(ctx);
+
+	return ret;
+}
+
+
+/***
+ * Externally visible functions
+ ***/
+
+int vas_create(const char *name, umode_t mode)
+{
+	struct vas *vas;
+	int ret;
+
+	if (!name)
+		return -EINVAL;
+
+	if (vas_find(name) > 0)
+		return -EEXIST;
+
+	pr_vas_debug("Creating a new VAS - name: %s\n", name);
+
+	/* Allocate and initialize the VAS. */
+	vas = __new_vas();
+	if (!vas)
+		return -ENOMEM;
+
+	if (strscpy(vas->name, name, VAS_MAX_NAME_LENGTH) < 0) {
+		ret = -EINVAL;
+		goto out_free;
+	}
+
+	mutex_init(&vas->mtx);
+
+	ret = init_vas_mm(vas);
+	if (ret != 0)
+		goto out_free;
+
+	vas->refcount = 0;
+
+	INIT_LIST_HEAD(&vas->attaches);
+	spin_lock_init(&vas->share_lock);
+	vas->sharing = 0;
+
+	vas->mode = mode & 0666;
+	vas->uid = current_uid();
+	vas->gid = current_gid();
+
+	ret = vas_insert(vas);
+	if (ret != 0)
+		/*
+		 * We don't need to do anything here. @vas_insert will care
+		 * for the deletion of the VAS before returning with an error.
+		 */
+		return ret;
+
+	return vas->id;
+
+out_free:
+	__delete_vas(vas);
+	return ret;
+}
+EXPORT_SYMBOL(vas_create);
+
+struct vas *vas_get(int vid)
+{
+	return vas_lookup(vid);
+}
+EXPORT_SYMBOL(vas_get);
+
+void vas_put(struct vas *vas)
+{
+	if (!vas)
+		return;
+
+	__vas_put(vas);
+}
+EXPORT_SYMBOL(vas_put);
+
+int vas_find(const char *name)
+{
+	struct vas *vas;
+
+	vas = vas_lookup_by_name(name);
+	if (vas) {
+		int vid = vas->id;
+
+		vas_put(vas);
+		return vid;
+	}
+
+	return -ESRCH;
+}
+EXPORT_SYMBOL(vas_find);
+
+int vas_delete(int vid)
+{
+	struct vas *vas;
+	int ret;
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	pr_vas_debug("Deleting VAS - name: %s\n", vas->name);
+
+	vas_lock(vas);
+
+	if (vas->refcount != 0) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/* The user needs write permission to the VAS to delete it. */
+	ret = __check_permission(vas->uid, vas->gid, vas->mode, MAY_WRITE);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to delete the VAS\n");
+		goto out_unlock;
+	}
+
+	vas_unlock(vas);
+
+	vas_remove(vas);
+	vas_put(vas);
+
+	return 0;
+
+out_unlock:
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_delete);
+
+int vas_attach(struct task_struct *tsk, int vid, int type)
+{
+	struct vas_context *ctx = tsk->vas_ctx;
+	struct vas *vas;
+	struct att_vas *avas;
+	int ret;
+
+	type &= (MAY_READ | MAY_WRITE);
+
+	if (!tsk)
+		return -EINVAL;
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	pr_vas_debug("Attaching VAS - name: %s - to task - pid: %d - %s\n",
+		     vas->name, tsk->pid, access_type_str(type));
+
+	vas_lock(vas);
+
+	/*
+	 * Before we can attach the VAS to the task we first have to make some
+	 * sanity checks.
+	 */
+
+	/*
+	 * 1: Check that the user has adequate permissions to attach the VAS in
+	 * the given way.
+	 */
+	ret = __check_permission(vas->uid, vas->gid, vas->mode, type);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to attach the VAS\n");
+		goto out_unlock;
+	}
+
+	/*
+	 * 2: Check if this VAS is already attached to a task. If yes check if
+	 * it is a different task or the one we want to attach currently.
+	 */
+	list_for_each_entry(avas, &vas->attaches, vas_link) {
+		if (avas->tsk == tsk) {
+			pr_vas_debug("VAS is already attached to the task\n");
+			ret = 0;
+			goto out_unlock;
+		}
+	}
+
+	/* 3: Check if we reached the maximum number of shares for this VAS. */
+	if (vas->refcount == VAS_MAX_SHARES) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * All sanity checks are done. We can now safely attach the VAS to the
+	 * given task.
+	 */
+
+	/* Allocate and initialize the attached-VAS data structure. */
+	avas = __new_att_vas();
+	if (!avas) {
+		ret = -ENOMEM;
+		goto out_unlock;
+	}
+
+	ret = init_att_vas_mm(avas, tsk);
+	if (ret != 0)
+		goto out_free_avas;
+
+	avas->vas = vas;
+	avas->tsk = tsk;
+	avas->type = type;
+
+	ret = __vas_attach(avas, tsk, vas);
+	if (ret != 0)
+		goto out_free_avas;
+
+	vas_context_lock(ctx);
+
+	list_add(&avas->tsk_link, &ctx->vases);
+	list_add(&avas->vas_link, &vas->attaches);
+
+	vas_context_unlock(ctx);
+
+	ret = 0;
+
+out_unlock:
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return ret;
+
+out_free_avas:
+	__delete_att_vas(avas);
+	goto out_unlock;
+}
+EXPORT_SYMBOL(vas_attach);
+
+int vas_detach(struct task_struct *tsk, int vid)
+{
+	struct vas_context *ctx = tsk->vas_ctx;
+	struct vas *vas;
+	struct att_vas *avas;
+	bool is_attached;
+	int ret;
+
+	if (!tsk)
+		return -EINVAL;
+
+	task_lock(tsk);
+	vas_context_lock(ctx);
+
+	is_attached = false;
+	list_for_each_entry(avas, &ctx->vases, tsk_link) {
+		if (avas->vas->id == vid) {
+			is_attached = true;
+			break;
+		}
+	}
+	if (!is_attached) {
+		pr_vas_debug("VAS is not attached to the given task\n");
+		ret = -EINVAL;
+		goto out_unlock_tsk;
+	}
+
+	vas = avas->vas;
+
+	/*
+	 * Make sure that our reference to the VAS can not be removed while we
+	 * are currently working with it.
+	 */
+	__vas_get(vas);
+
+	pr_vas_debug("Detaching VAS - name: %s - from task - pid: %d\n",
+		     vas->name, tsk->pid);
+
+	/*
+	 * Before we can detach the VAS from the task we have to perform some
+	 * sanity checks.
+	 */
+
+	/*
+	 * 1: Check if the VAS we want to detach is currently the active VAS
+	 * because we must not detach this VAS. The user first has to switch
+	 * away.
+	 */
+	if (tsk->active_vas == vid) {
+		pr_vas_debug("VAS is currently in use by the task\n");
+		ret = -EBUSY;
+		goto out_put_vas;
+	}
+
+	/*
+	 * We are done with the sanity checks. It is now safe to detach the VAS
+	 * from the given task.
+	 */
+	list_del(&avas->tsk_link);
+
+	vas_context_unlock(ctx);
+	task_unlock(tsk);
+
+	vas_lock(vas);
+
+	list_del(&avas->vas_link);
+
+	ret = __vas_detach(avas, tsk, vas);
+	if (ret != 0)
+		goto out_reinsert;
+
+	__delete_att_vas(avas);
+
+	vas_unlock(vas);
+	__vas_put(vas);
+
+	return 0;
+
+out_reinsert:
+	vas_context_lock(ctx);
+
+	list_add(&avas->tsk_link, &ctx->vases);
+	list_add(&avas->vas_link, &vas->attaches);
+
+	vas_context_unlock(ctx);
+	vas_unlock(vas);
+	__vas_put(vas);
+
+	return ret;
+
+out_put_vas:
+	__vas_put(vas);
+
+out_unlock_tsk:
+	vas_context_unlock(ctx);
+	task_unlock(tsk);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_detach);
+
+int vas_switch(struct task_struct *tsk, int vid)
+{
+	if (!tsk)
+		return -EINVAL;
+
+	return __vas_switch(tsk, vid);
+}
+EXPORT_SYMBOL(vas_switch);
+
+int vas_getattr(int vid, struct vas_attr *attr)
+{
+	struct vas *vas;
+	struct user_namespace *ns = current_user_ns();
+
+	if (!attr)
+		return -EINVAL;
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	pr_vas_debug("Getting attributes for VAS - name: %s\n", vas->name);
+
+	vas_lock(vas);
+
+	memset(attr, 0, sizeof(struct vas_attr));
+	attr->mode = vas->mode;
+	attr->user = from_kuid(ns, vas->uid);
+	attr->group = from_kgid(ns, vas->gid);
+
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return 0;
+}
+EXPORT_SYMBOL(vas_getattr);
+
+int vas_setattr(int vid, struct vas_attr *attr)
+{
+	struct vas *vas;
+	struct user_namespace *ns = current_user_ns();
+	int ret;
+
+	if (!attr)
+		return -EINVAL;
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	pr_vas_debug("Setting attributes for VAS - name: %s\n", vas->name);
+
+	vas_lock(vas);
+
+	/* The user needs write permission to change attributes for the VAS. */
+	ret = __check_permission(vas->uid, vas->gid, vas->mode, MAY_WRITE);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to set attributes for the VAS\n");
+		goto out_unlock;
+	}
+
+	vas->mode = attr->mode & 0666;
+	vas->uid = make_kuid(ns, attr->user);
+	vas->gid = make_kgid(ns, attr->group);
+
+	ret = 0;
+
+out_unlock:
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_setattr);
+
+void __init vas_init(void)
+{
+	/* Create the SLAB caches for our data structures. */
+	vas_cachep = KMEM_CACHE(vas, SLAB_PANIC|SLAB_NOTRACK);
+	att_vas_cachep = KMEM_CACHE(att_vas, SLAB_PANIC|SLAB_NOTRACK);
+	vas_context_cachep = KMEM_CACHE(vas_context, SLAB_PANIC|SLAB_NOTRACK);
+
+	/* Initialize the internal management data structures. */
+	idr_init(&vases);
+	spin_lock_init(&vases_lock);
+
+	/* Initialize the place holder variables. */
+	INVALID_VAS = __new_vas();
+
+	/* Initialize the VAS context of the init task. */
+	vas_clone(0, &init_task);
+}
+
+/*
+ * We need to use a postcore_initcall to initialize the sysfs directories,
+ * because the 'sys/kernel' directory will be initialized in a core_initcall.
+ * Hence, we have to queue the initialization of the VAS sysfs directories after
+ * this.
+ */
+static int __init vas_sysfs_init(void)
+{
+	/* Setup the sysfs base directories. */
+	vases_kset = kset_create_and_add("vas", NULL, kernel_kobj);
+	if (!vases_kset) {
+		pr_err("Failed to initialize the VAS sysfs directory\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+postcore_initcall(vas_sysfs_init);
+
+int vas_clone(int clone_flags, struct task_struct *tsk)
+{
+	int ret = 0;
+
+	struct vas_context *ctx;
+
+	if (clone_flags & CLONE_VM) {
+		ctx = current->vas_ctx;
+
+		pr_vas_debug("Copy VAS context (%p -- %d) for task - %p - from task - %p\n",
+			     ctx, ctx->refcount, tsk, current);
+
+		vas_context_lock(ctx);
+		ctx->refcount++;
+		vas_context_unlock(ctx);
+	} else {
+		pr_vas_debug("Create a new VAS context for task - %p\n",
+			     tsk);
+
+		ctx = __new_vas_context();
+		if (!ctx) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		spin_lock_init(&ctx->lock);
+		ctx->refcount = 1;
+		INIT_LIST_HEAD(&ctx->vases);
+	}
+
+	tsk->vas_ctx = ctx;
+
+out:
+	return ret;
+}
+
+void vas_exit(struct task_struct *tsk)
+{
+	struct vas_context *ctx = tsk->vas_ctx;
+
+	if (tsk->active_vas != 0) {
+		int error;
+
+		pr_vas_debug("Switch to original MM before exit for task - %p\n",
+			     tsk);
+
+		error = __vas_switch(tsk, 0);
+		if (error != 0)
+			pr_alert("Switching back to original MM failed with %d\n",
+				 error);
+	}
+
+	pr_vas_debug("Exiting VAS context (%p -- %d) for task - %p\n", ctx,
+		     ctx->refcount, tsk);
+
+	vas_context_lock(ctx);
+
+	ctx->refcount--;
+	tsk->vas_ctx = NULL;
+
+	vas_context_unlock(ctx);
+
+	if (ctx->refcount == 0) {
+		/*
+		 * We have to clear this VAS context from all the VAS it has
+		 * attached before it is save to delete it. There is no need to
+		 * hold the look while doing this since we are the last one
+		 * having a reference to this particular VAS context.
+		 */
+		struct att_vas *avas, *s_avas;
+
+		list_for_each_entry_safe(avas, s_avas, &ctx->vases, tsk_link) {
+			struct vas *vas = avas->vas;
+			int error;
+
+			pr_vas_debug("Detaching VAS - name: %s - from exiting task - pid: %d\n",
+				     vas->name, tsk->pid);
+
+			/*
+			 * Make sure our reference to the VAS is not deleted
+			 * while we are currently working with it.
+			 */
+			__vas_get(vas);
+
+			vas_lock(vas);
+
+			error = __vas_detach(avas, tsk, vas);
+			if (error != 0)
+				pr_alert("Detaching VAS from task failed with %d\n",
+					 error);
+
+			list_del(&avas->tsk_link);
+			list_del(&avas->vas_link);
+			__delete_att_vas(avas);
+
+			vas_unlock(vas);
+			__vas_put(vas);
+		}
+
+		/*
+		 * All the attached VAS are detached. Now it is safe to remove
+		 * this VAS context.
+		 */
+		__delete_vas_context(ctx);
+
+		pr_vas_debug("Deleted VAS context\n");
+	}
+}
+
+/***
+ * System Calls
+ ***/
+
+SYSCALL_DEFINE2(vas_create, const char __user *, name, umode_t, mode)
+{
+	char vas_name[VAS_MAX_NAME_LENGTH];
+	int len;
+
+	if (!name)
+		return -EINVAL;
+
+	len = strlen(name);
+	if (len >= VAS_MAX_NAME_LENGTH)
+		return -EINVAL;
+
+	if (copy_from_user(vas_name, name, len) != 0)
+		return -EFAULT;
+
+	vas_name[len] = '\0';
+
+	return vas_create(name, mode);
+}
+
+SYSCALL_DEFINE1(vas_delete, int, vid)
+{
+	if (vid < 0)
+		return -EINVAL;
+
+	return vas_delete(vid);
+}
+
+SYSCALL_DEFINE1(vas_find, const char __user *, name)
+{
+	char vas_name[VAS_MAX_NAME_LENGTH];
+	int len;
+
+	if (!name)
+		return -EINVAL;
+
+	len = strlen(name);
+	if (len >= VAS_MAX_NAME_LENGTH)
+		return -EINVAL;
+
+	if (copy_from_user(vas_name, name, len) != 0)
+		return -EFAULT;
+
+	vas_name[len] = '\0';
+
+	return vas_find(name);
+}
+
+SYSCALL_DEFINE3(vas_attach, pid_t, pid, int, vid, int, type)
+{
+	struct task_struct *tsk;
+	int vas_acc_type;
+
+	if (pid < 0 || vid < 0)
+		return -EINVAL;
+
+	tsk = pid == 0 ? current : find_task_by_vpid(pid);
+	if (!tsk)
+		return -ESRCH;
+
+	vas_acc_type = __build_vas_access_type(type);
+	if (vas_acc_type == -1)
+		return -EINVAL;
+
+	return vas_attach(tsk, vid, vas_acc_type);
+}
+
+SYSCALL_DEFINE2(vas_detach, pid_t, pid, int, vid)
+{
+	struct task_struct *tsk;
+
+	if (pid < 0 || vid < 0)
+		return -EINVAL;
+
+	tsk = pid == 0 ? current : find_task_by_vpid(pid);
+	if (!tsk)
+		return -ESRCH;
+
+	return vas_detach(tsk, vid);
+}
+
+SYSCALL_DEFINE1(vas_switch, int, vid)
+{
+	struct task_struct *tsk = current;
+
+	if (vid < 0)
+		return -EINVAL;
+
+	return vas_switch(tsk, vid);
+}
+
+SYSCALL_DEFINE0(active_vas)
+{
+	struct task_struct *tsk = current;
+
+	return tsk->active_vas;
+}
+
+SYSCALL_DEFINE2(vas_getattr, int, vid, struct vas_attr __user *, uattr)
+{
+	struct vas_attr attr;
+	int ret;
+
+	if (vid < 0 || !uattr)
+		return -EINVAL;
+
+	ret = vas_getattr(vid, &attr);
+	if (ret != 0)
+		return ret;
+
+	if (copy_to_user(uattr, &attr, sizeof(struct vas_attr)) != 0)
+		return -EFAULT;
+
+	return 0;
+}
+
+SYSCALL_DEFINE2(vas_setattr, int, vid, struct vas_attr __user *, uattr)
+{
+	struct vas_attr attr;
+
+	if (vid < 0 || !uattr)
+		return -EINVAL;
+
+	if (copy_from_user(&attr, uattr, sizeof(struct vas_attr)) != 0)
+		return -EFAULT;
+
+	return vas_setattr(vid, &attr);
+}
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
