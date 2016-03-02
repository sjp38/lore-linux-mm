Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFFF6B0254
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 13:54:49 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id n190so1993256iof.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 10:54:49 -0800 (PST)
Received: from mailout.easymail.ca (mailout.easymail.ca. [64.68.201.169])
        by mx.google.com with ESMTPS id 4si7419059igy.84.2016.03.02.10.54.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 10:54:47 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH] sparc64: Add support for Application Data Integrity (ADI)
Date: Wed,  2 Mar 2016 11:54:09 -0700
Message-Id: <1456944849-21869-1-git-send-email-khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org
Cc: Khalid Aziz <khalid.aziz@oracle.com>, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


Enable Application Data Integrity (ADI) support in the sparc
kernel for applications to use ADI in userspace. ADI is a new
feature supported on sparc M7 and newer processors. ADI is supported
for data fetches only and not instruction fetches. This patch adds
prctl commands to enable and disable ADI (TSTATE.mcde), return ADI
parameters to userspace, enable/disable MCD (Memory Corruption
Detection) on selected memory ranges and enable TTE.mcd in PTEs. It
also adds handlers for all traps related to MCD. ADI is not enabled
by default for any task and a task must explicitly enable ADI
(TSTATE.mcde), turn MCD on on a memory range and set version tag
for ADI to be effective for the task. This patch adds support for
ADI for hugepages only. Addresses passed into system calls must be
non-ADI tagged addresses.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
NOTES: ADI is a new feature added to M7 processor to allow hardware
	to catch rogue accesses to memory. An app can enable ADI on
	its data pages, set version tags on them and use versioned
	addresses (bits 63-60 of the address contain a version tag)
	to access the data pages. If a rogue app attempts to access
	ADI enabled data pages, its access is blocked and processor
	generates an exception. Enabling this functionality for all
	data pages of an app requires adding infrastructure to save
	version tags for any data pages that get swapped out and
	restoring those tags when pages are swapped back in. In this
	first implementation I am enabling ADI for hugepages only
	since these pages are locked in memory and hence avoid the
	issue of saving and restoring tags. Once this core functionality
	is stable, ADI for other memory pages can be enabled more
	easily.

 Documentation/prctl/sparc_adi.txt     |  62 ++++++++++
 Documentation/sparc/adi.txt           | 206 +++++++++++++++++++++++++++++++
 arch/sparc/Kconfig                    |  12 ++
 arch/sparc/include/asm/hugetlb.h      |  14 +++
 arch/sparc/include/asm/hypervisor.h   |   2 +
 arch/sparc/include/asm/mmu_64.h       |   1 +
 arch/sparc/include/asm/pgtable_64.h   |  15 +++
 arch/sparc/include/asm/processor_64.h |  19 +++
 arch/sparc/include/asm/ttable.h       |  10 ++
 arch/sparc/include/uapi/asm/asi.h     |   3 +
 arch/sparc/include/uapi/asm/pstate.h  |  10 ++
 arch/sparc/kernel/entry.h             |   3 +
 arch/sparc/kernel/head_64.S           |   1 +
 arch/sparc/kernel/mdesc.c             |  81 +++++++++++++
 arch/sparc/kernel/process_64.c        | 221 ++++++++++++++++++++++++++++++++++
 arch/sparc/kernel/sun4v_mcd.S         |  16 +++
 arch/sparc/kernel/traps_64.c          |  96 ++++++++++++++-
 arch/sparc/kernel/ttable_64.S         |   6 +-
 include/linux/mm.h                    |   2 +
 include/uapi/asm-generic/siginfo.h    |   5 +-
 include/uapi/linux/prctl.h            |  16 +++
 kernel/sys.c                          |  30 +++++
 22 files changed, 825 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/prctl/sparc_adi.txt
 create mode 100644 Documentation/sparc/adi.txt
 create mode 100644 arch/sparc/kernel/sun4v_mcd.S

