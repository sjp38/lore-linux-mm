Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31DB06B03C2
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:22:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o3so540854qto.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:30 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id x16si100682qta.307.2017.07.05.14.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:22:28 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id w12so188472qta.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:22:28 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 00/38] powerpc: Memory Protection Keys
Date: Wed,  5 Jul 2017 14:21:37 -0700
Message-Id: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Memory protection keys enable applications to protect its
address space from inadvertent access or corruption from
itself.

The overall idea:

 A process allocates a   key  and associates it with
 an  address  range  within    its   address   space.
 The process  then  can  dynamically  set read/write 
 permissions on  the   key   without  involving  the 
 kernel. Any  code that  violates   the  permissions
 of  the address space; as defined by its associated
 key, will receive a segmentation fault.

This patch series enables the feature on PPC64 HPTE
platform.

ISA3.0 section 5.7.13 describes the detailed specifications.


Testing:
	This patch series has passed all the protection key
	tests available in  the selftests directory.
	The tests are updated to work on both x86 and powerpc.

version v5:
	(1) reverted back to the old design -- store the 
	    key in the pte, instead of bypassing it.
	    The v4 design slowed down the hash page path.
	(2) detects key violation when kernel is told to 
		access user pages.
	(3) further refined the patches into smaller consumable
		units
	(4) page faults handlers captures the faulting key 
	    from the pte instead of the vma. This closes a
	    race between where the key update in the vma and
	    a key fault caused cause by the key programmed
	    in the pte.
	(5) a key created with access-denied should
	    also set it up to deny write. Fixed it.
	(6) protection-key number is displayed in smaps
		the x86 way.
version v4:
	(1) patches no more depend on the pte bits to program
		the hpte -- comment by Balbir
	(2) documentation updates
	(3) fixed a bug in the selftest.
	(4) unlike x86, powerpc lets signal handler change key
	    permission bits; the change will persist across
	    signal handler boundaries. Earlier we allowed
	    the signal handler to modify a field in the siginfo
	    structure which would than be used by the kernel
	    to program the key protection register (AMR)
       		-- resolves a issue raised by Ben.
    		"Calls to sys_swapcontext with a made-up context
	        will end up with a crap AMR if done by code who
	       	didn't know about that register".
	(5) these changes enable protection keys on 4k-page 
		kernel aswell.

version v3:
	(1) split the patches into smaller consumable
		patches.
	(2) added the ability to disable execute permission
		on a key at creation.
	(3) rename  calc_pte_to_hpte_pkey_bits() to
	    pte_to_hpte_pkey_bits() -- suggested by Anshuman
	(4) some code optimization and clarity in
		do_page_fault()  
	(5) A bug fix while invalidating a hpte slot in 
		__hash_page_4K() -- noticed by Aneesh
	

version v2:
	(1) documentation and selftest added
 	(2) fixed a bug in 4k hpte backed 64k pte where page
	    invalidation was not done correctly, and 
	    initialization of second-part-of-the-pte was not
	    done correctly if the pte was not yet Hashed
	    with a hpte.  Reported by Aneesh.
	(3) Fixed ABI breakage caused in siginfo structure.
		Reported by Anshuman.
	

version v1: Initial version

