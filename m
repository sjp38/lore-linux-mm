Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 157406B0037
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:35:03 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so542401wgg.13
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:35:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si4038712eeg.240.2014.01.09.06.35.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:35:02 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Fix ebizzy performance regression due to X86 TLB range flush v3
Date: Thu,  9 Jan 2014 14:34:53 +0000
Message-Id: <1389278098-27154-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since v2
o Rebase to v3.13-rc7 to pick up scheduler-related fixes
o Describe methodology in changelog
o Reset tlb flush shift for all models except Ivybridge

Changelog since v1
o Drop a pagetable walk that seems redundant
o Account for TLB flushes only when debugging
o Drop the patch that took number of CPUs to flush into account

ebizzy regressed between 3.4 and 3.10 while testing on a new
machine. Bisection initially found at least three problems of which the
first was commit 611ae8e3 (x86/tlb: enable tlb flush range support for
x86). Second was related to TLB flush accounting. The third was related
to ACPI cpufreq and so it was disabled for the purposes of this series.

The intent of the TLB range flush series was to preserve existing TLB
entries by flushing a range one page at a time instead of flushing the
address space. This makes a certain amount of sense if the address space
being flushed was known to have existing hot entries.  The decision on
whether to do a full mm flush or a number of single page flushes depends
on the size of the relevant TLB and how many of these hot entries would
be preserved by a targeted flush. This implicitly assumes a lot including
the following examples

o That the full TLB is in use by the task being flushed
o The TLB has hot entries that are going to be used in the near future
o The TLB has entries for the range being cached
o The cost of the per-page flushes is similar to a single mm flush
o Large pages are unimportant and can always be globally flushed
o Small flushes from workloads are very common

The first three are completely unknowable but unfortunately it is something
that is probably true of micro benchmarks designed to exercise these
paths. The fourth one depends completely on the hardware. The large page
check used to make sense but now the number of entries required to do
a range flush is so small that it is a redundant check. The last one is
the strangest because generally only a process that was mapping/unmapping
very small regions would hit this. It's possible it is the common case
for virtualised workloads that is managing the address space of its
guests. Maybe this was the real original motivation of the TLB range flush
support for x86.  If this is the case then the patches need to be revisited
and clearly flagged as being of benefit to virtualisation.

As things currently stand, Ebizzy sees very little benefit as it discards
newly allocated memory very quickly and regressed badly on Ivybridge where
it constantly flushes ranges of 128 pages one page at a time. Earlier
machines may not have seen this problem as the balance point was at a
different location. While I'm wary of optimising for such a benchmark,
it's commonly tested and it's apparent that the worst case defaults for
Ivybridge need to be re-examined.

The following small series brings ebizzy closer to 3.4-era performance
for the very limited set of machines tested. It does not bring
performance fully back in line but the recent idle power regression
fix has already been identified as regressing ebizzy performance
(http://www.spinics.net/lists/stable/msg31352.html) and would need to be
addressed first. Benchmark results are included in the relevant patch's
changelog.

 arch/x86/include/asm/tlbflush.h    |  6 ++---
 arch/x86/kernel/cpu/amd.c          |  5 +---
 arch/x86/kernel/cpu/intel.c        | 10 +++-----
 arch/x86/kernel/cpu/mtrr/generic.c |  4 +--
 arch/x86/mm/tlb.c                  | 52 ++++++++++----------------------------
 include/linux/vm_event_item.h      |  4 +--
 include/linux/vmstat.h             |  8 ++++++
 7 files changed, 32 insertions(+), 57 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
