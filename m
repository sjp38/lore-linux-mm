Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91F4E6B05D2
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n42so57092164qtn.10
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:01 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id z23si12173989qta.23.2017.07.15.20.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:00 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id v17so14723251qka.3
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:00 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 00/62] powerpc: Memory Protection Keys
Date: Sat, 15 Jul 2017 20:56:02 -0700
Message-Id: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Memory protection keys enable applications to protect its
address space from inadvertent access or corruption from
itself.

The overall idea:
-----------------
 A process allocates a   key  and associates it with
 an  address  range  within    its   address   space.
 The process  then  can  dynamically  set read/write 
 permissions on  the   key   without  involving  the 
 kernel. Any  code that  violates   the  permissions
 of  the address space; as defined by its associated
 key, will receive a segmentation fault.

This  patch series enables the feature on PPC64 HPTE
platform.

ISA3.0   section  5.7.13   describes  the  detailed
specifications.


Highlevel view of the design:
---------------------------
When  an  application associates a key with a address
address  range,  program  the key in    the Linux PTE.
When the MMU   detects  a page fault, allocate a hash
page  and   program  the  key into HPTE.  And finally
when the  MMU    detects  a  key  violation;  due  to
invalid    application  access, invoke the registered
signal   handler and provide the violated  key number
as   well  as the state of the key register (AMR), at
the time it faulted.


Testing:
-------
This  patch  series has passed all the protection key
tests   available    in   the selftests directory.The
tests are updated  to    work on both x86 and powerpc.



Outstanding issues:
-------------------
How will the application know if pkey is  enabled, if
so   how   many     pkeys     are       available? Is
PKEY_DISABLE_EXECUTE supported?  - Ben.


History:
-------
version v6:
	(1) selftest changes  are broken down into 20
		incremental patches.
	(2) A  separate   key  allocation  mask  that
       		includes    PKEY_DISABLE_EXECUTE   is 
		added for powerpc
	(3) pkey feature  is enabled for 64K HPT case
		only.  RPT and 4k HPT is disabled.
	(4) Documentation   is   updated   to  better 
		capture the semantics.
	(5) introduced   arch_pkeys_enabled() to find
       		if an arch enables pkeys.  Correspond-
		ing change the  logic   that displays
		key value in smaps.
	(6) code  rearranged  in many places based on
       		comments from   Dave Hansen,   Balbir,
	       	Anshuman.	
	(7) fixed  one bug where a bogus key could be
		associated     successfully        in
		pkey_mprotect().

version v5:
	(1) reverted back to the old  design -- store
	    the key in the pte,  instead of bypassing
	    it.  The v4  design  slowed down the hash
	    page path.
	(2) detects key violation when kernel is told
       		to access user pages.
	(3) further  refined the patches into smaller
       		consumable units
	(4) page faults   handlers captures the fault-
		ing key 
	    from the pte   instead of   the vma. This
	    closes  a  race  between  where  the  key 
	    update in the  vma and a key fault caused
	    by the key programmed in the pte.
	(5) a key created   with access-denied should
	    also set it up to deny write. Fixed it.
	(6) protection-key   number   is displayed in
       		smaps the x86 way.

version v4:
	(1) patches no more depend on the pte bits
       		to program the hpte
			-- comment by Balbir
	(2) documentation updates
	(3) fixed a bug in the selftest.
	(4) unlike x86, powerpc   lets signal handler
		change   key   permission   bits; the
	       	change   will   persist across signal
	       	handler   boundaries.   Earlier    we
	       	allowed   the   signal   handler   to
	       	modify   a   field   in   the siginfo
		structure   which would  than be used
       		by  the  kernel  to  program  the key
		protection register (AMR)
       		  -- resolves a issue raised by Ben.
    		"Calls  to  sys_swapcontext  with   a
		made-up  context  will  end up with a
		crap  AMR  if done by code who didn't
	       	know about that register".
	(5) these  changes  enable protection keys on
       		4k-page kernel aswell.

version v3:
	(1) split the patches into smaller consumable
		patches.
	(2) added  the  ability  to  disable  execute
       		permission  on  a  key  at   creation.
	(3) rename    calc_pte_to_hpte_pkey_bits() to
	    pte_to_hpte_pkey_bits()
		-- suggested by Anshuman
	(4) some   code   optimization and clarity in
		do_page_fault()  
	(5) A bug fix while  invalidating a hpte slot
		in __hash_page_4K()
       		-- noticed by Aneesh
	

version v2:
	(1) documentation and selftest added.
 	(2) fixed a  bug  in 4k  hpte  backed 64k pte
       		where  page    invalidation   was not
		done  correctly,  and  initialization
	       	of    second-part-of-the-pte  was not
		done    correctly  if the pte was not
	       	yet Hashed with a hpte.
	       	   --	Reported by Aneesh.
	(3) Fixed  ABI  breakage  caused in siginfo
       		structure.
		-- Reported by Anshuman.
	

version v1: Initial version


