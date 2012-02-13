Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 49BA76B13F4
	for <linux-mm@kvack.org>; Sun, 12 Feb 2012 19:49:24 -0500 (EST)
Date: Mon, 13 Feb 2012 01:48:15 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v5 1/3] kinterval: routines to manipulate generic
 intervals
Message-ID: <20120213004815.GA2052@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-2-git-send-email-andrea@betterlinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1329006098-5454-2-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sun, Feb 12, 2012 at 01:21:36AM +0100, Andrea Righi wrote:
> Add a generic infrastructure to efficiently keep track of intervals.
> 
> An interval is represented by a triplet (start, end, type). The values
> (start, end) define the bounds of the range. The type is a generic
> property associated to the interval. The interpretation of the type is
> left to the user.
> 
> Multiple intervals associated to the same object are stored in an
> interval tree (augmented rbtree) [1], with tree ordered on starting
> address. The tree cannot contain multiple entries of different
> interval types which overlap; in case of overlapping intervals new
> inserted intervals overwrite the old ones (completely or in part, in the
> second case the old interval is shrunk or split accordingly).
> 
> Reference:
>  [1] "Introduction to Algorithms" by Cormen, Leiserson, Rivest and Stein
> 
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> ---

For those who are interested, I've an extra patch for this part (must be
applied on top of the previous one): there's a bug fix and some
improvements.

I'll include the following fix in the next version of the
POSIX_FADV_NOREUSE patch set (sorry for this, but the whole patch set is
still totally experimental, especially the kinterval part, I also plan
to add a proper documentation and a sample test case in the samples/ dir
if we think it'll be useful).

Thanks,
-Andrea

---
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH] kinterval: fix interval boundaries and optimize insertion/removal

Use the right notation [start, end) instead of [start, end] for interval
boundaries, so now an interval does not include its endpoint. This is
the natural way to define a memory range (i.e, 0-4096 = all bytes
between 0 and 4095 included) and it makes easier to reuse this code also
for other similar cases.

Moreover, optimize insertion and removal code to be actually O(log(n)).

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 include/linux/kinterval.h |    2 +-
 lib/kinterval.c           |  135 ++++++++++++++++++++++++++++-----------------
 2 files changed, 86 insertions(+), 51 deletions(-)

diff --git a/include/linux/kinterval.h b/include/linux/kinterval.h
index 8152265..7a505f4 100644
--- a/include/linux/kinterval.h
+++ b/include/linux/kinterval.h
@@ -114,7 +114,7 @@ long kinterval_lookup_range(struct rb_root *root, u64 start, u64 end);
  */
 static inline long kinterval_lookup(struct rb_root *root, u64 addr)
 {
-	return kinterval_lookup_range(root, addr, addr);
+	return kinterval_lookup_range(root, addr, addr + 1);
 }
 
 /**
diff --git a/lib/kinterval.c b/lib/kinterval.c
index 2a9d463..28ee627 100644
--- a/lib/kinterval.c
+++ b/lib/kinterval.c
@@ -31,7 +31,7 @@ static struct kmem_cache *kinterval_cachep __read_mostly;
 
 static bool is_interval_overlapping(struct kinterval *node, u64 start, u64 end)
 {
-	return !(node->start > end || node->end < start);
+	return !(node->start >= end || node->end <= start);
 }
 
 static u64 get_subtree_max_end(struct rb_node *node)
@@ -76,23 +76,65 @@ static struct kinterval *
 kinterval_rb_lowest_match(struct rb_root *root, u64 start, u64 end)
 {
 	struct rb_node *node = root->rb_node;
-	struct kinterval *lower_range = NULL;
+	struct kinterval *lowest_match = NULL;
 
 	while (node) {
 		struct kinterval *range = rb_entry(node, struct kinterval, rb);
 
 		if (get_subtree_max_end(node->rb_left) > start) {
+			/* Lowest overlap if any must be on the left side */
 			node = node->rb_left;
 		} else if (is_interval_overlapping(range, start, end)) {
-			lower_range = range;
+			lowest_match = range;
 			break;
 		} else if (start >= range->start) {
+			/* Lowest overlap if any must be on the right side */
 			node = node->rb_right;
 		} else {
 			break;
 		}
 	}