Ram Pai (38):
  powerpc: Free up four 64K PTE bits in 4K backed HPTE pages
  powerpc: Free up four 64K PTE bits in 64K backed HPTE pages
  powerpc: introduce pte_set_hash_slot() helper
  powerpc: introduce pte_get_hash_gslot() helper
  powerpc: capture the PTE format changes in the dump pte report
  powerpc: use helper functions in __hash_page_64K() for 64K PTE
  powerpc: use helper functions in __hash_page_huge() for 64K PTE
  powerpc: use helper functions in __hash_page_4K() for 64K PTE
  powerpc: use helper functions in __hash_page_4K() for 4K PTE
  powerpc: use helper functions in flush_hash_page()
  mm: introduce an additional vma bit for powerpc pkey
  mm: ability to disable execute permission on a key at creation
  x86: disallow pkey creation with PKEY_DISABLE_EXECUTE
  powerpc: initial plumbing for key management
  powerpc: helper function to read,write AMR,IAMR,UAMOR registers
  powerpc: implementation for arch_set_user_pkey_access()
  powerpc: sys_pkey_alloc() and sys_pkey_free() system calls
  powerpc: store and restore the pkey state across context switches
  powerpc: introduce execute-only pkey
  powerpc: ability to associate pkey to a vma
  powerpc: implementation for arch_override_mprotect_pkey()
  powerpc: map vma key-protection bits to pte key bits.
  powerpc: sys_pkey_mprotect() system call
  powerpc: Program HPTE key protection bits
  powerpc: helper to validate key-access permissions of a pte
  powerpc: check key protection for user page access
  powerpc: Macro the mask used for checking DSI exception
  powerpc: implementation for arch_vma_access_permitted()
  powerpc: Handle exceptions caused by pkey violation
  powerpc: capture AMR register content on pkey violation
  powerpc: introduce get_pte_pkey() helper
  powerpc: capture the violated protection key on fault
  powerpc: Deliver SEGV signal on pkey violation
  procfs: display the protection-key number associated with a vma
  selftest: Move protecton key selftest to arch neutral directory
  selftest: PowerPC specific test updates to memory protection keys
  Documentation: Move protecton key documentation to arch neutral
    directory
  Documentation: PowerPC specific updates to memory protection keys

 Documentation/vm/protection-keys.txt          |  130 +++
 Documentation/x86/protection-keys.txt         |   85 --
 arch/powerpc/Kconfig                          |   16 +
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |   20 +
 arch/powerpc/include/asm/book3s/64/hash-64k.h |   60 +-
 arch/powerpc/include/asm/book3s/64/hash.h     |    7 +-
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |   10 +
 arch/powerpc/include/asm/book3s/64/mmu.h      |   10 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  |   96 ++-
 arch/powerpc/include/asm/mman.h               |   16 +-
 arch/powerpc/include/asm/mmu_context.h        |    5 +
 arch/powerpc/include/asm/paca.h               |    4 +
 arch/powerpc/include/asm/pkeys.h              |  159 +++
 arch/powerpc/include/asm/processor.h          |    5 +
 arch/powerpc/include/asm/reg.h                |    7 +-
 arch/powerpc/include/asm/systbl.h             |    3 +
 arch/powerpc/include/asm/unistd.h             |    6 +-
 arch/powerpc/include/uapi/asm/ptrace.h        |    3 +-
 arch/powerpc/include/uapi/asm/unistd.h        |    3 +
 arch/powerpc/kernel/asm-offsets.c             |    6 +
 arch/powerpc/kernel/exceptions-64s.S          |    2 +-
 arch/powerpc/kernel/process.c                 |   18 +
 arch/powerpc/kernel/setup_64.c                |    8 +
 arch/powerpc/kernel/signal_32.c               |    5 +
 arch/powerpc/kernel/signal_64.c               |    4 +
 arch/powerpc/kernel/traps.c                   |   14 +
 arch/powerpc/mm/Makefile                      |    1 +
 arch/powerpc/mm/dump_linuxpagetables.c        |    3 +-
 arch/powerpc/mm/fault.c                       |   26 +
 arch/powerpc/mm/hash64_4k.c                   |   14 +-
 arch/powerpc/mm/hash64_64k.c                  |  124 ++-
 arch/powerpc/mm/hash_utils_64.c               |   68 +-
 arch/powerpc/mm/hugetlbpage-hash64.c          |   16 +-
 arch/powerpc/mm/mmu_context_book3s64.c        |    5 +
 arch/powerpc/mm/pkeys.c                       |  243 ++++
 arch/x86/kernel/fpu/xstate.c                  |    3 +
 fs/proc/task_mmu.c                            |    6 +-
 include/linux/mm.h                            |   18 +-
 include/uapi/asm-generic/mman-common.h        |    4 +-
 tools/testing/selftests/vm/Makefile           |    1 +
 tools/testing/selftests/vm/pkey-helpers.h     |  365 ++++++
 tools/testing/selftests/vm/protection_keys.c  | 1488 +++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  219 ----
 tools/testing/selftests/x86/protection_keys.c | 1395 -----------------------
 45 files changed, 2872 insertions(+), 1831 deletions(-)
 create mode 100644 Documentation/vm/protection-keys.txt
 delete mode 100644 Documentation/x86/protection-keys.txt
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c
 create mode 100644 tools/testing/selftests/vm/pkey-helpers.h
 create mode 100644 tools/testing/selftests/vm/protection_keys.c
 delete mode 100644 tools/testing/selftests/x86/pkey-helpers.h
 delete mode 100644 tools/testing/selftests/x86/protection_keys.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
