Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 070966B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 15:30:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o9so1959491pgv.19
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 12:30:10 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 30si817802pgr.396.2018.11.02.12.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 12:30:09 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v8 0/4] KASLR feature to randomize each loadable module
Date: Fri,  2 Nov 2018 12:25:16 -0700
Message-Id: <20181102192520.4522-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jeyu@kernel.org, akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Hi,

This is V8 of the "KASLR feature to randomize each loadable module" patchset.
The purpose is to increase the randomization and also to make the modules
randomized in relation to each other instead of just the base, so that if one
module leaks the location of the others can't be inferred.

This version gets rid of the more complex, more LOC, new logic in vmalloc that
helped optimization around lazy the free area case, and hopefully makes this
patchset more straightforward. Earlier versions were concerned with efficiently
handling this case, but I have learned they are actually not common in real
world module loader usage. So instead there are some smaller tweaks to existing
vmalloc logic to allow an allocation to be tried without triggering a
purge_vmap_area_lazy() and retry, when it encounters a real (non lazy free)
area. The kselftest simulations have been updated with the logic of init
sections getting cleaned up as well.

There is a small allocation performance degradation versus v7 as a trade off, but
it is still faster on average than the existing algorithm until >7000 modules.

Changes for V8:
 - Simplify code by removing logic for optimum handling of lazy free areas

Changes for V7:
 - More 0-day build fixes, readability improvements (Kees Cook)

Changes for V6:
 - 0-day build fixes by removing un-needed functional testing, more error
   handling

Changes for V5:
 - Add module_alloc test module

Changes for V4:
 - Fix issue caused by KASAN, kmemleak being provided different allocation
   lengths (padding).
 - Avoid kmalloc until sure its needed in __vmalloc_node_try_addr.
 - Fixed issues reported by 0-day.

Changes for V3:
 - Code cleanup based on internal feedback. (thanks to Dave Hansen and Andriy
   Shevchenko)
 - Slight refactor of existing algorithm to more cleanly live along side new
   one.
 - BPF synthetic benchmark

Changes for V2:
 - New implementation of __vmalloc_node_try_addr based on the
   __vmalloc_node_range implementation, that only flushes TLB when needed.
 - Modified module loading algorithm to try to reduce the TLB flushes further.
 - Increase "random area" tries in order to increase the number of modules that
   can get high randomness.
 - Increase "random area" size to 2/3 of module area in order to increase the
   number of modules that can get high randomness.
 - Fix for 0day failures on other architectures.
 - Fix for wrong debugfs permissions. (thanks to Jann Horn)
 - Spelling fix. (thanks to Jann Horn)
 - Data on module_alloc performance and TLB flushes. (brought up by Kees Cook
   and Jann Horn)
 - Data on memory usage. (suggested by Jann)


Rick Edgecombe (4):
  vmalloc: Add __vmalloc_node_try_addr function
  x86/modules: Increase randomization for modules
  vmalloc: Add debugfs modfraginfo
  Kselftest for module text allocation benchmarking

 arch/x86/Kconfig                              |   3 +
 arch/x86/include/asm/kaslr_modules.h          |  38 ++
 arch/x86/include/asm/pgtable_64_types.h       |   7 +
 arch/x86/kernel/module.c                      | 111 ++++--
 include/linux/vmalloc.h                       |   3 +
 lib/Kconfig.debug                             |   9 +
 lib/Makefile                                  |   1 +
 lib/test_mod_alloc.c                          | 343 ++++++++++++++++++
 mm/vmalloc.c                                  | 228 ++++++++++--
 tools/testing/selftests/bpf/test_mod_alloc.sh |  29 ++
 10 files changed, 711 insertions(+), 61 deletions(-)
 create mode 100644 arch/x86/include/asm/kaslr_modules.h
 create mode 100644 lib/test_mod_alloc.c
 create mode 100755 tools/testing/selftests/bpf/test_mod_alloc.sh

-- 
2.17.1