-	return lower_range;
+	return lowest_match;
+}
+
+/*
+ * Merge two adjacent intervals, if they can be merged next is removed from the
+ * tree.
+ */
+static void kinterval_rb_merge_node(struct rb_root *root,
+			struct kinterval *prev, struct kinterval *next)
+{
+	struct rb_node *deepest;
+
+	if (prev && prev->type == next->type && prev->end == next->start) {
+		prev->end = next->end;
+		deepest = rb_augment_erase_begin(&next->rb);
+		rb_erase(&next->rb, root);
+		rb_augment_erase_end(deepest,
+				kinterval_rb_augment_cb, NULL);
+		kmem_cache_free(kinterval_cachep, next);
+	}
+}
+
+/*
+ * Try to merge a new inserted interval with the previous and the next
+ * interval.
+ */
+static void kinterval_rb_merge(struct rb_root *root, struct kinterval *new)
+{
+	struct kinterval *next, *prev;
+	struct rb_node *node;
+
+	node = rb_prev(&new->rb);
+	prev = node ? rb_entry(node, struct kinterval, rb) : NULL;
+
+	node = rb_next(&new->rb);
+	next = node ? rb_entry(node, struct kinterval, rb) : NULL;
+
+	if (next)
+		kinterval_rb_merge_node(root, new, next);
+	if (prev)
+		kinterval_rb_merge_node(root, prev, new);
 }
 
 static void
@@ -114,32 +156,8 @@ kinterval_rb_insert(struct rb_root *root, struct kinterval *new)
 	rb_link_node(&new->rb, parent, node);
 	rb_insert_color(&new->rb, root);
 	rb_augment_insert(&new->rb, kinterval_rb_augment_cb, NULL);
-}
 
