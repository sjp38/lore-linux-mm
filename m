Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93D756B000D
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:18:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id p11so2317464itc.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:18:40 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b193si3795530ioa.203.2018.02.21.09.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:18:36 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v12 10/11] sparc64: Add support for ADI (Application Data Integrity)
Date: Wed, 21 Feb 2018 10:15:52 -0700
Message-Id: <d8602e35e65c8bf6df1a85166bf181536a6f3664.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, akpm@linux-foundation.org, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, rob.gardner@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, anthony.yznaga@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, allen.pais@oracle.com, tklauser@distanz.ch, shannon.nelson@oracle.com, vijay.ac.kumar@oracle.com, mhocko@suse.com, jack@suse.cz, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aarcange@redhat.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, gregkh@linuxfoundation.org, nagarathnam.muthusamy@oracle.com, linux@roeck-us.net, jane.chu@oracle.com, dan.j.williams@intel.com, jglisse@redhat.com, ktkhai@virtuozzo.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

ADI is a new feature supported on SPARC M7 and newer processors to allow
hardware to catch rogue accesses to memory. ADI is supported for data
fetches only and not instruction fetches. An app can enable ADI on its
data pages, set version tags on them and use versioned addresses to
access the data pages. Upper bits of the address contain the version
tag. On M7 processors, upper four bits (bits 63-60) contain the version
tag. If a rogue app attempts to access ADI enabled data pages, its
access is blocked and processor generates an exception. Please see
Documentation/sparc/adi.txt for further details.

This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable
MCD (Memory Corruption Detection) on selected memory ranges, enable
TTE.mcd in PTEs, return ADI parameters to userspace and save/restore ADI
version tags on page swap out/in or migration. ADI is not enabled by
default for any task. A task must explicitly enable ADI on a memory
range and set version tag for ADI to be effective for the task.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
---
v10:
	- Added code to return from kernel path to set PSTATE.mcde if
	  kernel continues execution in another thread (Suggested by
	  Anthony Yznaga)
v9:
	- Added code to migrate ADI tags to copy_highpage() to
	  ensure tags get copied on page migration
	- Improved code to detect underflow and overflow when allocating
	  tag storage
v8: 
	- Added note to doc about non-faulting loads not triggering
	  ADI tag mismatch and more details on special tag values
	  of 0x0 and 0xf, as suggested by Anthony Yznaga)
	- Added an IPI on mprotect(...PROT_ADI...) call to set
	  TSTATE.MCDE on threads running on other processors and
	  restore of TSTATE.MCDE on context switch (suggested by
	  David Miller)
	- Removed restriction on enabling ADI on read-only memory
	  (suggested by Anthony Yznaga)
	- Changed kzalloc() for tag storage to use GFP_NOWAIT
	- Added code to handle overflow and underflow when allocating
	  tag storage, as suggested by Anthony Yznaga
	- Replaced sun_m7_patch_1insn_range() with sun4v_patch_1insn_range()
	  which is functionally identical (suggested by Anthony Yznaga)
	- Added membar after restoring ADI tags in copy_user_highpage(),
	  as suggested by David Miller

v7:
	- Enhanced arch_validate_prot() to enable ADI only on writable
	  addresses backed by physical RAM
	- Added support for saving/restoring ADI tags for each ADI
	  block size address range on a page on swap in/out
	- Added code to copy ADI tags on COW
	- Updated values for auxiliary vectors to not conflict with
	  values on other architectures to avoid conflict in glibc. glibc
	  consolidates all auxiliary vectors into its headers and
	  duplicate values in consolidated header are problematic
	- Disable same page merging on ADI enabled pages since ADI tags
	  may not match on pages with identical data
	- Broke the patch up further into smaller patches

v6:
	- Eliminated instructions to read and write PSTATE as well as
	  MCDPER and PMCDPER on every access to userspace addresses
	  by setting PSTATE and PMCDPER correctly upon entry into
	  kernel. PSTATE.mcde and PMCDPER are set upon entry into
	  kernel when running on an M7 processor. PSTATE.mcde being
	  set only affects memory accesses that have TTE.mcd set.
	  PMCDPER being set only affects writes to memory addresses
	  that have TTE.mcd set. This ensures any faults caused by
	  ADI tag mismatch on a write are exposed before kernel returns
	  to userspace.

v5:
	- Fixed indentation issues and instrcuctions in assembly code
	- Removed CONFIG_SPARC64 from mdesc.c
	- Changed to maintain state of MCDPER register in thread info
	  flags as opposed to in mm context. MCDPER is a per-thread
	  state and belongs in thread info flag as opposed to mm context
	  which is shared across threads. Added comments to clarify this
	  is a lazily maintained state and must be updated on context
	  switch and copy_process()
	- Updated code to use the new arch_do_swap_page() and
	  arch_unmap_one() functions

v4:
	- Broke patch up into smaller patches

v3:
	- Removed CONFIG_SPARC_ADI
	- Replaced prctl commands with mprotect
	- Added auxiliary vectors for ADI parameters
	- Enabled ADI for swappable pages

v2:
	- Fixed a build error

 Documentation/sparc/adi.txt             | 278 +++++++++++++++++++++++++++++
 arch/sparc/include/asm/mman.h           |  84 ++++++++-
 arch/sparc/include/asm/mmu_64.h         |  17 ++
 arch/sparc/include/asm/mmu_context_64.h |  50 ++++++
 arch/sparc/include/asm/page_64.h        |   6 +
 arch/sparc/include/asm/pgtable_64.h     |  46 +++++
 arch/sparc/include/asm/thread_info_64.h |   2 +-
 arch/sparc/include/asm/trap_block.h     |   2 +
 arch/sparc/include/uapi/asm/mman.h      |   2 +
 arch/sparc/kernel/adi_64.c              | 301 ++++++++++++++++++++++++++++++++
 arch/sparc/kernel/etrap_64.S            |  27 ++-
 arch/sparc/kernel/process_64.c          |  25 +++
 arch/sparc/kernel/rtrap_64.S            |  33 +++-
 arch/sparc/kernel/setup_64.c            |   2 +
 arch/sparc/kernel/urtt_fill.S           |   7 +-
 arch/sparc/kernel/vmlinux.lds.S         |   5 +
 arch/sparc/mm/gup.c                     |  37 ++++
 arch/sparc/mm/hugetlbpage.c             |  14 +-
 arch/sparc/mm/init_64.c                 |  69 ++++++++
 arch/sparc/mm/tsb.c                     |  21 +++
 include/linux/mm.h                      |   3 +
 mm/ksm.c                                |   4 +
 22 files changed, 1027 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/sparc/adi.txt

