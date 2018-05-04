Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDE46B0007
	for <linux-mm@kvack.org>; Fri,  4 May 2018 18:00:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y127so12430563qka.5
        for <linux-mm@kvack.org>; Fri, 04 May 2018 15:00:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor9627145qkd.14.2018.05.04.15.00.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 15:00:04 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 0/3] mm, x86, powerpc: Enhancements to Memory Protection Keys.
Date: Fri,  4 May 2018 14:59:40 -0700
Message-Id: <1525471183-21277-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de

This patch series provides arch-neutral enhancements to
enable memory-keys on new architecutes, and the corresponding
changes in x86 and powerpc specific code to support that.

a) Provides ability to support upto 32 keys.  PowerPC
        can handle 32 keys and hence needs this.

b) Arch-neutral code; and not the arch-specific code,
   determines the format of the string, that displays the key
   for each vma in smaps.

History:
-------
version 14:
	(1) made VM_PKEY_BIT4 unusable on x86, #defined it to 0
		-- comment by Dave Hansen
	(2) due to some reason this patch series continue to
	      break some or the other build. The last series
	      passed everything but created a merge
	      conflict followed by build failure for
	      Michael Ellermen. :(

version v13:
	(1) fixed a git bisect error. :(

version v12:
	(1) fixed compilation errors seen with various x86
	    configs.
version v11:
	(1) code that displays key in smaps is not any more
	    defined under CONFIG_ARCH_HAS_PKEYS.
		- Comment by Eric W. Biederman and Michal Hocko
	(2) merged two patches that implemented (1).
		- comment by Michal Hocko

version prior to v11:
	(1) used one additional bit from VM_HIGH_ARCH_*
		to support 32 keys.
		- Suggestion by Dave Hansen.
	(2) powerpc specific changes to support memory keys.


Ram Pai (3):
  mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS
    is enabled
  mm, powerpc, x86: introduce an additional vma bit for powerpc pkey
  mm, x86, powerpc: display pkey in smaps only if arch supports pkeys

 arch/powerpc/include/asm/mmu_context.h |    5 -----
 arch/powerpc/include/asm/pkeys.h       |    2 ++
 arch/x86/include/asm/mmu_context.h     |    5 -----
 arch/x86/include/asm/pkeys.h           |    1 +
 arch/x86/kernel/fpu/xstate.c           |    5 +++++
 arch/x86/kernel/setup.c                |    8 --------
 fs/proc/task_mmu.c                     |   16 +++++++++-------
 include/linux/mm.h                     |   15 +++++++++++----
 include/linux/pkeys.h                  |    7 ++++++-
 9 files changed, 34 insertions(+), 30 deletions(-)
