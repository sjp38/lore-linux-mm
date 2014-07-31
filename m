Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6A76B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:40:56 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so3831107pad.21
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:40:56 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id jc4si6369186pbb.80.2014.07.31.08.40.53
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 08:40:53 -0700 (PDT)
Subject: [PATCH 0/7] [RESEND][v4] x86: rework tlb range flushing code
From: Dave Hansen <dave@sr71.net>
Date: Thu, 31 Jul 2014 08:40:52 -0700
Message-Id: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>

x86 Maintainers,

I've sent this a couple of times and resolved all the feedback
I've received.  It has sign-offs from Mel and Rik.  Could this
get picked up in to the x86 tree, please?

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

I've run this through a variety of systems in the LKP harness,
as well as running it on my desktop for a few days.  I'm yet to
see an to see if any perfmance regressions (or gains) show up.

 arch/x86/include/asm/mmu_context.h |    6 ++
 arch/x86/include/asm/processor.h   |    1
 arch/x86/kernel/cpu/amd.c          |    7 --
 arch/x86/kernel/cpu/common.c       |   13 ----
 arch/x86/kernel/cpu/intel.c        |   26 ---------
 arch/x86/mm/tlb.c                  |  106 ++++++++++++++++++-------------------
 include/linux/mm_types.h           |    8 ++
 7 files changed, 68 insertions(+), 99 deletions(-)

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