diff --git a/Documentation/prctl/sparc_adi.txt b/Documentation/prctl/sparc_adi.txt
new file mode 100644
index 0000000..9cbdcae
--- /dev/null
+++ b/Documentation/prctl/sparc_adi.txt
@@ -0,0 +1,62 @@
+========
+Overview
+========
+
+SPARC M7 processor includes the feature Application Data Integrity (ADI).
+ADI allows a tag to be associated with a virtual memory address range
+and a process must access that memory range with the correct tag. ADI
+tag is embedded in bits 63-60 of virtual address. Once ADI is enabled
+on a range of memory addresses, the process can set a tag for blocks
+in this memory range n the cache using ASI_MCD_PRIMARY or
+ASI_MCD_ST_BLKINIT_PRIMARY. This tag is set for ADI block sized blocks
+which is provided to the kernel by machine description table.
+
+Linux kernel supports an application enabling and setting the ADI tag
+for a subset of its data pages. Those data pages have to be locked in
+memory since saving ADI tags to swap is not supported.
+
+
+New prctl options for ADI
+-------------------------
+
+Following new options to prctl() have been added to support ADI.
+
+	PR_GET_SPARC_ADICAPS - Get ADI capabilities for the processor.
+		These capabilities are used to set up ADI correctly
+		from userspace. Machine description table provides all
+		of the ADI capabilities information. arg2 to prctl() is
+		a pointer to struct adi_caps which is defined in
+		linux/prctl.h.
+
+
+	PR_SET_SPARC_ADI - Set the state of ADI in a user thread by
+		setting PSTATE.mcde bit in the user mode PSTATE register
+		of the calling thread based on the value passed in arg2:
+			1 == enable, 0 == disable, other == no change
+		Return the previous state of the PSTATE.mcde bit:
+			0 == was disabled, 1 == was enabled.
+		Set errno to EINVAL and return -1 if ADI is not available.
+
+
+	PR_ENABLE_SPARC_ADI - Enable ADI checking in all pages in the address
+		range specified. The pages in the range must be already
+		locked. This operation enables the TTE.mcd bit for the
+		pages specified. arg2 is the starting address for address
+		range and must be page aligned. arg3 is the length of
+		memory address range and must be a multiple of page size.
+
+
+	PR_DISABLE_SPARC_ADI - Disable ADI checking on all the pages in the
+		address range specified. This operation disables the
+		TTE.mcd bit for the pages specified. arg2 is the
+		starting address for address range and must be page
+		aligned. arg3 is the length of memory address range and
+		must be a multiple of page size.
+
+
+	PR_GET_SPARC_ADI_STATUS - Check if ADI is enabled or not for a
+		given virtual address. Returns 1 for enabled, else 0.
+
+
+All addresses passed to kernel must be non-ADI tagged addresses.
+Kernel does not enable ADI for kernel code.
diff --git a/Documentation/sparc/adi.txt b/Documentation/sparc/adi.txt
new file mode 100644
index 0000000..ac4a9d9
--- /dev/null
+++ b/Documentation/sparc/adi.txt
@@ -0,0 +1,206 @@
+Application Data Integrity (ADI)
+================================
+
+Sparc M7 processor adds the Application Data Integrity (ADI) feature.
+ADI allows a task to set version tags on any subset of its address
+space. Once ADI is enabled and version tags are set for ranges of
+address space of a task, the processor will compare the tag in pointers
+to memory in these ranges to the version set by the application
+previously. Access to memory is granted only if the tag in given
+pointer matches the tag set by the application. In case of mismatch,
+processor raises an exception.  ADI can be enabled on pages that are
+locked in memory, i.e.  are not swappable.
+
+Following steps must be taken by a task to enable ADI fully:
+
+1. Set the user mode PSTATE.mcde bit
+
+2. Set TTE.mcd bit on any TLB entries that correspond to the range of
+addresses ADI is being enabled on.
+
+3. Set the version tag for memory addresses.
+
+Kernel provides prctl() calls to perform steps 1 (PR_SET_SPARC_ADI) and
+2 (PR_ENABLE_SPARC_ADI). Please see Documentation/prctl/sparc_adi.txt
+for more details on these prctl calls. Step 3 is performed with an
+stxa instruction on the address using ASI_MCD_PRIMARY or
+ASI_MCD_ST_BLKINIT_PRIMARY. Version tags are stoed in bits 63-60 of
+address and are set on a cache line. Version tag values of 0x0 and 0xf
+are reserved.
+
+NOTE:	ADI is supported on hugepage only. Hugepages are already locked
+	in memory.
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
+		siginfo.si_addr = addr; /* address that caused trap */
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
+	sends the task SIGBUS signal with following info:
+
+		siginfo.si_signo = SIGBUS;
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
+functionality with the default 8M hugepages.
+
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/ipc.h>
+#include <sys/shm.h>
+#include <asm/asi.h>
+#include <linux/prctl.h>
+
+#define BUFFER_SIZE	32*1024*1024
+
+struct adi_caps adicap;
+
+main()
+{
+	unsigned long i, mcde;
+	char *shmaddr, *tmp_addr, *end, *veraddr, *clraddr;
+	int shmid, version;
+
+	if ((shmid = shmget(2, BUFFER_SIZE,
+				SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W)) < 0) {
+		perror("shmget failed");
+		exit(1);
+	}
+
+	shmaddr = shmat(shmid, NULL, 0);
+	if (shmaddr == (char *)-1) {
+		perror("shm attach failed");
+		shmctl(shmid, IPC_RMID, NULL);
+		exit(1);
+	}
+
+	/* Get the values for various ADI capabilities bits. These will
+	 * be used later for setting the ADI tag
+	 */
+	if (prctl(PR_GET_SPARC_ADICAPS, &adicap) < 0) {
+		perror("PR_GET_SPARC_ADICAPS failed");
+		goto err_out;
+	}
+
+	/* Set PSTATE.mcde
+	 */
+	if ((mcde = prctl(PR_SET_SPARC_ADI, PR_SET_SPARC_ADI_SET)) < 0) {
+		perror("PR_SET_SPARC_ADI failed");
+		goto err_out;
+	}
+
+	/* Set TTE.mcd on the address range for shm segment
+	 */
+	if (prctl(PR_ENABLE_SPARC_ADI, shmaddr, BUFFER_SIZE) < 0) {
+		perror("prctl failed");
+		goto err_out;
+	}
+
+	/* Set the ADI version tag on the shm segment
+	 */
+	version = 10;
+	tmp_addr = shmaddr;
+	end = shmaddr + BUFFER_SIZE;
+	while (tmp_addr < end) {
+		asm volatile(
+			"stxa %1, [%0]ASI_MCD_PRIMARY\n\t"
+			:
+			: "r" (tmp_addr), "r" (version));
+		tmp_addr += adicap.blksz;
+	}
+
+	/* Create a versioned address from the normal address
+	 */
+	tmp_addr = (void *) ((unsigned long)shmaddr << adicap.nbits);
+	tmp_addr = (void *) ((unsigned long)tmp_addr >> adicap.nbits);
+	veraddr = (void *) (((unsigned long)version << (64-adicap.nbits))
+			| (unsigned long)tmp_addr);
+
+	printf("Starting the writes:\n");
+	for (i = 0; i < BUFFER_SIZE; i++) {
+		veraddr[i] = (char)(i);
+		if (!(i % (1024 * 1024)))
+			printf(".");
+	}
+	printf("\n");
+
+	printf("Verifying data...");
+	for (i = 0; i < BUFFER_SIZE; i++)
+		if (veraddr[i] != (char)i)
+			printf("\nIndex %lu mismatched\n", i);
+	printf("Done.\n");
+
+	/* Disable ADI and clean up
+	 */
+	if (prctl(PR_DISABLE_SPARC_ADI, shmaddr, BUFFER_SIZE) < 0) {
+		perror("prctl failed");
+		goto err_out;
+	}
+
+	if (shmdt((const void *)shmaddr) != 0)
+		perror("Detach failure");
+	shmctl(shmid, IPC_RMID, NULL);
+
+	exit(0);
+
+err_out:
+	if (shmdt((const void *)shmaddr) != 0)
+		perror("Detach failure");
+	shmctl(shmid, IPC_RMID, NULL);
+	exit(1);
+}
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 56442d2..0aac0ae 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -80,6 +80,7 @@ config SPARC64
 	select NO_BOOTMEM
 	select HAVE_ARCH_AUDITSYSCALL
 	select ARCH_SUPPORTS_ATOMIC_RMW
