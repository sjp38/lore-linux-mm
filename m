Date: Thu, 27 Jan 2005 13:11:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] ext2: Apply Jack's ext3 speedups
Message-Id: <20050127131158.126f0f09.akpm@osdl.org>
In-Reply-To: <20050127205233.GB9225@thunk.org>
References: <200501270722.XAA10830@allur.sanmateo.akamai.com>
	<20050127205233.GB9225@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: pmeda@akamai.com, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Theodore Ts'o" <tytso@mit.edu> wrote:
>
> On Wed, Jan 26, 2005 at 11:22:39PM -0800, pmeda@akamai.com wrote:
> > 
> > Apply ext3 speedups added by Jan Kara to ext2.
> > Reference: http://linus.bkbits.net:8080/linux-2.5/gnupatch@41f127f2jwYahmKm0eWTJNpYcSyhPw
> > 
> 
> This patch isn't right, as it causes ext2_sparse_group(1) to return 0
> instead of 1.  Block groups number 0 and 1 must always contain a
> superblock.

I'd already queued up the below actually.  It seems to get things right?


From: Matthew Wilcox <matthew@wil.cx>

Port Andreas Dilger's and Jan Kara's patch for ext3 to ext2.  Also some
whitespace changes to get ext2/ext3 closer in sync.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/fs/ext2/balloc.c |   39 +++++++++++++++++++--------------------
 1 files changed, 19 insertions(+), 20 deletions(-)

diff -puN fs/ext2/balloc.c~minor-ext2-speedup fs/ext2/balloc.c
--- 25/fs/ext2/balloc.c~minor-ext2-speedup	2005-01-25 13:50:20.000000000 -0800
+++ 25-akpm/fs/ext2/balloc.c	2005-01-25 13:50:20.000000000 -0800
@@ -6,7 +6,7 @@
  * Laboratoire MASI - Institut Blaise Pascal
  * Universite Pierre et Marie Curie (Paris VI)
  *
- *  Enhanced block allocation by Stephen Tweedie (sct@dcs.ed.ac.uk), 1993
+ *  Enhanced block allocation by Stephen Tweedie (sct@redhat.com), 1993
  *  Big-endian to little-endian byte-swapping/bitmaps by
  *        David S. Miller (davem@caip.rutgers.edu), 1995
  */
@@ -52,9 +52,9 @@ struct ext2_group_desc * ext2_get_group_
 
 		return NULL;
 	}
-	
-	group_desc = block_group / EXT2_DESC_PER_BLOCK(sb);
-	offset = block_group % EXT2_DESC_PER_BLOCK(sb);
+
+	group_desc = block_group >> EXT2_DESC_PER_BLOCK_BITS(sb);
+	offset = block_group & (EXT2_DESC_PER_BLOCK(sb) - 1);
 	if (!sbi->s_group_desc[group_desc]) {
 		ext2_error (sb, "ext2_get_group_desc",
 			    "Group descriptor not loaded - "
@@ -62,7 +62,7 @@ struct ext2_group_desc * ext2_get_group_
 			     block_group, group_desc, offset);
 		return NULL;
 	}
-	
+
 	desc = (struct ext2_group_desc *) sbi->s_group_desc[group_desc]->b_data;
 	if (bh)
 		*bh = sbi->s_group_desc[group_desc];
@@ -236,12 +236,12 @@ do_more:
 
 	for (i = 0, group_freed = 0; i < count; i++) {
 		if (!ext2_clear_bit_atomic(sb_bgl_lock(sbi, block_group),
-					bit + i, (void *) bitmap_bh->b_data))
-			ext2_error (sb, "ext2_free_blocks",
-				      "bit already cleared for block %lu",
-				      block + i);
-		else
+						bit + i, bitmap_bh->b_data)) {
+			ext2_error(sb, __FUNCTION__,
+				"bit already cleared for block %lu", block + i);
+		} else {
 			group_freed++;
+		}
 	}
 
 	mark_buffer_dirty(bitmap_bh);
@@ -569,25 +569,24 @@ unsigned long ext2_count_free_blocks (st
 static inline int
 block_in_use(unsigned long block, struct super_block *sb, unsigned char *map)
 {
-	return ext2_test_bit ((block - le32_to_cpu(EXT2_SB(sb)->s_es->s_first_data_block)) %
+	return ext2_test_bit ((block -
+		le32_to_cpu(EXT2_SB(sb)->s_es->s_first_data_block)) %
 			 EXT2_BLOCKS_PER_GROUP(sb), map);
 }
 
 static inline int test_root(int a, int b)
 {
-	if (a == 0)
-		return 1;
-	while (1) {
-		if (a == 1)
-			return 1;
-		if (a % b)
-			return 0;
-		a = a / b;
-	}
+	int num = b;
+
+	while (a > num)
+		num *= b;
+	return num == a;
 }
 
 static int ext2_group_sparse(int group)
 {
+	if (group <= 1)
+		return 1;
 	return (test_root(group, 3) || test_root(group, 5) ||
 		test_root(group, 7));
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