diff --git a/Documentation/sparc/adi.txt b/Documentation/sparc/adi.txt
new file mode 100644
index 000000000000..e1aed155fb89
--- /dev/null
+++ b/Documentation/sparc/adi.txt
@@ -0,0 +1,278 @@
+Application Data Integrity (ADI)
+================================
+
+SPARC M7 processor adds the Application Data Integrity (ADI) feature.
+ADI allows a task to set version tags on any subset of its address
+space. Once ADI is enabled and version tags are set for ranges of
+address space of a task, the processor will compare the tag in pointers
+to memory in these ranges to the version set by the application
+previously. Access to memory is granted only if the tag in given pointer
+matches the tag set by the application. In case of mismatch, processor
+raises an exception.
+
+Following steps must be taken by a task to enable ADI fully:
+
+1. Set the user mode PSTATE.mcde bit. This acts as master switch for
+   the task's entire address space to enable/disable ADI for the task.
+
+2. Set TTE.mcd bit on any TLB entries that correspond to the range of
+   addresses ADI is being enabled on. MMU checks the version tag only
+   on the pages that have TTE.mcd bit set.
+
+3. Set the version tag for virtual addresses using stxa instruction
+   and one of the MCD specific ASIs. Each stxa instruction sets the
+   given tag for one ADI block size number of bytes. This step must
+   be repeated for entire page to set tags for entire page.
+
+ADI block size for the platform is provided by the hypervisor to kernel
+in machine description tables. Hypervisor also provides the number of
+top bits in the virtual address that specify the version tag.  Once
+version tag has been set for a memory location, the tag is stored in the
+physical memory and the same tag must be present in the ADI version tag
+bits of the virtual address being presented to the MMU. For example on
+SPARC M7 processor, MMU uses bits 63-60 for version tags and ADI block
+size is same as cacheline size which is 64 bytes. A task that sets ADI
+version to, say 10, on a range of memory, must access that memory using
+virtual addresses that contain 0xa in bits 63-60.
+
+ADI is enabled on a set of pages using mprotect() with PROT_ADI flag.
+When ADI is enabled on a set of pages by a task for the first time,
+kernel sets the PSTATE.mcde bit fot the task. Version tags for memory
+addresses are set with an stxa instruction on the addresses using
+ASI_MCD_PRIMARY or ASI_MCD_ST_BLKINIT_PRIMARY. ADI block size is
+provided by the hypervisor to the kernel.  Kernel returns the value of
+ADI block size to userspace using auxiliary vector along with other ADI
+info. Following auxiliary vectors are provided by the kernel:
+
+	AT_ADI_BLKSZ	ADI block size. This is the granularity and
+			alignment, in bytes, of ADI versioning.
+	AT_ADI_NBITS	Number of ADI version bits in the VA
+
+
+IMPORTANT NOTES:
+
+- Version tag values of 0x0 and 0xf are reserved. These values match any
+  tag in virtual address and never generate a mismatch exception.
+
+- Version tags are set on virtual addresses from userspace even though
+  tags are stored in physical memory. Tags are set on a physical page
+  after it has been allocated to a task and a pte has been created for
+  it.
+
+- When a task frees a memory page it had set version tags on, the page
+  goes back to free page pool. When this page is re-allocated to a task,
+  kernel clears the page using block initialization ASI which clears the
+  version tags as well for the page. If a page allocated to a task is
+  freed and allocated back to the same task, old version tags set by the
+  task on that page will no longer be present.
+
+- ADI tag mismatches are not detected for non-faulting loads.
+
+- Kernel does not set any tags for user pages and it is entirely a
+  task's responsibility to set any version tags. Kernel does ensure the
+  version tags are preserved if a page is swapped out to the disk and
+  swapped back in. It also preserves that version tags if a page is
+  migrated.
+
+- ADI works for any size pages. A userspace task need not be aware of
+  page size when using ADI. It can simply select a virtual address
+  range, enable ADI on the range using mprotect() and set version tags
+  for the entire range. mprotect() ensures range is aligned to page size
+  and is a multiple of page size.
+
+- ADI tags can only be set on writable memory. For example, ADI tags can
+  not be set on read-only mappings.
+
+
+
+ADI related traps
+-----------------
+
+With ADI enabled, following new traps may occur:
+
+Disrupting memory corruption
+
+	When a store accesses a memory localtion that has TTE.mcd=1,
+	the task is running with ADI enabled (PSTATE.mcde=1), and the ADI
+	tag in the address used (bits 63:60) does not match the tag set on
+	the corresponding cacheline, a memory corruption trap occurs. By
+	default, it is a disrupting trap and is sent to the hypervisor
+	first. Hypervisor creates a sun4v error report and sends a
+	resumable error (TT=0x7e) trap to the kernel. The kernel sends
+	a SIGSEGV to the task that resulted in this trap with the following
+	info:
+
+		siginfo.si_signo = SIGSEGV;
+		siginfo.errno = 0;
+		siginfo.si_code = SEGV_ADIDERR;
+		siginfo.si_addr = addr; /* PC where first mismatch occurred */
+		siginfo.si_trapno = 0;
+
+
+Precise memory corruption
+
+	When a store accesses a memory location that has TTE.mcd=1,
+	the task is running with ADI enabled (PSTATE.mcde=1), and the ADI
+	tag in the address used (bits 63:60) does not match the tag set on
+	the corresponding cacheline, a memory corruption trap occurs. If
+	MCD precise exception is enabled (MCDPERR=1), a precise
+	exception is sent to the kernel with TT=0x1a. The kernel sends
+	a SIGSEGV to the task that resulted in this trap with the following
+	info:
+
+		siginfo.si_signo = SIGSEGV;
+		siginfo.errno = 0;
+		siginfo.si_code = SEGV_ADIPERR;
+		siginfo.si_addr = addr;	/* address that caused trap */
+		siginfo.si_trapno = 0;
+
+	NOTE: ADI tag mismatch on a load always results in precise trap.
+
+
+MCD disabled
+
+	When a task has not enabled ADI and attempts to set ADI version
+	on a memory address, processor sends an MCD disabled trap. This
+	trap is handled by hypervisor first and the hypervisor vectors this
+	trap through to the kernel as Data Access Exception trap with
+	fault type set to 0xa (invalid ASI). When this occurs, the kernel
+	sends the task SIGSEGV signal with following info:
+
+		siginfo.si_signo = SIGSEGV;
+		siginfo.errno = 0;
+		siginfo.si_code = SEGV_ACCADI;
+		siginfo.si_addr = addr;	/* address that caused trap */
+		siginfo.si_trapno = 0;
+
+
+Sample program to use ADI
+-------------------------
+
+Following sample program is meant to illustrate how to use the ADI
+functionality.
+
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <elf.h>
+#include <sys/ipc.h>
+#include <sys/shm.h>
+#include <sys/mman.h>
+#include <asm/asi.h>
+
+#ifndef AT_ADI_BLKSZ
+#define AT_ADI_BLKSZ	48
+#endif
+#ifndef AT_ADI_NBITS
+#define AT_ADI_NBITS	49
+#endif
+
+#ifndef PROT_ADI
+#define PROT_ADI	0x10
+#endif
+
+#define BUFFER_SIZE     32*1024*1024UL
+
+main(int argc, char* argv[], char* envp[])
+{
+        unsigned long i, mcde, adi_blksz, adi_nbits;
+        char *shmaddr, *tmp_addr, *end, *veraddr, *clraddr;
+        int shmid, version;
+	Elf64_auxv_t *auxv;
+
+	adi_blksz = 0;
+
+	while(*envp++ != NULL);
+	for (auxv = (Elf64_auxv_t *)envp; auxv->a_type != AT_NULL; auxv++) {
+		switch (auxv->a_type) {
+		case AT_ADI_BLKSZ:
+			adi_blksz = auxv->a_un.a_val;
+			break;
+		case AT_ADI_NBITS:
+			adi_nbits = auxv->a_un.a_val;
+			break;
+		}
+	}
+	if (adi_blksz == 0) {
+		fprintf(stderr, "Oops! ADI is not supported\n");
+		exit(1);
+	}
+
+	printf("ADI capabilities:\n");
+	printf("\tBlock size = %ld\n", adi_blksz);
+	printf("\tNumber of bits = %ld\n", adi_nbits);
+
+        if ((shmid = shmget(2, BUFFER_SIZE,
+                                IPC_CREAT | SHM_R | SHM_W)) < 0) {
+                perror("shmget failed");
+                exit(1);
+        }
+
+        shmaddr = shmat(shmid, NULL, 0);
+        if (shmaddr == (char *)-1) {
+                perror("shm attach failed");
+                shmctl(shmid, IPC_RMID, NULL);
+                exit(1);
+        }
+
+	if (mprotect(shmaddr, BUFFER_SIZE, PROT_READ|PROT_WRITE|PROT_ADI)) {
+		perror("mprotect failed");
+		goto err_out;
+	}
+
+        /* Set the ADI version tag on the shm segment
+         */
+        version = 10;
+        tmp_addr = shmaddr;
+        end = shmaddr + BUFFER_SIZE;
+        while (tmp_addr < end) {
+                asm volatile(
+                        "stxa %1, [%0]0x90\n\t"
+                        :
+                        : "r" (tmp_addr), "r" (version));
+                tmp_addr += adi_blksz;
+        }
+	asm volatile("membar #Sync\n\t");
+
+        /* Create a versioned address from the normal address by placing
+	 * version tag in the upper adi_nbits bits
+         */
+        tmp_addr = (void *) ((unsigned long)shmaddr << adi_nbits);
+        tmp_addr = (void *) ((unsigned long)tmp_addr >> adi_nbits);
+        veraddr = (void *) (((unsigned long)version << (64-adi_nbits))
+                        | (unsigned long)tmp_addr);
+
+        printf("Starting the writes:\n");
+        for (i = 0; i < BUFFER_SIZE; i++) {
+                veraddr[i] = (char)(i);
+                if (!(i % (1024 * 1024)))
+                        printf(".");
+        }
+        printf("\n");
+
+        printf("Verifying data...");
+	fflush(stdout);
+        for (i = 0; i < BUFFER_SIZE; i++)
+                if (veraddr[i] != (char)i)
+                        printf("\nIndex %lu mismatched\n", i);
+        printf("Done.\n");
+
+        /* Disable ADI and clean up
+         */
+	if (mprotect(shmaddr, BUFFER_SIZE, PROT_READ|PROT_WRITE)) {
+		perror("mprotect failed");
+		goto err_out;
+	}
+
+        if (shmdt((const void *)shmaddr) != 0)
+                perror("Detach failure");
+        shmctl(shmid, IPC_RMID, NULL);
+
+        exit(0);
+
+err_out:
+        if (shmdt((const void *)shmaddr) != 0)
+                perror("Detach failure");
+        shmctl(shmid, IPC_RMID, NULL);
+        exit(1);
+}
diff --git a/arch/sparc/include/asm/mman.h b/arch/sparc/include/asm/mman.h
index 7e9472143f9b..f94532f25db1 100644
--- a/arch/sparc/include/asm/mman.h
+++ b/arch/sparc/include/asm/mman.h
@@ -7,5 +7,87 @@
 #ifndef __ASSEMBLY__
 #define arch_mmap_check(addr,len,flags)	sparc_mmap_check(addr,len)
 int sparc_mmap_check(unsigned long addr, unsigned long len);
