Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7B36B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 14:24:20 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so3965281pad.7
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 11:24:20 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qf5si21263346pac.375.2014.04.21.11.24.19
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 11:24:19 -0700 (PDT)
Subject: [PATCH 0/6] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Mon, 21 Apr 2014 11:24:18 -0700
Message-Id: <20140421182418.81CF7519@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, Dave Hansen <dave@sr71.net>


Changes from v2:
 * Added a brief comment above the ceiling tunable
 * Updated the documentation to mention large pages and say
   "individual flush" instead of invlpg in most cases.

Reposting with an instrumentation patch, and a few minor tweaks.
I'd love some more eyeballs on this, but I think it's ready for
-mm.

I've run this through a variety of systems in the LKP harness,
as well as running it on my desktop for a few days.  I'm yet to
see an to see if any perfmance regressions (or gains) show up.

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
