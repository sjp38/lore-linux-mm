Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 82E6B8D004F
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:49 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:46 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 21/24] sys_swapon: remove nr_good_pages variable
Date: Sat, 12 Feb 2011 16:49:22 -0200
Message-Id: <1297536565-8059-21-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

It still exists within setup_swap_map_and_extents(), but after it
nr_good_pages == p->pages.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d2404ca..5ec7183 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2039,7 +2039,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	int i, prev;
 	int error;
 	union swap_header *swap_header;
-	unsigned int nr_good_pages;
 	int nr_extents;
 	sector_t span;
 	unsigned long maxpages;
@@ -2123,7 +2122,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = nr_extents;
 		goto bad_swap;
 	}
-	nr_good_pages = p->pages;
 
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
@@ -2143,12 +2141,12 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
 	p->flags |= SWP_WRITEOK;
-	nr_swap_pages += nr_good_pages;
-	total_swap_pages += nr_good_pages;
+	nr_swap_pages += p->pages;
+	total_swap_pages += p->pages;
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
 			"Priority:%d extents:%d across:%lluk %s%s\n",
-		nr_good_pages<<(PAGE_SHIFT-10), name, p->prio,
+		p->pages<<(PAGE_SHIFT-10), name, p->prio,
 		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
 		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
 		(p->flags & SWP_DISCARDABLE) ? "D" : "");
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
