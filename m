Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF0146B003B
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:11:46 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so7582781pab.33
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 10:11:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bq3si7696587pbd.296.2014.03.10.10.11.43
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 10:11:46 -0700 (PDT)
Subject: [PATCH 0/7] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Mon, 10 Mar 2014 10:11:18 -0700
Message-Id: <20140310171118.7E16CD45@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, davidlohr@hp.com, Dave Hansen <dave@sr71.net>


Changes from v2:
 * Added a brief comment above the ceiling tunable
 * Updated the documentation to mention large pages and say
   "individual flush" instead of invlpg in most cases.

Reposting with an instrumentation patch, and a few minor tweaks.
I'd love some more eyeballs on this, but I think it's ready for
-mm.

I'm having it run through the LKP harness to see if any perfmance
regressions (or gains) show up.

Without the last (instrumentation/debugging) patch:

 arch/x86/include/asm/mmu_context.h |    6 ++
 arch/x86/include/asm/processor.h   |    1
 arch/x86/kernel/cpu/amd.c          |    7 --
 arch/x86/kernel/cpu/common.c       |   13 -----
 arch/x86/kernel/cpu/intel.c        |   26 ----------
 arch/x86/mm/tlb.c                  |   91 +++++++++++++++----------------------
 include/linux/mm_types.h           |   10 ++++
 mm/Makefile                        |    2
 8 files changed, 58 insertions(+), 98 deletions(-)

--

I originally went to look at this becuase I realized that newer
CPUs were not present in the intel_tlb_flushall_shift_set() code.

I went to try to figure out where to stick newer CPUs (do we
consider them more like SandyBridge or IvyBridge), and was not
able to repeat the original experiments.

Instead, this set does:
 1. Rework the code a bit to ready it for tracepoints
 2. Add tracepoints
 3. Add a new tunable and set it to a sane value

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
