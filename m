Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3AC6810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:32:12 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id q72so3969251ywg.0
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:32:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o203si1884512ywc.696.2017.08.25.15.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 15:32:07 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data Integrity)
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
From: Anthony Yznaga <anthony.yznaga@oracle.com>
In-Reply-To: <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
Date: Fri, 25 Aug 2017 15:31:04 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <F65BCC2D-8FA4-453F-8378-3369C44B0319@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com> <cover.1502219353.git.khalid.aziz@oracle.com> <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: David Miller <davem@davemloft.net>, dave.hansen@linux.intel.com, corbet@lwn.net, Bob Picco <bob.picco@oracle.com>, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>


> On Aug 9, 2017, at 2:26 PM, Khalid Aziz <khalid.aziz@oracle.com> =
wrote:
>=20
> ADI is a new feature supported on SPARC M7 and newer processors to =
allow
> hardware to catch rogue accesses to memory. ADI is supported for data
> fetches only and not instruction fetches. An app can enable ADI on its
> data pages, set version tags on them and use versioned addresses to
> access the data pages. Upper bits of the address contain the version
> tag. On M7 processors, upper four bits (bits 63-60) contain the =
version
> tag. If a rogue app attempts to access ADI enabled data pages, its
> access is blocked and processor generates an exception. Please see
> Documentation/sparc/adi.txt for further details.
>=20
> This patch extends mprotect to enable ADI (TSTATE.mcde), =
enable/disable
> MCD (Memory Corruption Detection) on selected memory ranges, enable
> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore =
ADI
> version tags on page swap out/in or migration. ADI is not enabled by
> default for any task. A task must explicitly enable ADI on a memory
> range and set version tag for ADI to be effective for the task.
>=20
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> ---
> v7:
> 	- Enhanced arch_validate_prot() to enable ADI only on writable
> 	  addresses backed by physical RAM
> 	- Added support for saving/restoring ADI tags for each ADI
> 	  block size address range on a page on swap in/out
> 	- Added code to copy ADI tags on COW
> 	- Updated values for auxiliary vectors to not conflict with
> 	  values on other architectures to avoid conflict in glibc. =
glibc
> 	  consolidates all auxiliary vectors into its headers and
> 	  duplicate values in consolidated header are problematic
> 	- Disable same page merging on ADI enabled pages since ADI tags
> 	  may not match on pages with identical data
> 	- Broke the patch up further into smaller patches
>=20
> v6:
> 	- Eliminated instructions to read and write PSTATE as well as
> 	  MCDPER and PMCDPER on every access to userspace addresses
> 	  by setting PSTATE and PMCDPER correctly upon entry into
> 	  kernel. PSTATE.mcde and PMCDPER are set upon entry into
> 	  kernel when running on an M7 processor. PSTATE.mcde being
> 	  set only affects memory accesses that have TTE.mcd set.
> 	  PMCDPER being set only affects writes to memory addresses
> 	  that have TTE.mcd set. This ensures any faults caused by
> 	  ADI tag mismatch on a write are exposed before kernel returns
> 	  to userspace.
>=20
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
>=20
> v4:
> 	- Broke patch up into smaller patches
>=20
> v3:
> 	- Removed CONFIG_SPARC_ADI
> 	- Replaced prctl commands with mprotect
> 	- Added auxiliary vectors for ADI parameters
> 	- Enabled ADI for swappable pages
>=20
> v2:
> 	- Fixed a build error
>=20
> Documentation/sparc/adi.txt             | 272 =
+++++++++++++++++++++++++++++++
> arch/sparc/include/asm/mman.h           |  72 ++++++++-
> arch/sparc/include/asm/mmu_64.h         |  17 ++
> arch/sparc/include/asm/mmu_context_64.h |  43 +++++
> arch/sparc/include/asm/page_64.h        |   4 +
> arch/sparc/include/asm/pgtable_64.h     |  46 ++++++
> arch/sparc/include/asm/thread_info_64.h |   2 +-
> arch/sparc/include/asm/trap_block.h     |   2 +
> arch/sparc/include/uapi/asm/mman.h      |   2 +
> arch/sparc/kernel/adi_64.c              | 277 =
++++++++++++++++++++++++++++++++
> arch/sparc/kernel/etrap_64.S            |  28 +++-
> arch/sparc/kernel/process_64.c          |  25 +++
> arch/sparc/kernel/setup_64.c            |  11 +-
> arch/sparc/kernel/vmlinux.lds.S         |   5 +
> arch/sparc/mm/gup.c                     |  37 +++++
> arch/sparc/mm/hugetlbpage.c             |  14 +-
> arch/sparc/mm/init_64.c                 |  33 ++++
> arch/sparc/mm/tsb.c                     |  21 +++
> include/linux/mm.h                      |   3 +
> mm/ksm.c                                |   4 +
> 20 files changed, 913 insertions(+), 5 deletions(-)
> create mode 100644 Documentation/sparc/adi.txt
>=20
> diff --git a/Documentation/sparc/adi.txt b/Documentation/sparc/adi.txt
> new file mode 100644
> index 000000000000..383bc65fec1e
> --- /dev/null
> +++ b/Documentation/sparc/adi.txt
> @@ -0,0 +1,272 @@
> +Application Data Integrity (ADI)
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +SPARC M7 processor adds the Application Data Integrity (ADI) feature.
> +ADI allows a task to set version tags on any subset of its address
> +space. Once ADI is enabled and version tags are set for ranges of
> +address space of a task, the processor will compare the tag in =
pointers
> +to memory in these ranges to the version set by the application
> +previously. Access to memory is granted only if the tag in given =
pointer
> +matches the tag set by the application. In case of mismatch, =
processor
> +raises an exception.
> +
> +Following steps must be taken by a task to enable ADI fully:
> +
> +1. Set the user mode PSTATE.mcde bit. This acts as master switch for
> +   the task's entire address space to enable/disable ADI for the =
task.
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
> +ADI block size for the platform is provided by the hypervisor to =
kernel
> +in machine description tables. Hypervisor also provides the number of
> +top bits in the virtual address that specify the version tag.  Once
> +version tag has been set for a memory location, the tag is stored in =
the
> +physical memory and the same tag must be present in the ADI version =
tag
> +bits of the virtual address being presented to the MMU. For example =
on
> +SPARC M7 processor, MMU uses bits 63-60 for version tags and ADI =
block
> +size is same as cacheline size which is 64 bytes. A task that sets =
ADI
> +version to, say 10, on a range of memory, must access that memory =
using
> +virtual addresses that contain 0xa in bits 63-60.
> +
> +ADI is enabled on a set of pages using mprotect() with PROT_ADI flag.
> +When ADI is enabled on a set of pages by a task for the first time,
> +kernel sets the PSTATE.mcde bit fot the task. Version tags for memory
> +addresses are set with an stxa instruction on the addresses using
> +ASI_MCD_PRIMARY or ASI_MCD_ST_BLKINIT_PRIMARY. ADI block size is
> +provided by the hypervisor to the kernel.  Kernel returns the value =
of
> +ADI block size to userspace using auxiliary vector along with other =
ADI
> +info. Following auxiliary vectors are provided by the kernel:
> +
> +	AT_ADI_BLKSZ	ADI block size. This is the granularity and
> +			alignment, in bytes, of ADI versioning.
> +	AT_ADI_NBITS	Number of ADI version bits in the VA

