Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D0F866B006E
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:03:23 -0500 (EST)
Received: by pdno5 with SMTP id o5so12013747pdn.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:03:23 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id zm4si11362561pbb.106.2015.02.20.20.03.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:03:23 -0800 (PST)
Received: by pdev10 with SMTP id v10so11962199pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:03:22 -0800 (PST)
Date: Fri, 20 Feb 2015 20:03:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 07/24] huge tmpfs: include shmem freeholes in available memory
 counts
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202001560.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

ShmemFreeHoles will be freed under memory pressure, but are not included
in MemFree: they need to be added into MemAvailable, and wherever the
kernel calculates freeable pages; but in a few other places also.

There is certainly room for debate about those places: I've made my
selection (and kept some notes), you may come up with a different list.
I decided against max_sane_readahead(), because I suspect it's already
too much; and left drivers/staging/android/lowmemorykiller.c out for now.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 fs/proc/meminfo.c   |    6 ++++++
 mm/mmap.c           |    1 +
 mm/page-writeback.c |    2 ++
 mm/vmscan.c         |    3 ++-
 4 files changed, 11 insertions(+), 1 deletion(-)

--- thpfs.orig/fs/proc/meminfo.c	2015-02-20 19:33:51.488038441 -0800
+++ thpfs/fs/proc/meminfo.c	2015-02-20 19:33:56.528026917 -0800
@@ -76,6 +76,12 @@ static int meminfo_proc_show(struct seq_
 	available += pagecache;
 
 	/*
+	 * Shmem freeholes help to keep huge pages intact, but contain
+	 * no data, and can be shrunk whenever small pages are needed.
+	 */
+	available += global_page_state(NR_SHMEM_FREEHOLES);
+
+	/*
 	 * Part of the reclaimable slab consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
 	 */
--- thpfs.orig/mm/mmap.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/mmap.c	2015-02-20 19:33:56.528026917 -0800
@@ -168,6 +168,7 @@ int __vm_enough_memory(struct mm_struct
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
+		free += global_page_state(NR_SHMEM_FREEHOLES);
 		free += global_page_state(NR_FILE_PAGES);
 
 		/*
--- thpfs.orig/mm/page-writeback.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/page-writeback.c	2015-02-20 19:33:56.532026908 -0800
@@ -187,6 +187,7 @@ static unsigned long zone_dirtyable_memo
 	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
 	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
 
+	nr_pages += zone_page_state(zone, NR_SHMEM_FREEHOLES);
 	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
 	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
 
@@ -241,6 +242,7 @@ static unsigned long global_dirtyable_me
 	x = global_page_state(NR_FREE_PAGES);
 	x -= min(x, dirty_balance_reserve);
 
+	x += global_page_state(NR_SHMEM_FREEHOLES);
 	x += global_page_state(NR_INACTIVE_FILE);
 	x += global_page_state(NR_ACTIVE_FILE);
 
--- thpfs.orig/mm/vmscan.c	2015-02-20 19:33:31.056085158 -0800
+++ thpfs/mm/vmscan.c	2015-02-20 19:33:56.532026908 -0800
@@ -1946,7 +1946,8 @@ static void get_scan_count(struct lruvec
 		unsigned long zonefile;
 		unsigned long zonefree;
 
-		zonefree = zone_page_state(zone, NR_FREE_PAGES);
+		zonefree = zone_page_state(zone, NR_FREE_PAGES) +
+			   zone_page_state(zone, NR_SHMEM_FREEHOLES);
 		zonefile = zone_page_state(zone, NR_ACTIVE_FILE) +
 			   zone_page_state(zone, NR_INACTIVE_FILE);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