+	select SPARC_ADI
 
 config ARCH_DEFCONFIG
 	string
@@ -314,6 +315,17 @@ if SPARC64
 source "kernel/power/Kconfig"
 endif
 
+config SPARC_ADI
+	bool "Application Data Integrity support"
+	def_bool y if SPARC64
+	help
+	  Support for Application Data Integrity (ADI). ADI feature allows
+	  a process to tag memory blocks with version tags. Once ADI is
+	  enabled and version tag is set on a memory block, any access to
+	  it is allowed only if the correct version tag is presented by
+	  a process. This feature is meant to help catch rogue accesses
+	  to memory.
+
 config SCHED_SMT
 	bool "SMT (Hyperthreading) scheduler support"
 	depends on SPARC64 && SMP
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 139e711..5e7547c 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -82,4 +82,18 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#ifdef CONFIG_SPARC_ADI
+static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
+			 struct page *page, int writeable)
+{
+	/* If this vma has ADI enabled on it, turn on TTE.mcd
+	 */
+	if (vma->vm_flags & VM_SPARC_ADI)
+		return pte_mkmcd(entry);
+	else
+		return pte_mknotmcd(entry);
+}
+#define arch_make_huge_pte arch_make_huge_pte
+#endif
+
 #endif /* _ASM_SPARC64_HUGETLB_H */