-#endif
+
+#ifdef CONFIG_SPARC64
+#include <asm/adi_64.h>
+
+static inline void ipi_set_tstate_mcde(void *arg)
+{
+	struct mm_struct *mm = arg;
+
+	/* Set TSTATE_MCDE for the task using address map that ADI has been
+	 * enabled on if the task is running. If not, it will be set
+	 * automatically at the next context switch
+	 */
+	if (current->mm == mm) {
+		struct pt_regs *regs;
+
+		regs = task_pt_regs(current);
+		regs->tstate |= TSTATE_MCDE;
+	}
+}
+
+#define arch_calc_vm_prot_bits(prot, pkey) sparc_calc_vm_prot_bits(prot)
+static inline unsigned long sparc_calc_vm_prot_bits(unsigned long prot)
+{
+	if (adi_capable() && (prot & PROT_ADI)) {
+		struct pt_regs *regs;
+
+		if (!current->mm->context.adi) {
+			regs = task_pt_regs(current);
+			regs->tstate |= TSTATE_MCDE;
+			current->mm->context.adi = true;
+			on_each_cpu_mask(mm_cpumask(current->mm),
+					 ipi_set_tstate_mcde, current->mm, 0);
+		}
+		return VM_SPARC_ADI;
+	} else {
+		return 0;
+	}
+}
+
+#define arch_vm_get_page_prot(vm_flags) sparc_vm_get_page_prot(vm_flags)
+static inline pgprot_t sparc_vm_get_page_prot(unsigned long vm_flags)
+{
+	return (vm_flags & VM_SPARC_ADI) ? __pgprot(_PAGE_MCD_4V) : __pgprot(0);
+}
+
+#define arch_validate_prot(prot, addr) sparc_validate_prot(prot, addr)
+static inline int sparc_validate_prot(unsigned long prot, unsigned long addr)
+{
+	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_ADI))
+		return 0;
+	if (prot & PROT_ADI) {
+		if (!adi_capable())
+			return 0;
+
+		if (addr) {
+			struct vm_area_struct *vma;
+
+			vma = find_vma(current->mm, addr);
+			if (vma) {
+				/* ADI can not be enabled on PFN
+				 * mapped pages
+				 */
+				if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+					return 0;
+
+				/* Mergeable pages can become unmergeable
+				 * if ADI is enabled on them even if they
+				 * have identical data on them. This can be
+				 * because ADI enabled pages with identical
+				 * data may still not have identical ADI
+				 * tags on them. Disallow ADI on mergeable
+				 * pages.
+				 */
+				if (vma->vm_flags & VM_MERGEABLE)
+					return 0;
+			}
+		}
+	}
+	return 1;
+}
+#endif /* CONFIG_SPARC64 */
+
+#endif /* __ASSEMBLY__ */
 #endif /* __SPARC_MMAN_H__ */
diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index ad4fb93508ba..7e2704c770e9 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -90,6 +90,20 @@ struct tsb_config {
 #define MM_NUM_TSBS	1
 #endif
 
+/* ADI tags are stored when a page is swapped out and the storage for
+ * tags is allocated dynamically. There is a tag storage descriptor
+ * associated with each set of tag storage pages. Tag storage descriptors
+ * are allocated dynamically. Since kernel will allocate a full page for
+ * each tag storage descriptor, we can store up to
+ * PAGE_SIZE/sizeof(tag storage descriptor) descriptors on that page.
+ */
+typedef struct {
+	unsigned long	start;		/* Start address for this tag storage */
+	unsigned long	end;		/* Last address for tag storage */
+	unsigned char	*tags;		/* Where the tags are */
+	unsigned long	tag_users;	/* number of references to descriptor */
+} tag_storage_desc_t;
+
 typedef struct {
 	spinlock_t		lock;
 	unsigned long		sparc64_ctx_val;
@@ -98,6 +112,9 @@ typedef struct {
 	struct tsb_config	tsb_block[MM_NUM_TSBS];
 	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
 	void			*vdso;
+	bool			adi;
+	tag_storage_desc_t	*tag_store;
+	spinlock_t		tag_lock;
 } mm_context_t;
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
index b361702ef52a..d12b35ac46d3 100644
--- a/arch/sparc/include/asm/mmu_context_64.h
+++ b/arch/sparc/include/asm/mmu_context_64.h
@@ -11,6 +11,7 @@
 #include <linux/smp.h>
 
 #include <asm/spitfire.h>
+#include <asm/adi_64.h>
 #include <asm-generic/mm_hooks.h>
 #include <asm/percpu.h>
 
@@ -136,6 +137,55 @@ static inline void switch_mm(struct mm_struct *old_mm, struct mm_struct *mm, str
 
 #define deactivate_mm(tsk,mm)	do { } while (0)
 #define activate_mm(active_mm, mm) switch_mm(active_mm, mm, NULL)
+
+#define  __HAVE_ARCH_START_CONTEXT_SWITCH
+static inline void arch_start_context_switch(struct task_struct *prev)
+{
+	/* Save the current state of MCDPER register for the process
+	 * we are switching from
+	 */
+	if (adi_capable()) {
+		register unsigned long tmp_mcdper;
+
+		__asm__ __volatile__(
+			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
+			"mov %%g1, %0\n\t"
+			: "=r" (tmp_mcdper)
+			:
+			: "g1");
+		if (tmp_mcdper)
+			set_tsk_thread_flag(prev, TIF_MCDPER);
+		else
+			clear_tsk_thread_flag(prev, TIF_MCDPER);
+	}
+}
+
+#define finish_arch_post_lock_switch	finish_arch_post_lock_switch
+static inline void finish_arch_post_lock_switch(void)
+{
+	/* Restore the state of MCDPER register for the new process
+	 * just switched to.
+	 */
+	if (adi_capable()) {
+		register unsigned long tmp_mcdper;
+
+		tmp_mcdper = test_thread_flag(TIF_MCDPER);
+		__asm__ __volatile__(
+			"mov %0, %%g1\n\t"
+			".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" */
+			".word 0xaf902001\n\t"	/* wrpr %g0, 1, %pmcdper */
+			:
+			: "ir" (tmp_mcdper)
+			: "g1");
+		if (current && current->mm && current->mm->context.adi) {
+			struct pt_regs *regs;
+
+			regs = task_pt_regs(current);
+			regs->tstate |= TSTATE_MCDE;
+		}
+	}
+}
+
 #endif /* !(__ASSEMBLY__) */
 
 #endif /* !(__SPARC64_MMU_CONTEXT_H) */
diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
index c28379b1b0fc..e80f2d5bf62f 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -48,6 +48,12 @@ struct page;
 void clear_user_page(void *addr, unsigned long vaddr, struct page *page);
 #define copy_page(X,Y)	memcpy((void *)(X), (void *)(Y), PAGE_SIZE)
 void copy_user_page(void *to, void *from, unsigned long vaddr, struct page *topage);
+#define __HAVE_ARCH_COPY_USER_HIGHPAGE
+struct vm_area_struct;
+void copy_user_highpage(struct page *to, struct page *from,
+			unsigned long vaddr, struct vm_area_struct *vma);
+#define __HAVE_ARCH_COPY_HIGHPAGE
+void copy_highpage(struct page *to, struct page *from);
 
 /* Unlike sparc32, sparc64's parameter passing API is more
  * sane in that structures which as small enough are passed
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 619332a44402..44d6ac47e035 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -19,6 +19,7 @@
 #include <asm/types.h>
 #include <asm/spitfire.h>
 #include <asm/asi.h>
+#include <asm/adi.h>
 #include <asm/page.h>
 #include <asm/processor.h>
 
@@ -606,6 +607,18 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	return pte;
 }
 
+static inline pte_t pte_mkmcd(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_MCD_4V;
+	return pte;
+}
+
+static inline pte_t pte_mknotmcd(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_MCD_4V;
+	return pte;
+}
+
 static inline unsigned long pte_young(pte_t pte)
 {
 	unsigned long mask;
@@ -1048,6 +1061,39 @@ int page_in_phys_avail(unsigned long paddr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long, unsigned long,
 		    unsigned long, pgprot_t);
 
+void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct *vma,
+		      unsigned long addr, pte_t pte);
+
+int adi_save_tags(struct mm_struct *mm, struct vm_area_struct *vma,
+		  unsigned long addr, pte_t oldpte);
+
+#define __HAVE_ARCH_DO_SWAP_PAGE
+static inline void arch_do_swap_page(struct mm_struct *mm,
+				     struct vm_area_struct *vma,
+				     unsigned long addr,
+				     pte_t pte, pte_t oldpte)
+{
+	/* If this is a new page being mapped in, there can be no
+	 * ADI tags stored away for this page. Skip looking for
+	 * stored tags
+	 */
+	if (pte_none(oldpte))
+		return;
+
+	if (adi_state.enabled && (pte_val(pte) & _PAGE_MCD_4V))
+		adi_restore_tags(mm, vma, addr, pte);
+}
+
+#define __HAVE_ARCH_UNMAP_ONE
+static inline int arch_unmap_one(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 unsigned long addr, pte_t oldpte)
+{
+	if (adi_state.enabled && (pte_val(oldpte) & _PAGE_MCD_4V))
+		return adi_save_tags(mm, vma, addr, oldpte);
+	return 0;
+}
+
 static inline int io_remap_pfn_range(struct vm_area_struct *vma,
 				     unsigned long from, unsigned long pfn,
 				     unsigned long size, pgprot_t prot)
diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index f7e7b0baec9f..7fb676360928 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -188,7 +188,7 @@ register struct thread_info *current_thread_info_reg asm("g6");
  *       in using in assembly, else we can't use the mask as
  *       an immediate value in instructions such as andcc.
  */
-/* flag bit 12 is available */
+#define TIF_MCDPER		12	/* Precise MCD exception */
 #define TIF_MEMDIE		13	/* is terminating due to OOM killer */
 #define TIF_POLLING_NRFLAG	14
 
diff --git a/arch/sparc/include/asm/trap_block.h b/arch/sparc/include/asm/trap_block.h
index 6a4c8652ad67..0f6d0c4f6683 100644
--- a/arch/sparc/include/asm/trap_block.h
+++ b/arch/sparc/include/asm/trap_block.h
@@ -76,6 +76,8 @@ extern struct sun4v_1insn_patch_entry __sun4v_1insn_patch,
 	__sun4v_1insn_patch_end;
 extern struct sun4v_1insn_patch_entry __fast_win_ctrl_1insn_patch,
 	__fast_win_ctrl_1insn_patch_end;
+extern struct sun4v_1insn_patch_entry __sun_m7_1insn_patch,
+	__sun_m7_1insn_patch_end;
 
 struct sun4v_2insn_patch_entry {
 	unsigned int	addr;
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 715a2c927e79..f6f99ec65bb3 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -6,6 +6,8 @@
 
 /* SunOS'ified... */
 
+#define PROT_ADI	0x10		/* ADI enabled */
+
 #define MAP_RENAME      MAP_ANONYMOUS   /* In SunOS terminology */
 #define MAP_NORESERVE   0x40            /* don't reserve swap pages */
 #define MAP_INHERIT     0x80            /* SunOS doesn't do this, but... */
diff --git a/arch/sparc/kernel/adi_64.c b/arch/sparc/kernel/adi_64.c
index 8fb72585d9f1..d0a2ac975b42 100644
--- a/arch/sparc/kernel/adi_64.c
+++ b/arch/sparc/kernel/adi_64.c
@@ -8,10 +8,24 @@
  * This work is licensed under the terms of the GNU GPL, version 2.
  */
 #include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/mm_types.h>
 #include <asm/mdesc.h>
 #include <asm/adi_64.h>
+#include <asm/mmu_64.h>
+#include <asm/pgtable_64.h>
+
+/* Each page of storage for ADI tags can accommodate tags for 128
+ * pages. When ADI enabled pages are being swapped out, it would be
+ * prudent to allocate at least enough tag storage space to accommodate
+ * SWAPFILE_CLUSTER number of pages. Allocate enough tag storage to
+ * store tags for four SWAPFILE_CLUSTER pages to reduce need for
+ * further allocations for same vma.
+ */
+#define TAG_STORAGE_PAGES	8
 
 struct adi_config adi_state;
+EXPORT_SYMBOL(adi_state);
 
 /* mdesc_adi_init() : Parse machine description provided by the
  *	hypervisor to detect ADI capabilities
@@ -84,6 +98,19 @@ void __init mdesc_adi_init(void)
 		goto adi_not_found;
 	adi_state.caps.ue_on_adi = *val;
 
+	/* Some of the code to support swapping ADI tags is written
+	 * assumption that two ADI tags can fit inside one byte. If
+	 * this assumption is broken by a future architecture change,
+	 * that code will have to be revisited. If that were to happen,
+	 * disable ADI support so we do not get unpredictable results
+	 * with programs trying to use ADI and their pages getting
+	 * swapped out
+	 */
+	if (adi_state.caps.nbits > 4) {
+		pr_warn("WARNING: ADI tag size >4 on this platform. Disabling AADI support\n");
+		adi_state.enabled = false;
+	}
+
 	mdesc_release(hp);
 	return;
 
@@ -94,3 +121,277 @@ void __init mdesc_adi_init(void)
 	if (hp)
 		mdesc_release(hp);
 }
+
+tag_storage_desc_t *find_tag_store(struct mm_struct *mm,
+				   struct vm_area_struct *vma,
+				   unsigned long addr)
+{
+	tag_storage_desc_t *tag_desc = NULL;
+	unsigned long i, max_desc, flags;
+
+	/* Check if this vma already has tag storage descriptor
+	 * allocated for it.
+	 */
+	max_desc = PAGE_SIZE/sizeof(tag_storage_desc_t);
+	if (mm->context.tag_store) {
+		tag_desc = mm->context.tag_store;
+		spin_lock_irqsave(&mm->context.tag_lock, flags);
+		for (i = 0; i < max_desc; i++) {
+			if ((addr >= tag_desc->start) &&
+			    ((addr + PAGE_SIZE - 1) <= tag_desc->end))
+				break;
+			tag_desc++;
+		}
+		spin_unlock_irqrestore(&mm->context.tag_lock, flags);
+
+		/* If no matching entries were found, this must be a
+		 * freshly allocated page
+		 */
+		if (i >= max_desc)
+			tag_desc = NULL;
+	}
+
+	return tag_desc;
+}
+
+tag_storage_desc_t *alloc_tag_store(struct mm_struct *mm,
+				    struct vm_area_struct *vma,
+				    unsigned long addr)
+{
+	unsigned char *tags;
+	unsigned long i, size, max_desc, flags;
+	tag_storage_desc_t *tag_desc, *open_desc;
+	unsigned long end_addr, hole_start, hole_end;
+
+	max_desc = PAGE_SIZE/sizeof(tag_storage_desc_t);
+	open_desc = NULL;
+	hole_start = 0;
+	hole_end = ULONG_MAX;
+	end_addr = addr + PAGE_SIZE - 1;
+
+	/* Check if this vma already has tag storage descriptor
+	 * allocated for it.
+	 */
+	spin_lock_irqsave(&mm->context.tag_lock, flags);
+	if (mm->context.tag_store) {
+		tag_desc = mm->context.tag_store;
+
+		/* Look for a matching entry for this address. While doing
+		 * that, look for the first open slot as well and find
+		 * the hole in already allocated range where this request
+		 * will fit in.
+		 */
+		for (i = 0; i < max_desc; i++) {
+			if (tag_desc->tag_users == 0) {
+				if (open_desc == NULL)
+					open_desc = tag_desc;
+			} else {
+				if ((addr >= tag_desc->start) &&
+				    (tag_desc->end >= (addr + PAGE_SIZE - 1))) {
+					tag_desc->tag_users++;
+					goto out;
+				}
+			}
+			if ((tag_desc->start > end_addr) &&
+			    (tag_desc->start < hole_end))
+				hole_end = tag_desc->start;
+			if ((tag_desc->end < addr) &&
+			    (tag_desc->end > hole_start))
+				hole_start = tag_desc->end;
+			tag_desc++;
+		}
+
+	} else {
+		size = sizeof(tag_storage_desc_t)*max_desc;
+		mm->context.tag_store = kzalloc(size, GFP_NOWAIT|__GFP_NOWARN);
+		if (mm->context.tag_store == NULL) {
+			tag_desc = NULL;
+			goto out;
+		}
+		tag_desc = mm->context.tag_store;
+		for (i = 0; i < max_desc; i++, tag_desc++)
+			tag_desc->tag_users = 0;
+		open_desc = mm->context.tag_store;
+		i = 0;
+	}
+
+	/* Check if we ran out of tag storage descriptors */
+	if (open_desc == NULL) {
+		tag_desc = NULL;
+		goto out;
+	}
+
+	/* Mark this tag descriptor slot in use and then initialize it */
+	tag_desc = open_desc;
+	tag_desc->tag_users = 1;
+
+	/* Tag storage has not been allocated for this vma and space
+	 * is available in tag storage descriptor. Since this page is
+	 * being swapped out, there is high probability subsequent pages
+	 * in the VMA will be swapped out as well. Allocate pages to
+	 * store tags for as many pages in this vma as possible but not
+	 * more than TAG_STORAGE_PAGES. Each byte in tag space holds
+	 * two ADI tags since each ADI tag is 4 bits. Each ADI tag
+	 * covers adi_blksize() worth of addresses. Check if the hole is
+	 * big enough to accommodate full address range for using
+	 * TAG_STORAGE_PAGES number of tag pages.
+	 */
+	size = TAG_STORAGE_PAGES * PAGE_SIZE;
+	end_addr = addr + (size*2*adi_blksize()) - 1;
+	/* Check for overflow. If overflow occurs, allocate only one page */
+	if (end_addr < addr) {
+		size = PAGE_SIZE;
+		end_addr = addr + (size*2*adi_blksize()) - 1;
+		/* If overflow happens with the minimum tag storage
+		 * allocation as well, adjust ending address for this
+		 * tag storage.
+		 */
+		if (end_addr < addr)
+			end_addr = ULONG_MAX;
+	}
+	if (hole_end < end_addr) {
+		/* Available hole is too small on the upper end of
+		 * address. Can we expand the range towards the lower
+		 * address and maximize use of this slot?
+		 */
+		unsigned long tmp_addr;
+
+		end_addr = hole_end - 1;
+		tmp_addr = end_addr - (size*2*adi_blksize()) + 1;
+		/* Check for underflow. If underflow occurs, allocate
+		 * only one page for storing ADI tags
+		 */
+		if (tmp_addr > addr) {
+			size = PAGE_SIZE;
+			tmp_addr = end_addr - (size*2*adi_blksize()) - 1;
+			/* If underflow happens with the minimum tag storage
+			 * allocation as well, adjust starting address for
+			 * this tag storage.
+			 */
+			if (tmp_addr > addr)
+				tmp_addr = 0;
+		}
+		if (tmp_addr < hole_start) {
+			/* Available hole is restricted on lower address
+			 * end as well
+			 */
+			tmp_addr = hole_start + 1;
+		}
+		addr = tmp_addr;
+		size = (end_addr + 1 - addr)/(2*adi_blksize());
+		size = (size + (PAGE_SIZE-adi_blksize()))/PAGE_SIZE;
+		size = size * PAGE_SIZE;
+	}
+	tags = kzalloc(size, GFP_NOWAIT|__GFP_NOWARN);
+	if (tags == NULL) {
+		tag_desc->tag_users = 0;
+		tag_desc = NULL;
+		goto out;
+	}
+	tag_desc->start = addr;
+	tag_desc->tags = tags;
+	tag_desc->end = end_addr;
+
+out:
+	spin_unlock_irqrestore(&mm->context.tag_lock, flags);
+	return tag_desc;
+}
+
+void del_tag_store(tag_storage_desc_t *tag_desc, struct mm_struct *mm)
+{
+	unsigned long flags;
+	unsigned char *tags = NULL;
+
+	spin_lock_irqsave(&mm->context.tag_lock, flags);
+	tag_desc->tag_users--;
+	if (tag_desc->tag_users == 0) {
+		tag_desc->start = tag_desc->end = 0;
+		/* Do not free up the tag storage space allocated
+		 * by the first descriptor. This is persistent
+		 * emergency tag storage space for the task.
+		 */
+		if (tag_desc != mm->context.tag_store) {
+			tags = tag_desc->tags;
+			tag_desc->tags = NULL;
+		}
+	}
+	spin_unlock_irqrestore(&mm->context.tag_lock, flags);
+	kfree(tags);
+}
+
+#define tag_start(addr, tag_desc)		\
+	((tag_desc)->tags + ((addr - (tag_desc)->start)/(2*adi_blksize())))
+
+/* Retrieve any saved ADI tags for the page being swapped back in and
+ * restore these tags to the newly allocated physical page.
+ */
+void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct *vma,
+		      unsigned long addr, pte_t pte)
+{
+	unsigned char *tag;
+	tag_storage_desc_t *tag_desc;
+	unsigned long paddr, tmp, version1, version2;
+
+	/* Check if the swapped out page has an ADI version
+	 * saved. If yes, restore version tag to the newly
+	 * allocated page.
+	 */
+	tag_desc = find_tag_store(mm, vma, addr);
+	if (tag_desc == NULL)
+		return;
+
+	tag = tag_start(addr, tag_desc);
+	paddr = pte_val(pte) & _PAGE_PADDR_4V;
+	for (tmp = paddr; tmp < (paddr+PAGE_SIZE); tmp += adi_blksize()) {
+		version1 = (*tag) >> 4;
+		version2 = (*tag) & 0x0f;
+		*tag++ = 0;
+		asm volatile("stxa %0, [%1] %2\n\t"
+			:
+			: "r" (version1), "r" (tmp),
+			  "i" (ASI_MCD_REAL));
+		tmp += adi_blksize();
+		asm volatile("stxa %0, [%1] %2\n\t"
+			:
+			: "r" (version2), "r" (tmp),
+			  "i" (ASI_MCD_REAL));
+	}
+	asm volatile("membar #Sync\n\t");
+
+	/* Check and mark this tag space for release later if
+	 * the swapped in page was the last user of tag space
+	 */
+	del_tag_store(tag_desc, mm);
+}
+
+/* A page is about to be swapped out. Save any ADI tags associated with
+ * this physical page so they can be restored later when the page is swapped
+ * back in.
+ */
+int adi_save_tags(struct mm_struct *mm, struct vm_area_struct *vma,
+		  unsigned long addr, pte_t oldpte)
+{
+	unsigned char *tag;
+	tag_storage_desc_t *tag_desc;
+	unsigned long version1, version2, paddr, tmp;
+
+	tag_desc = alloc_tag_store(mm, vma, addr);
+	if (tag_desc == NULL)
+		return -1;
+
+	tag = tag_start(addr, tag_desc);
+	paddr = pte_val(oldpte) & _PAGE_PADDR_4V;
+	for (tmp = paddr; tmp < (paddr+PAGE_SIZE); tmp += adi_blksize()) {
+		asm volatile("ldxa [%1] %2, %0\n\t"
+				: "=r" (version1)
+				: "r" (tmp), "i" (ASI_MCD_REAL));
+		tmp += adi_blksize();
+		asm volatile("ldxa [%1] %2, %0\n\t"
+				: "=r" (version2)
+				: "r" (tmp), "i" (ASI_MCD_REAL));
+		*tag = (version1 << 4) | version2;
+		tag++;
+	}
+
+	return 0;
+}
diff --git a/arch/sparc/kernel/etrap_64.S b/arch/sparc/kernel/etrap_64.S
index 5c77a2e0e991..08cc41f64725 100644
--- a/arch/sparc/kernel/etrap_64.S
+++ b/arch/sparc/kernel/etrap_64.S
@@ -151,7 +151,32 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
 		or	%l7, %l0, %l7
-		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
+661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
+		/* If userspace is using ADI, it could potentially pass
+		 * a pointer with version tag embedded in it. To maintain
+		 * the ADI security, we must enable PSTATE.mcde. Userspace
+		 * would have already set TTE.mcd in an earlier call to
+		 * kernel and set the version tag for the address being
+		 * dereferenced. Setting PSTATE.mcde would ensure any
+		 * access to userspace data through a system call honors
+		 * ADI and does not allow a rogue app to bypass ADI by
+		 * using system calls. Setting PSTATE.mcde only affects
+		 * accesses to virtual addresses that have TTE.mcd set.
+		 * Set PMCDPER to ensure any exceptions caused by ADI
+		 * version tag mismatch are exposed before system call
+		 * returns to userspace. Setting PMCDPER affects only
+		 * writes to virtual addresses that have TTE.mcd set and
+		 * have a version tag set as well.
+		 */
+		.section .sun_m7_1insn_patch, "ax"
+		.word	661b
+		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
+		.previous
+661:		nop
+		.section .sun_m7_1insn_patch, "ax"
+		.word	661b
+		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */
+		.previous
 		or	%l7, %l0, %l7
 		wrpr	%l2, %tnpc
 		wrpr	%l7, (TSTATE_PRIV | TSTATE_IE), %tstate
diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
index 318efd784a0b..454a8af28f13 100644
--- a/arch/sparc/kernel/process_64.c
+++ b/arch/sparc/kernel/process_64.c
@@ -670,6 +670,31 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	return 0;
 }
 
