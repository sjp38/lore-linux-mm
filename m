Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id A17186B0256
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:34 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so102513933wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g199si5289697wmg.66.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 00/14] mm flags in printk, page_owner improvements for debugging
Date: Tue, 26 Jan 2016 13:45:39 +0100
Message-Id: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Arnaldo Carvalho de Melo <acme@kernel.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Sasha Levin <sasha.levin@oracle.com>, Steven Rostedt <rostedt@goodmis.org>

Changes since v3:
- Rebased on next-20160125
- Changed the %pg format string for flags to %pG due to clash with another
  patch already merged merged
- Update GFP flags (patches 2, 3) for new changes and stuff I overlooked
  the last time
- __GFP_X flags are now printed as __GFP_X instead of GFP_X as that was just
  confusing and GFP_ATOMIC vs __GFP_ATOMIC already needed an exception

After v2 [1] of the page_owner series, I've moved mm-specific flags printing
into printk() and posted it on top of the series. But it makes more sense and
results in less code churn to do the printk() changes first. So this series
is two-part. Patches 1-6 are related to the flags handling in printk() and
tracepoints, and CC the printk, ftrace and perf maintainers. The rest is
the original page_owner series, CCing only mm people.

Adapted description of v2:

For page_owner, the main changes are
o Use static key to further reduce overhead when compiled in but not enabled.
o Improve output wrt. page and pageblock migratetypes
o Transfer the info on page migrations and track last migration reason.
o Dump the info as part of dump_page() to hopefully help debugging.

For the last point, Kirill requested a human readable printing of gfp_mask and
migratetype after v1. At that point it probably makes a lot of sense to do the
same for page alloc failure and OOM warnings. The flags have been undergoing
revisions recently, and we might be getting reports from various kernel
versions that differ. The ./scripts/gfp-translate tool needs to be pointed at
the corresponding sources to be accurate.  The downside is potentially breaking
scripts that grep these warnings, but it's not a first change done there over
the years.

Other changes since v1:
o Change placement of page owner migration calls to cover missing cases (Hugh)
o Move dump_page_owner() call up from dump_page_badflags(), so the latter can
  be used for adding debugging prints without page owner info (Kirill)

[1] https://lkml.org/lkml/2015/11/24/342

Vlastimil Babka (14):
  tracepoints: move trace_print_flags definitions to tracepoint-defs.h
  mm, tracing: make show_gfp_flags() up to date
  tools, perf: make gfp_compact_table up to date
  mm, tracing: unify mm flags handling in tracepoints and printk
  mm, printk: introduce new format string for flags
  mm, debug: replace dump_flags() with the new printk formats
  mm, page_alloc: print symbolic gfp_flags on allocation failure
  mm, oom: print symbolic gfp_flags in oom warning
  mm, page_owner: print migratetype of page and pageblock, symbolic
    flags
  mm, page_owner: convert page_owner_inited to static key
  mm, page_owner: copy page owner info during migration
  mm, page_owner: track and print last migrate reason
  mm, page_owner: dump page owner info from dump_page()
  mm, debug: move bad flags printing to bad_page()

 Documentation/printk-formats.txt   |  18 ++++
 Documentation/vm/page_owner.txt    |   9 +-
 include/linux/gfp.h                |   6 +-
 include/linux/migrate.h            |   6 +-
 include/linux/mmdebug.h            |   9 +-
 include/linux/mmzone.h             |   3 +
 include/linux/page_ext.h           |   1 +
 include/linux/page_owner.h         |  50 ++++++++---
 include/linux/trace_events.h       |  10 ---
 include/linux/tracepoint-defs.h    |  14 +++-
 include/trace/events/btrfs.h       |   2 +-
 include/trace/events/compaction.h  |   2 +-
 include/trace/events/gfpflags.h    |  43 ----------
 include/trace/events/huge_memory.h |   2 -
 include/trace/events/kmem.h        |   2 +-
 include/trace/events/mmflags.h     | 165 +++++++++++++++++++++++++++++++++++++
 include/trace/events/vmscan.h      |   2 +-
 lib/test_printf.c                  |  53 ++++++++++++
 lib/vsprintf.c                     |  75 +++++++++++++++++
 mm/debug.c                         | 165 +++++++++----------------------------
 mm/internal.h                      |   6 ++
 mm/migrate.c                       |  13 ++-
 mm/oom_kill.c                      |   7 +-
 mm/page_alloc.c                    |  29 +++++--
 mm/page_owner.c                    | 100 +++++++++++++++++-----
 mm/vmstat.c                        |  15 +---
 tools/perf/builtin-kmem.c          |  49 ++++++-----
 27 files changed, 583 insertions(+), 273 deletions(-)
 delete mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/mmflags.h

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
