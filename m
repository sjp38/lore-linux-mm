Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D404C280281
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 13:10:35 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o60so5440237wrc.14
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 10:10:35 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id h15si8469015wrb.551.2017.11.10.10.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 10:10:33 -0800 (PST)
Subject: Re: [PATCH v9 00/51] powerpc, mm: Memory Protection Keys
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <45ca9196-1d7d-d530-45df-4ee41773cace@c-s.fr>
Date: Fri, 10 Nov 2017 19:10:31 +0100
MIME-Version: 1.0
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

Hi

Le 06/11/2017 A  09:56, Ram Pai a A(C)critA :
> Memory protection keys enable applications to protect its
> address space from inadvertent access from or corruption
> by itself.
> 
> These patches along with the pte-bit freeing patch series
> enables the protection key feature on powerpc; 4k and 64k
> hashpage kernels. It also changes the generic and x86
> code to expose memkey features through sysfs. Finally
> testcases and Documentation is updated.
> 
> All patches can be found at --
> https://github.com/rampai/memorykeys.git memkey.v9

As far as I can see you are focussing the implementation on 64 bits 
powerpc. This could also be implemented on 32 bits powerpc, for instance 
the 8xx has MMU Access Protection Registers which can be used to define 
16 domains and could I think be used for implementing protection keys.
Of course the challenge after that would be to find 4 spare PTE bits, 
I'm sure we can find them on the 8xx, at least when using 16k pages we 
have 2 bits already available, then by merging PAGE_SHARED and PAGE_USER 
and by reducing PAGE_RO to only one bit we can get the 4 spare bits.

Therefore I think it would be great if you could implement a framework 
common to both PPC32 and PPC64.

Christophe

