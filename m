Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C112B6B003B
	for <linux-mm@kvack.org>; Tue, 28 May 2013 11:56:38 -0400 (EDT)
Message-ID: <51A4D3B5.6060802@parallels.com>
Date: Tue, 28 May 2013 21:26:37 +0530
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 16/34] xfs: convert buftarg LRU to generic code
References: <1369391368-31562-1-git-send-email-glommer@openvz.org> <1369391368-31562-17-git-send-email-glommer@openvz.org> <20130525002759.GK24543@dastard>
In-Reply-To: <20130525002759.GK24543@dastard>
Content-Type: multipart/mixed;
	boundary="------------030802010600060907070709"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel
 Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <dchinner@redhat.com>

--------------030802010600060907070709
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 05/25/2013 05:57 AM, Dave Chinner wrote:
> On Fri, May 24, 2013 at 03:59:10PM +0530, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> Convert the buftarg LRU to use the new generic LRU list and take
>> advantage of the functionality it supplies to make the buffer cache
>> shrinker node aware.
>>
>> * v7: Add NUMA aware flag
> 
> I know what is wrong with this patch that causes the unmount hang -
> it's the handling of the _XBF_LRU_DISPOSE flag no longer being
> modified atomically with the LRU lock. Hence there is a race where
> we can either lose the _XBF_LRU_DISPOSE or not see it and hence we
> can end up with code not detecting what list the buffer is on
> correctly.
> 
> I haven't had a chance to work out a fix for it yet. If this ends up
> likely to hold up the patch set, Glauber, then feel free to drop it
> from the series and I'll push a fixed version through the XFS tree
> in due course....
> 
> Cheers,
> 
> Dave.
> 
Please let me know what you think about the following two (very coarse)
patches. My idea is to expose more of the raw structures so XFS can do
the locking itself when needed.

The memcg parts need to be rebased on top of that. If you agree with the
approach, I will proceed with doing this.


--------------030802010600060907070709
Content-Type: text/x-patch; name="for-xfs-raw-api.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="for-xfs-raw-api.patch"

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index cf59a8a..95a73ea 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -40,8 +40,37 @@ struct list_lru {
 };
 
 int list_lru_init(struct list_lru *lru);
-int list_lru_add(struct list_lru *lru, struct list_head *item);
-int list_lru_del(struct list_lru *lru, struct list_head *item);
+
+struct list_lru_node *list_lru_to_node(struct list_lru *lru,
+				       struct list_head *item);
+int list_lru_add_node(struct list_lru *lru, struct list_lru_node *nlru,
+		      struct list_head *item);
+int list_lru_del_node(struct list_lru *lru, struct list_lru_node *nlru,
+		      struct list_head *item);
+
+static inline int list_lru_add(struct list_lru *lru, struct list_head *item)
+{
+	int ret;
+	struct list_lru_node *nlru = list_lru_to_node(lru, item);
+
+	spin_lock(&nlru->lock);
+	ret = list_lru_add_node(lru, nlru, item);
+	spin_unlock(&nlru->lock);
+
+	return ret;
+}
+
+static inline int list_lru_del(struct list_lru *lru, struct list_head *item)
+{
+	int ret;
+	struct list_lru_node *nlru = list_lru_to_node(lru, item);
+
+	spin_lock(&nlru->lock);
+	ret = list_lru_del_node(lru, nlru, item);
+	spin_unlock(&nlru->lock);
+
+	return ret;
+}
 
 unsigned long list_lru_count_node(struct list_lru *lru, int nid);
 static inline unsigned long list_lru_count(struct list_lru *lru)
diff --git a/lib/list_lru.c b/lib/list_lru.c
index dae13d6..f72029d 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -9,49 +9,53 @@
 #include <linux/mm.h>
 #include <linux/list_lru.h>
 
-int
-list_lru_add(
+struct list_lru_node *
+list_lru_to_node(
 	struct list_lru	*lru,
 	struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
+	return &lru->node[nid];
+}
+EXPORT_SYMBOL_GPL(list_lru_to_node);
+
+int
+list_lru_add_node(
+	struct list_lru		*lru,
+	struct list_lru_node	*nlru,
+	struct list_head	*item)
+{
+	int nid = page_to_nid(virt_to_page(item));
 
-	spin_lock(&nlru->lock);
 	BUG_ON(nlru->nr_items < 0);
 	if (list_empty(item)) {
 		list_add_tail(item, &nlru->list);
 		if (nlru->nr_items++ == 0)
 			node_set(nid, lru->active_nodes);
-		spin_unlock(&nlru->lock);
 		return 1;
 	}
-	spin_unlock(&nlru->lock);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(list_lru_add);
+EXPORT_SYMBOL_GPL(list_lru_add_node);
 
 int
-list_lru_del(
-	struct list_lru	*lru,
-	struct list_head *item)
+list_lru_del_node(
+	struct list_lru		*lru,
+	struct list_lru_node	*nlru,
+	struct list_head	*item)
 {
 	int nid = page_to_nid(virt_to_page(item));
-	struct list_lru_node *nlru = &lru->node[nid];
 
-	spin_lock(&nlru->lock);
 	if (!list_empty(item)) {
 		list_del_init(item);
 		if (--nlru->nr_items == 0)
 			node_clear(nid, lru->active_nodes);
 		BUG_ON(nlru->nr_items < 0);
-		spin_unlock(&nlru->lock);
 		return 1;
 	}
-	spin_unlock(&nlru->lock);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(list_lru_del);
+EXPORT_SYMBOL_GPL(list_lru_del_node);
 
 unsigned long
 list_lru_count_node(struct list_lru *lru, int nid)

--------------030802010600060907070709
Content-Type: text/x-patch; name="xfs-buf-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="xfs-buf-fix.patch"

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index f7212c1..3e179f2 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -89,10 +89,15 @@ static void
 xfs_buf_lru_add(
 	struct xfs_buf	*bp)
 {
-	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
+	struct list_lru_node *nlru;
+	nlru = list_lru_to_node(&bp->b_target->bt_lru, &bp->b_lru);
+
+	spin_lock(&nlru->lock);
+	if (list_lru_add_node(&bp->b_target->bt_lru, nlru, &bp->b_lru)) {
 		bp->b_lru_flags &= ~_XBF_LRU_DISPOSE;
 		atomic_inc(&bp->b_hold);
 	}
+	spin_unlock(&nlru->lock);
 }
 
 /*
@@ -122,6 +127,9 @@ void
 xfs_buf_stale(
 	struct xfs_buf	*bp)
 {
+	struct list_lru_node *nlru;
+	nlru = list_lru_to_node(&bp->b_target->bt_lru, &bp->b_lru);
+
 	ASSERT(xfs_buf_islocked(bp));
 
 	bp->b_flags |= XBF_STALE;
@@ -133,10 +141,12 @@ xfs_buf_stale(
 	 */
 	bp->b_flags &= ~_XBF_DELWRI_Q;
 
+	spin_lock(&nlru->lock);
 	atomic_set(&(bp)->b_lru_ref, 0);
 	if (!(bp->b_lru_flags & _XBF_LRU_DISPOSE) &&
-	    (list_lru_del(&bp->b_target->bt_lru, &bp->b_lru)))
+	    (list_lru_del_node(&bp->b_target->bt_lru, nlru, &bp->b_lru)))
 		atomic_dec(&bp->b_hold);
+	spin_unlock(&nlru->lock);
 
 	ASSERT(atomic_read(&bp->b_hold) >= 1);
 }

--------------030802010600060907070709--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