+/* TIF_MCDPER in thread info flags for current task is updated lazily upon
+ * a context switch. Update this flag in current task's thread flags
+ * before dup so the dup'd task will inherit the current TIF_MCDPER flag.
+ */
+int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
+{
+	if (adi_capable()) {
+		register unsigned long tmp_mcdper;
+
+		__asm__ __volatile__(
+			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
+			"mov %%g1, %0\n\t"
+			: "=r" (tmp_mcdper)
+			:
+			: "g1");
+		if (tmp_mcdper)
+			set_thread_flag(TIF_MCDPER);
+		else
+			clear_thread_flag(TIF_MCDPER);
+	}
+
+	*dst = *src;
+	return 0;
+}
+
 typedef struct {
 	union {
 		unsigned int	pr_regs[32];
diff --git a/arch/sparc/kernel/rtrap_64.S b/arch/sparc/kernel/rtrap_64.S
index 0b21042ab181..f6528884a2c8 100644
--- a/arch/sparc/kernel/rtrap_64.S
+++ b/arch/sparc/kernel/rtrap_64.S
@@ -25,13 +25,31 @@
 		.align			32
 __handle_preemption:
 		call			SCHEDULE_USER
-		 wrpr			%g0, RTRAP_PSTATE, %pstate
+661:		 wrpr			%g0, RTRAP_PSTATE, %pstate
+		/* If userspace is using ADI, it could potentially pass
+		 * a pointer with version tag embedded in it. To maintain
+		 * the ADI security, we must re-enable PSTATE.mcde before
+		 * we continue execution in the kernel for another thread.
+		 */
+		.section .sun_m7_1insn_patch, "ax"
+		.word	661b
+		 wrpr			%g0, RTRAP_PSTATE|PSTATE_MCDE, %pstate
+		.previous
 		ba,pt			%xcc, __handle_preemption_continue
 		 wrpr			%g0, RTRAP_PSTATE_IRQOFF, %pstate
 
 __handle_user_windows:
 		call			fault_in_user_windows
-		 wrpr			%g0, RTRAP_PSTATE, %pstate
+661:		 wrpr			%g0, RTRAP_PSTATE, %pstate
+		/* If userspace is using ADI, it could potentially pass
+		 * a pointer with version tag embedded in it. To maintain
+		 * the ADI security, we must re-enable PSTATE.mcde before
+		 * we continue execution in the kernel for another thread.
+		 */
+		.section .sun_m7_1insn_patch, "ax"
+		.word	661b
+		 wrpr			%g0, RTRAP_PSTATE|PSTATE_MCDE, %pstate
+		.previous
 		ba,pt			%xcc, __handle_preemption_continue
 		 wrpr			%g0, RTRAP_PSTATE_IRQOFF, %pstate
 
@@ -48,7 +66,16 @@ __handle_signal:
 		add			%sp, PTREGS_OFF, %o0
 		mov			%l0, %o2
 		call			do_notify_resume
-		 wrpr			%g0, RTRAP_PSTATE, %pstate
+661:		 wrpr			%g0, RTRAP_PSTATE, %pstate
+		/* If userspace is using ADI, it could potentially pass
+		 * a pointer with version tag embedded in it. To maintain
+		 * the ADI security, we must re-enable PSTATE.mcde before
+		 * we continue execution in the kernel for another thread.
+		 */
+		.section .sun_m7_1insn_patch, "ax"
+		.word	661b
+		 wrpr			%g0, RTRAP_PSTATE|PSTATE_MCDE, %pstate
+		.previous
 		wrpr			%g0, RTRAP_PSTATE_IRQOFF, %pstate
 
 		/* Signal delivery can modify pt_regs tstate, so we must
diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 34f7a533a74f..7944b3ca216a 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -294,6 +294,8 @@ static void __init sun4v_patch(void)
 	case SUN4V_CHIP_SPARC_M7:
 	case SUN4V_CHIP_SPARC_M8:
 	case SUN4V_CHIP_SPARC_SN:
+		sun4v_patch_1insn_range(&__sun_m7_1insn_patch,
+					&__sun_m7_1insn_patch_end);
 		sun_m7_patch_2insn_range(&__sun_m7_2insn_patch,
 					 &__sun_m7_2insn_patch_end);
 		break;
diff --git a/arch/sparc/kernel/urtt_fill.S b/arch/sparc/kernel/urtt_fill.S
index 44183aa59168..e4cee7be5cd0 100644
--- a/arch/sparc/kernel/urtt_fill.S
+++ b/arch/sparc/kernel/urtt_fill.S
@@ -50,7 +50,12 @@ user_rtt_fill_fixup_common:
 		SET_GL(0)
 		.previous
 
-		wrpr	%g0, RTRAP_PSTATE, %pstate
+661:		wrpr	%g0, RTRAP_PSTATE, %pstate
+		.section		.sun_m7_1insn_patch, "ax"
+		.word			661b
+		/* Re-enable PSTATE.mcde to maintain ADI security */
+		wrpr	%g0, RTRAP_PSTATE|PSTATE_MCDE, %pstate
+		.previous
 
 		mov	%l1, %g6
 		ldx	[%g6 + TI_TASK], %g4
diff --git a/arch/sparc/kernel/vmlinux.lds.S b/arch/sparc/kernel/vmlinux.lds.S
index 5a2344574f39..61afd787bd0c 100644
--- a/arch/sparc/kernel/vmlinux.lds.S
+++ b/arch/sparc/kernel/vmlinux.lds.S
@@ -145,6 +145,11 @@ SECTIONS
 		*(.pause_3insn_patch)
 		__pause_3insn_patch_end = .;
 	}
+	.sun_m7_1insn_patch : {
+		__sun_m7_1insn_patch = .;
+		*(.sun_m7_1insn_patch)
+		__sun_m7_1insn_patch_end = .;
+	}
 	.sun_m7_2insn_patch : {
 		__sun_m7_2insn_patch = .;
 		*(.sun_m7_2insn_patch)
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 5335ba3c850e..357b6047653a 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -12,6 +12,7 @@
 #include <linux/pagemap.h>
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
+#include <asm/adi.h>
 
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
@@ -201,6 +202,24 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	pgd_t *pgdp;
 	int nr = 0;
 
+#ifdef CONFIG_SPARC64
+	if (adi_capable()) {
+		long addr = start;
+
+		/* If userspace has passed a versioned address, kernel
+		 * will not find it in the VMAs since it does not store
+		 * the version tags in the list of VMAs. Storing version
+		 * tags in list of VMAs is impractical since they can be
+		 * changed any time from userspace without dropping into
+		 * kernel. Any address search in VMAs will be done with
+		 * non-versioned addresses. Ensure the ADI version bits
+		 * are dropped here by sign extending the last bit before
+		 * ADI bits. IOMMU does not implement version tags.
+		 */
+		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();
+		start = addr;
+	}
+#endif
 	start &= PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
@@ -231,6 +250,24 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	pgd_t *pgdp;
 	int nr = 0;
 
+#ifdef CONFIG_SPARC64
+	if (adi_capable()) {
+		long addr = start;
+
+		/* If userspace has passed a versioned address, kernel
+		 * will not find it in the VMAs since it does not store
+		 * the version tags in the list of VMAs. Storing version
+		 * tags in list of VMAs is impractical since they can be
+		 * changed any time from userspace without dropping into
+		 * kernel. Any address search in VMAs will be done with
+		 * non-versioned addresses. Ensure the ADI version bits
+		 * are dropped here by sign extending the last bit before
+		 * ADI bits. IOMMU does not implements version tags,
+		 */
+		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();
+		start = addr;
+	}
+#endif
 	start &= PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 0112d6942288..f78793a06bbd 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -182,8 +182,20 @@ pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 			 struct page *page, int writeable)
 {
 	unsigned int shift = huge_page_shift(hstate_vma(vma));
+	pte_t pte;
 
-	return hugepage_shift_to_tte(entry, shift);
+	pte = hugepage_shift_to_tte(entry, shift);
+
+#ifdef CONFIG_SPARC64
+	/* If this vma has ADI enabled on it, turn on TTE.mcd
+	 */
+	if (vma->vm_flags & VM_SPARC_ADI)
+		return pte_mkmcd(pte);
+	else
+		return pte_mknotmcd(pte);
+#else
+	return pte;
+#endif
 }
 
 static unsigned int sun4v_huge_tte_to_shift(pte_t entry)
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 995f9490334d..cb9ebac6663f 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -3160,3 +3160,72 @@ void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 		do_flush_tlb_kernel_range(start, end);
 	}
 }
