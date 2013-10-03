Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 593C76B005C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:25 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1670212pdj.18
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:24 -0700 (PDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so1657412pbc.8
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:22 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 10/14] vrange: Add core shrinking logic for swapless system
Date: Wed,  2 Oct 2013 17:51:39 -0700
Message-Id: <1380761503-14509-11-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds the core volatile range shrinking logic
needed to allow volatile range purging to function on
swapless systems.

This patch does not wire in the specific range purging logic,
but that will be added in the following patches.

The reason I use shrinker is that Dave and Glauber are trying to
make slab shrinker being aware of node/memcg so if the patchset
reach on mainline, we also can support node/memcg in vrange, easily.

Another reason I selected slab shrinker is that normally slab shrinker
is called after normal reclaim of file-backed page(ex, page cache)
so reclaiming preference would be this, I expect.(TODO: invstigate
and might need more tunes in reclaim path)

        page cache -> vrange by slab shrinking -> anon page

It does make sense because page cache can have stream data so there is
no point to shrink vrange pages if there are lots of streaming pages
in page cache.

In this version, I didn't check it works well but it's design concept
so we can make it work via modify page reclaim path.
I will have more experiment.

One of disadvantage with using slab shrink is that slab shrinker isn't
called in using memcg so memcg-noswap system cannot take advantage of it.
Hmm, Maybe I will jump into relcaim code to hook some point to control
vrange page shrinking more freely.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Renamed some functions and minor cleanups]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 mm/vrange.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 86 insertions(+), 3 deletions(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index 33e3ac1..e7c5a25 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -25,11 +25,19 @@ static inline unsigned int vrange_size(struct vrange *range)
 	return range->node.last + 1 - range->node.start;
 }
 
+static int shrink_vrange(struct shrinker *s, struct shrink_control *sc);
+
+static struct shrinker vrange_shrinker = {
+	.shrink = shrink_vrange,
+	.seeks = DEFAULT_SEEKS
+};
+
 static int __init vrange_init(void)
 {
 	INIT_LIST_HEAD(&vrange_list.list);
 	mutex_init(&vrange_list.lock);
 	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
+	register_shrinker(&vrange_shrinker);
 	return 0;
 }
 module_init(vrange_init);
@@ -58,9 +66,14 @@ static void __vrange_free(struct vrange *range)
 static inline void __vrange_lru_add(struct vrange *range)
 {
 	mutex_lock(&vrange_list.lock);
-	WARN_ON(!list_empty(&range->lru));
-	list_add(&range->lru, &vrange_list.list);
-	vrange_list.size += vrange_size(range);
+	/*
+	 * We need this check because it could be raced with
+	 * shrink_vrange and vrange_resize
+	 */
+	if (list_empty(&range->lru)) {
+		list_add(&range->lru, &vrange_list.list);
+		vrange_list.size += vrange_size(range);
+	}
 	mutex_unlock(&vrange_list.lock);
 }
 
@@ -84,6 +97,14 @@ static void __vrange_add(struct vrange *range, struct vrange_root *vroot)
 	__vrange_lru_add(range);
 }
 
+static inline int __vrange_get(struct vrange *vrange)
+{
+	if (!atomic_inc_not_zero(&vrange->refcount))
+		return 0;
+
+	return 1;
+}
+
 static inline void __vrange_put(struct vrange *range)
 {
 	if (atomic_dec_and_test(&range->refcount)) {
@@ -647,3 +668,65 @@ int discard_vpage(struct page *page)
 
 	return 1;
 }
+
+static struct vrange *vrange_isolate(void)
+{
+	struct vrange *vrange = NULL;
+	mutex_lock(&vrange_list.lock);
+	while (!list_empty(&vrange_list.list)) {
+		vrange = list_entry(vrange_list.list.prev,
+				struct vrange, lru);
+		list_del_init(&vrange->lru);
+		vrange_list.size -= vrange_size(vrange);
+
+		/* vrange is going to destroy */
+		if (__vrange_get(vrange))
+			break;
+
+		vrange = NULL;
+	}
+
+	mutex_unlock(&vrange_list.lock);
+	return vrange;
+}
+
+static unsigned int discard_vrange(struct vrange *vrange)
+{
+	return 0;
+}
+
+static int shrink_vrange(struct shrinker *s, struct shrink_control *sc)
+{
+	struct vrange *range = NULL;
+	long nr_to_scan = sc->nr_to_scan;
+	long size = vrange_list.size;
+
+	if (!nr_to_scan)
+		return size;
+
+	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_IO))
+		return -1;
+
+	while (size > 0 && nr_to_scan > 0) {
+		range = vrange_isolate();
+		if (!range)
+			break;
+
+		/* range is removing so don't bother */
+		if (!range->owner) {
+			__vrange_put(range);
+			size -= vrange_size(range);
+			nr_to_scan -= vrange_size(range);
+			continue;
+		}
+
+		if (discard_vrange(range) < 0)
+			__vrange_lru_add(range);
+		__vrange_put(range);
+
+		size -= vrange_size(range);
+		nr_to_scan -= vrange_size(range);
+	}
+
+	return size;
+}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
