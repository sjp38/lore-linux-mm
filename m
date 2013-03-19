Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 681456B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 04:54:52 -0400 (EDT)
Date: Tue, 19 Mar 2013 09:54:48 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3] mm: Make snapshotting pages for stable writes a
 per-bio operation
Message-ID: <20130319085448.GA5222@quack.suse.cz>
References: <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
 <20130313011020.GA5313@blackbox.djwong.org>
 <20130313085021.GA29730@quack.suse.cz>
 <20130313194429.GE5313@blackbox.djwong.org>
 <20130313210216.GA7754@quack.suse.cz>
 <20130314224243.GI5313@blackbox.djwong.org>
 <20130315100105.GA4889@quack.suse.cz>
 <20130315232816.GN5313@blackbox.djwong.org>
 <20130318174134.GB7852@quack.suse.cz>
 <20130318230259.GP5313@blackbox.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130318230259.GP5313@blackbox.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinnertech.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Mon 18-03-13 16:02:59, Darrick J. Wong wrote:
> Walking a bio's page mappings has proved problematic, so create a new bio flag
> to indicate that a bio's data needs to be snapshotted in order to guarantee
> stable pages during writeback.  Next, for the one user (ext3/jbd) of
> snapshotting, hook all the places where writes can be initiated without
> PG_writeback set, and set BIO_SNAP_STABLE there.  We must also flag journal
> "metadata" bios for stable writeout, since file data can be written through the
> journal.  Finally, the MS_SNAP_STABLE mount flag (only used by ext3) is now
> superfluous, so get rid of it.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> 
> [darrick.wong@oracle.com: Fold in a couple of small cleanups from akpm]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
  OK, now I'm happy with the patch :) You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/buffer.c                 |    9 ++++++++-
