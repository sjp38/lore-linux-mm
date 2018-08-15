Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7CAE6B026D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 16:34:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t5-v6so1009295pgp.17
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:34:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n3-v6si18917408pld.146.2018.08.15.13.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 13:34:20 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 0/3] KASLR feature to randomize each loadable module
Date: Wed, 15 Aug 2018 13:30:16 -0700
Message-Id: <1534365020-18943-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Hi,

This is V3 of the "KASLR feature to randomize each loadable module" patchset.
The purpose is to increase the randomization and also to make the modules
randomized in relation to each other instead of just the base, so that if one
module leaks the location of the others can't be inferred.

V3 is a code cleanup from the V2 I had sent out RFC. The performance and memory
usage is the same as V2, in summary:
 - Average allocation 2-4 times better than existing algorithm
 - Max allocation time usually faster than the existing algorithm
 - TLB flushes close to existing algorithm, within 1% for <1000 modules, 
 - Memory usage (for PTEs) usually ~1MB higher than existing algorithm
 - Average module capacity slightly reduced, in the range of 17000 for both

For runtime performance, a synthetic benchmark was run that does 5000000 BPF
JIT invocations each, from varying numbers of parallel processes, while the
kernel compiles sharing the same CPU to stand in for the cache impact of a real
workload. The seccomp filter invocations were just Jann Horn's seccomp filtering
test from this thread http://openwall.com/lists/kernel-hardening/2018/07/18/2,
except non-real time priority. The kernel was configured with KPTI and
retpoline, and pcid was disabled. There wasn't any significant difference
between the new and the old.


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
 arch/x86/kernel/module.c                | 163 ++++++++++++++++---
 include/linux/vmalloc.h                 |   3 +
 mm/vmalloc.c                            | 266 +++++++++++++++++++++++++++++++-
 4 files changed, 415 insertions(+), 24 deletions(-)

-- 
2.7.4