The previous patch series also defined AT_ADI_UEONADI.  Why was that
removed?

> +
> +
> +IMPORTANT NOTES:
> +
> +- Version tag values of 0x0 and 0xf are reserved.

The documentation should probably state more specifically that an
in-memory tag value of 0x0 or 0xf is treated as "match all" by the HW
meaning that a mismatch exception will never be generated regardless
of the tag bits set in the VA accessing the memory.

> +
> +- Version tags are set on virtual addresses from userspace even =
though
> +  tags are stored in physical memory. Tags are set on a physical page
> +  after it has been allocated to a task and a pte has been created =
for
> +  it.
> +
> +- When a task frees a memory page it had set version tags on, the =
page
> +  goes back to free page pool. When this page is re-allocated to a =
task,
> +  kernel clears the page using block initialization ASI which clears =
the
> +  version tags as well for the page. If a page allocated to a task is
> +  freed and allocated back to the same task, old version tags set by =
the
> +  task on that page will no longer be present.

The specifics should be included here, too, so someone doesn't have
to guess what's going on if they make changes and the tags are no longer
cleared.  The HW clears the tag for a cacheline for block initializing
stores to 64-byte aligned addresses if PSTATE.mcde=3D0 or TTE.mcd=3D0.
PSTATE.mce is set when executing in the kernel, but pages are cleared
using kernel physical mapping VAs which are mapped with TTE.mcd=3D0.

Another HW behavior that should be mentioned is that tag mismatches
are not detected for non-faulting loads.

> +
> +- Kernel does not set any tags for user pages and it is entirely a
> +  task's responsibility to set any version tags. Kernel does ensure =
the
> +  version tags are preserved if a page is swapped out to the disk and
> +  swapped back in. It also preserves that version tags if a page is
> +  migrated.

I only have a cursory understanding of how page migration works, but
I could not see how the tags would be preserved if a page were migrated.
I figured the place to copy the tags would be migrate_page_copy(), but
I don't see changes there.


