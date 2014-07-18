Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E5C1F6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:48:33 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so5251446pdb.38
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:48:33 -0700 (PDT)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id nl15si3201185pdb.117.2014.07.18.08.48.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jul 2014 08:48:32 -0700 (PDT)
From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH] mm: vmscan: unlock_page page when forcing reclaim
Date: Fri, 18 Jul 2014 11:48:02 -0400
Message-Id: <1405698484-25803-1-git-send-email-ryao@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mthode@mthode.org, kernel@gentoo.org, Richard Yao <ryao@gentoo.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>, Rik van Riel <riel@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

A small userland program I wrote to assist me in drive forensic
operations soft deadlocked on Linux 3.14.4. The stack trace from /proc
was:

[<ffffffff8112968e>] sleep_on_page_killable+0xe/0x40
[<ffffffff81129829>] wait_on_page_bit_killable+0x79/0x80
[<ffffffff811299a5>] __lock_page_or_retry+0x95/0xc0
[<ffffffff8112a95b>] filemap_fault+0x21b/0x420
[<ffffffff8115685e>] __do_fault+0x6e/0x520
[<ffffffff81156de3>] handle_pte_fault+0xd3/0x1f0
[<ffffffff81157073>] __handle_mm_fault+0x173/0x290
[<ffffffff811571d2>] handle_mm_fault+0x42/0xb0
[<ffffffff81587a11>] __do_page_fault+0x191/0x490
[<ffffffff81587dec>] do_page_fault+0xc/0x10
[<ffffffff81584622>] page_fault+0x22/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

The program used mmap() to do a linear scan of the device on 64-bit
hardware. The block device in question was 200GB in size and the system
had only 8GB of RAM. All IO operations stopped following pageout.

shrink_page_list() seemed to have raced with filemap_fault() by evicting
a page when we had an active fault handler. This is possible only
because 02c6de8d757cb32c0829a45d81c3dfcbcafd998b altered the behavior of
shrink_page_list() to ignore references. Consequently, we must call
unlock_page() instead of __clear_page_locked() when doing this so that
waiters are notified. unlock_page() here will cause active page fault
handlers to retry (depending on the architecture), which avoids the soft
deadlock.

Signed-off-by: Richard Yao <ryao@gentoo.org>
---
 mm/vmscan.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f56c8d..c07c635 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1083,13 +1083,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep_locked;
 
 		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
+		 * Unless we force reclaim, we have no other references and
+		 * there is no way to pick any more up (removed from LRU,
+		 * removed from pagecache). Can use non-atomic bitops now (and
 		 * we obviously don't have to worry about waking up a process
 		 * waiting on the page lock, because there are no references.
 		 */
-		__clear_page_locked(page);
+		if (force_reclaim)
+			unlock_page(page);
+		else
+			__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
