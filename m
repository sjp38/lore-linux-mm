Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id CFDE96B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 20:53:14 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so430809dae.21
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:53:14 -0800 (PST)
Date: Fri, 25 Jan 2013 17:53:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/11] ksm: NUMA trees and page migration
Message-ID: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's a KSM series, based on mmotm 2013-01-23-17-04: starting with
Petr's v7 "KSM: numa awareness sysfs knob"; then fixing the two issues
we had with that, fully enabling KSM page migration on the way.

(A different kind of KSM/NUMA issue which I've certainly not begun to
address here: when KSM pages are unmerged, there's usually no sense
in preferring to allocate the new pages local to the caller's node.)

Petr, I have intentionally changed the titles of yours: partly because
your "sysfs knob" understated it, but mainly because I think gmail is
liable to assign 1/11 and 2/11 to your earlier December thread, making
them vanish from this series.  I hope a change of title prevents that.

 1 ksm: allow trees per NUMA node
 2 ksm: add sysfs ABI Documentation
 3 ksm: trivial tidyups
 4 ksm: reorganize ksm_check_stable_tree
 5 ksm: get_ksm_page locked
 6 ksm: remove old stable nodes more thoroughly
 7 ksm: make KSM page migration possible
 8 ksm: make !merge_across_nodes migration safe
 9 mm: enable KSM page migration
10 mm: remove offlining arg to migrate_pages
11 ksm: stop hotremove lockdep warning

 Documentation/ABI/testing/sysfs-kernel-mm-ksm |   52 +
 Documentation/vm/ksm.txt                      |    7 
 include/linux/ksm.h                           |   18 
 include/linux/migrate.h                       |   14 
 mm/compaction.c                               |    2 
 mm/ksm.c                                      |  566 +++++++++++++---
 mm/memory-failure.c                           |    7 
 mm/memory.c                                   |   19 
 mm/memory_hotplug.c                           |    3 
 mm/mempolicy.c                                |   11 
 mm/migrate.c                                  |   61 -
 mm/page_alloc.c                               |    6 
 12 files changed, 580 insertions(+), 186 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
