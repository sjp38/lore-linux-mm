Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 192EF6B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 18:37:45 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so1454141pdb.37
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:37:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wh9si5696737pac.254.2014.04.25.15.37.43
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 15:37:43 -0700 (PDT)
Subject: [PATCH 0/8] [v4] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Fri, 25 Apr 2014 15:37:42 -0700
Message-Id: <20140425223742.0A27E42E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>

Changes from v3:
 * Include the patch I was using to gather detailed statistics
   about the length of the ranged TLB flushes
 * Fix some documentation typos
 * Add a patch to rework the remote tlb flush code to plumb the
   tracepoints in easier, and add missing tracepoints
 * use __print_symbolic() for the human-readable tracepoint 
   descriptions
 * change an int to bool in patch 1
 * Specifically call out that we removed itlb vs. dtlb logic

Changes from v2:
 * Added a brief comment above the ceiling tunable
 * Updated the documentation to mention large pages and say
   "individual flush" instead of invlpg in most cases.

I guess the x86 tree is probably the right place to queue this
up.

I've run this through a variety of systems in the LKP harness,
as well as running it on my desktop for a few days.  I'm yet to
see an to see if any perfmance regressions (or gains) show up.

Without the last (instrumentation/debugging) patch:

 arch/x86/include/asm/mmu_context.h |    6 ++
 arch/x86/include/asm/processor.h   |    1
 arch/x86/kernel/cpu/amd.c          |    7 --
 arch/x86/kernel/cpu/common.c       |   13 ----
 arch/x86/kernel/cpu/intel.c        |   26 ---------
 arch/x86/mm/tlb.c                  |  106 ++++++++++++++++++-------------------
 include/linux/mm_types.h           |    8 ++
 7 files changed, 68 insertions(+), 99 deletions(-)
[davehans@viggo linux.git]$ 

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
