Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E555D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 19:02:05 -0400 (EDT)
Date: Mon, 18 Mar 2013 16:01:36 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] mm: Make snapshotting pages for stable writes a per-bio
 operation
Message-ID: <20130318230136.GO5313@blackbox.djwong.org>
References: <5139DB90.5090302@gmail.com>
 <20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
 <20130313011020.GA5313@blackbox.djwong.org>
 <20130313085021.GA29730@quack.suse.cz>
 <20130313194429.GE5313@blackbox.djwong.org>
 <20130313210216.GA7754@quack.suse.cz>
 <20130314224243.GI5313@blackbox.djwong.org>
 <20130315100105.GA4889@quack.suse.cz>
 <20130315232816.GN5313@blackbox.djwong.org>
 <20130318174134.GB7852@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130318174134.GB7852@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinnertech.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Mon, Mar 18, 2013 at 06:41:34PM +0100, Jan Kara wrote:
> On Fri 15-03-13 16:28:16, Darrick J. Wong wrote:
> > Walking a bio's page mappings has proved problematic, so create a new bio flag
> > to indicate that a bio's data needs to be snapshotted in order to guarantee
> > stable pages during writeback.  Next, for the one user (ext3/jbd) of
> > snapshotting, hook all the places where writes can be initiated without
> > PG_writeback set, and set BIO_SNAP_STABLE there.  We must also flag journal
> > "metadata" bios for stable writeout if data=journal, since file data is written
> > through the journal.  Finally, the MS_SNAP_STABLE mount flag (only used by
> > ext3) is now superfluous, so get rid of it.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > [darrick.wong@oracle.com: Fold in a couple of small cleanups from akpm]
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  fs/buffer.c                 |    9 ++++++++-
> >  fs/ext3/super.c             |    3 ++-
> >  fs/jbd/commit.c             |   28 +++++++++++++++++++++++++---
> >  include/linux/blk_types.h   |    3 ++-
> >  include/linux/buffer_head.h |    1 +
> >  include/linux/jbd.h         |    1 +
> >  include/uapi/linux/fs.h     |    1 -
> >  mm/bounce.c                 |   21 +--------------------
> >  mm/page-writeback.c         |    4 ----
> >  9 files changed, 40 insertions(+), 31 deletions(-)
> > 
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index b4dcb34..71578d6 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -2949,7 +2949,7 @@ static void guard_bh_eod(int rw, struct bio *bio, struct buffer_head *bh)
> >  	}
> >  }
> >  
> > -int submit_bh(int rw, struct buffer_head * bh)
> > +int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags)
> >  {
> >  	struct bio *bio;
> >  	int ret = 0;
> > @@ -2984,6 +2984,7 @@ int submit_bh(int rw, struct buffer_head * bh)
> >  
> >  	bio->bi_end_io = end_bio_bh_io_sync;
> >  	bio->bi_private = bh;
> > +	bio->bi_flags |= bio_flags;
> >  
> >  	/* Take care of bh's that straddle the end of the device */
> >  	guard_bh_eod(rw, bio, bh);
> > @@ -2997,6 +2998,12 @@ int submit_bh(int rw, struct buffer_head * bh)
> >  	bio_put(bio);
> >  	return ret;
> >  }
> > +EXPORT_SYMBOL_GPL(_submit_bh);
> > +
> > +int submit_bh(int rw, struct buffer_head *bh)
> > +{
> > +	return _submit_bh(rw, bh, 0);
> > +}
> >  EXPORT_SYMBOL(submit_bh);
> >  
> >  /**
> > diff --git a/fs/ext3/super.c b/fs/ext3/super.c
> > index 1d6e2ed..e845b6de 100644
> > --- a/fs/ext3/super.c
> > +++ b/fs/ext3/super.c
> > @@ -2063,11 +2063,12 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
> >  		ext3_mark_recovery_complete(sb, es);
> >  		ext3_msg(sb, KERN_INFO, "recovery complete");
> >  	}
> > +	if (test_opt(sb, DATA_FLAGS) == EXT3_MOUNT_JOURNAL_DATA)
> > +		EXT3_SB(sb)->s_journal->j_flags |= JFS_JOURNALS_DATA;
>   Sadly this isn't enough. You can have inodes which journal data (there's
> an inode flag for this) in data=ordered mode. So what you have to do is to

Arrrgh, I forgot that you can do that per-inode. :(

> flag journal_heads (or buffer_heads) as containing journalled data. Or you
> can actually use PageChecked flag for this (it is going to be set on all
> write-enabled pages with journalled data). But it definitely requires also
> some playing with ->page_mkwrite() (calling ext3_journal_get_write_access()
> from there) and generally I'd rather postpone that to a separate commit. So
> just keep it simple and always set the bio flag as you did in the previous
> version. I'll write an optimization (mostly because ext4 needs it as well)
> and send it to you for testing.

Yeah, this is getting a bit complicated for a single patch.

--D
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