+
+void copy_user_highpage(struct page *to, struct page *from,
+	unsigned long vaddr, struct vm_area_struct *vma)
+{
+	char *vfrom, *vto;
+
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
+	copy_user_page(vto, vfrom, vaddr, to);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
+
+	/* If this page has ADI enabled, copy over any ADI tags
+	 * as well
+	 */
+	if (vma->vm_flags & VM_SPARC_ADI) {
+		unsigned long pfrom, pto, i, adi_tag;
+
+		pfrom = page_to_phys(from);
+		pto = page_to_phys(to);
+
+		for (i = pfrom; i < (pfrom + PAGE_SIZE); i += adi_blksize()) {
+			asm volatile("ldxa [%1] %2, %0\n\t"
+					: "=r" (adi_tag)
+					:  "r" (i), "i" (ASI_MCD_REAL));
+			asm volatile("stxa %0, [%1] %2\n\t"
+					:
+					: "r" (adi_tag), "r" (pto),
+					  "i" (ASI_MCD_REAL));
+			pto += adi_blksize();
+		}
+		asm volatile("membar #Sync\n\t");
+	}
+}
+EXPORT_SYMBOL(copy_user_highpage);
+
+void copy_highpage(struct page *to, struct page *from)
+{
+	char *vfrom, *vto;
+
+	vfrom = kmap_atomic(from);
+	vto = kmap_atomic(to);
+	copy_page(vto, vfrom);
+	kunmap_atomic(vto);
+	kunmap_atomic(vfrom);
+
+	/* If this platform is ADI enabled, copy any ADI tags
+	 * as well
+	 */
+	if (adi_capable()) {
+		unsigned long pfrom, pto, i, adi_tag;
+
+		pfrom = page_to_phys(from);
+		pto = page_to_phys(to);
+
+		for (i = pfrom; i < (pfrom + PAGE_SIZE); i += adi_blksize()) {
+			asm volatile("ldxa [%1] %2, %0\n\t"
+					: "=r" (adi_tag)
+					:  "r" (i), "i" (ASI_MCD_REAL));
+			asm volatile("stxa %0, [%1] %2\n\t"
+					:
+					: "r" (adi_tag), "r" (pto),
+					  "i" (ASI_MCD_REAL));
+			pto += adi_blksize();
+		}
+		asm volatile("membar #Sync\n\t");
+	}
+}
+EXPORT_SYMBOL(copy_highpage);
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index 75a04c1a2383..f5edc28aa3a5 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -546,6 +546,9 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 
 	mm->context.sparc64_ctx_val = 0UL;
 