-/* Merge adjacent intervals */
-static void kinterval_rb_merge(struct rb_root *root)
-{
-	struct kinterval *next, *prev = NULL;
-	struct rb_node *node, *deepest;
-
-	node = rb_first(root);
-	while (node) {
-		next = rb_entry(node, struct kinterval, rb);
-		node = rb_next(&next->rb);
-
-		if (prev && prev->type == next->type &&
-				prev->end == (next->start - 1) &&
-				prev->end < next->start) {
-			prev->end = next->end;
-			deepest = rb_augment_erase_begin(&next->rb);
-			rb_erase(&next->rb, root);
-			rb_augment_erase_end(deepest,
-					kinterval_rb_augment_cb, NULL);
-			kmem_cache_free(kinterval_cachep, next);
-		} else {
-			prev = next;
-		}
-	}
+	kinterval_rb_merge(root, new);
 }
 
 static int kinterval_rb_check_add(struct rb_root *root,
@@ -148,16 +166,17 @@ static int kinterval_rb_check_add(struct rb_root *root,
 	struct kinterval *old;
 	struct rb_node *node, *deepest;
 
-	node = rb_first(root);
+	old = kinterval_rb_lowest_match(root, new->start, new->end);
+	node = old ? &old->rb : NULL;
+
 	while (node) {
 		old = rb_entry(node, struct kinterval, rb);
+		node = rb_next(&old->rb);
+
 		/* Check all the possible matches within the range */
-		if (old->start > new->end)
+		if (old->start >= new->end)
 			break;
-		node = rb_next(&old->rb);
 
-		if (!is_interval_overlapping(old, new->start, new->end))
-			continue;
 		/*
 		 * Interval is overlapping another one, shrink the old interval
 		 * accordingly.
@@ -206,8 +225,12 @@ static int kinterval_rb_check_add(struct rb_root *root,
 			 * new         old
 			 * |___________|_______|
 			 */
+			deepest = rb_augment_erase_begin(&old->rb);
 			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
 			old->start = new->end + 1;
+			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 			break;
 		} else if (new->start >= old->start && new->end >= old->end) {
@@ -230,7 +253,7 @@ static int kinterval_rb_check_add(struct rb_root *root,
 			rb_erase(&old->rb, root);
 			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
 						NULL);
-			old->end = new->start - 1;
+			old->end = new->start;
 			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 		} else if (new->start >= old->start && new->end <= old->end) {
@@ -261,13 +284,17 @@ static int kinterval_rb_check_add(struct rb_root *root,
 			if (unlikely(!prev))
 				return -ENOMEM;
 
+			deepest = rb_augment_erase_begin(&old->rb);
 			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
 
 			prev->start = old->start;
-			old->start = new->end + 1;
-			prev->end = new->start - 1;
+			old->start = new->end;
+			prev->end = new->start;
 			prev->type = old->type;
 
+			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 
 			new->subtree_max_end = new->end;
@@ -280,7 +307,6 @@ static int kinterval_rb_check_add(struct rb_root *root,
 	}
 	new->subtree_max_end = new->end;
 	kinterval_rb_insert(root, new);
-	kinterval_rb_merge(root);
 
 	return 0;
 }
@@ -291,7 +317,7 @@ int kinterval_add(struct rb_root *root, u64 start, u64 end,
 	struct kinterval *range;
 	int ret;
 
-	if (end < start)
+	if (end <= start)
 		return -EINVAL;
 	range = kmem_cache_zalloc(kinterval_cachep, flags);
 	if (unlikely(!range))
@@ -314,16 +340,17 @@ static int kinterval_rb_check_del(struct rb_root *root,
 	struct kinterval *old;
 	struct rb_node *node, *deepest;
 
-	node = rb_first(root);
+	old = kinterval_rb_lowest_match(root, start, end);
+	node = old ? &old->rb : NULL;
+
 	while (node) {
 		old = rb_entry(node, struct kinterval, rb);
+		node = rb_next(&old->rb);
+
 		/* Check all the possible matches within the range */
-		if (old->start > end)
+		if (old->start >= end)
 			break;
-		node = rb_next(&old->rb);
 
-		if (!is_interval_overlapping(old, start, end))
-			continue;
 		if (start <= old->start && end >= old->end) {
 			/*
 			 * Completely erase the old range:
@@ -354,8 +381,12 @@ static int kinterval_rb_check_del(struct rb_root *root,
 			 *             old
 			 *             |_______|
 			 */
+			deepest = rb_augment_erase_begin(&old->rb);
 			rb_erase(&old->rb, root);
-			old->start = end + 1;
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
+			old->start = end;
+			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 			break;
 		} else if (start >= old->start && end >= old->end) {
@@ -378,7 +409,7 @@ static int kinterval_rb_check_del(struct rb_root *root,
 			rb_erase(&old->rb, root);
 			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
 						NULL);
-			old->end = start - 1;
+			old->end = start;
 			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 		} else if (start >= old->start && end <= old->end) {
@@ -403,13 +434,17 @@ static int kinterval_rb_check_del(struct rb_root *root,
 			if (unlikely(!prev))
 				return -ENOMEM;
 
+			deepest = rb_augment_erase_begin(&old->rb);
 			rb_erase(&old->rb, root);
+			rb_augment_erase_end(deepest, kinterval_rb_augment_cb,
+						NULL);
 
 			prev->start = old->start;
-			old->start = end + 1;
-			prev->end = start - 1;
+			old->start = end;
+			prev->end = start;
 			prev->type = old->type;
 
+			old->subtree_max_end = old->end;
 			kinterval_rb_insert(root, old);
 
 			prev->subtree_max_end = prev->end;
@@ -422,7 +457,7 @@ static int kinterval_rb_check_del(struct rb_root *root,
 
 int kinterval_del(struct rb_root *root, u64 start, u64 end, gfp_t flags)
 {
-	if (end < start)
+	if (end <= start)
 		return -EINVAL;
 	return kinterval_rb_check_del(root, start, end, flags);
 }
@@ -451,7 +486,7 @@ long kinterval_lookup_range(struct rb_root *root, u64 start, u64 end)
 {
 	struct kinterval *range;
 
-	if (end < start)
+	if (end <= start)
 		return -EINVAL;
 	range = kinterval_rb_lowest_match(root, start, end);
 	return range ? range->type : -ENOENT;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
