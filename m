Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 857516B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 17:38:33 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y86-v6so12226060pff.6
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 14:38:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f62-v6si14059200pfb.218.2018.10.01.14.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 14:38:31 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v7 0/4] KASLR feature to randomize each loadable module
Date: Mon,  1 Oct 2018 14:38:43 -0700
Message-Id: <1538429927-17834-1-git-send-email-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This is V7 of the "KASLR feature to randomize each loadable module" patchset.
The purpose is to increase the randomization and also to make the modules
randomized in relation to each other instead of just the base, so that if one
module leaks the location of the others can't be inferred.

This new version is some more 0-day build fixes, trying to improve the
readability and minimize IFDEFs.

On cleaning up the kaslr_enabled() weirdness, it turned out there were quite a
few conflicts depending on where I put the config helpers. I tried modules.h,
and kaslr.h, but this caused a bunch of conflicts related to PAGE_* macros being
defined in multiple places, and extern variables being named the same. In the
end I just created a new file called kaslr_modules.h.


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
 arch/x86/include/asm/kaslr_modules.h          |  38 +++
 arch/x86/include/asm/pgtable_64_types.h       |   7 +
 arch/x86/kernel/module.c                      | 139 ++++++++--
 include/linux/vmalloc.h                       |   3 +
 lib/Kconfig.debug                             |  10 +
 lib/Makefile                                  |   1 +
 lib/test_mod_alloc.c                          | 354 ++++++++++++++++++++++++++
 mm/vmalloc.c                                  | 275 +++++++++++++++++++-
 tools/testing/selftests/bpf/test_mod_alloc.sh |  29 +++
 10 files changed, 834 insertions(+), 25 deletions(-)
 create mode 100644 arch/x86/include/asm/kaslr_modules.h
 create mode 100644 lib/test_mod_alloc.c
 create mode 100755 tools/testing/selftests/bpf/test_mod_alloc.sh

-- 
2.7.4
