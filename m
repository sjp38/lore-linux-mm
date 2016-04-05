Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f170.google.com (mail-yw0-f170.google.com [209.85.161.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8FC6B028D
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:13:57 -0400 (EDT)
Received: by mail-yw0-f170.google.com with SMTP id d68so32665572ywe.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:13:57 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id i67si8752903ywf.226.2016.04.05.14.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:13:56 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id fe3so18071779pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:13:56 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:13:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 02/31] huge tmpfs: include shmem freeholes in available
 memory
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051412330.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

ShmemFreeHoles will be freed under memory pressure, but are not included
in MemFree: they need to be added into MemAvailable, and wherever the
kernel calculates freeable pages, rather than actually free pages.  They
must not be counted as free when considering whether to go to reclaim.

There is certainly room for debate about other places, but I think I've
got about the right list - though I'm unfamiliar with and undecided about
drivers/staging/android/lowmemorykiller.c and kernel/power/snapshot.c.

While NR_SHMEM_FREEHOLES should certainly not be counted in NR_FREE_PAGES,
there is a case for including ShmemFreeHoles in the user-visible MemFree
after all: I can see both sides of that argument, leaving it out so far.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/page-writeback.c |    2 ++
 mm/page_alloc.c     |    6 ++++++
 mm/util.c           |    1 +
 3 files changed, 9 insertions(+)

--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -285,6 +285,7 @@ static unsigned long zone_dirtyable_memo
 	 */
 	nr_pages -= min(nr_pages, zone->totalreserve_pages);
 
+	nr_pages += zone_page_state(zone, NR_SHMEM_FREEHOLES);
 	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
 	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
 
@@ -344,6 +345,7 @@ static unsigned long global_dirtyable_me
 	 */
 	x -= min(x, totalreserve_pages);
 
+	x += global_page_state(NR_SHMEM_FREEHOLES);
 	x += global_page_state(NR_INACTIVE_FILE);
 	x += global_page_state(NR_ACTIVE_FILE);
 
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3760,6 +3760,12 @@ long si_mem_available(void)
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
--- a/mm/util.c
+++ b/mm/util.c
@@ -496,6 +496,7 @@ int __vm_enough_memory(struct mm_struct
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
+		free += global_page_state(NR_SHMEM_FREEHOLES);
 		free += global_page_state(NR_FILE_PAGES);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
