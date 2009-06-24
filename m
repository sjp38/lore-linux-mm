Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B661B6B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 06:37:19 -0400 (EDT)
Subject: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: multipart/mixed; boundary="=-PTGv1Eia2d/totL+bhpG"
Date: Wed, 24 Jun 2009 11:38:24 +0100
Message-Id: <1245839904.3210.85.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, "a.p.zijlstra" <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--=-PTGv1Eia2d/totL+bhpG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

When writing to 2 (or more) devices at the same time, stop
balance_dirty_pages moving dirty pages to writeback when it has reached
the bdi threshold. This prevents balance_dirty_pages overshooting its
limits and moving all dirty pages to writeback.     

    
Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
---
balance_dirty_pages can overreact and move all of the dirty pages to
writeback unnecessarily.

balance_dirty_pages makes its decision to throttle based on the number
of dirty plus writeback pages that are over the calculated limit,so it
will continue to move pages even when there are plenty of pages in
writeback and less than the threshold still dirty.

This allows it to overshoot its limits and move all the dirty pages to
writeback while waiting for the drives to catch up and empty the
writeback list. 

A simple fio test easily demonstrates this problem.  

fio --name=f1 --directory=/disk1 --size=2G -rw=write
	--name=f2 --directory=/disk2 --size=1G --rw=write 		--startdelay=10

The attached graph before.png shows how all pages are moved to writeback
as the second write starts and the throttling kicks in.

after.png is the same test with the patch applied, which clearly shows
that it keeps dirty_background_ratio dirty pages in the buffer.
The values and timings of the graphs are only approximate but are good
enough to show the behaviour.  

This is the simplest fix I could find, but I'm not entirely sure that it
alone will be enough for all cases. But it certainly is an improvement
on my desktop machine writing to 2 disks.

Do we need something more for machines with large arrays where
bdi_threshold * number_of_drives is greater than the dirty_ratio ?

regards
Richard


This patch against 2.6.30 git latest, built and tested on x86_64. 

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7b0dcea..7687879 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -541,8 +541,11 @@ static void balance_dirty_pages(struct address_space *mapping)
 		 * filesystems (i.e. NFS) in which data may have been
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
+		 * Only move pages to writeback if this bdi is over its
+		 * threshold otherwise wait until the disk writes catch
+		 * up.
 		 */
-		if (bdi_nr_reclaimable) {
+		if (bdi_nr_reclaimable > bdi_thresh) {
 			writeback_inodes(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,


--=-PTGv1Eia2d/totL+bhpG
Content-Disposition: attachment; filename="before.png"
Content-Type: image/png; name="before.png"
Content-Transfer-Encoding: base64

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


--=-PTGv1Eia2d/totL+bhpG
Content-Disposition: attachment; filename="after.png"
Content-Type: image/png; name="after.png"
Content-Transfer-Encoding: base64

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
lEf+By3xl1WJPMexAAAAAElFTkSuQmCC


--=-PTGv1Eia2d/totL+bhpG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