diff --git a/arch/sparc/include/asm/hypervisor.h b/arch/sparc/include/asm/hypervisor.h
index f5b6537..2940bb3 100644
--- a/arch/sparc/include/asm/hypervisor.h
+++ b/arch/sparc/include/asm/hypervisor.h
@@ -547,6 +547,8 @@ struct hv_fault_status {
 #define HV_FAULT_TYPE_RESV1	13
 #define HV_FAULT_TYPE_UNALIGNED	14
 #define HV_FAULT_TYPE_INV_PGSZ	15
+#define HV_FAULT_TYPE_MCD	17
+#define HV_FAULT_TYPE_MCD_DIS	18
 /* Values 16 --> -2 are reserved.  */
 #define HV_FAULT_TYPE_MULTIPLE	-1
 
diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index 70067ce..8e98741 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -95,6 +95,7 @@ typedef struct {
 	unsigned long		huge_pte_count;
 	struct tsb_config	tsb_block[MM_NUM_TSBS];
 	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
+	unsigned char		adi;
 } mm_context_t;
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 131d36f..cddea30 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -162,6 +162,9 @@ bool kern_addr_valid(unsigned long addr);
 #define _PAGE_E_4V	  _AC(0x0000000000000800,UL) /* side-Effect          */
 #define _PAGE_CP_4V	  _AC(0x0000000000000400,UL) /* Cacheable in P-Cache */
 #define _PAGE_CV_4V	  _AC(0x0000000000000200,UL) /* Cacheable in V-Cache */
+/* Bit 9 is used to enable MCD corruption detection instead on M7
+ */
+#define _PAGE_MCD_4V	  _AC(0x0000000000000200,UL) /* Memory Corruption    */
 #define _PAGE_P_4V	  _AC(0x0000000000000100,UL) /* Privileged Page      */
 #define _PAGE_EXEC_4V	  _AC(0x0000000000000080,UL) /* Executable Page      */
 #define _PAGE_W_4V	  _AC(0x0000000000000040,UL) /* Writable             */
@@ -541,6 +544,18 @@ static inline pte_t pte_mkspecial(pte_t pte)
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
diff --git a/arch/sparc/include/asm/processor_64.h b/arch/sparc/include/asm/processor_64.h
index 6924bde..9a71701 100644
--- a/arch/sparc/include/asm/processor_64.h
+++ b/arch/sparc/include/asm/processor_64.h
@@ -97,6 +97,25 @@ struct thread_struct {
 struct task_struct;
 unsigned long thread_saved_pc(struct task_struct *);
 
+#ifdef CONFIG_SPARC_ADI
+extern struct adi_caps *get_adi_caps(void);
+extern long get_sparc_adicaps(unsigned long);
+extern long set_sparc_pstate_mcde(unsigned long);
+extern long enable_sparc_adi(unsigned long, unsigned long);
+extern long disable_sparc_adi(unsigned long, unsigned long);
+extern long get_sparc_adi_status(unsigned long);
+extern bool adi_capable(void);
+
+#define GET_SPARC_ADICAPS(a)	get_sparc_adicaps(a)
+#define SET_SPARC_MCDE(a)	set_sparc_pstate_mcde(a)
+#define ENABLE_SPARC_ADI(a, b)	enable_sparc_adi(a, b)
+#define DISABLE_SPARC_ADI(a, b)	disable_sparc_adi(a, b)
+#define GET_SPARC_ADI_STATUS(a)	get_sparc_adi_status(a)
+#define ADI_CAPABLE()		adi_capable()
+#else
+#define ADI_CAPABLE()		0
+#endif
+
 /* On Uniprocessor, even in RMO processes see TSO semantics */
 #ifdef CONFIG_SMP
 #define TSTATE_INITIAL_MM	TSTATE_TSO
diff --git a/arch/sparc/include/asm/ttable.h b/arch/sparc/include/asm/ttable.h
index 71b5a67..342b457 100644
--- a/arch/sparc/include/asm/ttable.h
+++ b/arch/sparc/include/asm/ttable.h
@@ -212,6 +212,16 @@
 	nop;						\
 	nop;
 
+#define SUN4V_MCD_PRECISE				\
+	ldxa	[%g0] ASI_SCRATCHPAD, %g2;		\
+	ldx	[%g2 + HV_FAULT_D_ADDR_OFFSET], %g4;	\
+	ldx	[%g2 + HV_FAULT_D_CTX_OFFSET], %g5;	\
+	ba,pt	%xcc, sun4v_mcd_detect_precise;		\
+	 nop;						\
+	nop;						\
+	nop;						\
+	nop;
+
 /* Before touching these macros, you owe it to yourself to go and
  * see how arch/sparc64/kernel/winfixup.S works... -DaveM
  *
diff --git a/arch/sparc/include/uapi/asm/asi.h b/arch/sparc/include/uapi/asm/asi.h
index 7ad7203d..7d099ac 100644
--- a/arch/sparc/include/uapi/asm/asi.h
+++ b/arch/sparc/include/uapi/asm/asi.h
@@ -244,6 +244,9 @@
 #define ASI_UDBL_CONTROL_R	0x7f /* External UDB control regs rd low*/
 #define ASI_INTR_R		0x7f /* IRQ vector dispatch read	*/
 #define ASI_INTR_DATAN_R	0x7f /* (III) In irq vector data reg N	*/
+#define ASI_MCD_PRIMARY		0x90 /* (NG7) MCD version load/store	*/
+#define ASI_MCD_ST_BLKINIT_PRIMARY	\
+				0x92 /* (NG7) MCD store BLKINIT primary	*/
 #define ASI_PIC			0xb0 /* (NG4) PIC registers		*/
 #define ASI_PST8_P		0xc0 /* Primary, 8 8-bit, partial	*/
 #define ASI_PST8_S		0xc1 /* Secondary, 8 8-bit, partial	*/
diff --git a/arch/sparc/include/uapi/asm/pstate.h b/arch/sparc/include/uapi/asm/pstate.h
index cf832e1..d0521db 100644
--- a/arch/sparc/include/uapi/asm/pstate.h
+++ b/arch/sparc/include/uapi/asm/pstate.h
@@ -10,7 +10,12 @@
  * -----------------------------------------------------------------------
  *  63  12  11   10    9     8    7   6   5     4     3     2     1    0
  */
+/* IG on V9 conflicts with MCDE on M7. PSTATE_MCDE will only be used on
+ * processors that support ADI which do not use IG, hence there is no
+ * functional conflict
+ */
 #define PSTATE_IG   _AC(0x0000000000000800,UL) /* Interrupt Globals.	*/
+#define PSTATE_MCDE _AC(0x0000000000000800,UL) /* MCD Enable		*/
 #define PSTATE_MG   _AC(0x0000000000000400,UL) /* MMU Globals.		*/
 #define PSTATE_CLE  _AC(0x0000000000000200,UL) /* Current Little Endian.*/
 #define PSTATE_TLE  _AC(0x0000000000000100,UL) /* Trap Little Endian.	*/
@@ -47,7 +52,12 @@
 #define TSTATE_ASI	_AC(0x00000000ff000000,UL) /* AddrSpace ID.	*/
 #define TSTATE_PIL	_AC(0x0000000000f00000,UL) /* %pil (Linux traps)*/
 #define TSTATE_PSTATE	_AC(0x00000000000fff00,UL) /* PSTATE.		*/
+/* IG on V9 conflicts with MCDE on M7. TSTATE_MCDE will only be used on
+ * processors that support ADI which do not support IG, hence there is
+ * no functional conflict
+ */
 #define TSTATE_IG	_AC(0x0000000000080000,UL) /* Interrupt Globals.*/
+#define TSTATE_MCDE	_AC(0x0000000000080000,UL) /* MCD enable.       */
 #define TSTATE_MG	_AC(0x0000000000040000,UL) /* MMU Globals.	*/
 #define TSTATE_CLE	_AC(0x0000000000020000,UL) /* CurrLittleEndian.	*/
 #define TSTATE_TLE	_AC(0x0000000000010000,UL) /* TrapLittleEndian.	*/
diff --git a/arch/sparc/kernel/entry.h b/arch/sparc/kernel/entry.h
index 0f67942..2078468 100644
--- a/arch/sparc/kernel/entry.h
+++ b/arch/sparc/kernel/entry.h
@@ -159,6 +159,9 @@ void sun4v_resum_overflow(struct pt_regs *regs);
 void sun4v_nonresum_error(struct pt_regs *regs,
 			  unsigned long offset);
 void sun4v_nonresum_overflow(struct pt_regs *regs);
+void sun4v_mem_corrupt_detect_precise(struct pt_regs *regs,
+				      unsigned long addr,
+				      unsigned long context);
 
 extern unsigned long sun4v_err_itlb_vaddr;
 extern unsigned long sun4v_err_itlb_ctx;
diff --git a/arch/sparc/kernel/head_64.S b/arch/sparc/kernel/head_64.S
index f2d30ca..f4a880b 100644
--- a/arch/sparc/kernel/head_64.S
+++ b/arch/sparc/kernel/head_64.S
@@ -878,6 +878,7 @@ sparc64_boot_end:
 #include "helpers.S"
 #include "hvcalls.S"
 #include "sun4v_tlb_miss.S"
+#include "sun4v_mcd.S"
 #include "sun4v_ivec.S"
 #include "ktlb.S"
 #include "tsb.S"
diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 6f80936..79f981c 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -12,6 +12,7 @@
 #include <linux/miscdevice.h>
 #include <linux/bootmem.h>
 #include <linux/export.h>
+#include <linux/prctl.h>
 
 #include <asm/cpudata.h>
 #include <asm/hypervisor.h>
@@ -512,6 +513,11 @@ EXPORT_SYMBOL(mdesc_node_name);
 
 static u64 max_cpus = 64;
 
+static struct {
+	bool enabled;
+	struct adi_caps caps;
+} adi_state;
+
 static void __init report_platform_properties(void)
 {
 	struct mdesc_handle *hp = mdesc_grab();
@@ -1007,6 +1013,80 @@ static int mdesc_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
+bool adi_capable(void)
+{
+	return adi_state.enabled;
+}
+
+struct adi_caps *get_adi_caps(void)
+{
+	return &adi_state.caps;
+}
+
+void __init
+init_adi(void)
+{
+	struct mdesc_handle *hp = mdesc_grab();
+	const char *prop;
+	u64 pn, *val;
+	int len;
+
+	adi_state.enabled = false;
+
+	if (!hp)
+		return;
+
+	pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "cpu");
+	if (pn == MDESC_NODE_NULL)
+		goto out;
+
+	prop = mdesc_get_property(hp, pn, "hwcap-list", &len);
+	if (!prop)
+		goto out;
+
+	/*
+	 * Look for "adp" keyword in hwcap-list which would indicate
+	 * ADI support
+	 */
+	while (len) {
+		int plen;
+
+		if (!strcmp(prop, "adp")) {
+			adi_state.enabled = true;
+			break;
+		}
+
+		plen = strlen(prop) + 1;
+		prop += plen;
+		len -= plen;
+	}
+
+	if (!adi_state.enabled)
+		goto out;
+
+	pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "platform");
+	if (pn == MDESC_NODE_NULL)
+		goto out;
+
+	val = (u64 *) mdesc_get_property(hp, pn, "adp-blksz", &len);
+	if (!val)
+		goto out;
+	adi_state.caps.blksz = *val;
+
+	val = (u64 *) mdesc_get_property(hp, pn, "adp-nbits", &len);
+	if (!val)
+		goto out;
+	adi_state.caps.nbits = *val;
+
+	val = (u64 *) mdesc_get_property(hp, pn, "ue-on-adp", &len);
+	if (!val)
+		goto out;
+	adi_state.caps.ue_on_adi = *val;
+
+out:
+	mdesc_release(hp);
+}
+
 static ssize_t mdesc_read(struct file *file, char __user *buf,
 			  size_t len, loff_t *offp)
 {
@@ -1110,5 +1190,6 @@ void __init sun4v_mdesc_init(void)
 
 	cur_mdesc = hp;
 
+	init_adi();
 	report_platform_properties();
 }
diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
index 46a5964..33fcc85 100644
--- a/arch/sparc/kernel/process_64.c
+++ b/arch/sparc/kernel/process_64.c
@@ -32,6 +32,8 @@
 #include <linux/sysrq.h>
 #include <linux/nmi.h>
 #include <linux/context_tracking.h>
+#include <linux/prctl.h>
+#include <linux/hugetlb.h>
 
 #include <asm/uaccess.h>
 #include <asm/page.h>
@@ -777,3 +779,222 @@ unsigned long get_wchan(struct task_struct *task)
 out:
 	return ret;
 }
