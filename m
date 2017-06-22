Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE976B02B4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:39:53 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 91so1166449qkq.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:39:53 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id v70si53306qkv.289.2017.06.21.18.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:39:50 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id o21so353531qtb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:39:50 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 00/23] powerpc: Memory Protection Keys
Date: Wed, 21 Jun 2017 18:39:16 -0700
Message-Id: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Memory protection keys enable applications to protect its
address space from inadvertent access or corruption from
itself.

The overall idea:

 A process allocates a   key  and associates it with
 a  address  range  within    its   address   space.
 The process  than  can  dynamically  set read/write 
 permissions on  the   key   without  involving  the 
 kernel. Any  code that  violates   the  permissions
 off the address space; as defined by its associated
 key, will receive a segmentation fault.

This patch series enables the feature on PPC64.
It is enabled on HPTE 64K-page platform.

ISA3.0 section 5.7.13 describes the detailed specifications.


Testing:
	This patch series has passed all the protection key
	tests available in  the selftests directory.
	The tests are updated to work on both x86 and powerpc.

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
	
Outstanding known issue:
    Calls to sys_swapcontext with a made-up context will end 
    up with a crap AMR if done by code who didn't know about
    that register. -- Reported by Ben.

version v1: Initial version

Thanks-to: Dave Hansen, Aneesh, Paul Mackerras,
	   Michael Ellermen


Ram Pai (23):
  powerpc: Free up four 64K PTE bits in 4K backed HPTE pages
  powerpc: introduce set_hidx_slot helper
  powerpc: introduce get_hidx_gslot helper
  powerpc: Free up four 64K PTE bits in 64K backed HPTE pages
  powerpc: capture the PTE format changes in the dump pte report
  powerpc: use helper functions in __hash_page_4K() for 64K PTE
  powerpc: use helper functions in __hash_page_4K() for 4K PTE
  powerpc: use helper functions in flush_hash_page()
  mm: introduce an additional vma bit for powerpc pkey
  mm: provide the ability to disable execute on a key at creation
  x86: key creation with PKEY_DISABLE_EXECUTE is disallowed
  powerpc: Implement sys_pkey_alloc and sys_pkey_free system call
  powerpc: store and restore the pkey state across context switches
  powerpc: Implementation for sys_mprotect_pkey() system call
  powerpc: Program HPTE key protection bits
  powerpc: Macro the mask used for checking DSI exception
  powerpc: Handle exceptions caused by violation of pkey protection
  powerpc: Deliver SEGV signal on pkey violation
  selftest: Move protecton key selftest to arch neutral directory
  selftest: PowerPC specific test updates to memory protection keys
  Documentation: Move protecton key documentation to arch neutral
    directory
  Documentation: PowerPC specific updates to memory protection keys
  procfs: display the protection-key number associated with a vma

 Documentation/filesystems/proc.txt            |    3 +-
 Documentation/vm/protection-keys.txt          |  110 ++
 Documentation/x86/protection-keys.txt         |   85 --
 arch/powerpc/Kconfig                          |   15 +
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |   14 +
 arch/powerpc/include/asm/book3s/64/hash-64k.h |   53 +-
 arch/powerpc/include/asm/book3s/64/hash.h     |   15 +-
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |    5 +
 arch/powerpc/include/asm/book3s/64/mmu.h      |   10 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  |   84 +-
 arch/powerpc/include/asm/mman.h               |   14 +-
 arch/powerpc/include/asm/mmu_context.h        |   12 +
 arch/powerpc/include/asm/paca.h               |    1 +
 arch/powerpc/include/asm/pkeys.h              |  159 +++
 arch/powerpc/include/asm/processor.h          |    5 +
 arch/powerpc/include/asm/reg.h                |    7 +-
 arch/powerpc/include/asm/systbl.h             |    3 +
 arch/powerpc/include/asm/unistd.h             |    6 +-
 arch/powerpc/include/uapi/asm/ptrace.h        |    3 +-
 arch/powerpc/include/uapi/asm/unistd.h        |    3 +
 arch/powerpc/kernel/asm-offsets.c             |    5 +
 arch/powerpc/kernel/exceptions-64s.S          |   18 +-
 arch/powerpc/kernel/process.c                 |   18 +
 arch/powerpc/kernel/signal_32.c               |   14 +
 arch/powerpc/kernel/signal_64.c               |   14 +
 arch/powerpc/kernel/traps.c                   |   49 +
 arch/powerpc/mm/Makefile                      |    1 +
 arch/powerpc/mm/dump_linuxpagetables.c        |    3 +-
 arch/powerpc/mm/fault.c                       |   22 +
 arch/powerpc/mm/hash64_4k.c                   |   14 +-
 arch/powerpc/mm/hash64_64k.c                  |  111 +-
 arch/powerpc/mm/hash_utils_64.c               |   36 +-
 arch/powerpc/mm/hugetlbpage-hash64.c          |   16 +-
 arch/powerpc/mm/mmu_context_book3s64.c        |    5 +
 arch/powerpc/mm/pkeys.c                       |  267 +++++
 arch/x86/kernel/fpu/xstate.c                  |    3 +
 fs/proc/task_mmu.c                            |   18 +-
 include/linux/mm.h                            |   18 +-
 include/uapi/asm-generic/mman-common.h        |    4 +-
 tools/testing/selftests/vm/Makefile           |    1 +
 tools/testing/selftests/vm/pkey-helpers.h     |  365 ++++++
 tools/testing/selftests/vm/protection_keys.c  | 1483 +++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  219 ----
 tools/testing/selftests/x86/protection_keys.c | 1395 -----------------------
 45 files changed, 2868 insertions(+), 1840 deletions(-)
 create mode 100644 Documentation/vm/protection-keys.txt
 delete mode 100644 Documentation/x86/protection-keys.txt
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c
 create mode 100644 tools/testing/selftests/vm/pkey-helpers.h
 create mode 100644 tools/testing/selftests/vm/protection_keys.c
 delete mode 100644 tools/testing/selftests/x86/pkey-helpers.h
 delete mode 100644 tools/testing/selftests/x86/protection_keys.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