>  fs/ext3/super.c             |    1 -
>  fs/jbd/commit.c             |   25 ++++++++++++++++++++++---
>  include/linux/blk_types.h   |    3 ++-
>  include/linux/buffer_head.h |    1 +
>  include/uapi/linux/fs.h     |    1 -
>  mm/bounce.c                 |   21 +--------------------
>  mm/page-writeback.c         |    4 ----
>  8 files changed, 34 insertions(+), 31 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index b4dcb34..71578d6 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2949,7 +2949,7 @@ static void guard_bh_eod(int rw, struct bio *bio, struct buffer_head *bh)
>  	}
>  }
>  
> -int submit_bh(int rw, struct buffer_head * bh)
> +int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags)
>  {
>  	struct bio *bio;
>  	int ret = 0;
> @@ -2984,6 +2984,7 @@ int submit_bh(int rw, struct buffer_head * bh)
>  
>  	bio->bi_end_io = end_bio_bh_io_sync;
>  	bio->bi_private = bh;
> +	bio->bi_flags |= bio_flags;
>  
>  	/* Take care of bh's that straddle the end of the device */
>  	guard_bh_eod(rw, bio, bh);
> @@ -2997,6 +2998,12 @@ int submit_bh(int rw, struct buffer_head * bh)
>  	bio_put(bio);
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(_submit_bh);
> +
> +int submit_bh(int rw, struct buffer_head *bh)
> +{
> +	return _submit_bh(rw, bh, 0);
> +}
>  EXPORT_SYMBOL(submit_bh);
>  
>  /**
> diff --git a/fs/ext3/super.c b/fs/ext3/super.c
> index fb5120a..3dc48cc 100644
> --- a/fs/ext3/super.c
> +++ b/fs/ext3/super.c
> @@ -2067,7 +2067,6 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
>  		test_opt(sb,DATA_FLAGS) == EXT3_MOUNT_JOURNAL_DATA ? "journal":
>  		test_opt(sb,DATA_FLAGS) == EXT3_MOUNT_ORDERED_DATA ? "ordered":
>  		"writeback");
> -	sb->s_flags |= MS_SNAP_STABLE;
>  
>  	return 0;
>  
> diff --git a/fs/jbd/commit.c b/fs/jbd/commit.c
> index 86b39b1..11bb11f 100644
> --- a/fs/jbd/commit.c
> +++ b/fs/jbd/commit.c
> @@ -162,8 +162,17 @@ static void journal_do_submit_data(struct buffer_head **wbuf, int bufs,
>  
>  	for (i = 0; i < bufs; i++) {
>  		wbuf[i]->b_end_io = end_buffer_write_sync;
> -		/* We use-up our safety reference in submit_bh() */
> -		submit_bh(write_op, wbuf[i]);
> +		/*
> +		 * Here we write back pagecache data that may be mmaped. Since
> +		 * we cannot afford to clean the page and set PageWriteback
> +		 * here due to lock ordering (page lock ranks above transaction
> +		 * start), the data can change while IO is in flight. Tell the
> +		 * block layer it should bounce the bio pages if stable data
> +		 * during write is required.
> +		 *
> +		 * We use up our safety reference in submit_bh().
> +		 */
> +		_submit_bh(write_op, wbuf[i], 1 << BIO_SNAP_STABLE);
>  	}
>  }
>  
> @@ -667,7 +676,17 @@ start_journal_io:
>  				clear_buffer_dirty(bh);
>  				set_buffer_uptodate(bh);
>  				bh->b_end_io = journal_end_buffer_io_sync;
> -				submit_bh(write_op, bh);
> +				/*
> +				 * In data=journal mode, here we can end up
> +				 * writing pagecache data that might be
> +				 * mmapped. Since we can't afford to clean the
> +				 * page and set PageWriteback (see the comment
> +				 * near the other use of _submit_bh()), the
> +				 * data can change while the write is in
> +				 * flight.  Tell the block layer to bounce the
> +				 * bio pages if stable pages are required.
> +				 */
> +				_submit_bh(write_op, bh, 1 << BIO_SNAP_STABLE);
>  			}
>  			cond_resched();
>  
> diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
> index cdf1119..22990cf 100644
> --- a/include/linux/blk_types.h
> +++ b/include/linux/blk_types.h
> @@ -111,12 +111,13 @@ struct bio {
>  #define BIO_FS_INTEGRITY 9	/* fs owns integrity data, not block layer */
>  #define BIO_QUIET	10	/* Make BIO Quiet */
>  #define BIO_MAPPED_INTEGRITY 11/* integrity metadata has been remapped */
> +#define BIO_SNAP_STABLE	12	/* bio data must be snapshotted during write */
>  
>  /*
>   * Flags starting here get preserved by bio_reset() - this includes
>   * BIO_POOL_IDX()
>   */
> -#define BIO_RESET_BITS	12
> +#define BIO_RESET_BITS	13
>  
>  #define bio_flagged(bio, flag)	((bio)->bi_flags & (1 << (flag)))
>  
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index 5afc4f9..4c16c4a 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -181,6 +181,7 @@ void ll_rw_block(int, int, struct buffer_head * bh[]);
>  int sync_dirty_buffer(struct buffer_head *bh);
>  int __sync_dirty_buffer(struct buffer_head *bh, int rw);
>  void write_dirty_buffer(struct buffer_head *bh, int rw);
> +int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags);
>  int submit_bh(int, struct buffer_head *);
>  void write_boundary_block(struct block_device *bdev,
>  			sector_t bblock, unsigned blocksize);
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index c7fc1e6..a4ed56c 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -88,7 +88,6 @@ struct inodes_stat_t {
>  #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
>  
>  /* These sb flags are internal to the kernel */
> -#define MS_SNAP_STABLE	(1<<27) /* Snapshot pages during writeback, if needed */
>  #define MS_NOSEC	(1<<28)
>  #define MS_BORN		(1<<29)
>  #define MS_ACTIVE	(1<<30)
> diff --git a/mm/bounce.c b/mm/bounce.c
> index 5f89017..a5c2ec3 100644
> --- a/mm/bounce.c
> +++ b/mm/bounce.c
> @@ -181,32 +181,13 @@ static void bounce_end_io_read_isa(struct bio *bio, int err)
>  #ifdef CONFIG_NEED_BOUNCE_POOL
>  static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
>  {
> -	struct page *page;
> -	struct backing_dev_info *bdi;
> -	struct address_space *mapping;
> -	struct bio_vec *from;
> -	int i;
> -
>  	if (bio_data_dir(bio) != WRITE)
>  		return 0;
>  
>  	if (!bdi_cap_stable_pages_required(&q->backing_dev_info))
>  		return 0;
>  
> -	/*
> -	 * Based on the first page that has a valid mapping, decide whether or
> -	 * not we have to employ bounce buffering to guarantee stable pages.
> -	 */
> -	bio_for_each_segment(from, bio, i) {
> -		page = from->bv_page;
> -		mapping = page_mapping(page);
> -		if (!mapping)
> -			continue;
> -		bdi = mapping->backing_dev_info;
> -		return mapping->host->i_sb->s_flags & MS_SNAP_STABLE;
> -	}
> -
> -	return 0;
> +	return test_bit(BIO_SNAP_STABLE, &bio->bi_flags);
>  }
>  #else
>  static int must_snapshot_stable_pages(struct request_queue *q, struct bio *bio)
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index efe6814..4514ad7 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2311,10 +2311,6 @@ void wait_for_stable_page(struct page *page)
>  
>  	if (!bdi_cap_stable_pages_required(bdi))
>  		return;
> -#ifdef CONFIG_NEED_BOUNCE_POOL
> -	if (mapping->host->i_sb->s_flags & MS_SNAP_STABLE)
> -		return;
> -#endif /* CONFIG_NEED_BOUNCE_POOL */
>  
>  	wait_on_page_writeback(page);
>  }
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