+
+#ifdef CONFIG_SPARC_ADI
+long get_sparc_adicaps(unsigned long val)
+{
+	struct adi_caps *caps;
+
+	if (!ADI_CAPABLE())
+		return -EINVAL;
+
+	caps = get_adi_caps();
+	if (val)
+		if (copy_to_user((void *)val, caps, sizeof(struct adi_caps)))
+			return -EFAULT;
+	return 0;
+}
+
+long set_sparc_pstate_mcde(unsigned long val)
+{
+	unsigned long error;
+	struct pt_regs *regs;
+
+	if (!ADI_CAPABLE())
+		return -EINVAL;
+
+	/* We do not allow anonymous tasks to enable ADI because they
+	 * run in borrowed aadress space.
+	 */
+	if (current->mm == NULL)
+		return -EINVAL;
+
+	regs = task_pt_regs(current);
+	if (regs->tstate & TSTATE_MCDE)
+		error = 1;
+	else
+		error = 0;
+	switch (val) {
+	case 1:
+		regs->tstate |= TSTATE_MCDE;
+		current->mm->context.adi = 1;
+		break;
+	case 0:
+		regs->tstate &= ~TSTATE_MCDE;
+		current->mm->context.adi = 0;
+		break;
+	default:
+		break;
+	}
+
+	return error;
+}
+
+long enable_sparc_adi(unsigned long addr, unsigned long len)
+{
+	unsigned long end, pagemask;
+	int error;
+	struct vm_area_struct *vma, *vma2;
+	struct mm_struct *mm;
+
+	if (!ADI_CAPABLE())
+		return -EINVAL;
+
+	vma = find_vma(current->mm, addr);
+	if (unlikely(!vma) || (vma->vm_start > addr))
+		return -EFAULT;
+
+	/* ADI is supported for hugepages only
+	 */
+	if (!is_vm_hugetlb_page(vma))
+		return -EFAULT;
+
+	/* Is the start address page aligned and is the length multiple
+	 * of page size?
+	 */
+	pagemask = ~(vma_kernel_pagesize(vma) - 1);
+	if (addr & ~pagemask)
+		return -EINVAL;
+	if (len & ~pagemask)
+		return -EINVAL;
+
+	end = addr + len;
+	if (end == addr)
+		return 0;
+
+	/* Verify end of the region is not out of bounds
+	 */
+	vma2 = find_vma(current->mm, end-1);
+	if (unlikely(!vma2) || (vma2->vm_start > end))
+		return -EFAULT;
+
+	error = 0;
+	while (1) {
+		/* If the address space ADI is to be enabled in, does not cover
+		 * this vma in its entirety, we will need to split it.
+		 */
+		mm = vma->vm_mm;
+		if (addr != vma->vm_start) {
+			error = split_vma(mm, vma, addr, 1);
+			if (error)
+				goto out;
+		}
+
+		if (end < vma->vm_end) {
+			error = split_vma(mm, vma, end, 0);
+			if (error)
+				goto out;
+		}
+
+		/* Update the ADI info in vma and PTE
+		 */
+		vma->vm_flags |= VM_SPARC_ADI;
+
+		if (end > vma->vm_end) {
+			change_protection(vma, addr, vma->vm_end,
+					  vma->vm_page_prot,
+					  vma_wants_writenotify(vma), 0);
+			addr = vma->vm_end;
+		} else {
+			change_protection(vma, addr, end, vma->vm_page_prot,
+					vma_wants_writenotify(vma), 0);
+			break;
+		}
+
+		vma = find_vma(current->mm, addr);
+		if (unlikely(!vma) || (vma->vm_start > addr))
+			return -EFAULT;
+	}
+out:
+	if (error == -ENOMEM)
+		error = -EAGAIN;
+	return error;
+}
+
+long disable_sparc_adi(unsigned long addr, unsigned long len)
+{
+	unsigned long end, pagemask;
+	struct vm_area_struct *vma, *vma2, *prev;
+	struct mm_struct *mm;
+	pgoff_t pgoff;
+
+	if (!ADI_CAPABLE())
+		return -EINVAL;
+
+	vma = find_vma(current->mm, addr);
+	if (unlikely(!vma) || (vma->vm_start > addr))
+		return -EFAULT;
+
+	/* ADI is supported for hugepages only
+	 */
+	if (!is_vm_hugetlb_page(vma))
+		return -EINVAL;
+
+	/* Is the start address page aligned and is the length multiple
+	 * of page size?
+	 */
+	pagemask = ~(vma_kernel_pagesize(vma) - 1);
+	if (addr & ~pagemask)
+		return -EINVAL;
+	if (len & ~pagemask)
+		return -EINVAL;
+
+	end = addr + len;
+	if (end == addr)
+		return 0;
+
+	/* Verify end of the region is not out of bounds
+	 */
+	vma2 = find_vma(current->mm, end-1);
+	if (unlikely(!vma2) || (vma2->vm_start > end))
+		return -EFAULT;
+
+	while (1) {
+		mm = vma->vm_mm;
+
+		/* Update the ADI info in vma and check if this vma can
+		 * be merged with adjacent ones
+		 */
+		pgoff = vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT);
+		prev = vma_merge(mm, prev, addr, end, vma->vm_flags,
+				 vma->anon_vma, vma->vm_file, pgoff,
+				 vma_policy(vma), vma->vm_userfaultfd_ctx);
+		if (prev)
+			vma = prev;
+
+		vma->vm_flags &= ~VM_SPARC_ADI;
+		if (end > vma->vm_end) {
+			change_protection(vma, addr, vma->vm_end,
+					  vma->vm_page_prot,
+					  vma_wants_writenotify(vma), 0);
+			addr = vma->vm_end;
+		} else {
+			change_protection(vma, addr, end, vma->vm_page_prot,
+					  vma_wants_writenotify(vma), 0);
+			break;
+		}
+
+		vma = find_vma_prev(current->mm, addr, &prev);
+		if (unlikely(!vma) || (vma->vm_start > addr))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+long get_sparc_adi_status(unsigned long addr)
+{
+	struct vm_area_struct *vma;
+
+	if (!ADI_CAPABLE())
+		return -EINVAL;
+
+	vma = find_vma(current->mm, addr);
+	if (unlikely(!vma) || (vma->vm_start > addr))
+		return -EFAULT;
+
+	if (vma->vm_flags & VM_SPARC_ADI)
+		return 1;
+
+	return 0;
+}
+#endif
diff --git a/arch/sparc/kernel/sun4v_mcd.S b/arch/sparc/kernel/sun4v_mcd.S
new file mode 100644
index 0000000..d1d1259
--- /dev/null
+++ b/arch/sparc/kernel/sun4v_mcd.S
@@ -0,0 +1,16 @@
+/* sun4v_mcd.S: Sun4v memory corruption detected precise exception handler
+ *
+ * Copyright (C) 2015 Bob Picco <bob.picco@oracle.com>
+ * Copyright (C) 2015 Khalid Aziz <khalid.aziz@oracle.com>
+ */
+	.text
+	.align 32
+
+sun4v_mcd_detect_precise:
+	ba,pt	%xcc, etrap
+	rd	%pc, %g7
+	or	%l4, %g0, %o1
+	or 	%l5, %g0, %o2
+	call	sun4v_mem_corrupt_detect_precise
+	add	%sp, PTREGS_OFF, %o0
+	ba,a,pt	%xcc, rtrap
diff --git a/arch/sparc/kernel/traps_64.c b/arch/sparc/kernel/traps_64.c
index d21cd62..29db583 100644
--- a/arch/sparc/kernel/traps_64.c
+++ b/arch/sparc/kernel/traps_64.c
@@ -351,12 +351,31 @@ void sun4v_data_access_exception(struct pt_regs *regs, unsigned long addr, unsig
 		regs->tpc &= 0xffffffff;
 		regs->tnpc &= 0xffffffff;
 	}
-	info.si_signo = SIGSEGV;
+
+	/* MCD (Memory Corruption Detection) disabled trap (TT=0x19) in HV
+	 * is vectored thorugh data access exception trap with fault type
+	 * set to HV_FAULT_TYPE_MCD_DIS. Check for MCD disabled trap
+	 */
 	info.si_errno = 0;
-	info.si_code = SEGV_MAPERR;
 	info.si_addr = (void __user *) addr;
 	info.si_trapno = 0;
-	force_sig_info(SIGSEGV, &info, current);
+	switch (type) {
+	case HV_FAULT_TYPE_INV_ASI:
+		info.si_signo = SIGILL;
+		info.si_code = ILL_ILLADR;
+		force_sig_info(SIGILL, &info, current);
+		break;
+	case HV_FAULT_TYPE_MCD_DIS:
+		info.si_signo = SIGSEGV;
+		info.si_code = SEGV_ACCADI;
+		force_sig_info(SIGSEGV, &info, current);
+		break;
+	default:
+		info.si_signo = SIGSEGV;
+		info.si_code = SEGV_MAPERR;
+		force_sig_info(SIGSEGV, &info, current);
+		break;
+	}
 }
 
 void sun4v_data_access_exception_tl1(struct pt_regs *regs, unsigned long addr, unsigned long type_ctx)
