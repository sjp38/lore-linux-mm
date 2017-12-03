Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6013F6B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 20:45:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g202so5857420ita.4
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 17:45:26 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c65si256970itg.125.2017.12.02.17.45.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Dec 2017 17:45:24 -0800 (PST)
Subject: Re: [PATCH v18 05/10] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
	<201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
	<201711302235.FAJ57385.OFJHOVQOFtMSFL@I-love.SAKURA.ne.jp>
	<20171130143952.GB12684@bombadil.infradead.org>
In-Reply-To: <20171130143952.GB12684@bombadil.infradead.org>
Message-Id: <201712031044.AJJ00592.VHOStQLMOFJFFO@I-love.SAKURA.ne.jp>
Date: Sun, 3 Dec 2017 10:44:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> On Thu, Nov 30, 2017 at 10:35:03PM +0900, Tetsuo Handa wrote:
> > According to xb_set_bit(), it seems to me that we are trying to avoid memory allocation
> > for "struct ida_bitmap" when all set bits within a 1024-bits bitmap reside in the first
> > 61 bits.
> > 
> > But does such saving help? Is there characteristic bias that majority of set bits resides
> > in the first 61 bits, for "bit" is "unsigned long" which holds a page number (isn't it)?
> > If no such bias, wouldn't eliminating radix_tree_exception() case and always storing
> > "struct ida_bitmap" simplifies the code (and make the processing faster)?
> 
> It happens all the time.  The vast majority of users of the IDA set
> low bits.  Also, it's the first 62 bits -- going up to 63 bits with the
> XArray rewrite.

Oops, 0...61 is 62 bits.

What I meant is below (untested) patch. If correct, it can save lines and make
the code easier to read.

 lib/radix-tree.c | 20 +------------
 lib/xbitmap.c    | 88 +++++---------------------------------------------------
 2 files changed, 8 insertions(+), 100 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a039588..fb84b91 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2152,25 +2152,7 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
  */
 __must_check bool xb_preload(gfp_t gfp)
 {
-	if (!this_cpu_read(ida_bitmap)) {
-		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
-
-		if (!bitmap)
-			return false;
-		/*
-		 * The per-CPU variable is updated with preemption enabled.
-		 * If the calling task is unlucky to be scheduled to another
-		 * CPU which has no ida_bitmap allocation, it will be detected
-		 * when setting a bit (i.e. __xb_set_bit()).
-		 */
-		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
-		kfree(bitmap);
-	}
-
-	if (__radix_tree_preload(gfp, XB_PRELOAD_SIZE) < 0)
-		return false;
-
-	return true;
+	return __radix_tree_preload(gfp, XB_PRELOAD_SIZE) == 0;
 }
 EXPORT_SYMBOL(xb_preload);
 
diff --git a/lib/xbitmap.c b/lib/xbitmap.c
index 816dd3e..426d168 100644
--- a/lib/xbitmap.c
+++ b/lib/xbitmap.c
@@ -18,7 +18,7 @@
  * This function is used to set a bit in the xbitmap. If the bitmap that @bit
  * resides in is not there, the per-cpu ida_bitmap will be taken.
  *
- * Returns: 0 on success. %-EAGAIN indicates that @bit was not set.
+ * Returns: 0 on success. Negative value on failure.
  */
 int xb_set_bit(struct xb *xb, unsigned long bit)
 {
@@ -28,46 +28,19 @@ int xb_set_bit(struct xb *xb, unsigned long bit)
 	struct radix_tree_node *node;
 	void **slot;
 	struct ida_bitmap *bitmap;
-	unsigned long ebit;
 
 	bit %= IDA_BITMAP_BITS;
-	ebit = bit + 2;
 
 	err = __radix_tree_create(root, index, 0, &node, &slot);
 	if (err)
 		return err;
 	bitmap = rcu_dereference_raw(*slot);
-	if (radix_tree_exception(bitmap)) {
-		unsigned long tmp = (unsigned long)bitmap;
-
-		if (ebit < BITS_PER_LONG) {
-			tmp |= 1UL << ebit;
-			rcu_assign_pointer(*slot, (void *)tmp);
-			return 0;
-		}
-		bitmap = this_cpu_xchg(ida_bitmap, NULL);
-		if (!bitmap) {
-			__radix_tree_delete(root, node, slot);
-			return -EAGAIN;
-		}
-		memset(bitmap, 0, sizeof(*bitmap));
-		bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
-		rcu_assign_pointer(*slot, bitmap);
-	}
-
 	if (!bitmap) {
-		if (ebit < BITS_PER_LONG) {
-			bitmap = (void *)((1UL << ebit) |
-					RADIX_TREE_EXCEPTIONAL_ENTRY);
-			__radix_tree_replace(root, node, slot, bitmap, NULL);
-			return 0;
-		}
-		bitmap = this_cpu_xchg(ida_bitmap, NULL);
+		bitmap = kzalloc(sizeof(*bitmap), GFP_NOWAIT | __GFP_NOWARN);
 		if (!bitmap) {
 			__radix_tree_delete(root, node, slot);
-			return -EAGAIN;
+			return -ENOMEM;
 		}
-		memset(bitmap, 0, sizeof(*bitmap));
 		__radix_tree_replace(root, node, slot, bitmap, NULL);
 	}
 
@@ -82,7 +55,7 @@ int xb_set_bit(struct xb *xb, unsigned long bit)
  *  @bit: index of the bit to set
  *
  * A wrapper of the xb_preload() and xb_set_bit().
- * Returns: 0 on success; -EAGAIN or -ENOMEM on error.
+ * Returns: 0 on success; -ENOMEM on error.
  */
 int xb_preload_and_set_bit(struct xb *xb, unsigned long bit, gfp_t gfp)
 {
@@ -113,25 +86,10 @@ void xb_clear_bit(struct xb *xb, unsigned long bit)
 	struct radix_tree_node *node;
 	void **slot;
 	struct ida_bitmap *bitmap;
-	unsigned long ebit;
 
 	bit %= IDA_BITMAP_BITS;
-	ebit = bit + 2;
 
 	bitmap = __radix_tree_lookup(root, index, &node, &slot);
-	if (radix_tree_exception(bitmap)) {
-		unsigned long tmp = (unsigned long)bitmap;
-
-		if (ebit >= BITS_PER_LONG)
-			return;
-		tmp &= ~(1UL << ebit);
-		if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
-			__radix_tree_delete(root, node, slot);
-		else
-			rcu_assign_pointer(*slot, (void *)tmp);
-		return;
-	}
-
 	if (!bitmap)
 		return;
 
@@ -164,20 +122,7 @@ void xb_clear_bit_range(struct xb *xb, unsigned long start, unsigned long end)
 		unsigned long bit = start % IDA_BITMAP_BITS;
 
 		bitmap = __radix_tree_lookup(root, index, &node, &slot);
-		if (radix_tree_exception(bitmap)) {
-			unsigned long ebit = bit + 2;
-			unsigned long tmp = (unsigned long)bitmap;
-
-			nbits = min(end - start + 1, BITS_PER_LONG - ebit);
-
-			if (ebit >= BITS_PER_LONG)
-				continue;
-			bitmap_clear(&tmp, ebit, nbits);
-			if (tmp == RADIX_TREE_EXCEPTIONAL_ENTRY)
-				__radix_tree_delete(root, node, slot);
-			else
-				rcu_assign_pointer(*slot, (void *)tmp);
-		} else if (bitmap) {
+		if (bitmap) {
 			nbits = min(end - start + 1, IDA_BITMAP_BITS - bit);
 
 			if (nbits != IDA_BITMAP_BITS)
@@ -212,12 +157,6 @@ bool xb_test_bit(const struct xb *xb, unsigned long bit)
 
 	if (!bitmap)
 		return false;
-	if (radix_tree_exception(bitmap)) {
-		bit += RADIX_TREE_EXCEPTIONAL_SHIFT;
-		if (bit >= BITS_PER_LONG)
-			return false;
-		return (unsigned long)bitmap & (1UL << bit);
-	}
 	return test_bit(bit, bitmap->bitmap);
 }
 EXPORT_SYMBOL(xb_test_bit);
@@ -236,20 +175,7 @@ static unsigned long xb_find_next_bit(struct xb *xb, unsigned long start,
 		unsigned long bit = start % IDA_BITMAP_BITS;
 
 		bmap = __radix_tree_lookup(root, index, &node, &slot);
-		if (radix_tree_exception(bmap)) {
-			unsigned long tmp = (unsigned long)bmap;
-			unsigned long ebit = bit + 2;
-
-			if (ebit >= BITS_PER_LONG)
-				continue;
-			if (set)
-				ret = find_next_bit(&tmp, BITS_PER_LONG, ebit);
-			else
-				ret = find_next_zero_bit(&tmp, BITS_PER_LONG,
-							 ebit);
-			if (ret < BITS_PER_LONG)
-				return ret - 2 + IDA_BITMAP_BITS * index;
-		} else if (bmap) {
+		if (bmap) {
 			if (set)
 				ret = find_next_bit(bmap->bitmap,
 						    IDA_BITMAP_BITS, bit);
@@ -258,7 +184,7 @@ static unsigned long xb_find_next_bit(struct xb *xb, unsigned long start,
 							 IDA_BITMAP_BITS, bit);
 			if (ret < IDA_BITMAP_BITS)
 				return ret + index * IDA_BITMAP_BITS;
-		} else if (!bmap && !set) {
+		} else if (!set) {
 			return start;
 		}
 	}
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
