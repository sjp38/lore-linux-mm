Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D802C6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 18:43:04 -0400 (EDT)
Date: Thu, 14 Mar 2013 15:42:43 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
Message-ID: <20130314224243.GI5313@blackbox.djwong.org>
References: <5139DB90.5090302@gmail.com>
 <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
 <20130313011020.GA5313@blackbox.djwong.org>
 <20130313085021.GA29730@quack.suse.cz>
 <20130313194429.GE5313@blackbox.djwong.org>
 <20130313210216.GA7754@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130313210216.GA7754@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinneretch.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Wed, Mar 13, 2013 at 10:02:16PM +0100, Jan Kara wrote:
> On Wed 13-03-13 12:44:29, Darrick J. Wong wrote:
> > On Wed, Mar 13, 2013 at 09:50:21AM +0100, Jan Kara wrote:
> > > On Tue 12-03-13 18:10:20, Darrick J. Wong wrote:
> > > > On Tue, Mar 12, 2013 at 03:32:21PM -0700, Andrew Morton wrote:
> > > > > On Fri, 08 Mar 2013 20:37:36 +0800 Shuge <shugelinux@gmail.com> wrote:
> > > > > 
> > > > > > The bounce accept slab pages from jbd2, and flush dcache on them.
> > > > > > When enabling VM_DEBUG, it will tigger VM_BUG_ON in page_mapping().
> > > > > > So, check PageSlab to avoid it in __blk_queue_bounce().
> > > > > > 
> > > > > > Bug URL: http://lkml.org/lkml/2013/3/7/56
> > > > > > 
> > > > > > ...
> > > > > >
> > > > > > --- a/mm/bounce.c
> > > > > > +++ b/mm/bounce.c
> > > > > > @@ -214,7 +214,8 @@ static void __blk_queue_bounce(struct request_queue 
> > > > > > *q, struct bio **bio_orig,
> > > > > >   		if (rw == WRITE) {
> > > > > >   			char *vto, *vfrom;
> > > > > >   -			flush_dcache_page(from->bv_page);
> > > > > > +			if (unlikely(!PageSlab(from->bv_page)))
> > > > > > +				flush_dcache_page(from->bv_page);
> > > > > >   			vto = page_address(to->bv_page) + to->bv_offset;
> > > > > >   			vfrom = kmap(from->bv_page) + from->bv_offset;
> > > > > >   			memcpy(vto, vfrom, to->bv_len);
> > > > > 
> > > > > I guess this is triggered by Catalin's f1a0c4aa0937975b ("arm64: Cache
> > > > > maintenance routines"), which added a page_mapping() call to arm64's
> > > > > arch/arm64/mm/flush.c:flush_dcache_page().
> > > > > 
> > > > > What's happening is that jbd2 is using kmalloc() to allocate buffer_head
> > > > > data.  That gets submitted down the BIO layer and __blk_queue_bounce()
> > > > > calls flush_dcache_page() which in the arm64 case calls page_mapping()
> > > > > and page_mapping() does VM_BUG_ON(PageSlab) and splat.
> > > > > 
> > > > > The unusual thing about all of this is that the payload for some disk
> > > > > IO is coming from kmalloc, rather than being a user page.  It's oddball
> > > > > but we've done this for ages and should continue to support it.
> > > > > 
> > > > > 
> > > > > Now, the page from kmalloc() cannot be in highmem, so why did the
> > > > > bounce code decide to bounce it?
> > > > > 
> > > > > __blk_queue_bounce() does
> > > > > 
> > > > > 		/*
> > > > > 		 * is destination page below bounce pfn?
> > > > > 		 */
> > > > > 		if (page_to_pfn(page) <= queue_bounce_pfn(q) && !force)
> > > > > 			continue;
> > > > > 
> > > > > and `force' comes from must_snapshot_stable_pages().  But
> > > > > must_snapshot_stable_pages() must have returned false, because if it
> > > > > had returned true then it would have been must_snapshot_stable_pages()
> > > > > which went BUG, because must_snapshot_stable_pages() calls page_mapping().
> > > > > 
> > > > > So my tentative diagosis is that arm64 is fishy.  A page which was
> > > > > allocated via jbd2_alloc(GFP_NOFS)->kmem_cache_alloc() ended up being
> > > > > above arm64's queue_bounce_pfn().  Can you please do a bit of
> > > > > investigation to work out if this is what is happening?  Find out why
> > > > > __blk_queue_bounce() decided to bounce a page which shouldn't have been
> > > > > bounced?
> > > > 
> > > > That sure is strange.  I didn't see any obvious reasons why we'd end up with a
> > > > kmalloc above queue_bounce_pfn().  But then I don't have any arm64s either.
> > > > 
> > > > > This is all terribly fragile :( afaict if someone sets
> > > > > bdi_cap_stable_pages_required() against that jbd2 queue, we're going to
> > > > > hit that BUG_ON() again, via must_snapshot_stable_pages()'s
> > > > > page_mapping() call.  (Darrick, this means you ;))
> > > > 
> > > > Wheeee.  You're right, we shouldn't be calling page_mapping on slab pages.
> > > > We can keep walking the bio segments to find a non-slab page that can tell us
> > > > MS_SNAP_STABLE is set, since we probably won't need the bounce buffer anyway.
> > > > 
> > > > How does something like this look?  (+ the patch above)
> > >   Umm, this won't quite work. We can have a bio which has just PageSlab
> > > page attached and so you won't be able to get to the superblock. Heh, isn't
> > > the whole page_mapping() thing in must_snapshot_stable_pages() wrong? When we
> > > do direct IO, these pages come directly from userspace and hell knows where
> > > they come from. Definitely their page_mapping() doesn't give us anything
> > > useful... Sorry for not realizing this earlier when reviewing the patch.
> > > 
> > > ... remembering why we need to get to sb and why ext3 needs this ... So
> > > maybe a better solution would be to have a bio flag meaning that pages need
> > > bouncing? And we would set it from filesystems that need it - in case of
> > > ext3 only writeback of data from kjournald actually needs to bounce the
> > > pages. Thoughts?
> > 
> > What about dirty pages that don't result in journal transactions?  I think
> > ext3_sync_file() eventually calls ext3_ordered_writepage, which then calls
> > __block_write_full_page, which in turn calls submit_bh().
>   So here we have two options:
> Either we let ext3 wait the same way as other filesystems when stable pages
> are required. Then only data IO from kjournald needs to be bounced (all
> other IO is properly protected by PageWriteback bit).
> 
> Or we won't let ext3 wait (as it is now), keep the superblock flag that fs
> needs bouncing, and set the bio flag in __block_write_full_page() and
> kjournald based on the sb flag.
> 
> I think the first option is slightly better but I don't feel strongly
> about that.

I like that first option -- it contains the kludgery to jbd instead of
spreading it around.  Here's a patch that passes a quick smoke test on ext[34],
xfs, and vfat.  What do you think of this one?  Should I create a
submit_snapshot_bh() instead of letting callers stuff in arbitrary dangerous
BH_ flags?

--D
---
From: Darrick J. Wong <darrick.wong@oracle.com>
Subject: [PATCH] mm: Make snapshotting pages for stable writes a per-bio operation

Walking a bio's page mappings has proved problematic, so create a new bio flag
to indicate that a bio's data needs to be snapshotted in order to guarantee
stable pages during writeback.  Next, for the one user (ext3/jbd) of
snapshotting, hook all the places where writes can be initiated without
PG_writeback set, and set BIO_SNAP_STABLE there.  Finally, the MS_SNAP_STABLE
mount flag (only used by ext3) is now superfluous, so get rid of it.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/buffer.c                 |    9 ++++++++-
 fs/ext3/super.c             |    1 -
 fs/jbd/commit.c             |    4 ++--
 include/linux/blk_types.h   |    3 ++-
 include/linux/buffer_head.h |    1 +
 include/uapi/linux/fs.h     |    1 -
 mm/bounce.c                 |   21 +--------------------
 mm/page-writeback.c         |    4 ----
 8 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index b4dcb34..8c1c21a 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2949,7 +2949,7 @@ static void guard_bh_eod(int rw, struct bio *bio, struct buffer_head *bh)
 	}
 }
 
-int submit_bh(int rw, struct buffer_head * bh)
+int _submit_bh(int rw, struct buffer_head * bh, unsigned long flags)
 {
 	struct bio *bio;
 	int ret = 0;
@@ -2984,6 +2984,7 @@ int submit_bh(int rw, struct buffer_head * bh)
 
 	bio->bi_end_io = end_bio_bh_io_sync;
 	bio->bi_private = bh;
+	bio->bi_flags |= flags;
 
 	/* Take care of bh's that straddle the end of the device */
 	guard_bh_eod(rw, bio, bh);
@@ -2997,6 +2998,12 @@ int submit_bh(int rw, struct buffer_head * bh)
 	bio_put(bio);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(_submit_bh);
+
+int submit_bh(int rw, struct buffer_head * bh)
+{
+	return _submit_bh(rw, bh, 0);
+}
 EXPORT_SYMBOL(submit_bh);
 
 /**
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index 1d6e2ed..4fff1b7 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -2067,7 +2067,6 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
 		test_opt(sb,DATA_FLAGS) == EXT3_MOUNT_JOURNAL_DATA ? "journal":
 		test_opt(sb,DATA_FLAGS) == EXT3_MOUNT_ORDERED_DATA ? "ordered":
 		"writeback");
-	sb->s_flags |= MS_SNAP_STABLE;
 
 	return 0;
 
diff --git a/fs/jbd/commit.c b/fs/jbd/commit.c
index 86b39b1..b91b688 100644
--- a/fs/jbd/commit.c
+++ b/fs/jbd/commit.c
@@ -163,7 +163,7 @@ static void journal_do_submit_data(struct buffer_head **wbuf, int bufs,
 	for (i = 0; i < bufs; i++) {
 		wbuf[i]->b_end_io = end_buffer_write_sync;
 		/* We use-up our safety reference in submit_bh() */
-		submit_bh(write_op, wbuf[i]);
+		_submit_bh(write_op, wbuf[i], 1 << BIO_SNAP_STABLE);
 	}
 }
 
@@ -667,7 +667,7 @@ start_journal_io:
 				clear_buffer_dirty(bh);
 				set_buffer_uptodate(bh);
 				bh->b_end_io = journal_end_buffer_io_sync;
-				submit_bh(write_op, bh);
+				_submit_bh(write_op, bh, 1 << BIO_SNAP_STABLE);
 			}
 			cond_resched();
 
diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index cdf1119..22990cf 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -111,12 +111,13 @@ struct bio {
 #define BIO_FS_INTEGRITY 9	/* fs owns integrity data, not block layer */
 #define BIO_QUIET	10	/* Make BIO Quiet */
 #define BIO_MAPPED_INTEGRITY 11/* integrity metadata has been remapped */
+#define BIO_SNAP_STABLE	12	/* bio data must be snapshotted during write */
 
 /*
  * Flags starting here get preserved by bio_reset() - this includes
  * BIO_POOL_IDX()
  */
-#define BIO_RESET_BITS	12
+#define BIO_RESET_BITS	13
 
 #define bio_flagged(bio, flag)	((bio)->bi_flags & (1 << (flag)))
 
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 5afc4f9..714d5d9 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -181,6 +181,7 @@ void ll_rw_block(int, int, struct buffer_head * bh[]);
 int sync_dirty_buffer(struct buffer_head *bh);
 int __sync_dirty_buffer(struct buffer_head *bh, int rw);
 void write_dirty_buffer(struct buffer_head *bh, int rw);
+int _submit_bh(int, struct buffer_head *, unsigned long);
 int submit_bh(int, struct buffer_head *);
 void write_boundary_block(struct block_device *bdev,
 			sector_t bblock, unsigned blocksize);
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index c7fc1e6..a4ed56c 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -88,7 +88,6 @@ struct inodes_stat_t {
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
 
 /* These sb flags are internal to the kernel */
-#define MS_SNAP_STABLE	(1<<27) /* Snapshot pages during writeback, if needed */
 #define MS_NOSEC	(1<<28)
 #define MS_BORN		(1<<29)
 #define MS_ACTIVE	(1<<30)
diff --git a/mm/bounce.c b/mm/bounce.c
index 5f89017..a5c2ec3 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -181,32 +181,13 @@ static void bounce_end_io_read_isa(struct bio *bio, int err)
 #ifdef CONFIG_NEED_BOUNCE_POOL
 static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
 {
-	struct page *page;
-	struct backing_dev_info *bdi;
-	struct address_space *mapping;
-	struct bio_vec *from;
-	int i;
-
 	if (bio_data_dir(bio) != WRITE)
 		return 0;
 
 	if (!bdi_cap_stable_pages_required(&q->backing_dev_info))
 		return 0;
 
-	/*
-	 * Based on the first page that has a valid mapping, decide whether or
-	 * not we have to employ bounce buffering to guarantee stable pages.
-	 */
-	bio_for_each_segment(from, bio, i) {
-		page = from->bv_page;
-		mapping = page_mapping(page);
-		if (!mapping)
-			continue;
-		bdi = mapping->backing_dev_info;
-		return mapping->host->i_sb->s_flags & MS_SNAP_STABLE;
-	}
-
-	return 0;
+	return test_bit(BIO_SNAP_STABLE, &bio->bi_flags);
 }
 #else
 static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index efe6814..4514ad7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2311,10 +2311,6 @@ void wait_for_stable_page(struct page *page)
 
 	if (!bdi_cap_stable_pages_required(bdi))
 		return;
-#ifdef CONFIG_NEED_BOUNCE_POOL
-	if (mapping->host->i_sb->s_flags & MS_SNAP_STABLE)
-		return;
-#endif /* CONFIG_NEED_BOUNCE_POOL */
 
 	wait_on_page_writeback(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
