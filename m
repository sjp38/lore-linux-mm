From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 15/26] bufferhead: Revert constructor removal
Date: Fri, 31 Aug 2007 18:41:22 -0700
Message-ID: <20070901014222.762921292@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0015-slab_defrag_buffer_head_revert.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

The constructor for buffer_head slabs was removed recently. We need
the constructor in order to insure that slab objects always have a definite
state even before we allocated them.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 0e5ec37..f4824d1 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2960,9 +2960,8 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep, gfp_flags);
+	struct buffer_head *ret = kmem_cache_alloc(bh_cachep, gfp_flags);
 	if (ret) {
-		INIT_LIST_HEAD(&ret->b_assoc_buffers);
 		get_cpu_var(bh_accounting).nr++;
 		recalc_bh_state();
 		put_cpu_var(bh_accounting);
@@ -3003,12 +3002,24 @@ static int buffer_cpu_notify(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 
+static void
+init_buffer_head(void *data, struct kmem_cache *cachep, unsigned long flags)
+{
+	struct buffer_head * bh = (struct buffer_head *)data;
+
+	memset(bh, 0, sizeof(*bh));
+	INIT_LIST_HEAD(&bh->b_assoc_buffers);
+}
+
 void __init buffer_init(void)
 {
 	int nrpages;
 
-	bh_cachep = KMEM_CACHE(buffer_head,
-			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
+	bh_cachep = kmem_cache_create("buffer_head",
+			sizeof(struct buffer_head), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
+				SLAB_MEM_SPREAD),
+				init_buffer_head);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
-- 
1.5.2.4

-- 
