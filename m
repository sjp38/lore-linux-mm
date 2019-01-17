Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0808E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 19:33:38 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a2so5000489pgt.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:33:38 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y10si7582915plt.406.2019.01.16.16.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 16:33:37 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 00/17] Merge text_poke fixes and executable lockdowns
Date: Wed, 16 Jan 2019 16:32:42 -0800
Message-Id: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This patchset improves several overlapping issues around stale TLB
entries and W^X violations. It is combined from a slightly tweaked
"x86/alternative: text_poke() enhancements v7" [1] and a next version of
the "Don’t leave executable TLB entries to freed pages v2" [2]
patchsets that were conflicting.

The related issues that this fixes:
1. Fixmap PTEs that are used for patching are available for access from
   other cores and might be exploited. They are not even flushed from
   the TLB in remote cores, so the risk is even higher. Address this
   issue by introducing a temporary mm that is only used during
   patching. Unfortunately, due to init ordering, fixmap is still used
   during boot-time patching. Future patches can eliminate the need for
   it.
2. Missing lockdep assertion to ensure text_mutex is taken. It is
   actually not always taken, so fix the instances that were found not
   to take the lock (although they should be safe even without taking
   the lock).
3. Module_alloc returning memory that is RWX until a module is finished
   loading.
4. Sometimes when memory is freed via the module subsystem, an
   executable permissioned TLB entry can remain to a freed page. If the
   page is re-used to back an address that will receive data from
   userspace, it can result in user data being mapped as executable in
   the kernel. The root of this behavior is vfree lazily flushing the
   TLB, but not lazily freeing the underlying pages.

The new changes from "Don’t leave executable TLB entries to freed pages
v2":
 - Add support for case of hibernate trying to save an unmapped page
   on the directmap. (Ard Biesheuvel)
 - No week arch breakout for vfree-ing special memory (Andy Lutomirski)
 - Avoid changing deferred free code by moving modules init free to work
   queue (Andy Lutomirski)
 - Plug in new flag for kprobes and ftrace
 - More arch generic names for set_pages functions (Ard Biesheuvel)
 - Fix for TLB not always flushing the directmap (Nadav Amit)
 
New changes from from "x86/alternative: text_poke() enhancements v7"
 - Fix build failure on CONFIG_RANDOMIZE_BASE=n (Rick)
 - Remove text_poke usage from ftrace (Nadav)
 
[1] https://lkml.org/lkml/2018/12/5/200
[2] https://lkml.org/lkml/2018/12/11/1571

Andy Lutomirski (1):
  x86/mm: temporary mm struct

Nadav Amit (12):
  Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
  x86/jump_label: Use text_poke_early() during early init
  fork: provide a function for copying init_mm
  x86/alternative: initializing temporary mm for patching
  x86/alternative: use temporary mm for text poking
  x86/kgdb: avoid redundant comparison of patched code
  x86/ftrace: set trampoline pages as executable
  x86/kprobes: Instruction pages initialization enhancements
  x86: avoid W^X being broken during modules loading
  x86/jump-label: remove support for custom poker
  x86/alternative: Remove the return value of text_poke_*()
  module: Prevent module removal racing with text_poke()

Rick Edgecombe (4):
  Add set_alias_ function and x86 implementation
  mm: Make hibernate handle unmapped pages
  vmalloc: New flags for safe vfree on special perms
  Plug in new special vfree flag

 arch/Kconfig                         |   4 +
 arch/x86/Kconfig                     |   1 +
 arch/x86/include/asm/fixmap.h        |   2 -
 arch/x86/include/asm/mmu_context.h   |  32 +++++
 arch/x86/include/asm/pgtable.h       |   3 +
 arch/x86/include/asm/set_memory.h    |   3 +
 arch/x86/include/asm/text-patching.h |   7 +-
 arch/x86/kernel/alternative.c        | 197 ++++++++++++++++++++-------
 arch/x86/kernel/ftrace.c             |  15 +-
 arch/x86/kernel/jump_label.c         |  19 ++-
 arch/x86/kernel/kgdb.c               |  25 +---
 arch/x86/kernel/kprobes/core.c       |  19 ++-
 arch/x86/kernel/module.c             |   2 +-
 arch/x86/mm/init_64.c                |  36 +++++
 arch/x86/mm/pageattr.c               |  16 ++-
 arch/x86/xen/mmu_pv.c                |   2 -
 include/linux/filter.h               |  18 +--
 include/linux/mm.h                   |  18 +--
 include/linux/sched/task.h           |   1 +
 include/linux/set_memory.h           |  10 ++
 include/linux/vmalloc.h              |  13 ++
 init/main.c                          |   3 +
 kernel/bpf/core.c                    |   1 -
 kernel/fork.c                        |  24 +++-
 kernel/module.c                      |  87 ++++++------
 mm/page_alloc.c                      |   6 +-
 mm/vmalloc.c                         | 122 ++++++++++++++---
 27 files changed, 497 insertions(+), 189 deletions(-)

-- 
2.17.1
