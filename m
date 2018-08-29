Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 717F36B4E24
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 18:59:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q12-v6so3935577pgp.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 15:59:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o13-v6si4876523pll.86.2018.08.29.15.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 15:59:44 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 0/3] KASLR feature to randomize each loadable module
Date: Wed, 29 Aug 2018 15:59:36 -0700
Message-Id: <1535583579-6138-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Hi,

This is v4 of the "KASLR feature to randomize each loadable module" patchset.
The purpose is to increase the randomization and also to make the modules
randomized in relation to each other instead of just the base, so that if one
module leaks the location of the others can't be inferred. It is enabled for
x86_64 for now.

V4 is a few small fixes. I humbly think this is in pretty good shape at this
point, unless anyone has any comments. The only other big change I was
considering was moving the new randomization algorithm into vmalloc so it could
be re-used for other architectures or possibly other vmalloc usages.

A few words on how this was tested - As previously mentioned, the entropy
estimates were done using extracted module text sizes from the in-tree modules.
These were also used to run 100,000's of simulated module allocations by calling
module_alloc from a test module, including testing until allocation failure. The
simulations kept track of every allocation address to make sure there were no
collisions, and verified memory was actually mapped.

In addition the __vmalloc_node_try_addr function has a suite of unit tests that
verify for a bunch of edge cases that it:
 - Allows for allocations when it should
 - Reports the right error code if it collides with a lazy-free area or real
   allocation
 - Verifies it frees a lazy free area when it should

These synthetic tests were also how the performance metrics were gathered.

Changes for V4:
 - Fix issue caused by KASAN, kmemleak being provided different allocation
   lengths (padding).
 - Avoid kmalloc until sure its needed in __vmalloc_node_try_addr.
 - Fix for debug file hang when the last VA is a lazy purge area
 - Fixed issues reported by 0-day build system.

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


Rick Edgecombe (3):
  vmalloc: Add __vmalloc_node_try_addr function
  x86/modules: Increase randomization for modules
  vmalloc: Add debugfs modfraginfo

 arch/x86/include/asm/pgtable_64_types.h |   7 +
 arch/x86/kernel/module.c                | 165 ++++++++++++++++---
 include/linux/vmalloc.h                 |   3 +
 mm/vmalloc.c                            | 279 +++++++++++++++++++++++++++++++-
 4 files changed, 429 insertions(+), 25 deletions(-)

-- 
2.7.4
