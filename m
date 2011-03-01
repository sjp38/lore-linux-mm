Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0029B8D003E
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:03 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 20/24] sys_swapon: simplify error flow in setup_swap_map_and_extents
Date: Tue,  1 Mar 2011 20:28:44 -0300
Message-Id: <1299022128-6239-21-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

Since there is no cleanup to do, there is no reason to jump to a label.
Return directly instead.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 26eb84a..5f6df81 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1998,7 +1998,6 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 					sector_t *span)
 {
 	int i;
-	int error;
 	unsigned int nr_good_pages;
 	int nr_extents;
 
@@ -2006,10 +2005,8 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
 		unsigned int page_nr = swap_header->info.badpages[i];
-		if (page_nr == 0 || page_nr > swap_header->info.last_page) {
-			error = -EINVAL;
-			goto bad_swap;
-		}
+		if (page_nr == 0 || page_nr > swap_header->info.last_page)
+			return -EINVAL;
 		if (page_nr < maxpages) {
 			swap_map[page_nr] = SWAP_MAP_BAD;
 			nr_good_pages--;
@@ -2021,22 +2018,16 @@ static int setup_swap_map_and_extents(struct swap_info_struct *p,
 		p->max = maxpages;
 		p->pages = nr_good_pages;
 		nr_extents = setup_swap_extents(p, span);
-		if (nr_extents < 0) {
-			error = nr_extents;
-			goto bad_swap;
-		}
+		if (nr_extents < 0)
+			return nr_extents;
 		nr_good_pages = p->pages;
 	}
 	if (!nr_good_pages) {
 		printk(KERN_WARNING "Empty swap-file\n");
-		error = -EINVAL;
-		goto bad_swap;
+		return -EINVAL;
 	}
 
 	return nr_extents;
-
-bad_swap:
-	return error;
 }
 
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
