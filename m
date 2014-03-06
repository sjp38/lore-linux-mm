Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6E16B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 19:45:22 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kq14so1849699pab.37
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 16:45:21 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id zt8si3728096pbc.15.2014.03.05.16.45.20
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 16:45:21 -0800 (PST)
Subject: [PATCH 0/7] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Wed, 05 Mar 2014 16:45:19 -0800
Message-Id: <20140306004519.BBD70A1A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>

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
