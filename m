Date: Tue, 25 Nov 2008 21:39:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/9] swapfile: remove v0 SWAP-SPACE message
In-Reply-To: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
Message-ID: <Pine.LNX.4.64.0811252137590.17555@blonde.site>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel has not supported v0 SWAP-SPACE since 2.5.22: I think we can now
safely drop its "version 0 swap is no longer supported" message - just say
"Unable to find swap-space signature" as usual.  This removes one level of
indentation from a stretch of sys_swapon().

I'd have liked to be specific, saying "Unable to find SWAPSPACE2 signature",
but it's just too confusing that the version 1 signature shows the number 2.

Irrelevant nearby cleanup: kmap(page) already gives page_address(page).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
This reindentation clashes with memcg-swap-cgroup-for-remembering-usage.patch
See the [PATCH 0/9] message for two hunks to replace its final hunk.

 mm/swapfile.c |  146 +++++++++++++++++++++---------------------------
 1 file changed, 65 insertions(+), 81 deletions(-)

--- swapfile3/mm/swapfile.c	2008-11-25 12:41:24.000000000 +0000
+++ swapfile4/mm/swapfile.c	2008-11-25 12:41:26.000000000 +0000
@@ -1447,7 +1447,6 @@ asmlinkage long sys_swapon(const char __
 	int i, prev;
 	int error;
 	union swap_header *swap_header = NULL;
-	int swap_header_version;
 	unsigned int nr_good_pages = 0;
 	int nr_extents = 0;
 	sector_t span;
@@ -1544,101 +1543,86 @@ asmlinkage long sys_swapon(const char __
 		error = PTR_ERR(page);
 		goto bad_swap;
 	}
-	kmap(page);
-	swap_header = page_address(page);
+	swap_header = kmap(page);
 
-	if (!memcmp("SWAP-SPACE",swap_header->magic.magic,10))
-		swap_header_version = 1;
-	else if (!memcmp("SWAPSPACE2",swap_header->magic.magic,10))
-		swap_header_version = 2;
-	else {
+	if (memcmp("SWAPSPACE2", swap_header->magic.magic, 10)) {
 		printk(KERN_ERR "Unable to find swap-space signature\n");
 		error = -EINVAL;
 		goto bad_swap;
 	}
 
-	switch (swap_header_version) {
-	case 1:
-		printk(KERN_ERR "version 0 swap is no longer supported. "
-			"Use mkswap -v1 %s\n", name);
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
 		error = -EINVAL;
 		goto bad_swap;
-	case 2:
-		/* swap partition endianess hack... */
-		if (swab32(swap_header->info.version) == 1) {
-			swab32s(&swap_header->info.version);
-			swab32s(&swap_header->info.last_page);
-			swab32s(&swap_header->info.nr_badpages);
-			for (i = 0; i < swap_header->info.nr_badpages; i++)
-				swab32s(&swap_header->info.badpages[i]);
-		}
-		/* Check the swap header's sub-version and the size of
-                   the swap file and bad block lists */
-		if (swap_header->info.version != 1) {
-			printk(KERN_WARNING
-			       "Unable to handle swap header version %d\n",
-			       swap_header->info.version);
-			error = -EINVAL;
-			goto bad_swap;
-		}
+	}
 
-		p->lowest_bit  = 1;
-		p->cluster_next = 1;
+	p->lowest_bit  = 1;
+	p->cluster_next = 1;
 
-		/*
-		 * Find out how many pages are allowed for a single swap
-		 * device. There are two limiting factors: 1) the number of
-		 * bits for the swap offset in the swp_entry_t type and
-		 * 2) the number of bits in the a swap pte as defined by
-		 * the different architectures. In order to find the
-		 * largest possible bit mask a swap entry with swap type 0
-		 * and swap offset ~0UL is created, encoded to a swap pte,
-		 * decoded to a swp_entry_t again and finally the swap
-		 * offset is extracted. This will mask all the bits from
-		 * the initial ~0UL mask that can't be encoded in either
-		 * the swp_entry_t or the architecture definition of a
-		 * swap pte.
-		 */
-		maxpages = swp_offset(pte_to_swp_entry(swp_entry_to_pte(swp_entry(0,~0UL)))) - 1;
-		if (maxpages > swap_header->info.last_page)
-			maxpages = swap_header->info.last_page;
-		p->highest_bit = maxpages - 1;
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
+			swp_entry_to_pte(swp_entry(0, ~0UL)))) - 1;
+	if (maxpages > swap_header->info.last_page)
+		maxpages = swap_header->info.last_page;
+	p->highest_bit = maxpages - 1;
 
-		error = -EINVAL;
-		if (!maxpages)
-			goto bad_swap;
-		if (swapfilepages && maxpages > swapfilepages) {
-			printk(KERN_WARNING
-			       "Swap area shorter than signature indicates\n");
-			goto bad_swap;
-		}
-		if (swap_header->info.nr_badpages && S_ISREG(inode->i_mode))
-			goto bad_swap;
-		if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
-			goto bad_swap;
+	error = -EINVAL;
+	if (!maxpages)
+		goto bad_swap;
+	if (swapfilepages && maxpages > swapfilepages) {
+		printk(KERN_WARNING
+		       "Swap area shorter than signature indicates\n");
+		goto bad_swap;
+	}
+	if (swap_header->info.nr_badpages && S_ISREG(inode->i_mode))
+		goto bad_swap;
+	if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
+		goto bad_swap;
 
-		/* OK, set up the swap map and apply the bad block list */
-		swap_map = vmalloc(maxpages * sizeof(short));
-		if (!swap_map) {
-			error = -ENOMEM;
-			goto bad_swap;
-		}
+	/* OK, set up the swap map and apply the bad block list */
+	swap_map = vmalloc(maxpages * sizeof(short));
+	if (!swap_map) {
+		error = -ENOMEM;
+		goto bad_swap;
+	}
 
-		error = 0;
-		memset(swap_map, 0, maxpages * sizeof(short));
-		for (i = 0; i < swap_header->info.nr_badpages; i++) {
-			int page_nr = swap_header->info.badpages[i];
-			if (page_nr <= 0 || page_nr >= swap_header->info.last_page)
-				error = -EINVAL;
-			else
-				swap_map[page_nr] = SWAP_MAP_BAD;
-		}
-		nr_good_pages = swap_header->info.last_page -
-				swap_header->info.nr_badpages -
-				1 /* header page */;
-		if (error)
+	memset(swap_map, 0, maxpages * sizeof(short));
+	for (i = 0; i < swap_header->info.nr_badpages; i++) {
+		int page_nr = swap_header->info.badpages[i];
+		if (page_nr <= 0 || page_nr >= swap_header->info.last_page) {
+			error = -EINVAL;
 			goto bad_swap;
+		}
+		swap_map[page_nr] = SWAP_MAP_BAD;
 	}
+	nr_good_pages = swap_header->info.last_page -
+			swap_header->info.nr_badpages -
+			1 /* header page */;
 
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