@@ -1801,6 +1820,7 @@ struct sun4v_error_entry {
 #define SUN4V_ERR_ATTRS_ASI		0x00000080
 #define SUN4V_ERR_ATTRS_PRIV_REG	0x00000100
 #define SUN4V_ERR_ATTRS_SPSTATE_MSK	0x00000600
+#define SUN4V_ERR_ATTRS_MCD		0x00000800
 #define SUN4V_ERR_ATTRS_SPSTATE_SHFT	9
 #define SUN4V_ERR_ATTRS_MODE_MSK	0x03000000
 #define SUN4V_ERR_ATTRS_MODE_SHFT	24
@@ -1998,6 +2018,36 @@ static void sun4v_log_error(struct pt_regs *regs, struct sun4v_error_entry *ent,
 	}
 }
 
+/* Handle memory corruption detected error which is vectored in
+ * through resumable error trap.
+ */
+void do_mcd_err(struct pt_regs *regs, struct sun4v_error_entry ent)
+{
+	siginfo_t info;
+
+	if (notify_die(DIE_TRAP, "MCD error", regs,
+		       0, 0x34, SIGSEGV) == NOTIFY_STOP)
+		return;
+
+	if (regs->tstate & TSTATE_PRIV) {
+		/* ADI tag mismatch in kernel mode means illegal access to
+		 * kernel memory through rogue means potentially.
+		 */
+		pr_emerg("mcd_err: ADI tag mismatch in kernel at "
+			"ADDR[%016llx], going.\n", ent.err_raddr);
+		die_if_kernel("MCD error", regs);
+	}
+
+	/* Send SIGSEGV to the userspace process with the right code
+	 */
+	info.si_signo = SIGSEGV;
+	info.si_errno = 0;
+	info.si_code = SEGV_ADIDERR;
+	info.si_addr = (void __user *)ent.err_raddr;
+	info.si_trapno = 0;
+	force_sig_info(SIGSEGV, &info, current);
+}
+
 /* We run with %pil set to PIL_NORMAL_MAX and PSTATE_IE enabled in %pstate.
  * Log the event and clear the first word of the entry.
  */
