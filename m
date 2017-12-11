Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 762D06B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 23:23:19 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so11723826itc.9
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 20:23:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m101si11167654ioo.300.2017.12.10.20.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Dec 2017 20:23:18 -0800 (PST)
Date: Sun, 10 Dec 2017 20:23:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171211042315.GA25236@bombadil.infradead.org>
References: <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207003843.GG4094@dastard>
 <20171208230131.GC32293@bombadil.infradead.org>
 <20171210235745.GR5858@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171210235745.GR5858@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Dec 11, 2017 at 10:57:45AM +1100, Dave Chinner wrote:
> i.e.  the fact the cmpxchg failed may not have anything to do with a
> race condtion - it failed because the slot wasn't empty like we
> expected it to be. There can be any number of reasons the slot isn't
> empty - the API should not "document" that the reason the insert
> failed was a race condition. It should document the case that we
> "couldn't insert because there was an existing entry in the slot".
> Let the surrounding code document the reason why that might have
> happened - it's not for the API to assume reasons for failure.
> 
> i.e. this API and potential internal implementation makes much
> more sense:
> 
> int
> xa_store_iff_empty(...)
> {
> 	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
> 	if (!curr)
> 		return 0;	/* success! */
> 	if (!IS_ERR(curr))
> 		return -EEXIST;	/* failed - slot not empty */
> 	return PTR_ERR(curr);	/* failed - XA internal issue */
> }
> 
> as it replaces the existing preload and insert code in the XFS code
> paths whilst letting us handle and document the "insert failed
> because slot not empty" case however we want. It implies nothing
> about *why* the slot wasn't empty, just that we couldn't do the
> insert because it wasn't empty.

Yeah, OK.  So, over the top of the recent changes I'm looking at this:

I'm not in love with xa_store_empty() as a name.  I almost want
xa_store_weak(), but after my MAP_FIXED_WEAK proposed name got shot
down, I'm leery of it.  "empty" is at least a concept we already have
in the API with the comment for xa_init() talking about an empty array
and xa_empty().  I also considered xa_store_null and xa_overwrite_null
and xa_replace_null().  Naming remains hard.

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 941f38bb94a4..586b43836905 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -451,7 +451,7 @@ xfs_iget_cache_miss(
 	int			flags,
 	int			lock_flags)
 {
-	struct xfs_inode	*ip, *curr;
+	struct xfs_inode	*ip;
 	int			error;
 	xfs_agino_t		agino = XFS_INO_TO_AGINO(mp, ino);
 	int			iflags;
@@ -498,8 +498,7 @@ xfs_iget_cache_miss(
 	xfs_iflags_set(ip, iflags);
 
 	/* insert the new inode */
-	curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
-	error = __xa_race(curr, -EAGAIN);
+	error = xa_store_empty(&pag->pag_ici_xa, agino, ip, GFP_NOFS, -EAGAIN);
 	if (error)
 		goto out_unlock;
 
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 5792b6dbb040..cc7cc5253a67 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -271,43 +271,30 @@ static inline int xa_err(void *entry)
 }
 
 /**
- * __xa_race() - Turn a cmpxchg result into an errno.
- * @entry: Result from calling an XArray function.
- * @errno: Error number to return if we lost the race.
+ * xa_store_empty() - Store this entry in the XArray unless another entry is
+ * 			already present.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ * @rc: Number to return if another entry was present.
  *
- * Like xa_race(), but returns the error number of your choice.  Calling
- * __xa_race(entry, 0) has the same result (but is less efficient) as
- * calling xa_err().
+ * Like xa_store(), but will fail and return the supplied error number if
+ * the existing entry at @index is not %NULL.
  *
  * Return: A negative errno or 0.
  */
-static inline int __xa_race(void *entry, int errno)
+static inline int xa_store_empty(struct xarray *xa, unsigned long index,
+		void *entry, gfp_t gfp, int errno)
 {
-	if (!entry)
+	void *curr = xa_cmpxchg(xa, index, NULL, entry, gfp);
+	if (!curr)
 		return 0;
-	if (xa_is_err(entry))
-		return (long)entry >> 2;
+	if (xa_is_err(curr))
+		return xa_err(curr);
 	return errno;
 }
 
-/**
- * xa_race() - Turn a cmpxchg result into an errno.
- * @entry: Result from calling an XArray function.
- *
- * It is common to use xa_cmpxchg() to ensure that only one thread assigns
- * a value to an index.  Pass the result from xa_cmpxchg() to xa_race() to
- * get an errno back.  This function also handles any other error which
- * may have been returned by xa_cmpxchg() such as ENOMEM.
- *
- * If you don't care that you lost the race, you can use xa_err() instead.
- *
- * Return: A negative errno or 0.
- */
-static inline int xa_race(void *entry)
-{
-	return __xa_race(entry, -EEXIST);
-}
-
 /* Everything below here is the Advanced API.  Proceed with caution. */
 
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 85d1bc963ab6..87ed55af823e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -614,8 +614,8 @@ static int cgwb_create(struct backing_dev_info *bdi,
 	spin_lock_irqsave(&cgwb_lock, flags);
 	if (test_bit(WB_registered, &bdi->wb.state) &&
 	    blkcg_cgwb_list->next && memcg_cgwb_list->next) {
-		ret = xa_race(xa_cmpxchg(&bdi->cgwb_xa, memcg_css->id, NULL,
-						wb, GFP_ATOMIC));
+		ret = xa_store_empty(&bdi->cgwb_xa, memcg_css->id, wb,
+					GFP_ATOMIC, -EEXIST);
 		if (!ret) {
 			list_add_tail_rcu(&wb->bdi_node, &bdi->wb_list);
 			list_add(&wb->memcg_node, memcg_cgwb_list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
