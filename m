Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 777E46B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 10:09:16 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c17so15119315wmd.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 07:09:16 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id a6si5608681wmh.59.2015.12.11.07.09.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Dec 2015 07:09:15 -0800 (PST)
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 11 Dec 2015 15:09:14 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4EB01219005E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:09:05 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tBBF9CK642729498
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:09:13 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tBBF9Cnw010041
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 08:09:12 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH/RFC] mm/swapfile: reduce kswapd overhead by not filling up disks
Date: Fri, 11 Dec 2015 16:09:34 +0100
Message-Id: <1449846574-35511-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>

if a user has more than one swap disk with different priorities, the
swap code will fill up the hight prio disk until the last block is
used.
The swap code will continue to scan the first disk also when its
already filling the 2nd or 3rd disk.
We have seen kswapd running at 100% CPU, with the majority of hits
in the scanning code of scan_swap_map, even for non-rotational disks
when this happens.
For example with 3 disks
disk1 99.9%
disk2 10%
disk3 0%
it will scan the bitmap of disk1 (and as the disk is full the
cluster optimization does not trigger) for every page that will
likely go to disk2 anyway.

By doing a first scan that only uses up to 98%, we force the swap
code to use the 2nd disk slightly earlier, but it reduces kswapd
cpu usage significantly. The 2nd scan will then allow to fill
the remaining 2%, again starting with the highest prio disk.

The code does not affect cases with all the same swap priorities,
unless all disks are about 98% full.
There is one issue with mythis approach: If there is a mix between
same and different priorities, the code will loop too often due
to the requeue, so and idea for a better fix is welcome.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 mm/swapfile.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5887731..d3817cf 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -640,6 +640,7 @@ swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si, *next;
 	pgoff_t offset;
+	bool first = true;
 
 	if (atomic_long_read(&nr_swap_pages) <= 0)
 		goto noswap;
@@ -653,6 +654,12 @@ start_over:
 		plist_requeue(&si->avail_list, &swap_avail_head);
 		spin_unlock(&swap_avail_lock);
 		spin_lock(&si->lock);
+		/* at 98% usage lets try the other swaps */
+		if (first && si->inuse_pages / 98 * 100 > si->pages) {
+			spin_lock(&swap_avail_lock);
+			spin_unlock(&si->lock);
+			goto nextsi;
+		}
 		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
 			spin_lock(&swap_avail_lock);
 			if (plist_node_empty(&si->avail_list)) {
@@ -692,6 +699,10 @@ nextsi:
 		if (plist_node_empty(&next->avail_list))
 			goto start_over;
 	}
+	if (first) {
+		first = false;
+		goto start_over;
+	}
 
 	spin_unlock(&swap_avail_lock);
 
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
