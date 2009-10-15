Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0D5B76B0055
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:58:53 -0400 (EDT)
Date: Thu, 15 Oct 2009 01:58:51 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 9/9] swap_info: reorder its fields
In-Reply-To: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910150157310.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Reorder (and comment) the fields of swap_info_struct, to make better
use of its cachelines: it's good for swap_duplicate() in particular
if unsigned int max and swap_map are near the start.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/swap.h |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

--- si8/include/linux/swap.h	2009-10-14 21:27:07.000000000 +0100
+++ si9/include/linux/swap.h	2009-10-14 21:27:14.000000000 +0100
@@ -167,21 +167,21 @@ struct swap_info_struct {
 	signed short	prio;		/* swap priority of this type */
 	signed char	type;		/* strange name for an index */
 	signed char	next;		/* next type on the swap list */
-	struct file *swap_file;
-	struct block_device *bdev;
-	struct swap_extent first_swap_extent;
-	struct swap_extent *curr_swap_extent;
-	unsigned char *swap_map;
-	unsigned int lowest_bit;
-	unsigned int highest_bit;
+	unsigned int	max;		/* extent of the swap_map */
+	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
+	unsigned int lowest_bit;	/* index of first free in swap_map */
+	unsigned int highest_bit;	/* index of last free in swap_map */
+	unsigned int pages;		/* total of usable pages of swap */
+	unsigned int inuse_pages;	/* number of those currently in use */
+	unsigned int cluster_next;	/* likely index for next allocation */
+	unsigned int cluster_nr;	/* countdown to next cluster search */
 	unsigned int lowest_alloc;	/* while preparing discard cluster */
 	unsigned int highest_alloc;	/* while preparing discard cluster */
-	unsigned int cluster_next;
-	unsigned int cluster_nr;
-	unsigned int pages;
-	unsigned int max;
-	unsigned int inuse_pages;
-	unsigned int old_block_size;
+	struct swap_extent *curr_swap_extent;
+	struct swap_extent first_swap_extent;
+	struct block_device *bdev;	/* swap device or bdev of swap file */
+	struct file *swap_file;		/* seldom referenced */
+	unsigned int old_block_size;	/* seldom referenced */
 };
 
 struct swap_list_t {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
