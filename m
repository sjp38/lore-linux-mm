Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8986B0069
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:01:21 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e4so157673334pfg.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:01:21 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w133si24630024pfd.255.2017.01.25.14.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:01:18 -0800 (PST)
Subject: Re: [PATCH v5 4/4] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1485362562.git.khalid.aziz@oracle.com>
 <0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
From: Rob Gardner <rob.gardner@oracle.com>
Message-ID: <154bc417-6333-f9ac-653b-9ed280f08450@oracle.com>
Date: Wed, 25 Jan 2017 15:00:42 -0700
MIME-Version: 1.0
In-Reply-To: <0b6865aabc010ee3a7ea956a70447abbab53ea70.1485362562.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, davem@davemloft.net, corbet@lwn.net
Cc: viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, mike.kravetz@oracle.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com, adam.buchbinder@gmail.com, hughd@google.com, minchan@kernel.org, keescook@chromium.org, chris.hyser@oracle.com, atish.patra@oracle.com, cmetcalf@mellanox.com, atomlin@redhat.com, jslaby@suse.cz, joe@perches.com, paul.gortmaker@windriver.com, mhocko@suse.com, lstoakes@gmail.com, jack@suse.cz, dave.hansen@linux.intel.com, vbabka@suse.cz, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/25/2017 12:57 PM, Khalid Aziz wrote:
> ADI is a new feature supported on SPARC M7 and newer processors to allow
> hardware to catch rogue accesses to memory. ADI is supported for data
> fetches only and not instruction fetches. An app can enable ADI on its
> data pages, set version tags on them and use versioned addresses to
> access the data pages. Upper bits of the address contain the version
> tag. On M7 processors, upper four bits (bits 63-60) contain the version
> tag. If a rogue app attempts to access ADI enabled data pages, its
> access is blocked and processor generates an exception. Please see
> Documentation/sparc/adi.txt for further details.
>
> This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable
> MCD (Memory Corruption Detection) on selected memory ranges, enable
> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore ADI
> version tags on page swap out/in or migration. It also adds handlers for
> traps related to MCD. ADI is not enabled by default for any task. A task
> must explicitly enable ADI on a memory range and set version tag for ADI
> to be effective for the task.
>
> This initial implementation supports saving and restoring one tag per
> page. A page must use same version tag across the entire page for the
> tag to survive swap and migration. Swap swupport infrastructure in this
> patch allows for this capability to be expanded to store/restore more
> than one tag per page in future.
>
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> ---
> v5:
> 	- Fixed indentation issues and instrcuctions in assembly code
> 	- Removed CONFIG_SPARC64 from mdesc.c
> 	- Changed to maintain state of MCDPER register in thread info
> 	  flags as opposed to in mm context. MCDPER is a per-thread
> 	  state and belongs in thread info flag as opposed to mm context
> 	  which is shared across threads. Added comments to clarify this
> 	  is a lazily maintained state and must be updated on context
> 	  switch and copy_process()
> 	- Updated code to use the new arch_do_swap_page() and
> 	  arch_unmap_one() functions
>
> v4:
> 	- Broke patch up into smaller patches
>
> v3:
> 	- Removed CONFIG_SPARC_ADI
> 	- Replaced prctl commands with mprotect
> 	- Added auxiliary vectors for ADI parameters
> 	- Enabled ADI for swappable pages
>
> v2:
> 	- Fixed a build error
>
>   Documentation/sparc/adi.txt             | 288 ++++++++++++++++++++++++++++++++
>   arch/sparc/include/asm/adi.h            |   6 +
>   arch/sparc/include/asm/adi_64.h         |  46 +++++
>   arch/sparc/include/asm/elf_64.h         |   8 +
>   arch/sparc/include/asm/hugetlb.h        |  13 ++
>   arch/sparc/include/asm/mman.h           |  40 ++++-
>   arch/sparc/include/asm/mmu_64.h         |   1 +
>   arch/sparc/include/asm/mmu_context_64.h |  43 +++++
>   arch/sparc/include/asm/pgtable_64.h     |  85 +++++++++-
>   arch/sparc/include/asm/thread_info_64.h |   1 +
>   arch/sparc/include/asm/uaccess_64.h     | 120 ++++++++++++-
>   arch/sparc/include/uapi/asm/auxvec.h    |   8 +
>   arch/sparc/include/uapi/asm/mman.h      |   2 +
>   arch/sparc/kernel/Makefile              |   1 +
>   arch/sparc/kernel/adi_64.c              |  93 +++++++++++
>   arch/sparc/kernel/mdesc.c               |   2 +
>   arch/sparc/kernel/process_64.c          |  25 +++
>   arch/sparc/kernel/traps_64.c            |  88 +++++++++-
>   arch/sparc/mm/gup.c                     |  37 ++++
>   include/linux/mm.h                      |   2 +
>   20 files changed, 897 insertions(+), 12 deletions(-)
>   create mode 100644 Documentation/sparc/adi.txt
>   create mode 100644 arch/sparc/include/asm/adi.h
>   create mode 100644 arch/sparc/include/asm/adi_64.h
>   create mode 100644 arch/sparc/kernel/adi_64.c
>
> diff --git a/Documentation/sparc/adi.txt b/Documentation/sparc/adi.txt
> new file mode 100644
> index 0000000..1740f8a
> --- /dev/null
> +++ b/Documentation/sparc/adi.txt
> @@ -0,0 +1,288 @@
> +Application Data Integrity (ADI)
> +================================
> +
> +SPARC M7 processor adds the Application Data Integrity (ADI) feature.
> +ADI allows a task to set version tags on any subset of its address
> +space. Once ADI is enabled and version tags are set for ranges of
> +address space of a task, the processor will compare the tag in pointers
> +to memory in these ranges to the version set by the application
> +previously. Access to memory is granted only if the tag in given
> +pointer matches the tag set by the application. In case of mismatch,
> +processor raises an exception.
> +
> +Following steps must be taken by a task to enable ADI fully:
> +
> +1. Set the user mode PSTATE.mcde bit. This acts as master switch for
> +   the task's entire address space to enable/disable ADI for the task.
> +
> +2. Set TTE.mcd bit on any TLB entries that correspond to the range of
> +   addresses ADI is being enabled on. MMU checks the version tag only
> +   on the pages that have TTE.mcd bit set.
> +
> +3. Set the version tag for virtual addresses using stxa instruction
> +   and one of the MCD specific ASIs. Each stxa instruction sets the
> +   given tag for one ADI block size number of bytes. This step must
> +   be repeated for entire page to set tags for entire page.
> +
> +ADI block size for the platform is provided by the hypervisor to the
> +kernel in machine description tables. Hypervisor also provides the
> +number of top bits in the virtual address that specify the version tag.
> +Once version tag has been set for a memory location, the tag is stored
> +in the physical memory and the same tag must be present in the ADI
> +version tag bits of the virtual address being presented to the MMU. For
> +example on SPARC M7 processor, MMU uses bits 63-60 for version tags and
> +ADI block size is same as cacheline size which is 64 bytes. A task that
> +sets ADI version to say 10 on a range of memory, must access that memory
> +using virtual addresses that contain 0xa in bits 63-60.
> +
> +ADI is enabled on a set of pages using mprotect() with PROT_ADI flag.
> +When ADI is enabled on a set of pages by a task for the first time,
> +kernel sets the PSTATE.mcde bit fot the task. Version tags for memory
> +addresses are set with an stxa instruction on the addresses using
> +ASI_MCD_PRIMARY or ASI_MCD_ST_BLKINIT_PRIMARY. ADI block size is
> +provided by the hypervisor to the kernel.  Kernel returns the value of
> +ADI block size to userspace using auxiliary vector along with other ADI
> +info. Following auxiliary vectors are provided by the kernel:
> +
> +	AT_ADI_BLKSZ	ADI block size. This is the granularity and
> +			alignment, in bytes, of ADI versioning.
> +	AT_ADI_NBITS	Number of ADI version bits in the VA
> +	AT_ADI_UEONADI	ADI version of memory containing uncorrectable
> +			errors will be set to this value
> +
> +
> +IMPORTANT NOTES:
> +
> +- Version tag values of 0x0 and 0xf are reserved.
> +
> +- Version tags are set on virtual addresses from userspace even though
> +  tags are stored in physical memory. Tags are set on a physical page
> +  after it has been allocated to a task and a pte has been created for
> +  it.
> +
> +- When a task frees a memory page it had set version tags on, the page
> +  goes back to free page pool. When this page is re-allocated to a task,
> +  kernel clears the page using block initialization ASI which clears the
> +  version tags as well for the page. If a page allocated to a task is
> +  freed and allocated back to the same task, old version tags set by the
> +  task on that page will no longer be present.
> +
> +- Kernel does not set any tags for user pages and it is entirely a
> +  task's responsibility to set any version tags. Kernel does ensure the
> +  version tags are preserved if a page is swapped out to the disk and
> +  swapped back in. It also preserves that version tags if a page is
> +  migrated.
> +
> +- Initial implementation assumes a single page uses exact same version
> +  tag for the entire page. Kernel saves the version tag for only the
> +  first byte when swapping or migrating a page and restores that tag to
> +  the entire page after swapping in or migrating the page. Future
> +  implementations may expand kernel's capability to store/restore more
> +  than one tag per page.
> +
> +- ADI works for any size pages. A userspace task need not be aware of
> +  page size when using ADI. It can simply select a virtual address
> +  range, enable ADI on the range using mprotect() and set version tags
> +  for the entire range. mprotect() ensures range is aligned to page size
> +  and is a multiple of page size.
> +
> +
> +
> +ADI related traps
> +-----------------
> +
> +With ADI enabled, following new traps may occur:
> +
> +Disrupting memory corruption
> +
> +	When a store accesses a memory localtion that has TTE.mcd=1,
> +	the task is running with ADI enabled (PSTATE.mcde=1), and the ADI
> +	tag in the address used (bits 63:60) does not match the tag set on
> +	the corresponding cacheline, a memory corruption trap occurs. By
> +	default, it is a disrupting trap and is sent to the hypervisor
> +	first. Hypervisor creates a sun4v error report and sends a
> +	resumable error (TT=0x7e) trap to the kernel. The kernel sends
> +	a SIGSEGV to the task that resulted in this trap with the following
> +	info:
> +
> +		siginfo.si_signo = SIGSEGV;
> +		siginfo.errno = 0;
> +		siginfo.si_code = SEGV_ADIDERR;
> +		siginfo.si_addr = addr; /* PC where first mismatch occurred */
> +		siginfo.si_trapno = 0;
> +
> +
> +Precise memory corruption
> +
> +	When a store accesses a memory location that has TTE.mcd=1,
> +	the task is running with ADI enabled (PSTATE.mcde=1), and the ADI
> +	tag in the address used (bits 63:60) does not match the tag set on
> +	the corresponding cacheline, a memory corruption trap occurs. If
> +	MCD precise exception is enabled (MCDPERR=1), a precise
> +	exception is sent to the kernel with TT=0x1a. The kernel sends
> +	a SIGSEGV to the task that resulted in this trap with the following
> +	info:
> +
> +		siginfo.si_signo = SIGSEGV;
> +		siginfo.errno = 0;
> +		siginfo.si_code = SEGV_ADIPERR;
> +		siginfo.si_addr = addr;	/* address that caused trap */
> +		siginfo.si_trapno = 0;
> +
> +	NOTE: ADI tag mismatch on a load always results in precise trap.
> +
> +
> +MCD disabled
> +
> +	When a task has not enabled ADI and attempts to set ADI version
> +	on a memory address, processor sends an MCD disabled trap. This
> +	trap is handled by hypervisor first and the hypervisor vectors this
> +	trap through to the kernel as Data Access Exception trap with
> +	fault type set to 0xa (invalid ASI). When this occurs, the kernel
> +	sends the task SIGSEGV signal with following info:
> +
> +		siginfo.si_signo = SIGSEGV;
> +		siginfo.errno = 0;
> +		siginfo.si_code = SEGV_ACCADI;
> +		siginfo.si_addr = addr;	/* address that caused trap */
> +		siginfo.si_trapno = 0;
> +
> +
> +Sample program to use ADI
> +-------------------------
> +
> +Following sample program is meant to illustrate how to use the ADI
> +functionality.
> +
> +#include <unistd.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <elf.h>
> +#include <sys/ipc.h>
> +#include <sys/shm.h>
> +#include <sys/mman.h>
> +#include <asm/asi.h>
> +
> +#ifndef AT_ADI_BLKSZ
> +#define AT_ADI_BLKSZ	34
> +#endif
> +#ifndef AT_ADI_NBITS
> +#define AT_ADI_NBITS	35
> +#endif
> +#ifndef AT_ADI_UEONADI
> +#define AT_ADI_UEONADI	36
> +#endif
> +
> +#ifndef PROT_ADI
> +#define PROT_ADI	0x10
> +#endif
> +
> +#define BUFFER_SIZE     32*1024*1024UL
> +
> +main(int argc, char* argv[], char* envp[])
> +{
> +        unsigned long i, mcde, adi_blksz, adi_nbits, adi_ueonadi;
> +        char *shmaddr, *tmp_addr, *end, *veraddr, *clraddr;
> +        int shmid, version;
> +	Elf64_auxv_t *auxv;
> +
> +	adi_blksz = 0;
> +
> +	while(*envp++ != NULL);
> +	for (auxv = (Elf64_auxv_t *)envp; auxv->a_type != AT_NULL; auxv++) {
> +		switch (auxv->a_type) {
> +		case AT_ADI_BLKSZ:
> +			adi_blksz = auxv->a_un.a_val;
> +			break;
> +		case AT_ADI_NBITS:
> +			adi_nbits = auxv->a_un.a_val;
> +			break;
> +		case AT_ADI_UEONADI:
> +			adi_ueonadi = auxv->a_un.a_val;
> +			break;
> +		}
> +	}
> +	if (adi_blksz == 0) {
> +		fprintf(stderr, "Oops! ADI is not supported\n");
> +		exit(1);
> +	}
> +
> +	printf("ADI capabilities:\n");
> +	printf("\tBlock size = %ld\n", adi_blksz);
> +	printf("\tNumber of bits = %ld\n", adi_nbits);
> +	printf("\tUE on ADI error = %ld\n", adi_ueonadi);
> +
> +        if ((shmid = shmget(2, BUFFER_SIZE,
> +                                IPC_CREAT | SHM_R | SHM_W)) < 0) {
> +                perror("shmget failed");
> +                exit(1);
> +        }
> +
> +        shmaddr = shmat(shmid, NULL, 0);
> +        if (shmaddr == (char *)-1) {
> +                perror("shm attach failed");
> +                shmctl(shmid, IPC_RMID, NULL);
> +                exit(1);
> +        }
> +
> +	if (mprotect(shmaddr, BUFFER_SIZE, PROT_READ|PROT_WRITE|PROT_ADI)) {
> +		perror("mprotect failed");
> +		goto err_out;
> +	}
> +
> +        /* Set the ADI version tag on the shm segment
> +         */
> +        version = 10;
> +        tmp_addr = shmaddr;
> +        end = shmaddr + BUFFER_SIZE;
> +        while (tmp_addr < end) {
> +                asm volatile(
> +                        "stxa %1, [%0]0x90\n\t"
> +                        :
> +                        : "r" (tmp_addr), "r" (version));
> +                tmp_addr += adi_blksz;
> +        }
> +	asm volatile("membar #Sync\n\t");
> +
> +        /* Create a versioned address from the normal address by placing
> +	 * version tag in the upper adi_nbits bits
> +         */
> +        tmp_addr = (void *) ((unsigned long)shmaddr << adi_nbits);
> +        tmp_addr = (void *) ((unsigned long)tmp_addr >> adi_nbits);
> +        veraddr = (void *) (((unsigned long)version << (64-adi_nbits))
> +                        | (unsigned long)tmp_addr);
> +
> +        printf("Starting the writes:\n");
> +        for (i = 0; i < BUFFER_SIZE; i++) {
> +                veraddr[i] = (char)(i);
> +                if (!(i % (1024 * 1024)))
> +                        printf(".");
> +        }
> +        printf("\n");
> +
> +        printf("Verifying data...");
> +	fflush(stdout);
> +        for (i = 0; i < BUFFER_SIZE; i++)
> +                if (veraddr[i] != (char)i)
> +                        printf("\nIndex %lu mismatched\n", i);
> +        printf("Done.\n");
> +
> +        /* Disable ADI and clean up
> +         */
> +	if (mprotect(shmaddr, BUFFER_SIZE, PROT_READ|PROT_WRITE)) {
> +		perror("mprotect failed");
> +		goto err_out;
> +	}
> +
> +        if (shmdt((const void *)shmaddr) != 0)
> +                perror("Detach failure");
> +        shmctl(shmid, IPC_RMID, NULL);
> +
> +        exit(0);
> +
> +err_out:
> +        if (shmdt((const void *)shmaddr) != 0)
> +                perror("Detach failure");
> +        shmctl(shmid, IPC_RMID, NULL);
> +        exit(1);
> +}
> diff --git a/arch/sparc/include/asm/adi.h b/arch/sparc/include/asm/adi.h
> new file mode 100644
> index 0000000..acad0d0
> --- /dev/null
> +++ b/arch/sparc/include/asm/adi.h
> @@ -0,0 +1,6 @@
> +#ifndef ___ASM_SPARC_ADI_H
> +#define ___ASM_SPARC_ADI_H
> +#if defined(__sparc__) && defined(__arch64__)
> +#include <asm/adi_64.h>
> +#endif
> +#endif
> diff --git a/arch/sparc/include/asm/adi_64.h b/arch/sparc/include/asm/adi_64.h
> new file mode 100644
> index 0000000..24fe52f
> --- /dev/null
> +++ b/arch/sparc/include/asm/adi_64.h
> @@ -0,0 +1,46 @@
> +/* adi_64.h: ADI related data structures
> + *
> + * Copyright (C) 2016 Khalid Aziz (khalid.aziz@oracle.com)
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + */
> +#ifndef __ASM_SPARC64_ADI_H
> +#define __ASM_SPARC64_ADI_H
> +
> +#include <linux/types.h>
> +
> +#ifndef __ASSEMBLY__
> +
> +struct adi_caps {
> +	__u64 blksz;
> +	__u64 nbits;
> +	__u64 ue_on_adi;
> +};
> +
> +struct adi_config {
> +	bool enabled;
> +	struct adi_caps caps;
> +};
> +
> +extern struct adi_config adi_state;
> +
> +extern void mdesc_adi_init(void);
> +
> +static inline bool adi_capable(void)
> +{
> +	return adi_state.enabled;
> +}
> +
> +static inline unsigned long adi_blksize(void)
> +{
> +	return adi_state.caps.blksz;
> +}
> +
> +static inline unsigned long adi_nbits(void)
> +{
> +	return adi_state.caps.nbits;
> +}
> +
> +#endif	/* __ASSEMBLY__ */
> +
> +#endif	/* !(__ASM_SPARC64_ADI_H) */
> diff --git a/arch/sparc/include/asm/elf_64.h b/arch/sparc/include/asm/elf_64.h
> index 3f2d403..cf00fbc 100644
> --- a/arch/sparc/include/asm/elf_64.h
> +++ b/arch/sparc/include/asm/elf_64.h
> @@ -210,4 +210,12 @@ do {	if ((ex).e_ident[EI_CLASS] == ELFCLASS32)	\
>   			(current->personality & (~PER_MASK)));	\
>   } while (0)
>   
> +#define ARCH_DLINFO						\
> +do {								\
> +	extern struct adi_config adi_state;			\
> +	NEW_AUX_ENT(AT_ADI_BLKSZ, adi_state.caps.blksz);	\
> +	NEW_AUX_ENT(AT_ADI_NBITS, adi_state.caps.nbits);	\
> +	NEW_AUX_ENT(AT_ADI_UEONADI, adi_state.caps.ue_on_adi);	\
> +} while (0)
> +
>   #endif /* !(__ASM_SPARC64_ELF_H) */
> diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
> index dcbf985..ac2fe18 100644
> --- a/arch/sparc/include/asm/hugetlb.h
> +++ b/arch/sparc/include/asm/hugetlb.h
> @@ -77,5 +77,18 @@ static inline void arch_clear_hugepage_flags(struct page *page)
>   void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>   			    unsigned long end, unsigned long floor,
>   			    unsigned long ceiling);
> +#ifdef CONFIG_SPARC64
> +static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> +			 struct page *page, int writeable)
> +{
> +	/* If this vma has ADI enabled on it, turn on TTE.mcd
> +	 */
> +	if (vma->vm_flags & VM_SPARC_ADI)
> +		return pte_mkmcd(entry);
> +	else
> +		return pte_mknotmcd(entry);
> +}
> +#define arch_make_huge_pte arch_make_huge_pte
> +#endif
>   
>   #endif /* _ASM_SPARC64_HUGETLB_H */
> diff --git a/arch/sparc/include/asm/mman.h b/arch/sparc/include/asm/mman.h
> index 59bb593..95d3abc 100644
> --- a/arch/sparc/include/asm/mman.h
> +++ b/arch/sparc/include/asm/mman.h
> @@ -6,5 +6,43 @@
>   #ifndef __ASSEMBLY__
>   #define arch_mmap_check(addr,len,flags)	sparc_mmap_check(addr,len)
>   int sparc_mmap_check(unsigned long addr, unsigned long len);
> -#endif
> +
> +#ifdef CONFIG_SPARC64
> +#include <asm/adi_64.h>
> +
> +#define arch_calc_vm_prot_bits(prot, pkey) sparc_calc_vm_prot_bits(prot)
> +static inline unsigned long sparc_calc_vm_prot_bits(unsigned long prot)
> +{
> +	if (prot & PROT_ADI) {
> +		struct pt_regs *regs;
> +
> +		if (!current->mm->context.adi) {
> +			regs = task_pt_regs(current);
> +			regs->tstate |= TSTATE_MCDE;
> +			current->mm->context.adi = true;
> +		}
> +		return VM_SPARC_ADI;
> +	} else {
> +		return 0;
> +	}
> +}
> +
> +#define arch_vm_get_page_prot(vm_flags) sparc_vm_get_page_prot(vm_flags)
> +static inline pgprot_t sparc_vm_get_page_prot(unsigned long vm_flags)
> +{
> +	return (vm_flags & VM_SPARC_ADI) ? __pgprot(_PAGE_MCD_4V) : __pgprot(0);
> +}
> +
> +#define arch_validate_prot(prot) sparc_validate_prot(prot)
> +static inline int sparc_validate_prot(unsigned long prot)
> +{
> +	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_ADI))
> +		return 0;
> +	if ((prot & PROT_ADI) && !adi_capable())
> +		return 0;
> +	return 1;
> +}
> +#endif /* CONFIG_SPARC64 */
> +
> +#endif /* __ASSEMBLY__ */
>   #endif /* __SPARC_MMAN_H__ */
> diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
> index f7de0db..e1d30ac 100644
> --- a/arch/sparc/include/asm/mmu_64.h
> +++ b/arch/sparc/include/asm/mmu_64.h
> @@ -96,6 +96,7 @@ typedef struct {
>   	unsigned long		thp_pte_count;
>   	struct tsb_config	tsb_block[MM_NUM_TSBS];
>   	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
> +	bool			adi;
>   } mm_context_t;
>   
>   #endif /* !__ASSEMBLY__ */
> diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
> index b84be67..3b78c4f 100644
> --- a/arch/sparc/include/asm/mmu_context_64.h
> +++ b/arch/sparc/include/asm/mmu_context_64.h
> @@ -7,6 +7,7 @@
>   
>   #include <linux/spinlock.h>
>   #include <asm/spitfire.h>
> +#include <asm/adi_64.h>
>   #include <asm-generic/mm_hooks.h>
>   
>   static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
> @@ -127,6 +128,7 @@ static inline void switch_mm(struct mm_struct *old_mm, struct mm_struct *mm, str
>   		__flush_tlb_mm(CTX_HWBITS(mm->context),
>   			       SECONDARY_CONTEXT);
>   	}
> +
>   	spin_unlock_irqrestore(&mm->context.lock, flags);
>   }
>   
> @@ -151,6 +153,47 @@ static inline void activate_mm(struct mm_struct *active_mm, struct mm_struct *mm
>   	spin_unlock_irqrestore(&mm->context.lock, flags);
>   }
>   
> +#define  __HAVE_ARCH_START_CONTEXT_SWITCH
> +static inline void arch_start_context_switch(struct task_struct *prev)
> +{
> +	/* Save the current state of MCDPER register for the process we are
> +	 * switching from
> +	 */
> +	if (adi_capable()) {
> +		register unsigned long tmp_mcdper;
> +
> +		__asm__ __volatile__(
> +			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
> +			"mov %%g1, %0\n\t"
> +			: "=r" (tmp_mcdper)
> +			:
> +			: "g1");
> +		if (tmp_mcdper)
> +			set_tsk_thread_flag(prev, TIF_MCDPER);
> +		else
> +			clear_tsk_thread_flag(prev, TIF_MCDPER);
> +	}
> +}
> +
> +#define finish_arch_post_lock_switch	finish_arch_post_lock_switch
> +static inline void finish_arch_post_lock_switch(void)
> +{
> +	/* Restore the state of MCDPER register for the new process
> +	 * just switched to.
> +	 */
> +	if (adi_capable()) {
> +		register unsigned long tmp_mcdper;
> +
> +		tmp_mcdper = test_thread_flag(TIF_MCDPER);
> +		__asm__ __volatile__(
> +			"mov %0, %%g1\n\t"
> +			".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" */
> +			:
> +			: "ir" (tmp_mcdper)
> +			: "g1");
> +	}
> +}
> +
>   #endif /* !(__ASSEMBLY__) */
>   
>   #endif /* !(__SPARC64_MMU_CONTEXT_H) */
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index f4e4834..8b74985 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -17,6 +17,7 @@
>   #include <asm/types.h>
>   #include <asm/spitfire.h>
>   #include <asm/asi.h>
> +#include <asm/adi.h>
>   #include <asm/page.h>
>   #include <asm/processor.h>
>   
> @@ -564,6 +565,18 @@ static inline pte_t pte_mkspecial(pte_t pte)
>   	return pte;
>   }
>   
> +static inline pte_t pte_mkmcd(pte_t pte)
> +{
> +	pte_val(pte) |= _PAGE_MCD_4V;
> +	return pte;
> +}
> +
> +static inline pte_t pte_mknotmcd(pte_t pte)
> +{
> +	pte_val(pte) &= ~_PAGE_MCD_4V;
> +	return pte;
> +}
> +
>   static inline unsigned long pte_young(pte_t pte)
>   {
>   	unsigned long mask;
> @@ -964,9 +977,14 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>   pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
>   #endif
>   
> -/* Encode and de-code a swap entry */
> +/* Encode and de-code a swap entry. Upper bits of offset are used to
> + * store the ADI version tag for pages that have ADI enabled and tags set
> + */
>   #define __swp_type(entry)	(((entry).val >> PAGE_SHIFT) & 0xffUL)
> -#define __swp_offset(entry)	((entry).val >> (PAGE_SHIFT + 8UL))
> +#define __swp_offset(entry)		\
> +	((((entry).val << adi_nbits()) >> adi_nbits()) >> (PAGE_SHIFT + 8UL))
> +#define __swp_aditag(entry)		\
> +	((entry).val >> (sizeof(unsigned long)-adi_nbits()))
>   #define __swp_entry(type, offset)	\
>   	( (swp_entry_t) \
>   	  { \
> @@ -989,6 +1007,69 @@ int page_in_phys_avail(unsigned long paddr);
>   int remap_pfn_range(struct vm_area_struct *, unsigned long, unsigned long,
>   		    unsigned long, pgprot_t);
>   
> +#define __HAVE_ARCH_DO_SWAP_PAGE
> +static inline void arch_do_swap_page(struct mm_struct *mm, unsigned long addr,
> +				     pte_t pte, pte_t oldpte)
> +{
> +	if (pte_val(pte) & _PAGE_MCD_4V) {
> +		swp_entry_t tmp;
> +		pgoff_t swap_off;
> +		unsigned long swap_type, version;
> +
> +		/* Check if the swapped out page has an ADI version
> +		 * saved in the swap offset. If yes, restore
> +		 * version tag to the newly allocated page
> +		 */
> +		tmp = __pte_to_swp_entry(oldpte);
> +		swap_off = __swp_offset(tmp);
> +		swap_type = __swp_type(tmp);
> +		version = __swp_aditag(tmp);
> +		if (version) {
> +			unsigned long i, paddr;
> +
> +			paddr = pte_val(pte) & _PAGE_PADDR_4V;
> +			for (i = paddr; i < (paddr+PAGE_SIZE);
> +					i += adi_blksize())
> +				asm volatile("stxa %0, [%1] %2\n\t"
> +					:
> +					: "r" (version), "r" (i),
> +					  "i" (ASI_MCD_REAL));
> +		}
> +	}
> +}
> +
> +#define __HAVE_ARCH_UNMAP_ONE
> +static inline void arch_unmap_one(struct mm_struct *mm, unsigned long addr,
> +				  pte_t pte, pte_t oldpte)
> +{
> +	if (pte_val(oldpte) & _PAGE_MCD_4V) {
> +		unsigned long version, paddr;
> +
> +		paddr = pte_val(oldpte) & _PAGE_PADDR_4V;
> +		asm volatile("ldxa [%1] %2, %0\n\t"
> +			     : "=r" (version)
> +			     : "r" (paddr), "i" (ASI_MCD_REAL));
> +		if (version) {
> +			swp_entry_t tmp;
> +			pgoff_t swap_off;
> +			unsigned long swap_type, shift_size;
> +
> +			/* Save ADI version tag in the top bits
> +			 * of swap offset
> +			 */
> +			tmp = __pte_to_swp_entry(pte);
> +			swap_off = __swp_offset(tmp);
> +			swap_type = __swp_type(tmp);
> +			shift_size = PAGE_SHIFT + 8UL + adi_nbits();
> +			swap_off = (swap_off << shift_size)>>shift_size;
> +			swap_off = (version << (sizeof(unsigned long) -
> +					        shift_size)) | swap_off;
> +			tmp = __swp_entry(swap_type, swap_off);
> +			pte = __swp_entry_to_pte(tmp);
> +		}
> +	}
> +}
> +
>   static inline int io_remap_pfn_range(struct vm_area_struct *vma,
>   				     unsigned long from, unsigned long pfn,
>   				     unsigned long size, pgprot_t prot)
> diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
> index 3d7b925..b08fd39 100644
> --- a/arch/sparc/include/asm/thread_info_64.h
> +++ b/arch/sparc/include/asm/thread_info_64.h
> @@ -191,6 +191,7 @@ register struct thread_info *current_thread_info_reg asm("g6");
>    *       an immediate value in instructions such as andcc.
>    */
>   /* flag bit 12 is available */
> +#define TIF_MCDPER		12	/* Precise MCD exception */
>   #define TIF_MEMDIE		13	/* is terminating due to OOM killer */
>   #define TIF_POLLING_NRFLAG	14
>   
> diff --git a/arch/sparc/include/asm/uaccess_64.h b/arch/sparc/include/asm/uaccess_64.h
> index 5373136..6bfe818 100644
> --- a/arch/sparc/include/asm/uaccess_64.h
> +++ b/arch/sparc/include/asm/uaccess_64.h
> @@ -10,8 +10,10 @@
>   #include <linux/compiler.h>
>   #include <linux/string.h>
>   #include <linux/thread_info.h>
> +#include <linux/sched.h>
>   #include <asm/asi.h>
>   #include <asm/spitfire.h>
> +#include <asm/adi_64.h>
>   #include <asm-generic/uaccess-unaligned.h>
>   #include <asm/extable_64.h>
>   #endif
> @@ -72,6 +74,31 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
>   	__chk_range_not_ok((unsigned long __force)(addr), size, limit); \
>   })
>   
> +static inline void enable_adi(void)
> +{
> +	/*
> +	 * If userspace is using ADI, it could potentially pass a pointer
> +	 * with version tag embedded in it. To maintain the ADI security,
> +	 * we must enable PSTATE.mcde. Userspace would have already set
> +	 * TTE.mcd in an earlier call to kernel and set the version tag
> +	 * for the address being dereferenced. Setting PSTATE.mcde would
> +	 * ensure any access to userspace data through a system call
> +	 * honors ADI and does not allow a rogue app to bypass ADI by
> +	 * using system calls. Also to ensure the right exception,
> +	 * precise or disrupting, is delivered to the userspace, update
> +	 * PMCDPER to match MCDPER
> +	 */
> +	__asm__ __volatile__(
> +		"rdpr %%pstate, %%g1\n\t"
> +		"or %%g1, %0, %%g1\n\t"
> +		"wrpr %%g1, %%g0, %%pstate\n\t"
> +		".word 0x83438000\n\t"	/* rd %mcdper, %g1 */
> +		".word 0xaf900001\n\t"	/* wrpr  %g0, %g1, %pmcdper */
> +		:
> +		: "i" (PSTATE_MCDE)
> +		: "g1");
> +}
> +
>   static inline int __access_ok(const void __user * addr, unsigned long size)
>   {
>   	return 1;
> @@ -112,7 +139,9 @@ struct __large_struct { unsigned long buf[100]; };
>   #define __m(x) ((struct __large_struct *)(x))
>   
>   #define __put_user_nocheck(data, addr, size) ({			\
> -	register int __pu_ret;					\
> +	register int __pu_ret, __adi_status;				\
> +	if ((__adi_status = (current->mm && current->mm->context.adi)))	\
> +		enable_adi();					\
>   	switch (size) {						\
>   	case 1: __put_user_asm(data, b, addr, __pu_ret); break;	\
>   	case 2: __put_user_asm(data, h, addr, __pu_ret); break;	\
> @@ -120,6 +149,9 @@ struct __large_struct { unsigned long buf[100]; };
>   	case 8: __put_user_asm(data, x, addr, __pu_ret); break;	\
>   	default: __pu_ret = __put_user_bad(); break;		\
>   	}							\
> +	if (__adi_status)					\
> +		/* wrpr  %g0, %pmcdper */			\
> +		__asm__ __volatile__(".word 0xaf900000"::);	\
>   	__pu_ret;						\
>   })
>   
> @@ -146,8 +178,10 @@ __asm__ __volatile__(							\
>   int __put_user_bad(void);
>   
>   #define __get_user_nocheck(data, addr, size, type) ({			     \
> -	register int __gu_ret;						     \
> +	register int __gu_ret, __adi_status;				     \
>   	register unsigned long __gu_val;				     \
> +	if ((__adi_status = (current->mm && current->mm->context.adi)))	     \
> +		enable_adi();						     \
>   	switch (size) {							     \
>   		case 1: __get_user_asm(__gu_val, ub, addr, __gu_ret); break; \
>   		case 2: __get_user_asm(__gu_val, uh, addr, __gu_ret); break; \
> @@ -159,6 +193,9 @@ int __put_user_bad(void);
>   			break;						     \
>   	} 								     \
>   	data = (__force type) __gu_val;					     \
> +	if (__adi_status)						     \
> +		/* wrpr  %g0, %pmcdper */				     \
> +		__asm__ __volatile__(".word 0xaf900000"::);		     \
>   	 __gu_ret;							     \
>   })
>   
> @@ -185,15 +222,53 @@ __asm__ __volatile__(							\
>   
>   int __get_user_bad(void);
>   
> +/* When kernel access userspace memory, it must honor ADI setting
> + * to ensure ADI protection continues across system calls. Kernel
> + * must set PSTATE.mcde bit. It must also update PMCDPER register
> + * to reflect MCDPER register so the kind of exception generated
> + * in case of ADI version tag mismatch, is what the userspace is
> + * expecting. PMCDPER exists only on the processors that support
> + * ADI and must be accessed conditionally to avoid illegal
> + * instruction trap.
> + */
> +#define user_access_begin()						\
> +	do {								\
> +		if (current->mm && current->mm->context.adi)		\
> +			enable_adi();					\
> +	} while (0)
> +
> +#define user_access_end()						\
> +	do {								\
> +		if (adi_capable())					\
> +			/* wrpr  %g0, %pmcdper */			\
> +			__asm__ __volatile__(".word 0xaf900000"::);	\
> +	} while (0)
> +
> +#define unsafe_get_user(x, ptr, err)		\
> +		do { if (unlikely(__get_user(x, ptr))) goto err; } while (0)
> +#define unsafe_put_user(x, ptr, err)		\
> +		do { if (unlikely(__put_user(x, ptr))) goto err; } while (0)
> +
> +
>   unsigned long __must_check ___copy_from_user(void *to,
>   					     const void __user *from,
>   					     unsigned long size);
>   static inline unsigned long __must_check
>   copy_from_user(void *to, const void __user *from, unsigned long size)
>   {
> +	unsigned long ret, adi_status;
> +
>   	check_object_size(to, size, false);
>   
> -	return ___copy_from_user(to, from, size);
> +	if ((adi_status = (current->mm && current->mm->context.adi)))
> +		enable_adi();
> +
> +	ret = ___copy_from_user(to, from, size);
> +	if (adi_status)
> +		/* wrpr  %g0, %pmcdper */
> +		__asm__ __volatile__(".word 0xaf900000"::);
> +
> +	return ret;
>   }
>   #define __copy_from_user copy_from_user
>   
> @@ -203,9 +278,18 @@ unsigned long __must_check ___copy_to_user(void __user *to,
>   static inline unsigned long __must_check
>   copy_to_user(void __user *to, const void *from, unsigned long size)
>   {
> +	unsigned long ret, adi_status;
> +
>   	check_object_size(from, size, true);
>   
> -	return ___copy_to_user(to, from, size);
> +	if ((adi_status = (current->mm && current->mm->context.adi)))
> +		enable_adi();
> +
> +	ret = ___copy_to_user(to, from, size);
> +	if (adi_status)
> +		/* wrpr  %g0, %pmcdper */
> +		__asm__ __volatile__(".word 0xaf900000"::);
> +	return ret;
>   }
>   #define __copy_to_user copy_to_user
>   
> @@ -215,13 +299,37 @@ unsigned long __must_check ___copy_in_user(void __user *to,
>   static inline unsigned long __must_check
>   copy_in_user(void __user *to, void __user *from, unsigned long size)
>   {
> -	return ___copy_in_user(to, from, size);
> +	unsigned long ret, adi_status;
> +
> +	if ((adi_status = (current->mm && current->mm->context.adi)))
> +		enable_adi();
> +
> +	ret = ___copy_in_user(to, from, size);
> +	if (adi_status)
> +		/* wrpr  %g0, %pmcdper */
> +		__asm__ __volatile__(".word 0xaf900000"::);
> +
> +	return ret;
>   }
>   #define __copy_in_user copy_in_user
>   
>   unsigned long __must_check __clear_user(void __user *, unsigned long);
>   
> -#define clear_user __clear_user
> +static inline unsigned long __must_check
> +___clear_user(void __user *uaddr, unsigned long size)
> +{
> +	unsigned long ret, adi_status;
> +
> +	if ((adi_status = (current->mm && current->mm->context.adi)))
> +		enable_adi();
> +	ret = __clear_user(uaddr, size);
> +	if (adi_status)
> +		/* wrpr  %g0, %pmcdper */
> +		__asm__ __volatile__(".word 0xaf900000"::);
> +	return ret;
> +}
> +
> +#define clear_user ___clear_user
>   
>   __must_check long strlen_user(const char __user *str);
>   __must_check long strnlen_user(const char __user *str, long n);
> diff --git a/arch/sparc/include/uapi/asm/auxvec.h b/arch/sparc/include/uapi/asm/auxvec.h
> index ad6f360..6fe1249 100644
> --- a/arch/sparc/include/uapi/asm/auxvec.h
> +++ b/arch/sparc/include/uapi/asm/auxvec.h
> @@ -1,4 +1,12 @@
>   #ifndef __ASMSPARC_AUXVEC_H
>   #define __ASMSPARC_AUXVEC_H
>   
> +#ifdef CONFIG_SPARC64
> +#define AT_ADI_BLKSZ	34
> +#define AT_ADI_NBITS	35
> +#define AT_ADI_UEONADI	36
> +
> +#define AT_VECTOR_SIZE_ARCH	3
> +#endif
> +
>   #endif /* !(__ASMSPARC_AUXVEC_H) */
> diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
> index 9765896..a72c033 100644
> --- a/arch/sparc/include/uapi/asm/mman.h
> +++ b/arch/sparc/include/uapi/asm/mman.h
> @@ -5,6 +5,8 @@
>   
>   /* SunOS'ified... */
>   
> +#define PROT_ADI	0x10		/* ADI enabled */
> +
>   #define MAP_RENAME      MAP_ANONYMOUS   /* In SunOS terminology */
>   #define MAP_NORESERVE   0x40            /* don't reserve swap pages */
>   #define MAP_INHERIT     0x80            /* SunOS doesn't do this, but... */
> diff --git a/arch/sparc/kernel/Makefile b/arch/sparc/kernel/Makefile
> index fa3c02d..c9c4e76 100644
> --- a/arch/sparc/kernel/Makefile
> +++ b/arch/sparc/kernel/Makefile
> @@ -67,6 +67,7 @@ obj-$(CONFIG_SPARC64)   += visemul.o
>   obj-$(CONFIG_SPARC64)   += hvapi.o
>   obj-$(CONFIG_SPARC64)   += sstate.o
>   obj-$(CONFIG_SPARC64)   += mdesc.o
> +obj-$(CONFIG_SPARC64)   += adi_64.o
>   obj-$(CONFIG_SPARC64)	+= pcr.o
>   obj-$(CONFIG_SPARC64)	+= nmi.o
>   obj-$(CONFIG_SPARC64_SMP) += cpumap.o
> diff --git a/arch/sparc/kernel/adi_64.c b/arch/sparc/kernel/adi_64.c
> new file mode 100644
> index 0000000..aba1960
> --- /dev/null
> +++ b/arch/sparc/kernel/adi_64.c
> @@ -0,0 +1,93 @@
> +/* adi_64.c: support for ADI (Application Data Integrity) feature on
> + * sparc m7 and newer processors. This feature is also known as
> + * SSM (Silicon Secured Memory).
> + *
> + * Copyright (C) 2016 Khalid Aziz (khalid.aziz@oracle.com)
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + */
> +#include <linux/init.h>
> +#include <asm/mdesc.h>
> +#include <asm/adi_64.h>
> +
> +struct adi_config adi_state;
> +
> +/* mdesc_adi_init() : Parse machine description provided by the
> + *	hypervisor to detect ADI capabilities
> + *
> + * Hypervisor reports ADI capabilities of platform in "hwcap-list" property
> + * for "cpu" node. If the platform supports ADI, "hwcap-list" property
> + * contains the keyword "adp". If the platform supports ADI, "platform"
> + * node will contain "adp-blksz", "adp-nbits" and "ue-on-adp" properties
> + * to describe the ADI capabilities.
> + */
> +void __init mdesc_adi_init(void)
> +{
> +	struct mdesc_handle *hp = mdesc_grab();
> +	const char *prop;
> +	u64 pn, *val;
> +	int len;
> +
> +	if (!hp)
> +		goto adi_not_found;
> +
> +	pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "cpu");
> +	if (pn == MDESC_NODE_NULL)
> +		goto adi_not_found;
> +
> +	prop = mdesc_get_property(hp, pn, "hwcap-list", &len);
> +	if (!prop)
> +		goto adi_not_found;
> +
> +	/*
> +	 * Look for "adp" keyword in hwcap-list which would indicate
> +	 * ADI support
> +	 */
> +	adi_state.enabled = false;
> +	while (len) {
> +		int plen;
> +
> +		if (!strcmp(prop, "adp")) {
> +			adi_state.enabled = true;
> +			break;
> +		}
> +
> +		plen = strlen(prop) + 1;
> +		prop += plen;
> +		len -= plen;
> +	}
> +
> +	if (!adi_state.enabled)
> +		goto adi_not_found;
> +
> +	/* Find the ADI properties in "platform" node. If all ADI
> +	 * properties are not found, ADI support is incomplete and
> +	 * do not enable ADI in the kernel.
> +	 */
> +	pn = mdesc_node_by_name(hp, MDESC_NODE_NULL, "platform");
> +	if (pn == MDESC_NODE_NULL)
> +		goto adi_not_found;
> +
> +	val = (u64 *) mdesc_get_property(hp, pn, "adp-blksz", &len);
> +	if (!val)
> +		goto adi_not_found;
> +	adi_state.caps.blksz = *val;
> +
> +	val = (u64 *) mdesc_get_property(hp, pn, "adp-nbits", &len);
> +	if (!val)
> +		goto adi_not_found;
> +	adi_state.caps.nbits = *val;
> +
> +	val = (u64 *) mdesc_get_property(hp, pn, "ue-on-adp", &len);
> +	if (!val)
> +		goto adi_not_found;
> +	adi_state.caps.ue_on_adi = *val;
> +
> +	mdesc_release(hp);
> +	return;
> +
> +adi_not_found:
> +	adi_state.enabled = false;
> +	if (hp)
> +		mdesc_release(hp);
> +}
> diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
> index 8a6982d..0703a60 100644
> --- a/arch/sparc/kernel/mdesc.c
> +++ b/arch/sparc/kernel/mdesc.c
> @@ -20,6 +20,7 @@
>   #include <asm/uaccess.h>
>   #include <asm/oplib.h>
>   #include <asm/smp.h>
> +#include <asm/adi.h>
>   
>   /* Unlike the OBP device tree, the machine description is a full-on
>    * DAG.  An arbitrary number of ARCs are possible from one
> @@ -1104,5 +1105,6 @@ void __init sun4v_mdesc_init(void)
>   
>   	cur_mdesc = hp;
>   
> +	mdesc_adi_init();
>   	report_platform_properties();
>   }
> diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
> index 47ff558..0baa283 100644
> --- a/arch/sparc/kernel/process_64.c
> +++ b/arch/sparc/kernel/process_64.c
> @@ -680,6 +680,31 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
>   	return 0;
>   }
>   
> +/* TIF_MCDPER in thread info flags for current task is updated lazily upon
> + * a context switch. Update the this flag in current task's thread flags
> + * before dup so the dup'd task will inherit the current TIF_MCDPER flag.
> + */
> +int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
> +{
> +	if (adi_capable()) {
> +		register unsigned long tmp_mcdper;
> +
> +		__asm__ __volatile__(
> +			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
> +			"mov %%g1, %0\n\t"
> +			: "=r" (tmp_mcdper)
> +			:
> +			: "g1");
> +		if (tmp_mcdper)
> +			set_thread_flag(TIF_MCDPER);
> +		else
> +			clear_thread_flag(TIF_MCDPER);
> +	}
> +
> +	*dst = *src;
> +	return 0;
> +}
> +
>   typedef struct {
>   	union {
>   		unsigned int	pr_regs[32];
> diff --git a/arch/sparc/kernel/traps_64.c b/arch/sparc/kernel/traps_64.c
> index 500c9c6..576937c 100644
> --- a/arch/sparc/kernel/traps_64.c
> +++ b/arch/sparc/kernel/traps_64.c
> @@ -44,6 +44,7 @@
>   #include <asm/memctrl.h>
>   #include <asm/cacheflush.h>
>   #include <asm/setup.h>
> +#include <asm/adi_64.h>
>   
>   #include "entry.h"
>   #include "kernel.h"
> @@ -351,12 +352,31 @@ void sun4v_data_access_exception(struct pt_regs *regs, unsigned long addr, unsig
>   		regs->tpc &= 0xffffffff;
>   		regs->tnpc &= 0xffffffff;
>   	}
> -	info.si_signo = SIGSEGV;
> +
> +	/* MCD (Memory Corruption Detection) disabled trap (TT=0x19) in HV
> +	 * is vectored thorugh data access exception trap with fault type
> +	 * set to HV_FAULT_TYPE_MCD_DIS. Check for MCD disabled trap
> +	 */
>   	info.si_errno = 0;
> -	info.si_code = SEGV_MAPERR;
>   	info.si_addr = (void __user *) addr;
>   	info.si_trapno = 0;
> -	force_sig_info(SIGSEGV, &info, current);
> +	switch (type) {
> +	case HV_FAULT_TYPE_INV_ASI:
> +		info.si_signo = SIGILL;
> +		info.si_code = ILL_ILLADR;
> +		force_sig_info(SIGILL, &info, current);
> +		break;
> +	case HV_FAULT_TYPE_MCD_DIS:
> +		info.si_signo = SIGSEGV;
> +		info.si_code = SEGV_ACCADI;
> +		force_sig_info(SIGSEGV, &info, current);
> +		break;
> +	default:
> +		info.si_signo = SIGSEGV;
> +		info.si_code = SEGV_MAPERR;
> +		force_sig_info(SIGSEGV, &info, current);
> +		break;
> +	}
>   }
>   
>   void sun4v_data_access_exception_tl1(struct pt_regs *regs, unsigned long addr, unsigned long type_ctx)
> @@ -1801,6 +1821,7 @@ struct sun4v_error_entry {
>   #define SUN4V_ERR_ATTRS_ASI		0x00000080
>   #define SUN4V_ERR_ATTRS_PRIV_REG	0x00000100
>   #define SUN4V_ERR_ATTRS_SPSTATE_MSK	0x00000600
> +#define SUN4V_ERR_ATTRS_MCD		0x00000800
>   #define SUN4V_ERR_ATTRS_SPSTATE_SHFT	9
>   #define SUN4V_ERR_ATTRS_MODE_MSK	0x03000000
>   #define SUN4V_ERR_ATTRS_MODE_SHFT	24
> @@ -1998,6 +2019,54 @@ static void sun4v_log_error(struct pt_regs *regs, struct sun4v_error_entry *ent,
>   	}
>   }
>   
> +/* Handle memory corruption detected error which is vectored in
> + * through resumable error trap.
> + */
> +void do_mcd_err(struct pt_regs *regs, struct sun4v_error_entry ent)
> +{
> +	siginfo_t info;
> +
> +	if (notify_die(DIE_TRAP, "MCD error", regs,
> +		       0, 0x34, SIGSEGV) == NOTIFY_STOP)
> +		return;
> +
> +	if (regs->tstate & TSTATE_PRIV) {
> +		/* MCD exception could happen because the task was running
> +		 * a system call with MCD enabled and passed a non-versioned
> +		 * pointer or pointer with bad version tag to  the system
> +		 * call. In such cases, hypervisor places the address of
> +		 * offending instruction in the resumable error report. This
> +		 * is a deferred error, so the read/write that caused the trap
> +		 * was potentially retired long time back and we may have
> +		 * no choice but to send SIGSEGV to the process.
> +		 */
> +		const struct exception_table_entry *entry;
> +
> +		entry = search_exception_tables(regs->tpc);
> +		if (entry) {
> +			/* Looks like a bad syscall parameter */
> +#ifdef DEBUG_EXCEPTIONS
> +			pr_emerg("Exception: PC<%016lx> faddr<UNKNOWN>\n",
> +				 regs->tpc);
> +			pr_emerg("EX_TABLE: insn<%016lx> fixup<%016lx>\n",
> +				 ent.err_raddr, entry->fixup);
> +#endif
> +			regs->tpc = entry->fixup;
> +			regs->tnpc = regs->tpc + 4;
> +			return;
> +		}
> +	}
> +
> +	/* Send SIGSEGV to the userspace process with the right code
> +	 */
> +	info.si_signo = SIGSEGV;
> +	info.si_errno = 0;
> +	info.si_code = SEGV_ADIDERR;
> +	info.si_addr = (void __user *)ent.err_raddr;
> +	info.si_trapno = 0;
> +	force_sig_info(SIGSEGV, &info, current);
> +}
> +
>   /* We run with %pil set to PIL_NORMAL_MAX and PSTATE_IE enabled in %pstate.
>    * Log the event and clear the first word of the entry.
>    */
> @@ -2035,6 +2104,14 @@ void sun4v_resum_error(struct pt_regs *regs, unsigned long offset)
>   		goto out;
>   	}
>   
> +	/* If this is a memory corruption detected error, call the
> +	 * handler
> +	 */
> +	if (local_copy.err_attrs & SUN4V_ERR_ATTRS_MCD) {
> +		do_mcd_err(regs, local_copy);
> +		return;
> +	}
> +
>   	sun4v_log_error(regs, &local_copy, cpu,
>   			KERN_ERR "RESUMABLE ERROR",
>   			&sun4v_resum_oflow_cnt);
> @@ -2543,6 +2620,11 @@ void sun4v_mem_corrupt_detect_precise(struct pt_regs *regs, unsigned long addr,
>   {
>   	siginfo_t info;
>   
> +	if (!adi_capable()) {
> +		bad_trap(regs, 0x1a);
> +		return;
> +	}
> +
>   	if (notify_die(DIE_TRAP, "memory corruption precise exception", regs,
>   		       0, 0x8, SIGSEGV) == NOTIFY_STOP)
>   		return;
> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
> index cd0e32b..579f7ae 100644
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -11,6 +11,7 @@
>   #include <linux/pagemap.h>
>   #include <linux/rwsem.h>
>   #include <asm/pgtable.h>
> +#include <asm/adi.h>
>   
>   /*
>    * The performance critical leaf functions are made noinline otherwise gcc
> @@ -157,6 +158,24 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   	pgd_t *pgdp;
>   	int nr = 0;
>   
> +#ifdef CONFIG_SPARC64
> +	if (adi_capable()) {
> +		long addr = start;
> +
> +		/* If userspace has passed a versioned address, kernel
> +		 * will not find it in the VMAs since it does not store
> +		 * the version tags in the list of VMAs. Storing version
> +		 * tags in list of VMAs is impractical since they can be
> +		 * changed any time from userspace without dropping into
> +		 * kernel. Any address search in VMAs will be done with
> +		 * non-versioned addresses. Ensure the ADI version bits
> +		 * are dropped here by sign extending the last bit before
> +		 * ADI bits. IOMMU does not implement version tags.
> +		 */
> +		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();


So you are depending on the sign extension to clear the ADI bits... but 
this only happens if there is a zero in that "last bit before ADI bits". 
If the last bit is a 1, then the ADI bits will be set instead of 
cleared.  That seems like an unintended consequence given the comment. I 
am aware of the value of adi_nbits() and of the number of valid bits in 
a virtual address on the M7 processor, but wouldn't using 'unsigned 
long' for everything here guarantee the ADI bits get cleared regardless 
of the state of the last non-adi bit?


> +		start = addr;
> +	}
> +#endif
>   	start &= PAGE_MASK;
>   	addr = start;
>   	len = (unsigned long) nr_pages << PAGE_SHIFT;
> @@ -187,6 +206,24 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   	pgd_t *pgdp;
>   	int nr = 0;
>   
> +#ifdef CONFIG_SPARC64
> +	if (adi_capable()) {
> +		long addr = start;
> +
> +		/* If userspace has passed a versioned address, kernel
> +		 * will not find it in the VMAs since it does not store
> +		 * the version tags in the list of VMAs. Storing version
> +		 * tags in list of VMAs is impractical since they can be
> +		 * changed any time from userspace without dropping into
> +		 * kernel. Any address search in VMAs will be done with
> +		 * non-versioned addresses. Ensure the ADI version bits
> +		 * are dropped here by sign extending the last bit before
> +		 * ADI bits. IOMMU does not implements version tags,
> +		 */
> +		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();

Same comment here, and the various other places that employ this same 
code construct.


Rob




> +		start = addr;
> +	}
> +#endif
>   	start &= PAGE_MASK;
>   	addr = start;
>   	len = (unsigned long) nr_pages << PAGE_SHIFT;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a92c8d7..5c894a5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -225,6 +225,8 @@ extern unsigned int kobjsize(const void *objp);
>   # define VM_GROWSUP	VM_ARCH_1
>   #elif defined(CONFIG_IA64)
>   # define VM_GROWSUP	VM_ARCH_1
> +#elif defined(CONFIG_SPARC64)
> +# define VM_SPARC_ADI	VM_ARCH_1	/* Uses ADI tag for access control */
>   #elif !defined(CONFIG_MMU)
>   # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of data (nommu mmap) */
>   #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