Ram Pai (62):
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
  powerpc: initial pkey plumbing
  mm: introduce an additional vma bit for powerpc pkey
  powerpc: track allocation status of all pkeys
  powerpc: helper function to read,write AMR,IAMR,UAMOR registers
  powerpc: helper functions to initialize AMR, IAMR and UMOR registers
  powerpc: cleaup AMR,iAMR when a key is allocated or freed
  powerpc: implementation for arch_set_user_pkey_access()
  powerpc: sys_pkey_alloc() and sys_pkey_free() system calls
  powerpc: ability to create execute-disabled pkeys
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
  mm: introduce arch_pkeys_enabled()
  x86: implementation for arch_pkeys_enabled()
  powerpc: implementation for arch_pkeys_enabled()
  mm: display pkey in smaps if arch_pkeys_enabled() is true
  x86: delete arch_show_smap()
  selftest/x86: Move protecton key selftest to arch neutral directory
  selftest/vm: rename all references to pkru to a generic name
  selftest/vm: move generic definitions to header file
  selftest/vm: typecast the pkey register
  selftest/vm: generics function to handle shadow key register
  selftest/vm: fix the wrong assert in pkey_disable_set()
  selftest/vm: fixed bugs in pkey_disable_clear()
  selftest/vm: clear the bits in shadow reg when a pkey is freed.
  selftest/vm: fix alloc_random_pkey() to make it really random
  selftest/vm: introduce two arch independent abstraction
  selftest/vm: pkey register should match shadow pkey
  selftest/vm: generic cleanup
  selftest/vm: powerpc implementation for generic abstraction
  selftest/vm: fix an assertion in test_pkey_alloc_exhaust()
  selftest/vm: associate key on a mapped page and detect access
    violation
  selftest/vm: detect no key violation on a freed key
  selftest/vm: associate key on a mapped page and detect write
    violation
  selftest/vm: detect no write key-violation on a freed key
  selftest/vm: detect write violation on a mapped access-denied-key
    page
  selftest/vm: sub-page allocator
  Documentation/x86: Move protecton key documentation to arch neutral
    directory
  Documentation/vm: PowerPC specific updates to memory protection keys

 Documentation/vm/protection-keys.txt          |  125 ++
 Documentation/x86/protection-keys.txt         |   85 --
 arch/powerpc/Kconfig                          |   16 +
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |   20 +
 arch/powerpc/include/asm/book3s/64/hash-64k.h |   60 +-
 arch/powerpc/include/asm/book3s/64/hash.h     |    7 +-
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |   10 +
 arch/powerpc/include/asm/book3s/64/mmu.h      |   10 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  |   64 +-
 arch/powerpc/include/asm/mman.h               |   16 +-
 arch/powerpc/include/asm/mmu_context.h        |   14 +
 arch/powerpc/include/asm/paca.h               |    4 +
 arch/powerpc/include/asm/pkeys.h              |  226 ++++
 arch/powerpc/include/asm/processor.h          |    5 +
 arch/powerpc/include/asm/reg.h                |    8 +-
 arch/powerpc/include/asm/systbl.h             |    3 +
 arch/powerpc/include/asm/unistd.h             |    6 +-
 arch/powerpc/include/uapi/asm/ptrace.h        |    1 +
 arch/powerpc/include/uapi/asm/unistd.h        |    3 +
 arch/powerpc/kernel/asm-offsets.c             |    6 +
 arch/powerpc/kernel/exceptions-64s.S          |    2 +-
 arch/powerpc/kernel/process.c                 |   18 +
 arch/powerpc/kernel/setup_64.c                |    4 +
 arch/powerpc/kernel/signal_32.c               |    5 +
 arch/powerpc/kernel/signal_64.c               |    4 +
 arch/powerpc/kernel/traps.c                   |   15 +
 arch/powerpc/mm/Makefile                      |    1 +
 arch/powerpc/mm/dump_linuxpagetables.c        |    3 +-
 arch/powerpc/mm/fault.c                       |   31 +
 arch/powerpc/mm/hash64_4k.c                   |   14 +-
 arch/powerpc/mm/hash64_64k.c                  |  124 ++-
 arch/powerpc/mm/hash_utils_64.c               |   65 +-
 arch/powerpc/mm/hugetlbpage-hash64.c          |   16 +-
 arch/powerpc/mm/mmu_context_book3s64.c        |    2 +
 arch/powerpc/mm/pkeys.c                       |  279 +++++
 arch/x86/include/asm/pkeys.h                  |    1 +
 arch/x86/kernel/fpu/xstate.c                  |    5 +
 arch/x86/kernel/setup.c                       |    8 -
 fs/proc/task_mmu.c                            |   15 +-
 include/linux/mm.h                            |   20 +-
 include/linux/pkeys.h                         |    5 +
 tools/testing/selftests/vm/Makefile           |    1 +
 tools/testing/selftests/vm/pkey-helpers.h     |  394 +++++++
 tools/testing/selftests/vm/protection_keys.c  | 1500 +++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile          |    2 +-
 tools/testing/selftests/x86/pkey-helpers.h    |  219 ----
 tools/testing/selftests/x86/protection_keys.c | 1395 -----------------------
 47 files changed, 2993 insertions(+), 1844 deletions(-)
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