> 
> The overall idea:
> -----------------
>   A process allocates a key and associates it with
>   an address range within its address space.
>   The process then can dynamically set read/write
>   permissions on the key without involving the
>   kernel. Any code that violates the permissions
>   of the address space; as defined by its associated
>   key, will receive a segmentation fault.
> 
> This patch series enables the feature on PPC64 HPTE
> platform.
> 
> ISA3.0 section 5.7.13 describes the detailed
> specifications.
> 
> 
> Highlevel view of the design:
> ---------------------------
> When an application associates a key with a address
> address range, program the key in the Linux PTE.
> When the MMU detects a page fault, allocate a hash
> page and program the key into HPTE. And finally
> when the MMU detects a key violation; due to
> invalid application access, invoke the registered
> signal handler and provide the violated key number.
> 
> 
> Testing:
> -------
> This patch series has passed all the protection key
> tests available in the selftest directory.The
> tests are updated to work on both x86 and powerpc.
> The selftests have passed on x86 and powerpc hardware.
> 
> History:
> -------
> version v9:
> 	(1) used jump-labels to optimize code
> 		-- Balbir
> 	(2) fixed a register initialization bug noted
> 		by Balbir
> 	(3) fixed inappropriate use of paca to pass
> 		siginfo and keys to signal handler
> 	(4) Cleanup of comment style not to be right
> 		justified -- mpe
> 	(5) restructured the patches to depend on the
> 		availability of VM_PKEY_BIT4 in
> 		include/linux/mm.h
> 	(6) Incorporated comments from Dave Hansen
> 		towards changes to selftest and got
> 		them tested on x86.
> 
> version v8:
> 	(1) Contents of the AMR register withdrawn from
> 	the siginfo structure. Applications can always
> 	read the AMR register.
> 	(2) AMR/IAMR/UAMOR are now available through
> 		ptrace system call. -- thanks to Thiago
> 	(3) code changes to handle legacy power cpus
> 	that do not support execute-disable.
> 	(4) incorporates many code improvement
> 		suggestions.
> 
> version v7:
> 	(1) refers to device tree property to enable
> 		protection keys.
> 	(2) adds 4K PTE support.
> 	(3) fixes a couple of bugs noticed by Thiago
> 	(4) decouples this patch series from arch-
> 	 independent code. This patch series can
> 	 now stand by itself, with one kludge
> 	patch(2).
> version v7:
> 	(1) refers to device tree property to enable
> 		protection keys.
> 	(2) adds 4K PTE support.
> 	(3) fixes a couple of bugs noticed by Thiago
> 	(4) decouples this patch series from arch-
> 	 independent code. This patch series can
> 	 now stand by itself, with one kludge
> 	 patch(2).
> 
> version v6:
> 	(1) selftest changes are broken down into 20
> 		incremental patches.
> 	(2) A separate key allocation mask that
> 		includes PKEY_DISABLE_EXECUTE is
> 		added for powerpc
> 	(3) pkey feature is enabled for 64K HPT case
> 		only. RPT and 4k HPT is disabled.
> 	(4) Documentation is updated to better
> 		capture the semantics.
> 	(5) introduced arch_pkeys_enabled() to find
> 		if an arch enables pkeys. Correspond-
> 		ing change the logic that displays
> 		key value in smaps.
> 	(6) code rearranged in many places based on
> 		comments from Dave Hansen, Balbir,
> 		Anshuman.	
> 	(7) fixed one bug where a bogus key could be
> 		associated successfully in
> 		pkey_mprotect().
> 
> version v5:
> 	(1) reverted back to the old design -- store
> 	 the key in the pte, instead of bypassing
> 	 it. The v4 design slowed down the hash
> 	 page path.
> 	(2) detects key violation when kernel is told
> 		to access user pages.
> 	(3) further refined the patches into smaller
> 		consumable units
> 	(4) page faults handlers captures the fault-
> 		ing key
> 	 from the pte instead of the vma. This
> 	 closes a race between where the key
> 	 update in the vma and a key fault caused
> 	 by the key programmed in the pte.
> 	(5) a key created with access-denied should
> 	 also set it up to deny write. Fixed it.
> 	(6) protection-key number is displayed in
>   		smaps the x86 way.
> 
> version v4:
> 	(1) patches no more depend on the pte bits
> 		to program the hpte
> 			-- comment by Balbir
> 	(2) documentation updates
> 	(3) fixed a bug in the selftest.
> 	(4) unlike x86, powerpc lets signal handler
> 		change key permission bits; the
> 		change will persist across signal
> 		handler boundaries. Earlier we
> 		allowed the signal handler to
> 		modify a field in the siginfo
> 		structure which would than be used
> 		by the kernel to program the key
> 		protection register (AMR)
> 		 -- resolves a issue raised by Ben.
> 		"Calls to sys_swapcontext with a
> 		made-up context will end up with a
> 		crap AMR if done by code who didn't
> 		know about that register".
> 	(5) these changes enable protection keys on
>   		4k-page kernel aswell.
> 
> version v3:
> 	(1) split the patches into smaller consumable
> 		patches.
> 	(2) added the ability to disable execute
> 		permission on a key at creation.
> 	(3) rename calc_pte_to_hpte_pkey_bits() to
> 	pte_to_hpte_pkey_bits()
> 		-- suggested by Anshuman
> 	(4) some code optimization and clarity in
> 		do_page_fault()
> 	(5) A bug fix while invalidating a hpte slot
> 		in __hash_page_4K()
> 		-- noticed by Aneesh
> 	
> 
> version v2:
> 	(1) documentation and selftest added.
>   	(2) fixed a bug in 4k hpte backed 64k pte
> 		where page invalidation was not
> 		done correctly, and initialization
> 		of second-part-of-the-pte was not
> 		done correctly if the pte was not
> 		yet Hashed with a hpte.
> 		--	Reported by Aneesh.
> 	(3) Fixed ABI breakage caused in siginfo
> 		structure.
> 		-- Reported by Anshuman.
> 	
> 
> version v1: Initial version
> 
> Ram Pai (47):
>    mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS
>      is enabled
>    mm, powerpc, x86: introduce an additional vma bit for powerpc pkey
>    powerpc: initial pkey plumbing
>    powerpc: track allocation status of all pkeys
>    powerpc: helper function to read,write AMR,IAMR,UAMOR registers
>    powerpc: helper functions to initialize AMR, IAMR and UAMOR registers
>    powerpc: cleanup AMR, IAMR when a key is allocated or freed
>    powerpc: implementation for arch_set_user_pkey_access()
>    powerpc: ability to create execute-disabled pkeys
>    powerpc: store and restore the pkey state across context switches
>    powerpc: introduce execute-only pkey
>    powerpc: ability to associate pkey to a vma
>    powerpc: implementation for arch_override_mprotect_pkey()
>    powerpc: map vma key-protection bits to pte key bits.
>    powerpc: Program HPTE key protection bits
>    powerpc: helper to validate key-access permissions of a pte
>    powerpc: check key protection for user page access
>    powerpc: implementation for arch_vma_access_permitted()
>    powerpc: Handle exceptions caused by pkey violation
>    powerpc: introduce get_mm_addr_key() helper
>    powerpc: Deliver SEGV signal on pkey violation
>    powerpc: Enable pkey subsystem
>    powerpc: sys_pkey_alloc() and sys_pkey_free() system calls
>    powerpc: sys_pkey_mprotect() system call
>    powerpc: add sys_pkey_modify() system call
>    mm, x86 : introduce arch_pkeys_enabled()
>    mm: display pkey in smaps if arch_pkeys_enabled() is true
>    Documentation/x86: Move protecton key documentation to arch neutral
>      directory
>    Documentation/vm: PowerPC specific updates to memory protection keys
>    selftest/x86: Move protecton key selftest to arch neutral directory
>    selftest/vm: rename all references to pkru to a generic name
>    selftest/vm: move generic definitions to header file
>    selftest/vm: typecast the pkey register
>    selftest/vm: generic function to handle shadow key register
>    selftest/vm: fix the wrong assert in pkey_disable_set()
>    selftest/vm: fixed bugs in pkey_disable_clear()
>    selftest/vm: clear the bits in shadow reg when a pkey is freed.
>    selftest/vm: fix alloc_random_pkey() to make it really random
>    selftest/vm: introduce two arch independent abstraction
>    selftest/vm: pkey register should match shadow pkey
>    selftest/vm: generic cleanup
>    selftest/vm: powerpc implementation for generic abstraction
>    selftest/vm: fix an assertion in test_pkey_alloc_exhaust()
>    selftest/vm: associate key on a mapped page and detect access
>      violation
>    selftest/vm: associate key on a mapped page and detect write
>      violation
>    selftest/vm: detect write violation on a mapped access-denied-key
>      page
>    selftest/vm: sub-page allocator
> 
> Thiago Jung Bauermann (4):
>    powerpc/ptrace: Add memory protection key regset
>    mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add sysfs interface
>    selftests/powerpc: Add ptrace tests for Protection Key register
>    selftests/powerpc: Add core file test for Protection Key register
> 
>   Documentation/vm/protection-keys.txt               |  161 +++
>   Documentation/x86/protection-keys.txt              |   85 --
>   arch/powerpc/Kconfig                               |   15 +
>   arch/powerpc/include/asm/book3s/64/mmu-hash.h      |    5 +
>   arch/powerpc/include/asm/book3s/64/mmu.h           |   10 +
>   arch/powerpc/include/asm/book3s/64/pgtable.h       |   42 +-
>   arch/powerpc/include/asm/bug.h                     |    1 +
>   arch/powerpc/include/asm/cputable.h                |   15 +-
>   arch/powerpc/include/asm/mman.h                    |   13 +-
>   arch/powerpc/include/asm/mmu.h                     |    9 +
>   arch/powerpc/include/asm/mmu_context.h             |   24 +
>   arch/powerpc/include/asm/pkeys.h                   |  247 ++++
>   arch/powerpc/include/asm/processor.h               |    5 +
>   arch/powerpc/include/asm/systbl.h                  |    4 +
>   arch/powerpc/include/asm/unistd.h                  |    6 +-
>   arch/powerpc/include/uapi/asm/elf.h                |    1 +
>   arch/powerpc/include/uapi/asm/mman.h               |    6 +
>   arch/powerpc/include/uapi/asm/unistd.h             |    4 +
>   arch/powerpc/kernel/entry_64.S                     |    9 +
>   arch/powerpc/kernel/process.c                      |    7 +
>   arch/powerpc/kernel/prom.c                         |   18 +
>   arch/powerpc/kernel/ptrace.c                       |   66 +
>   arch/powerpc/kernel/traps.c                        |   19 +-
>   arch/powerpc/mm/Makefile                           |    1 +
>   arch/powerpc/mm/fault.c                            |   49 +-
>   arch/powerpc/mm/hash_utils_64.c                    |   29 +
>   arch/powerpc/mm/mmu_context_book3s64.c             |    2 +
>   arch/powerpc/mm/pkeys.c                            |  463 +++++++
>   arch/x86/include/asm/mmu_context.h                 |    4 +-
>   arch/x86/include/asm/pkeys.h                       |    2 +
>   arch/x86/kernel/fpu/xstate.c                       |    5 +
>   arch/x86/kernel/setup.c                            |    8 -
>   arch/x86/mm/pkeys.c                                |    9 +
>   fs/proc/task_mmu.c                                 |   16 +-
>   include/linux/mm.h                                 |   12 +-
>   include/linux/pkeys.h                              |    7 +-
>   include/uapi/linux/elf.h                           |    1 +
>   mm/mprotect.c                                      |   88 ++
>   tools/testing/selftests/powerpc/include/reg.h      |    1 +
>   tools/testing/selftests/powerpc/ptrace/Makefile    |    5 +-
>   tools/testing/selftests/powerpc/ptrace/core-pkey.c |  438 ++++++
>   .../testing/selftests/powerpc/ptrace/ptrace-pkey.c |  443 ++++++
>   tools/testing/selftests/vm/Makefile                |    1 +
>   tools/testing/selftests/vm/pkey-helpers.h          |  405 ++++++
>   tools/testing/selftests/vm/protection_keys.c       | 1464 ++++++++++++++++++++
>   tools/testing/selftests/x86/Makefile               |    2 +-
>   tools/testing/selftests/x86/pkey-helpers.h         |  220 ---
>   tools/testing/selftests/x86/protection_keys.c      | 1395 -------------------
>   48 files changed, 4095 insertions(+), 1747 deletions(-)
>   create mode 100644 Documentation/vm/protection-keys.txt
>   delete mode 100644 Documentation/x86/protection-keys.txt
>   create mode 100644 arch/powerpc/include/asm/pkeys.h
>   create mode 100644 arch/powerpc/mm/pkeys.c
>   create mode 100644 tools/testing/selftests/powerpc/ptrace/core-pkey.c
>   create mode 100644 tools/testing/selftests/powerpc/ptrace/ptrace-pkey.c
>   create mode 100644 tools/testing/selftests/vm/pkey-helpers.h
>   create mode 100644 tools/testing/selftests/vm/protection_keys.c
>   delete mode 100644 tools/testing/selftests/x86/pkey-helpers.h
>   delete mode 100644 tools/testing/selftests/x86/protection_keys.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