+	mm->context.tag_store = NULL;
+	spin_lock_init(&mm->context.tag_lock);
+
 #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
 	/* We reset them to zero because the fork() page copying
 	 * will re-increment the counters as the parent PTEs are
@@ -611,4 +614,22 @@ void destroy_context(struct mm_struct *mm)
 	}
 
 	spin_unlock_irqrestore(&ctx_alloc_lock, flags);
+
+	/* If ADI tag storage was allocated for this task, free it */
+	if (mm->context.tag_store) {
+		tag_storage_desc_t *tag_desc;
+		unsigned long max_desc;
+		unsigned char *tags;
+
+		tag_desc = mm->context.tag_store;
+		max_desc = PAGE_SIZE/sizeof(tag_storage_desc_t);
+		for (i = 0; i < max_desc; i++) {
+			tags = tag_desc->tags;
+			tag_desc->tags = NULL;
+			kfree(tags);
+			tag_desc++;
+		}
+		kfree(mm->context.tag_store);
+		mm->context.tag_store = NULL;
+	}
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ae806dbc63ee..32fe6919a11b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -245,6 +245,9 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_GROWSUP	VM_ARCH_1
 #elif defined(CONFIG_IA64)
 # define VM_GROWSUP	VM_ARCH_1
+#elif defined(CONFIG_SPARC64)
+# define VM_SPARC_ADI	VM_ARCH_1	/* Uses ADI tag for access control */
+# define VM_ARCH_CLEAR	VM_SPARC_ADI
 #elif !defined(CONFIG_MMU)
 # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
 #endif
diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f5da70..adb5f991da8e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2369,6 +2369,10 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		if (*vm_flags & VM_SAO)
 			return 0;
 #endif
+#ifdef VM_SPARC_ADI
+		if (*vm_flags & VM_SPARC_ADI)
+			return 0;
+#endif
 
 		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
 			err = __ksm_enter(mm);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
