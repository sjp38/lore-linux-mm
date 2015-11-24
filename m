Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 93DE56B0259
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:48 -0500 (EST)
Received: by wmec201 with SMTP id c201so24562502wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:36:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o67si6304736wmb.70.2015.11.24.04.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:43 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/9] page_owner improvements for debugging
Date: Tue, 24 Nov 2015 13:36:12 +0100
Message-Id: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

This is the second version of patchset which originally aimed to improve the
page_owner functionality. Thanks to feedback from v1 and some bugs I
discovered along the way, it is now larger in scope and number of patches.
It's based on next-20151124.

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

Note I'm not entirely happy about the dump_gfpflag_names() implementation, due
to usage of pr_cont() unreliable on SMP (and I've seen spurious newlines in
dmesg output, while being correct on serial console or /var/log/messages).
It also doesn't allow plugging the gfp_mask translation into
/sys/kernel/debug/page_owner where it also could make sense. Maybe a new
*printf formatting flag? Too specialized maybe? Or just prepare the string in
a buffer on stack with strscpy?

Other changes since v1:
o Change placement of page owner migration calls to cover missing cases (Hugh)
o Move dump_page_owner() call up from dump_page_badflags(), so the latter can
  be used for adding debugging prints without page owner info (Kirill)

Vlastimil Babka (9):
  mm, debug: fix wrongly filtered flags in dump_vma()
  mm, page_owner: print symbolic migratetype of both page and pageblock
  mm, page_owner: convert page_owner_inited to static key
  mm, page_owner: copy page owner info during migration
  mm, page_owner: track and print last migrate reason
  mm, debug: introduce dump_gfpflag_names() for symbolic printing of
    gfp_flags
  mm, page_owner: dump page owner info from dump_page()
  mm, page_alloc: print symbolic gfp_flags on allocation failure
  mm, oom: print symbolic gfp_flags in oom warning

 Documentation/vm/page_owner.txt |  9 +++--
 include/linux/migrate.h         |  6 ++-
 include/linux/mmdebug.h         |  1 +
 include/linux/mmzone.h          |  3 ++
 include/linux/page_ext.h        |  1 +
 include/linux/page_owner.h      | 50 ++++++++++++++++++-------
 include/trace/events/gfpflags.h | 14 +++++--
 mm/debug.c                      | 44 ++++++++++++++++------
 mm/migrate.c                    | 23 ++++++++++--
 mm/oom_kill.c                   | 10 +++--
 mm/page_alloc.c                 | 18 ++++++++-
 mm/page_owner.c                 | 82 +++++++++++++++++++++++++++++++++++++----
 mm/vmstat.c                     | 15 +-------
 13 files changed, 213 insertions(+), 63 deletions(-)

-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
