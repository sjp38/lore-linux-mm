Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EDD048D004B
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:48 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:45 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 16/24] sys_swapon: separate parsing of swapfile header
Date: Sat, 12 Feb 2011 16:49:17 -0200
Message-Id: <1297536565-8059-16-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Move the code which parses and checks the swapfile header (except for
the bad block list) to a separate function. Only code movement, no
functional changes.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |  140 ++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 78 insertions(+), 62 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 60c7784..314fb21 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1918,6 +1918,82 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 	return 0;
 }
 
+static unsigned long read_swap_header(struct swap_info_struct *p,
+					union swap_header *swap_header,
+					struct inode *inode)
+{
+	int i;
+	unsigned long maxpages;
+	unsigned long swapfilepages;
+
+	if (memcmp("SWAPSPACE2", swap_header->magic.magic, 10)) {
+		printk(KERN_ERR "Unable to find swap-space signature\n");
+		goto bad_swap;
+	}
+
+	/* swap partition endianess hack... */
+	if (swab32(swap_header->info.version) == 1) {
+		swab32s(&swap_header->info.version);
+		swab32s(&swap_header->info.last_page);
+		swab32s(&swap_header->info.nr_badpages);
+		for (i = 0; i < swap_header->info.nr_badpages; i++)
+			swab32s(&swap_header->info.badpages[i]);
+	}
+	/* Check the swap header's sub-version */
+	if (swap_header->info.version != 1) {
+		printk(KERN_WARNING
+		       "Unable to handle swap header version %d\n",
+		       swap_header->info.version);
+		goto bad_swap;
+	}
+
+	p->lowest_bit  = 1;
+	p->cluster_next = 1;
+	p->cluster_nr = 0;
+
+	/*
+	 * Find out how many pages are allowed for a single swap
+	 * device. There are two limiting factors: 1) the number of
+	 * bits for the swap offset in the swp_entry_t type and
+	 * 2) the number of bits in the a swap pte as defined by
+	 * the different architectures. In order to find the
+	 * largest possible bit mask a swap entry with swap type 0
+	 * and swap offset ~0UL is created, encoded to a swap pte,
+	 * decoded to a swp_entry_t again and finally the swap
+	 * offset is extracted. This will mask all the bits from
+	 * the initial ~0UL mask that can't be encoded in either
+	 * the swp_entry_t or the architecture definition of a
+	 * swap pte.
+	 */
+	maxpages = swp_offset(pte_to_swp_entry(
+			swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
+	if (maxpages > swap_header->info.last_page) {
+		maxpages = swap_header->info.last_page + 1;
+		/* p->max is an unsigned int: don't overflow it */
+		if ((unsigned int)maxpages == 0)
+			maxpages = UINT_MAX;
+	}
+	p->highest_bit = maxpages - 1;
+
+	if (!maxpages)
+		goto bad_swap;
+	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
+	if (swapfilepages && maxpages > swapfilepages) {
+		printk(KERN_WARNING
+		       "Swap area shorter than signature indicates\n");
+		goto bad_swap;
+	}
+	if (swap_header->info.nr_badpages && S_ISREG(inode->i_mode))
+		goto bad_swap;
+	if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
+		goto bad_swap;
+
+	return maxpages;
+
+bad_swap:
+	return 0;
+}
+
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
@@ -1931,7 +2007,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	int nr_extents = 0;
 	sector_t span;
 	unsigned long maxpages;
-	unsigned long swapfilepages;
 	unsigned char *swap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
@@ -1989,71 +2064,12 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	swap_header = kmap(page);
 
-	if (memcmp("SWAPSPACE2", swap_header->magic.magic, 10)) {
-		printk(KERN_ERR "Unable to find swap-space signature\n");
+	maxpages = read_swap_header(p, swap_header, inode);
+	if (unlikely(!maxpages)) {
 		error = -EINVAL;
 		goto bad_swap;
 	}
 
-	/* swap partition endianess hack... */
-	if (swab32(swap_header->info.version) == 1) {
-		swab32s(&swap_header->info.version);
-		swab32s(&swap_header->info.last_page);
-		swab32s(&swap_header->info.nr_badpages);
-		for (i = 0; i < swap_header->info.nr_badpages; i++)
-			swab32s(&swap_header->info.badpages[i]);
-	}
-	/* Check the swap header's sub-version */
-	if (swap_header->info.version != 1) {
-		printk(KERN_WARNING
-		       "Unable to handle swap header version %d\n",
-		       swap_header->info.version);
-		error = -EINVAL;
-		goto bad_swap;
-	}
-
-	p->lowest_bit  = 1;
-	p->cluster_next = 1;
-	p->cluster_nr = 0;
-
-	/*
-	 * Find out how many pages are allowed for a single swap
-	 * device. There are two limiting factors: 1) the number of
-	 * bits for the swap offset in the swp_entry_t type and
-	 * 2) the number of bits in the a swap pte as defined by
-	 * the different architectures. In order to find the
-	 * largest possible bit mask a swap entry with swap type 0
-	 * and swap offset ~0UL is created, encoded to a swap pte,
-	 * decoded to a swp_entry_t again and finally the swap
-	 * offset is extracted. This will mask all the bits from
-	 * the initial ~0UL mask that can't be encoded in either
-	 * the swp_entry_t or the architecture definition of a
-	 * swap pte.
-	 */
-	maxpages = swp_offset(pte_to_swp_entry(
-			swp_entry_to_pte(swp_entry(0, ~0UL)))) + 1;
-	if (maxpages > swap_header->info.last_page) {
-		maxpages = swap_header->info.last_page + 1;
-		/* p->max is an unsigned int: don't overflow it */
-		if ((unsigned int)maxpages == 0)
-			maxpages = UINT_MAX;
-	}
-	p->highest_bit = maxpages - 1;
-
-	error = -EINVAL;
-	if (!maxpages)
-		goto bad_swap;
-	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
-	if (swapfilepages && maxpages > swapfilepages) {
-		printk(KERN_WARNING
-		       "Swap area shorter than signature indicates\n");
-		goto bad_swap;
-	}
-	if (swap_header->info.nr_badpages && S_ISREG(inode->i_mode))
-		goto bad_swap;
-	if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
-		goto bad_swap;
-
 	/* OK, set up the swap map and apply the bad block list */
 	swap_map = vzalloc(maxpages);
 	if (!swap_map) {
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
