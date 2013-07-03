Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3225C6B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:19 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 3/5] radix-tree: introduce radix_tree_[next/prev]_present()
Date: Wed,  3 Jul 2013 17:34:18 +0900
Message-Id: <1372840460-5571-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index ffc444c..045b325 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -230,6 +230,10 @@ unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
 unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan);
+unsigned long radix_tree_next_present(struct radix_tree_root *root,
+				unsigned long index, unsigned long max_scan);
+unsigned long radix_tree_prev_present(struct radix_tree_root *root,
+				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e796429..e02e3b8 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -984,6 +984,40 @@ unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_prev_hole);
 
+unsigned long radix_tree_next_present(struct radix_tree_root *root,
+				unsigned long index, unsigned long max_scan)
+{
+	unsigned long i;
+
+	for (i = 0; i < max_scan; i++) {
+		if (radix_tree_lookup(root, index))
+			break;
+		index++;
+		if (index == 0)
+			break;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(radix_tree_next_present);
+
+unsigned long radix_tree_prev_present(struct radix_tree_root *root,
+				   unsigned long index, unsigned long max_scan)
+{
+	unsigned long i;
+
+	for (i = 0; i < max_scan; i++) {
+		if (radix_tree_lookup(root, index))
+			break;
+		index--;
+		if (index == ULONG_MAX)
+			break;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(radix_tree_prev_present);
+
 /**
  *	radix_tree_gang_lookup - perform multiple lookup on a radix tree
  *	@root:		radix tree root
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
