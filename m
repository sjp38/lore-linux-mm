Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 07A1A6B0036
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:19 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so1320814eek.16
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id i1si8258873eev.5.2013.12.08.23.09.15
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:15 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/18] NUMA balancing segmentation fault fixes and misc followups v3
Date: Mon,  9 Dec 2013 07:08:54 +0000
Message-Id: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Alex Thorlton reported segementation faults when NUMA balancing is enabled
on large machines. There is no obvious explanation from the console what the
problem but similar problems have been observed by Rik van Riel and myself
if migration was aggressive enough. Alex, this series is against 3.13-rc2,
a verification that the fix addresses your problem would be appreciated.

This series starts with a range of patches aimed at addressing the
segmentation fault problem while offsetting some of the cost to avoid badly
regressing performance in -stable. Those that are cc'd to stable (patches
1-12) should be merged ASAP. The rest of the series is relatively minor
stuff that fell out during the course of development that is ok to wait
for the next merge window but should help with the continued development
of NUMA balancing.

 arch/sparc/include/asm/pgtable_64.h |   4 +-
 arch/x86/include/asm/pgtable.h      |  11 +++-
 arch/x86/mm/gup.c                   |  13 +++++
 include/asm-generic/pgtable.h       |   2 +-
 include/linux/migrate.h             |   9 ++++
 include/linux/mm_types.h            |  44 +++++++++++++++
 include/linux/mmzone.h              |   5 +-
 include/trace/events/migrate.h      |  26 +++++++++
 include/trace/events/sched.h        |  93 ++++++++++++++++++++++++++++++++
 kernel/fork.c                       |   1 +
 kernel/sched/core.c                 |   2 +
 kernel/sched/fair.c                 |  15 +++++-
 mm/huge_memory.c                    |  45 ++++++++++++----
 mm/migrate.c                        | 103 ++++++++++++++++++++++++++++--------
 mm/mprotect.c                       |  15 ++++--
 mm/pgtable-generic.c                |   8 ++-
 16 files changed, 348 insertions(+), 48 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