> +
> +- ADI works for any size pages. A userspace task need not be aware of
> +  page size when using ADI. It can simply select a virtual address
> +  range, enable ADI on the range using mprotect() and set version =
tags
> +  for the entire range. mprotect() ensures range is aligned to page =
size
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
> +	When a store accesses a memory localtion that has TTE.mcd=3D1,
> +	the task is running with ADI enabled (PSTATE.mcde=3D1), and the =
ADI
> +	tag in the address used (bits 63:60) does not match the tag set =
on
> +	the corresponding cacheline, a memory corruption trap occurs. By
> +	default, it is a disrupting trap and is sent to the hypervisor
> +	first. Hypervisor creates a sun4v error report and sends a
> +	resumable error (TT=3D0x7e) trap to the kernel. The kernel sends
> +	a SIGSEGV to the task that resulted in this trap with the =
following
> +	info:
> +
> +		siginfo.si_signo =3D SIGSEGV;
> +		siginfo.errno =3D 0;
> +		siginfo.si_code =3D SEGV_ADIDERR;
> +		siginfo.si_addr =3D addr; /* PC where first mismatch =
occurred */
> +		siginfo.si_trapno =3D 0;
> +
> +
> +Precise memory corruption
> +
> +	When a store accesses a memory location that has TTE.mcd=3D1,
> +	the task is running with ADI enabled (PSTATE.mcde=3D1), and the =
ADI
> +	tag in the address used (bits 63:60) does not match the tag set =
on
> +	the corresponding cacheline, a memory corruption trap occurs. If
> +	MCD precise exception is enabled (MCDPERR=3D1), a precise
> +	exception is sent to the kernel with TT=3D0x1a. The kernel sends
> +	a SIGSEGV to the task that resulted in this trap with the =
following
> +	info:
> +
> +		siginfo.si_signo =3D SIGSEGV;
> +		siginfo.errno =3D 0;
> +		siginfo.si_code =3D SEGV_ADIPERR;
> +		siginfo.si_addr =3D addr;	/* address that caused =
trap */
> +		siginfo.si_trapno =3D 0;
> +
> +	NOTE: ADI tag mismatch on a load always results in precise trap.
> +
> +
> +MCD disabled
> +
> +	When a task has not enabled ADI and attempts to set ADI version
> +	on a memory address, processor sends an MCD disabled trap. This
> +	trap is handled by hypervisor first and the hypervisor vectors =
this
> +	trap through to the kernel as Data Access Exception trap with
> +	fault type set to 0xa (invalid ASI). When this occurs, the =
kernel
> +	sends the task SIGSEGV signal with following info:
> +
> +		siginfo.si_signo =3D SIGSEGV;
> +		siginfo.errno =3D 0;
> +		siginfo.si_code =3D SEGV_ACCADI;
> +		siginfo.si_addr =3D addr;	/* address that caused =
trap */
> +		siginfo.si_trapno =3D 0;
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
> +#define AT_ADI_BLKSZ	48
> +#endif
> +#ifndef AT_ADI_NBITS
> +#define AT_ADI_NBITS	49
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
> +        unsigned long i, mcde, adi_blksz, adi_nbits;
> +        char *shmaddr, *tmp_addr, *end, *veraddr, *clraddr;
> +        int shmid, version;
> +	Elf64_auxv_t *auxv;
> +
> +	adi_blksz =3D 0;
> +
> +	while(*envp++ !=3D NULL);
> +	for (auxv =3D (Elf64_auxv_t *)envp; auxv->a_type !=3D AT_NULL; =
auxv++) {
> +		switch (auxv->a_type) {
> +		case AT_ADI_BLKSZ:
> +			adi_blksz =3D auxv->a_un.a_val;
> +			break;
> +		case AT_ADI_NBITS:
> +			adi_nbits =3D auxv->a_un.a_val;
> +			break;
> +		}
> +	}
> +	if (adi_blksz =3D=3D 0) {
> +		fprintf(stderr, "Oops! ADI is not supported\n");
> +		exit(1);
> +	}
> +
> +	printf("ADI capabilities:\n");
> +	printf("\tBlock size =3D %ld\n", adi_blksz);
> +	printf("\tNumber of bits =3D %ld\n", adi_nbits);
> +
> +        if ((shmid =3D shmget(2, BUFFER_SIZE,
> +                                IPC_CREAT | SHM_R | SHM_W)) < 0) {
> +                perror("shmget failed");
> +                exit(1);
> +        }
> +
> +        shmaddr =3D shmat(shmid, NULL, 0);
> +        if (shmaddr =3D=3D (char *)-1) {
> +                perror("shm attach failed");
> +                shmctl(shmid, IPC_RMID, NULL);
> +                exit(1);
> +        }
> +
> +	if (mprotect(shmaddr, BUFFER_SIZE, =
PROT_READ|PROT_WRITE|PROT_ADI)) {
> +		perror("mprotect failed");
> +		goto err_out;
> +	}
> +
> +        /* Set the ADI version tag on the shm segment
> +         */
> +        version =3D 10;
> +        tmp_addr =3D shmaddr;
> +        end =3D shmaddr + BUFFER_SIZE;
> +        while (tmp_addr < end) {
> +                asm volatile(
> +                        "stxa %1, [%0]0x90\n\t"
> +                        :
> +                        : "r" (tmp_addr), "r" (version));
> +                tmp_addr +=3D adi_blksz;
> +        }
> +	asm volatile("membar #Sync\n\t");
> +
> +        /* Create a versioned address from the normal address by =
placing
> +	 * version tag in the upper adi_nbits bits
> +         */
> +        tmp_addr =3D (void *) ((unsigned long)shmaddr << adi_nbits);
> +        tmp_addr =3D (void *) ((unsigned long)tmp_addr >> adi_nbits);
> +        veraddr =3D (void *) (((unsigned long)version << =
(64-adi_nbits))
> +                        | (unsigned long)tmp_addr);
> +
> +        printf("Starting the writes:\n");
> +        for (i =3D 0; i < BUFFER_SIZE; i++) {
> +                veraddr[i] =3D (char)(i);
> +                if (!(i % (1024 * 1024)))
> +                        printf(".");
> +        }
> +        printf("\n");
> +
> +        printf("Verifying data...");
> +	fflush(stdout);
> +        for (i =3D 0; i < BUFFER_SIZE; i++)
> +                if (veraddr[i] !=3D (char)i)
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
> +        if (shmdt((const void *)shmaddr) !=3D 0)
> +                perror("Detach failure");
> +        shmctl(shmid, IPC_RMID, NULL);
> +
> +        exit(0);
> +
> +err_out:
> +        if (shmdt((const void *)shmaddr) !=3D 0)
> +                perror("Detach failure");
> +        shmctl(shmid, IPC_RMID, NULL);
> +        exit(1);
> +}
> diff --git a/arch/sparc/include/asm/mman.h =
b/arch/sparc/include/asm/mman.h
> index 59bb5938d852..b799796ad963 100644
> --- a/arch/sparc/include/asm/mman.h
> +++ b/arch/sparc/include/asm/mman.h
> @@ -6,5 +6,75 @@
> #ifndef __ASSEMBLY__
> #define arch_mmap_check(addr,len,flags)	=
sparc_mmap_check(addr,len)
> int sparc_mmap_check(unsigned long addr, unsigned long len);
> -#endif
> +
> +#ifdef CONFIG_SPARC64
> +#include <asm/adi_64.h>
> +
> +#define arch_calc_vm_prot_bits(prot, pkey) =
sparc_calc_vm_prot_bits(prot)
> +static inline unsigned long sparc_calc_vm_prot_bits(unsigned long =
prot)
> +{
> +	if (prot & PROT_ADI) {
> +		struct pt_regs *regs;
> +
> +		if (!current->mm->context.adi) {
> +			regs =3D task_pt_regs(current);
> +			regs->tstate |=3D TSTATE_MCDE;
> +			current->mm->context.adi =3D true;

If a process is multi-threaded when it enables ADI on some memory for
the first time, TSTATE_MCDE will only be set for the calling thread
and it will not be possible to enable it for the other threads.
One possible way to handle this is to enable TSTATE_MCDE for all user
threads when they are initialized if adi_capable() returns true.


> +		}
> +		return VM_SPARC_ADI;
> +	} else {
> +		return 0;
> +	}
> +}
> +
> +#define arch_vm_get_page_prot(vm_flags) =
sparc_vm_get_page_prot(vm_flags)
> +static inline pgprot_t sparc_vm_get_page_prot(unsigned long vm_flags)
> +{
> +	return (vm_flags & VM_SPARC_ADI) ? __pgprot(_PAGE_MCD_4V) : =
__pgprot(0);
> +}
> +
> +#define arch_validate_prot(prot, addr) sparc_validate_prot(prot, =
addr)
> +static inline int sparc_validate_prot(unsigned long prot, unsigned =
long addr)
> +{
> +	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | =
PROT_ADI))
> +		return 0;
> +	if (prot & PROT_ADI) {
> +		if (!adi_capable())
> +			return 0;
> +
> +		/* ADI tags can not be set on read-only memory, so it =
makes
> +		 * sense to enable ADI on writable memory only.
> +		 */
> +		if (!(prot & PROT_WRITE))
> +			return 0;

This prevents the use of ADI for the legitimate case where shared memory
is mapped read/write for a master process but mapped read-only for a
client process.  The master process could set the tags and communicate
the expected tag values to the client.


> +
> +		if (addr) {
> +			struct vm_area_struct *vma;
> +
> +			vma =3D find_vma(current->mm, addr);
> +			if (vma) {
> +				/* ADI can not be enabled on PFN
> +				 * mapped pages
> +				 */
> +				if (vma->vm_flags & (VM_PFNMAP | =
VM_MIXEDMAP))
> +					return 0;
> +
> +				/* Mergeable pages can become =
unmergeable
> +				 * if ADI is enabled on them even if =
they
> +				 * have identical data on them. This can =
be
> +				 * because ADI enabled pages with =
identical
> +				 * data may still not have identical ADI
> +				 * tags on them. Disallow ADI on =
mergeable
> +				 * pages.
> +				 */
> +				if (vma->vm_flags & VM_MERGEABLE)
> +					return 0;
> +			}
> +		}
> +	}
> +	return 1;
> +}
> +#endif /* CONFIG_SPARC64 */
> +
> +#endif /* __ASSEMBLY__ */
> #endif /* __SPARC_MMAN_H__ */
> diff --git a/arch/sparc/include/asm/mmu_64.h =
b/arch/sparc/include/asm/mmu_64.h
> index 83b36a5371ff..a65d51ebe00b 100644
> --- a/arch/sparc/include/asm/mmu_64.h
> +++ b/arch/sparc/include/asm/mmu_64.h
> @@ -89,6 +89,20 @@ struct tsb_config {
> #define MM_NUM_TSBS	1
> #endif
>=20
> +/* ADI tags are stored when a page is swapped out and the storage for
> + * tags is allocated dynamically. There is a tag storage descriptor
> + * associated with each set of tag storage pages. Tag storage =
descriptors
> + * are allocated dynamically. Since kernel will allocate a full page =
for
> + * each tag storage descriptor, we can store up to
> + * PAGE_SIZE/sizeof(tag storage descriptor) descriptors on that page.
> + */
> +typedef struct {
> +	unsigned long	start;		/* Start address for this tag =
storage */
> +	unsigned long	end;		/* Last address for tag storage =
*/
> +	unsigned char	*tags;		/* Where the tags are */
> +	unsigned long	tag_users;	/* number of references to =
descriptor */
> +} tag_storage_desc_t;
> +
> typedef struct {
> 	spinlock_t		lock;
> 	unsigned long		sparc64_ctx_val;
> @@ -96,6 +110,9 @@ typedef struct {
> 	unsigned long		thp_pte_count;
> 	struct tsb_config	tsb_block[MM_NUM_TSBS];
> 	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
> +	bool			adi;
> +	tag_storage_desc_t	*tag_store;
> +	spinlock_t		tag_lock;
> } mm_context_t;
>=20
> #endif /* !__ASSEMBLY__ */
> diff --git a/arch/sparc/include/asm/mmu_context_64.h =
b/arch/sparc/include/asm/mmu_context_64.h
> index 2cddcda4f85f..68de059551f9 100644
> --- a/arch/sparc/include/asm/mmu_context_64.h
> +++ b/arch/sparc/include/asm/mmu_context_64.h
> @@ -9,6 +9,7 @@
> #include <linux/mm_types.h>
>=20
> #include <asm/spitfire.h>
> +#include <asm/adi_64.h>
> #include <asm-generic/mm_hooks.h>
>=20
> static inline void enter_lazy_tlb(struct mm_struct *mm, struct =
task_struct *tsk)
> @@ -129,6 +130,48 @@ static inline void switch_mm(struct mm_struct =
*old_mm, struct mm_struct *mm, str
>=20
> #define deactivate_mm(tsk,mm)	do { } while (0)
> #define activate_mm(active_mm, mm) switch_mm(active_mm, mm, NULL)
> +
> +#define  __HAVE_ARCH_START_CONTEXT_SWITCH
> +static inline void arch_start_context_switch(struct task_struct =
*prev)
> +{
> +	/* Save the current state of MCDPER register for the process
> +	 * we are switching from
> +	 */
> +	if (adi_capable()) {
> +		register unsigned long tmp_mcdper;
> +
> +		__asm__ __volatile__(
> +			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
> +			"mov %%g1, %0\n\t"
> +			: "=3Dr" (tmp_mcdper)
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
> +		tmp_mcdper =3D test_thread_flag(TIF_MCDPER);
> +		__asm__ __volatile__(
> +			"mov %0, %%g1\n\t"
> +			".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" =
*/
> +			:
> +			: "ir" (tmp_mcdper)
> +			: "g1");
> +	}
> +}
> +
> #endif /* !(__ASSEMBLY__) */
>=20
> #endif /* !(__SPARC64_MMU_CONTEXT_H) */
> diff --git a/arch/sparc/include/asm/page_64.h =
b/arch/sparc/include/asm/page_64.h
> index 5961b2d8398a..dc582c5611f8 100644
> --- a/arch/sparc/include/asm/page_64.h
> +++ b/arch/sparc/include/asm/page_64.h
> @@ -46,6 +46,10 @@ struct page;
> void clear_user_page(void *addr, unsigned long vaddr, struct page =
*page);
> #define copy_page(X,Y)	memcpy((void *)(X), (void *)(Y), =
PAGE_SIZE)
> void copy_user_page(void *to, void *from, unsigned long vaddr, struct =
page *topage);
> +#define __HAVE_ARCH_COPY_USER_HIGHPAGE
> +struct vm_area_struct;
> +void copy_user_highpage(struct page *to, struct page *from,
> +			unsigned long vaddr, struct vm_area_struct =
*vma);
>=20
> /* Unlike sparc32, sparc64's parameter passing API is more
>  * sane in that structures which as small enough are passed
> diff --git a/arch/sparc/include/asm/pgtable_64.h =
b/arch/sparc/include/asm/pgtable_64.h
> index af045061f41e..51da342c392d 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -18,6 +18,7 @@
> #include <asm/types.h>
> #include <asm/spitfire.h>
> #include <asm/asi.h>
> +#include <asm/adi.h>
> #include <asm/page.h>
> #include <asm/processor.h>
>=20
> @@ -570,6 +571,18 @@ static inline pte_t pte_mkspecial(pte_t pte)
> 	return pte;
> }
>=20
> +static inline pte_t pte_mkmcd(pte_t pte)
> +{
> +	pte_val(pte) |=3D _PAGE_MCD_4V;
> +	return pte;
> +}
> +
> +static inline pte_t pte_mknotmcd(pte_t pte)
> +{
> +	pte_val(pte) &=3D ~_PAGE_MCD_4V;
> +	return pte;
> +}
> +
> static inline unsigned long pte_young(pte_t pte)
> {
> 	unsigned long mask;
> @@ -1001,6 +1014,39 @@ int page_in_phys_avail(unsigned long paddr);
> int remap_pfn_range(struct vm_area_struct *, unsigned long, unsigned =
long,
> 		    unsigned long, pgprot_t);
>=20
> +void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct =
*vma,
> +		      unsigned long addr, pte_t pte);
> +
> +int adi_save_tags(struct mm_struct *mm, struct vm_area_struct *vma,
> +		  unsigned long addr, pte_t oldpte);
> +
> +#define __HAVE_ARCH_DO_SWAP_PAGE
> +static inline void arch_do_swap_page(struct mm_struct *mm,
> +				     struct vm_area_struct *vma,
> +				     unsigned long addr,
> +				     pte_t pte, pte_t oldpte)
> +{
> +	/* If this is a new page being mapped in, there can be no
> +	 * ADI tags stored away for this page. Skip looking for
> +	 * stored tags
> +	 */
> +	if (pte_none(oldpte))
> +		return;
> +
> +	if (adi_state.enabled && (pte_val(pte) & _PAGE_MCD_4V))
> +		adi_restore_tags(mm, vma, addr, pte);
> +}
> +
> +#define __HAVE_ARCH_UNMAP_ONE
> +static inline int arch_unmap_one(struct mm_struct *mm,
> +				 struct vm_area_struct *vma,
> +				 unsigned long addr, pte_t oldpte)
> +{
> +	if (adi_state.enabled && (pte_val(oldpte) & _PAGE_MCD_4V))
> +		return adi_save_tags(mm, vma, addr, oldpte);
> +	return 0;
> +}
> +
> static inline int io_remap_pfn_range(struct vm_area_struct *vma,
> 				     unsigned long from, unsigned long =
pfn,
> 				     unsigned long size, pgprot_t prot)
> diff --git a/arch/sparc/include/asm/thread_info_64.h =
b/arch/sparc/include/asm/thread_info_64.h
> index 38a24f257b85..9c04acb1f9af 100644
> --- a/arch/sparc/include/asm/thread_info_64.h
> +++ b/arch/sparc/include/asm/thread_info_64.h
> @@ -190,7 +190,7 @@ register struct thread_info =
*current_thread_info_reg asm("g6");
>  *       in using in assembly, else we can't use the mask as
>  *       an immediate value in instructions such as andcc.
>  */
> -/* flag bit 12 is available */
> +#define TIF_MCDPER		12	/* Precise MCD exception */
> #define TIF_MEMDIE		13	/* is terminating due to OOM =
killer */
> #define TIF_POLLING_NRFLAG	14
>=20
> diff --git a/arch/sparc/include/asm/trap_block.h =
b/arch/sparc/include/asm/trap_block.h
> index ec9c04de3664..b283e940671a 100644
> --- a/arch/sparc/include/asm/trap_block.h
> +++ b/arch/sparc/include/asm/trap_block.h
> @@ -72,6 +72,8 @@ struct sun4v_1insn_patch_entry {
> };
> extern struct sun4v_1insn_patch_entry __sun4v_1insn_patch,
> 	__sun4v_1insn_patch_end;
> +extern struct sun4v_1insn_patch_entry __sun_m7_1insn_patch,
> +	__sun_m7_1insn_patch_end;
>=20
> struct sun4v_2insn_patch_entry {
> 	unsigned int	addr;
> diff --git a/arch/sparc/include/uapi/asm/mman.h =
b/arch/sparc/include/uapi/asm/mman.h
> index 9765896ecb2c..a72c03397345 100644
> --- a/arch/sparc/include/uapi/asm/mman.h
> +++ b/arch/sparc/include/uapi/asm/mman.h
> @@ -5,6 +5,8 @@
>=20
> /* SunOS'ified... */
>=20
> +#define PROT_ADI	0x10		/* ADI enabled */
> +
> #define MAP_RENAME      MAP_ANONYMOUS   /* In SunOS terminology */
> #define MAP_NORESERVE   0x40            /* don't reserve swap pages */
> #define MAP_INHERIT     0x80            /* SunOS doesn't do this, =
but... */
> diff --git a/arch/sparc/kernel/adi_64.c b/arch/sparc/kernel/adi_64.c
> index 9fbb5dd4a7bf..83c1e36ae5fa 100644
> --- a/arch/sparc/kernel/adi_64.c
> +++ b/arch/sparc/kernel/adi_64.c
> @@ -7,10 +7,24 @@
>  * This work is licensed under the terms of the GNU GPL, version 2.
>  */
> #include <linux/init.h>
> +#include <linux/slab.h>
> +#include <linux/mm_types.h>
> #include <asm/mdesc.h>
> #include <asm/adi_64.h>
> +#include <asm/mmu_64.h>
> +#include <asm/pgtable_64.h>
> +
> +/* Each page of storage for ADI tags can accommodate tags for 128
> + * pages. When ADI enabled pages are being swapped out, it would be
> + * prudent to allocate at least enough tag storage space to =
accommodate
> + * SWAPFILE_CLUSTER number of pages. Allocate enough tag storage to
> + * store tags for four SWAPFILE_CLUSTER pages to reduce need for
> + * further allocations for same vma.
> + */
> +#define TAG_STORAGE_PAGES	8
>=20
> struct adi_config adi_state;
> +EXPORT_SYMBOL(adi_state);
>=20
> /* mdesc_adi_init() : Parse machine description provided by the
>  *	hypervisor to detect ADI capabilities
> @@ -78,6 +92,19 @@ void __init mdesc_adi_init(void)
> 		goto adi_not_found;
> 	adi_state.caps.nbits =3D *val;
>=20
> +	/* Some of the code to support swapping ADI tags is written
> +	 * assumption that two ADI tags can fit inside one byte. If
> +	 * this assumption is broken by a future architecture change,
> +	 * that code will have to be revisited. If that were to happen,
> +	 * disable ADI support so we do not get unpredictable results
> +	 * with programs trying to use ADI and their pages getting
> +	 * swapped out
> +	 */
> +	if (adi_state.caps.nbits > 4) {
> +		pr_warn("WARNING: ADI tag size >4 on this platform. =
Disabling AADI support\n");
> +		adi_state.enabled =3D false;
> +	}
> +
> 	mdesc_release(hp);
> 	return;
>=20
> @@ -88,3 +115,253 @@ void __init mdesc_adi_init(void)
> 	if (hp)
> 		mdesc_release(hp);
> }
> +
> +tag_storage_desc_t *find_tag_store(struct mm_struct *mm,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr)
> +{
> +	tag_storage_desc_t *tag_desc =3D NULL;
> +	unsigned long i, max_desc, flags;
> +
> +	/* Check if this vma already has tag storage descriptor
> +	 * allocated for it.
> +	 */
> +	max_desc =3D PAGE_SIZE/sizeof(tag_storage_desc_t);
> +	if (mm->context.tag_store) {
> +		tag_desc =3D mm->context.tag_store;
> +		spin_lock_irqsave(&mm->context.tag_lock, flags);
> +		for (i =3D 0; i < max_desc; i++) {
> +			if ((addr >=3D tag_desc->start) &&
> +			    ((addr + PAGE_SIZE - 1) <=3D tag_desc->end))
> +				break;
> +			tag_desc++;
> +		}
> +		spin_unlock_irqrestore(&mm->context.tag_lock, flags);
> +
> +		/* If no matching entries were found, this must be a
> +		 * freshly allocated page
> +		 */
> +		if (i >=3D max_desc)
> +			tag_desc =3D NULL;
> +	}
> +
> +	return tag_desc;
> +}
> +
> +tag_storage_desc_t *alloc_tag_store(struct mm_struct *mm,
> +				    struct vm_area_struct *vma,
> +				    unsigned long addr)
> +{
> +	unsigned char *tags;
> +	unsigned long i, size, max_desc, flags;
> +	tag_storage_desc_t *tag_desc, *open_desc;
> +	unsigned long end_addr, hole_start, hole_end;
> +
> +	max_desc =3D PAGE_SIZE/sizeof(tag_storage_desc_t);
> +	open_desc =3D NULL;
> +	hole_start =3D 0;
> +	hole_end =3D ULONG_MAX;
> +	end_addr =3D addr + PAGE_SIZE - 1;
> +
> +	/* Check if this vma already has tag storage descriptor
> +	 * allocated for it.
> +	 */
> +	spin_lock_irqsave(&mm->context.tag_lock, flags);
> +	if (mm->context.tag_store) {
> +		tag_desc =3D mm->context.tag_store;
> +
> +		/* Look for a matching entry for this address. While =
doing
> +		 * that, look for the first open slot as well and find
> +		 * the hole in already allocated range where this =
request
> +		 * will fit in.
> +		 */
> +		for (i =3D 0; i < max_desc; i++) {
> +			if (tag_desc->tag_users =3D=3D 0) {
> +				if (open_desc =3D=3D NULL)
> +					open_desc =3D tag_desc;
> +			} else {
> +				if ((addr >=3D tag_desc->start) &&
> +				    (tag_desc->end >=3D (addr + =
PAGE_SIZE - 1))) {
> +					tag_desc->tag_users++;
> +					goto out;
> +				}
> +			}
> +			if ((tag_desc->start > end_addr) &&
> +			    (tag_desc->start < hole_end))
> +				hole_end =3D tag_desc->start;
> +			if ((tag_desc->end < addr) &&
> +			    (tag_desc->end > hole_start))
> +				hole_start =3D tag_desc->end;
> +			tag_desc++;
> +		}
> +
> +	} else {
> +		size =3D sizeof(tag_storage_desc_t)*max_desc;
> +		mm->context.tag_store =3D kzalloc(size, =
GFP_NOIO|__GFP_NOWARN);

The spin_lock_irqsave() above means that all but level 15 interrupts
will be disabled when kzalloc() is called.  If kzalloc() can sleep
there's a risk of deadlock.


> +		if (mm->context.tag_store =3D=3D NULL) {
> +			tag_desc =3D NULL;
> +			goto out;
> +		}
> +		tag_desc =3D mm->context.tag_store;
> +		for (i =3D 0; i < max_desc; i++, tag_desc++)
> +			tag_desc->tag_users =3D 0;
> +		open_desc =3D mm->context.tag_store;
> +		i =3D 0;
> +	}
> +
> +	/* Check if we ran out of tag storage descriptors */
> +	if (open_desc =3D=3D NULL) {
> +		tag_desc =3D NULL;
> +		goto out;
> +	}
> +
> +	/* Mark this tag descriptor slot in use and then initialize it =
*/
> +	tag_desc =3D open_desc;
> +	tag_desc->tag_users =3D 1;
> +
> +	/* Tag storage has not been allocated for this vma and space
> +	 * is available in tag storage descriptor. Since this page is
> +	 * being swapped out, there is high probability subsequent pages
> +	 * in the VMA will be swapped out as well. Allocates pages to
> +	 * store tags for as many pages in this vma as possible but not
> +	 * more than TAG_STORAGE_PAGES. Each byte in tag space holds
> +	 * two ADI tags since each ADI tag is 4 bits. Each ADI tag
> +	 * covers adi_blksize() worth of addresses. Check if the hole is
> +	 * big enough to accommodate full address range for using
> +	 * TAG_STORAGE_PAGES number of tag pages.
> +	 */
> +	size =3D TAG_STORAGE_PAGES * PAGE_SIZE;
> +	end_addr =3D addr + (size*2*adi_blksize()) - 1;

Since size > PAGE_SIZE, end_addr could theoretically overflow.


> +	if (hole_end < end_addr) {
> +		/* Available hole is too small on the upper end of
> +		 * address. Can we expand the range towards the lower
> +		 * address and maximize use of this slot?
> +		 */
> +		unsigned long tmp_addr;
> +
> +		end_addr =3D hole_end - 1;
> +		tmp_addr =3D end_addr - (size*2*adi_blksize()) + 1;

Similarily, tmp_addr may underflow.

> +		if (tmp_addr < hole_start) {
> +			/* Available hole is restricted on lower address
> +			 * end as well
> +			 */
> +			tmp_addr =3D hole_start + 1;
> +		}
> +		addr =3D tmp_addr;
> +		size =3D (end_addr + 1 - addr)/(2*adi_blksize());
> +		size =3D (size + (PAGE_SIZE-adi_blksize()))/PAGE_SIZE;
> +		size =3D size * PAGE_SIZE;
> +	}
> +	tags =3D kzalloc(size, GFP_NOIO|__GFP_NOWARN);

Potential deadlock due to PIL=3D14?


> +	if (tags =3D=3D NULL) {
> +		tag_desc->tag_users =3D 0;
> +		tag_desc =3D NULL;
> +		goto out;
> +	}
> +	tag_desc->start =3D addr;
> +	tag_desc->tags =3D tags;
> +	tag_desc->end =3D end_addr;
> +
> +out:
> +	spin_unlock_irqrestore(&mm->context.tag_lock, flags);
> +	return tag_desc;
> +}
> +
> +void del_tag_store(tag_storage_desc_t *tag_desc, struct mm_struct =
*mm)
> +{
> +	unsigned long flags;
> +	unsigned char *tags =3D NULL;
> +
> +	spin_lock_irqsave(&mm->context.tag_lock, flags);
> +	tag_desc->tag_users--;
> +	if (tag_desc->tag_users =3D=3D 0) {
> +		tag_desc->start =3D tag_desc->end =3D 0;
> +		/* Do not free up the tag storage space allocated
> +		 * by the first descriptor. This is persistent
> +		 * emergency tag storage space for the task.
> +		 */
> +		if (tag_desc !=3D mm->context.tag_store) {
> +			tags =3D tag_desc->tags;
> +			tag_desc->tags =3D NULL;
> +		}
> +	}
> +	spin_unlock_irqrestore(&mm->context.tag_lock, flags);
> +	kfree(tags);
> +}
> +
> +#define tag_start(addr, tag_desc)		\
> +	((tag_desc)->tags + ((addr - =
(tag_desc)->start)/(2*adi_blksize())))
> +
> +/* Retrieve any saved ADI tags for the page being swapped back in and
> + * restore these tags to the newly allocated physical page.
> + */
> +void adi_restore_tags(struct mm_struct *mm, struct vm_area_struct =
*vma,
> +		      unsigned long addr, pte_t pte)
> +{
> +	unsigned char *tag;
> +	tag_storage_desc_t *tag_desc;
> +	unsigned long paddr, tmp, version1, version2;
> +
> +	/* Check if the swapped out page has an ADI version
> +	 * saved. If yes, restore version tag to the newly
> +	 * allocated page.
> +	 */
> +	tag_desc =3D find_tag_store(mm, vma, addr);
> +	if (tag_desc =3D=3D NULL)
> +		return;
> +
> +	tag =3D tag_start(addr, tag_desc);
> +	paddr =3D pte_val(pte) & _PAGE_PADDR_4V;
> +	for (tmp =3D paddr; tmp < (paddr+PAGE_SIZE); tmp +=3D =
adi_blksize()) {
> +		version1 =3D (*tag) >> 4;
> +		version2 =3D (*tag) & 0x0f;
> +		*tag++ =3D 0;
> +		asm volatile("stxa %0, [%1] %2\n\t"
> +			:
> +			: "r" (version1), "r" (tmp),
> +			  "i" (ASI_MCD_REAL));
> +		tmp +=3D adi_blksize();
> +		asm volatile("stxa %0, [%1] %2\n\t"
> +			:
> +			: "r" (version2), "r" (tmp),
> +			  "i" (ASI_MCD_REAL));
> +	}
> +	asm volatile("membar #Sync\n\t");
> +
> +	/* Check and mark this tag space for release later if
> +	 * the swapped in page was the last user of tag space
> +	 */
> +	del_tag_store(tag_desc, mm);
> +}
> +
> +/* A page is about to be swapped out. Save any ADI tags associated =
with
> + * this physical page so they can be restored later when the page is =
swapped
> + * back in.
> + */
> +int adi_save_tags(struct mm_struct *mm, struct vm_area_struct *vma,
> +		  unsigned long addr, pte_t oldpte)
> +{
> +	unsigned char *tag;
> +	tag_storage_desc_t *tag_desc;
> +	unsigned long version1, version2, paddr, tmp;
> +
> +	tag_desc =3D alloc_tag_store(mm, vma, addr);
> +	if (tag_desc =3D=3D NULL)
> +		return -1;
> +
> +	tag =3D tag_start(addr, tag_desc);
> +	paddr =3D pte_val(oldpte) & _PAGE_PADDR_4V;
> +	for (tmp =3D paddr; tmp < (paddr+PAGE_SIZE); tmp +=3D =
adi_blksize()) {
> +		asm volatile("ldxa [%1] %2, %0\n\t"
> +				: "=3Dr" (version1)
> +				: "r" (tmp), "i" (ASI_MCD_REAL));
> +		tmp +=3D adi_blksize();
> +		asm volatile("ldxa [%1] %2, %0\n\t"
> +				: "=3Dr" (version2)
> +				: "r" (tmp), "i" (ASI_MCD_REAL));
> +		*tag =3D (version1 << 4) | version2;
> +		tag++;
> +	}
> +
> +	return 0;
> +}
> diff --git a/arch/sparc/kernel/etrap_64.S =
b/arch/sparc/kernel/etrap_64.S
> index 1276ca2567ba..7be33bf45cff 100644
> --- a/arch/sparc/kernel/etrap_64.S
> +++ b/arch/sparc/kernel/etrap_64.S
> @@ -132,7 +132,33 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
> 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
> 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
> 		or	%l7, %l0, %l7
> -		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
> +661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
> +		/*
> +		 * If userspace is using ADI, it could potentially pass
> +		 * a pointer with version tag embedded in it. To =
maintain
> +		 * the ADI security, we must enable PSTATE.mcde. =
Userspace
> +		 * would have already set TTE.mcd in an earlier call to
> +		 * kernel and set the version tag for the address being
> +		 * dereferenced. Setting PSTATE.mcde would ensure any
> +		 * access to userspace data through a system call honors
> +		 * ADI and does not allow a rogue app to bypass ADI by
> +		 * using system calls. Setting PSTATE.mcde only affects
> +		 * accesses to virtual addresses that have TTE.mcd set.
> +		 * Set PMCDPER to ensure any exceptions caused by ADI
> +		 * version tag mismatch are exposed before system call
> +		 * returns to userspace. Setting PMCDPER affects only
> +		 * writes to virtual addresses that have TTE.mcd set and
> +		 * have a version tag set as well.
> +		 */
> +		.section .sun_m7_1insn_patch, "ax"
> +		.word	661b
> +		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
> +		.previous
> +661:		nop
> +		.section .sun_m7_1insn_patch, "ax"
> +		.word	661b
> +		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */

I commented on this on the last patch series revision.  PMCDPER could be
set once when each CPU is configured rather than every time the kernel
is entered.  Since it's never cleared, setting it repeatedly =
unnecessarily
impacts the performance of etrap.

Also, there are places in rtrap where PSTATE is set before continuing
execution in the kernel.  These should also be patched to set =
TSTATE_MCDE.


> +		.previous
> 		or	%l7, %l0, %l7
> 		wrpr	%l2, %tnpc
> 		wrpr	%l7, (TSTATE_PRIV | TSTATE_IE), %tstate
> diff --git a/arch/sparc/kernel/process_64.c =
b/arch/sparc/kernel/process_64.c
> index b96104da5bd6..defa5723dfa6 100644
> --- a/arch/sparc/kernel/process_64.c
> +++ b/arch/sparc/kernel/process_64.c
> @@ -664,6 +664,31 @@ int copy_thread(unsigned long clone_flags, =
unsigned long sp,
> 	return 0;
> }
>=20
> +/* TIF_MCDPER in thread info flags for current task is updated lazily =
upon
> + * a context switch. Update the this flag in current task's thread =
flags
> + * before dup so the dup'd task will inherit the current TIF_MCDPER =
flag.
> + */
> +int arch_dup_task_struct(struct task_struct *dst, struct task_struct =
*src)
> +{
> +	if (adi_capable()) {
> +		register unsigned long tmp_mcdper;
> +
> +		__asm__ __volatile__(
> +			".word 0x83438000\n\t"	/* rd  %mcdper, %g1 */
> +			"mov %%g1, %0\n\t"
> +			: "=3Dr" (tmp_mcdper)
> +			:
> +			: "g1");
> +		if (tmp_mcdper)
> +			set_thread_flag(TIF_MCDPER);
> +		else
> +			clear_thread_flag(TIF_MCDPER);
> +	}
> +
> +	*dst =3D *src;
> +	return 0;
> +}
> +
> typedef struct {
> 	union {
> 		unsigned int	pr_regs[32];
> diff --git a/arch/sparc/kernel/setup_64.c =
b/arch/sparc/kernel/setup_64.c
> index 422b17880955..a9da205da394 100644
> --- a/arch/sparc/kernel/setup_64.c
> +++ b/arch/sparc/kernel/setup_64.c
> @@ -240,6 +240,12 @@ void sun4v_patch_1insn_range(struct =
sun4v_1insn_patch_entry *start,
> 	}
> }
>=20
> +void sun_m7_patch_1insn_range(struct sun4v_1insn_patch_entry *start,
> +			     struct sun4v_1insn_patch_entry *end)
> +{
> +	sun4v_patch_1insn_range(start, end);
> +}
> +
> void sun4v_patch_2insn_range(struct sun4v_2insn_patch_entry *start,
> 			     struct sun4v_2insn_patch_entry *end)
> {
> @@ -289,9 +295,12 @@ static void __init sun4v_patch(void)
> 	sun4v_patch_2insn_range(&__sun4v_2insn_patch,
> 				&__sun4v_2insn_patch_end);
> 	if (sun4v_chip_type =3D=3D SUN4V_CHIP_SPARC_M7 ||
> -	    sun4v_chip_type =3D=3D SUN4V_CHIP_SPARC_SN)
> +	    sun4v_chip_type =3D=3D SUN4V_CHIP_SPARC_SN) {
> +		sun_m7_patch_1insn_range(&__sun_m7_1insn_patch,
> +					 &__sun_m7_1insn_patch_end);
> 		sun_m7_patch_2insn_range(&__sun_m7_2insn_patch,
> 					 &__sun_m7_2insn_patch_end);

Why not call sun4v_patch_1insn_range() and sun4v_patch_2insn_range()
here instead of adding new functions that just call these functions?

Anthony

> +		}
>=20
> 	sun4v_hvapi_init();
> }
> diff --git a/arch/sparc/kernel/vmlinux.lds.S =
b/arch/sparc/kernel/vmlinux.lds.S
> index 572db686f845..20a70682cce7 100644
> --- a/arch/sparc/kernel/vmlinux.lds.S
> +++ b/arch/sparc/kernel/vmlinux.lds.S
> @@ -144,6 +144,11 @@ SECTIONS
> 		*(.pause_3insn_patch)
> 		__pause_3insn_patch_end =3D .;
> 	}
> +	.sun_m7_1insn_patch : {
> +		__sun_m7_1insn_patch =3D .;
> +		*(.sun_m7_1insn_patch)
> +		__sun_m7_1insn_patch_end =3D .;
> +	}
> 	.sun_m7_2insn_patch : {
> 		__sun_m7_2insn_patch =3D .;
> 		*(.sun_m7_2insn_patch)
> diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
> index cd0e32bbcb1d..579f7ae75b35 100644
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -11,6 +11,7 @@
> #include <linux/pagemap.h>
> #include <linux/rwsem.h>
> #include <asm/pgtable.h>
> +#include <asm/adi.h>
>=20
> /*
>  * The performance critical leaf functions are made noinline otherwise =
gcc
> @@ -157,6 +158,24 @@ int __get_user_pages_fast(unsigned long start, =
int nr_pages, int write,
> 	pgd_t *pgdp;
> 	int nr =3D 0;
>=20
> +#ifdef CONFIG_SPARC64
> +	if (adi_capable()) {
> +		long addr =3D start;
> +
> +		/* If userspace has passed a versioned address, kernel
> +		 * will not find it in the VMAs since it does not store
> +		 * the version tags in the list of VMAs. Storing version
> +		 * tags in list of VMAs is impractical since they can be
> +		 * changed any time from userspace without dropping into
> +		 * kernel. Any address search in VMAs will be done with
> +		 * non-versioned addresses. Ensure the ADI version bits
> +		 * are dropped here by sign extending the last bit =
before
> +		 * ADI bits. IOMMU does not implement version tags.
> +		 */
> +		addr =3D (addr << (long)adi_nbits()) >> =
(long)adi_nbits();
> +		start =3D addr;
> +	}
> +#endif
> 	start &=3D PAGE_MASK;
> 	addr =3D start;
> 	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
> @@ -187,6 +206,24 @@ int get_user_pages_fast(unsigned long start, int =
nr_pages, int write,
> 	pgd_t *pgdp;
> 	int nr =3D 0;
>=20
> +#ifdef CONFIG_SPARC64
> +	if (adi_capable()) {
> +		long addr =3D start;
> +
> +		/* If userspace has passed a versioned address, kernel
> +		 * will not find it in the VMAs since it does not store
> +		 * the version tags in the list of VMAs. Storing version
> +		 * tags in list of VMAs is impractical since they can be
> +		 * changed any time from userspace without dropping into
> +		 * kernel. Any address search in VMAs will be done with
> +		 * non-versioned addresses. Ensure the ADI version bits
> +		 * are dropped here by sign extending the last bit =
before
> +		 * ADI bits. IOMMU does not implements version tags,
> +		 */
> +		addr =3D (addr << (long)adi_nbits()) >> =
(long)adi_nbits();
> +		start =3D addr;
> +	}
> +#endif
> 	start &=3D PAGE_MASK;
> 	addr =3D start;
> 	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
> diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
> index 88855e383b34..487ed1f1ce86 100644
> --- a/arch/sparc/mm/hugetlbpage.c
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -177,8 +177,20 @@ pte_t arch_make_huge_pte(pte_t entry, struct =
vm_area_struct *vma,
> 			 struct page *page, int writeable)
> {
> 	unsigned int shift =3D huge_page_shift(hstate_vma(vma));
> +	pte_t pte;
>=20
> -	return hugepage_shift_to_tte(entry, shift);
> +	pte =3D hugepage_shift_to_tte(entry, shift);
> +
> +#ifdef CONFIG_SPARC64
> +	/* If this vma has ADI enabled on it, turn on TTE.mcd
> +	 */
> +	if (vma->vm_flags & VM_SPARC_ADI)
> +		return pte_mkmcd(pte);
> +	else
> +		return pte_mknotmcd(pte);
> +#else
> +	return pte;
> +#endif
> }
>=20
> static unsigned int sun4v_huge_tte_to_shift(pte_t entry)
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 3c40ebd50f92..94854e7e833e 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -3087,3 +3087,36 @@ void flush_tlb_kernel_range(unsigned long =
start, unsigned long end)
> 		do_flush_tlb_kernel_range(start, end);
> 	}
> }
> +
> +void copy_user_highpage(struct page *to, struct page *from,
> +	unsigned long vaddr, struct vm_area_struct *vma)
> +{
> +	char *vfrom, *vto;
> +
> +	vfrom =3D kmap_atomic(from);
> +	vto =3D kmap_atomic(to);
> +	copy_user_page(vto, vfrom, vaddr, to);
> +	kunmap_atomic(vto);
> +	kunmap_atomic(vfrom);
> +
> +	/* If this page has ADI enabled, copy over any ADI tags
> +	 * as well
> +	 */
> +	if (vma->vm_flags & VM_SPARC_ADI) {
> +		unsigned long pfrom, pto, i, adi_tag;
> +
> +		pfrom =3D page_to_phys(from);
> +		pto =3D page_to_phys(to);
> +
> +		for (i =3D pfrom; i < (pfrom + PAGE_SIZE); i +=3D =
adi_blksize()) {
> +			asm volatile("ldxa [%1] %2, %0\n\t"
> +					: "=3Dr" (adi_tag)
> +					:  "r" (i), "i" (ASI_MCD_REAL));
> +			asm volatile("stxa %0, [%1] %2\n\t"
> +					:
> +					: "r" (adi_tag), "r" (pto),
> +					  "i" (ASI_MCD_REAL));
> +			pto +=3D adi_blksize();
> +		}
> +	}
> +}
> diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
> index 0d4b998c7d7b..6518cc42056b 100644
> --- a/arch/sparc/mm/tsb.c
> +++ b/arch/sparc/mm/tsb.c
> @@ -545,6 +545,9 @@ int init_new_context(struct task_struct *tsk, =
struct mm_struct *mm)
>=20
> 	mm->context.sparc64_ctx_val =3D 0UL;
>=20
> +	mm->context.tag_store =3D NULL;
> +	spin_lock_init(&mm->context.tag_lock);
> +
> #if defined(CONFIG_HUGETLB_PAGE) || =
defined(CONFIG_TRANSPARENT_HUGEPAGE)
> 	/* We reset them to zero because the fork() page copying
> 	 * will re-increment the counters as the parent PTEs are
> @@ -610,4 +613,22 @@ void destroy_context(struct mm_struct *mm)
> 	}
>=20
> 	spin_unlock_irqrestore(&ctx_alloc_lock, flags);
> +
> +	/* If ADI tag storage was allocated for this task, free it */
> +	if (mm->context.tag_store) {
> +		tag_storage_desc_t *tag_desc;
> +		unsigned long max_desc;
> +		unsigned char *tags;
> +
> +		tag_desc =3D mm->context.tag_store;
> +		max_desc =3D PAGE_SIZE/sizeof(tag_storage_desc_t);
> +		for (i =3D 0; i < max_desc; i++) {
> +			tags =3D tag_desc->tags;
> +			tag_desc->tags =3D NULL;
> +			kfree(tags);
> +			tag_desc++;
> +		}
> +		kfree(mm->context.tag_store);
> +		mm->context.tag_store =3D NULL;
> +	}
> }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b7aa3932e6d4..c0972114036f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -231,6 +231,9 @@ extern unsigned int kobjsize(const void *objp);
> # define VM_GROWSUP	VM_ARCH_1
> #elif defined(CONFIG_IA64)
> # define VM_GROWSUP	VM_ARCH_1
> +#elif defined(CONFIG_SPARC64)
> +# define VM_SPARC_ADI	VM_ARCH_1	/* Uses ADI tag for =
access control */
> +# define VM_ARCH_CLEAR	VM_SPARC_ADI
> #elif !defined(CONFIG_MMU)
> # define VM_MAPPED_COPY	VM_ARCH_1	/* T if mapped copy of =
data (nommu mmap) */
> #endif
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 216184af0e19..bb82399816ef 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1797,6 +1797,10 @@ int ksm_madvise(struct vm_area_struct *vma, =
unsigned long start,
> 		if (*vm_flags & VM_SAO)
> 			return 0;
> #endif
> +#ifdef VM_SPARC_ADI
> +		if (*vm_flags & VM_SPARC_ADI)
> +			return 0;
> +#endif
>=20
> 		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
> 			err =3D __ksm_enter(mm);
> --=20
> 2.11.0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
