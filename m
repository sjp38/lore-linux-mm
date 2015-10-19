Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F2ACB82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:44:18 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so82436154pac.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:44:18 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id co2si49712685pbb.197.2015.10.18.21.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:44:18 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so17421348pad.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:44:18 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:44:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/12] mm: page migration cleanups, and a little mlock
Message-ID: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rafael Aquini <aquini@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Minchan Kim <minchan@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

Here's a series of mostly trivial cleanups to page migration, following
on from a preliminary cleanup to Documentation, and to the way rmap
calls mlock_vma_page (which has to be duplicated in page migration).

This started out as patch 04/24 "mm: make page migration's newpage
handling more robust" in my huge tmpfs series against v3.19 in February.
It was already a portmanteau then, and more has been thrown in since:
not much of relevance to tmpfs, just cleanups that looked worth making.

A few minor fixes on the way, nothing I think worth sending to stable.
Mostly trivial, but 12/12 and a few of the others deserve some thought.

Diffed against v4.3-rc6: I couldn't decide whether to use that or
the v4.3-rc5-mm1 as base, but there's very little conflict anyway:
4/12 should have the second arg to page_remove_rmap() if it goes after
Kirill's THP refcounting series, and 10/12 should have the TTU_FREE
block inserted if it goes after Minchan's MADV_FREE series.

 1/12 mm Documentation: undoc non-linear vmas
 2/12 mm: rmap use pte lock not mmap_sem to set PageMlocked
 3/12 mm: page migration fix PageMlocked on migrated pages
 4/12 mm: rename mem_cgroup_migrate to mem_cgroup_replace_page
 5/12 mm: correct a couple of page migration comments
 6/12 mm: page migration use the put_new_page whenever necessary
 7/12 mm: page migration trylock newpage at same level as oldpage
 8/12 mm: page migration remove_migration_ptes at lock+unlock level
 9/12 mm: simplify page migration's anon_vma comment and flow
10/12 mm: page migration use migration entry for swapcache too
11/12 mm: page migration avoid touching newpage until no going back
12/12 mm: migrate dirty page without clear_page_dirty_for_io etc

 Documentation/filesystems/proc.txt   |    1 
 Documentation/vm/page_migration      |   27 +-
 Documentation/vm/unevictable-lru.txt |  120 +-----------
 include/linux/memcontrol.h           |    7 
 mm/balloon_compaction.c              |   10 -
 mm/filemap.c                         |    2 
 mm/internal.h                        |    9 
 mm/memcontrol.c                      |   29 --
 mm/migrate.c                         |  244 ++++++++++++-------------
 mm/rmap.c                            |   99 ++++------
 mm/shmem.c                           |    2 
 11 files changed, 213 insertions(+), 337 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