@@ -2035,6 +2085,14 @@ void sun4v_resum_error(struct pt_regs *regs, unsigned long offset)
 		goto out;
 	}
 
+	/* If this is a memory corruption detected error, call the
+	 * handler
+	 */
+	if (local_copy.err_attrs & SUN4V_ERR_ATTRS_MCD) {
+		do_mcd_err(regs, local_copy);
+		return;
+	}
+
 	sun4v_log_error(regs, &local_copy, cpu,
 			KERN_ERR "RESUMABLE ERROR",
 			&sun4v_resum_oflow_cnt);
@@ -2531,6 +2589,38 @@ void sun4v_do_mna(struct pt_regs *regs, unsigned long addr, unsigned long type_c
 	force_sig_info(SIGBUS, &info, current);
 }
 
+void sun4v_mem_corrupt_detect_precise(struct pt_regs *regs, unsigned long addr,
+				      unsigned long context)
+{
+	siginfo_t info;
+
+	if (!ADI_CAPABLE()) {
+		bad_trap(regs, 0x1a);
+		return;
+	}
+
+	if (notify_die(DIE_TRAP, "memory corruption precise exception", regs,
+		       0, 0x8, SIGSEGV) == NOTIFY_STOP)
+		return;
+
+	if (regs->tstate & TSTATE_PRIV) {
+		pr_emerg("sun4v_mem_corrupt_detect_precise: ADDR[%016lx] "
+			"CTX[%lx], going.\n", addr, context);
+		die_if_kernel("MCD precise", regs);
+	}
+
+	if (test_thread_flag(TIF_32BIT)) {
+		regs->tpc &= 0xffffffff;
+		regs->tnpc &= 0xffffffff;
+	}
+	info.si_signo = SIGSEGV;
+	info.si_code = SEGV_ADIPERR;
+	info.si_errno = 0;
+	info.si_addr = (void __user *) addr;
+	info.si_trapno = 0;
+	force_sig_info(SIGSEGV, &info, current);
+}
+
 void do_privop(struct pt_regs *regs)
 {
 	enum ctx_state prev_state = exception_enter();
diff --git a/arch/sparc/kernel/ttable_64.S b/arch/sparc/kernel/ttable_64.S
index c6dfdaa..2343bf0 100644
--- a/arch/sparc/kernel/ttable_64.S
+++ b/arch/sparc/kernel/ttable_64.S
@@ -25,8 +25,10 @@ tl0_ill:	membar #Sync
 		TRAP_7INSNS(do_illegal_instruction)
 tl0_privop:	TRAP(do_privop)
 tl0_resv012:	BTRAP(0x12) BTRAP(0x13) BTRAP(0x14) BTRAP(0x15) BTRAP(0x16) BTRAP(0x17)
-tl0_resv018:	BTRAP(0x18) BTRAP(0x19) BTRAP(0x1a) BTRAP(0x1b) BTRAP(0x1c) BTRAP(0x1d)
-tl0_resv01e:	BTRAP(0x1e) BTRAP(0x1f)
+tl0_resv018:	BTRAP(0x18) BTRAP(0x19)
+tl0_mcd:	SUN4V_MCD_PRECISE
+tl0_resv01b:	BTRAP(0x1b)
+tl0_resv01c:	BTRAP(0x1c) BTRAP(0x1d)	BTRAP(0x1e) BTRAP(0x1f)
 tl0_fpdis:	TRAP_NOSAVE(do_fpdis)
 tl0_fpieee:	TRAP_SAVEFPU(do_fpieee)
 tl0_fpother:	TRAP_NOSAVE(do_fpother_check_fitos)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..5a80219 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -168,6 +168,8 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_GROWSUP	VM_ARCH_1
 #elif defined(CONFIG_IA64)
 # define VM_GROWSUP	VM_ARCH_1
+#elif defined(CONFIG_SPARC64)
+# define VM_SPARC_ADI	VM_ARCH_1	/* Uses ADI tag for access control */
 #elif !defined(CONFIG_MMU)
 # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
 #endif
diff --git a/include/uapi/asm-generic/siginfo.h b/include/uapi/asm-generic/siginfo.h
index 1e35520..8235d6e 100644
--- a/include/uapi/asm-generic/siginfo.h
+++ b/include/uapi/asm-generic/siginfo.h
@@ -206,7 +206,10 @@ typedef struct siginfo {
 #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
 #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
 #define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
-#define NSIGSEGV	3
+#define SEGV_ACCADI	(__SI_FAULT|4)	/* ADI not enabled for mapped object */
+#define SEGV_ADIDERR	(__SI_FAULT|5)	/* Disrupting MCD error */
+#define SEGV_ADIPERR	(__SI_FAULT|6)	/* Precise MCD exception */
+#define NSIGSEGV	6
 
 /*
  * SIGBUS si_codes
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759..422c246 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,20 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/* SPARC ADI operations, see Documentation/prctl/sparc_adi.txt for details */
+#define PR_GET_SPARC_ADICAPS	48
+#define PR_SET_SPARC_ADI	49
+# define PR_SET_SPARC_ADI_CLEAR	0
+# define PR_SET_SPARC_ADI_SET	1
+#define PR_ENABLE_SPARC_ADI	50
+#define PR_DISABLE_SPARC_ADI	51
+#define PR_GET_SPARC_ADI_STATUS	52
+
+/* Data structure returned by PR_GET_SPARC_ADICAPS */
+struct adi_caps {
+	__u64 blksz;
+	__u64 nbits;
+	__u64 ue_on_adi;
+};
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 6af9212..fa7b5d9 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -103,6 +103,21 @@
 #ifndef SET_FP_MODE
 # define SET_FP_MODE(a,b)	(-EINVAL)
 #endif
+#ifndef GET_SPARC_ADICAPS
+# define GET_SPARC_ADICAPS(a)		(-EINVAL)
+#endif
+#ifndef SET_SPARC_MCDE
+# define SET_SPARC_MCDE(a)		(-EINVAL)
+#endif
+#ifndef ENABLE_SPARC_ADI
+# define ENABLE_SPARC_ADI(a, b)		(-EINVAL)
+#endif
+#ifndef DISABLE_SPARC_ADI
+# define DISABLE_SPARC_ADI(a, b)	(-EINVAL)
+#endif
+#ifndef GET_SPARC_ADI_STATUS
+# define GET_SPARC_ADI_STATUS(a)	(-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -2266,6 +2281,21 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+	case PR_GET_SPARC_ADICAPS:
+		error = GET_SPARC_ADICAPS(arg2);
+		break;
+	case PR_SET_SPARC_ADI:
+		error = SET_SPARC_MCDE(arg2);
+		break;
+	case PR_ENABLE_SPARC_ADI:
+		error = ENABLE_SPARC_ADI(arg2, arg3);
+		break;
+	case PR_DISABLE_SPARC_ADI:
+		error = DISABLE_SPARC_ADI(arg2, arg3);
+		break;
+	case PR_GET_SPARC_ADI_STATUS:
+		error = GET_SPARC_ADI_STATUS(arg2);
+		break;
 	default:
 		error = -EINVAL;
 		break;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
