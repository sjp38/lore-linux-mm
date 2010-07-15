Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DFE86201FE
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 11:35:38 -0400 (EDT)
Date: Thu, 15 Jul 2010 23:35:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/6] writeback: dont redirty tail an inode with dirty
 pages
Message-ID: <20100715153530.GC6511@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021749.021449821@intel.com>
 <20100712020109.GB25335@dastard>
 <20100712153127.GB30222@localhost>
 <20100712151317.bd9d656c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712151317.bd9d656c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 06:13:17AM +0800, Andrew Morton wrote:
> On Mon, 12 Jul 2010 23:31:27 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > > +		} else if (inode->i_state & I_DIRTY) {
> > > > +			/*
> > > > +			 * At least XFS will redirty the inode during the
> > > > +			 * writeback (delalloc) and on io completion (isize).
> > > > +			 */
> > > > +			redirty_tail(inode);
> > > 
> > > I'd drop the mention of XFS here - any filesystem that does delayed
> > > allocation or unwritten extent conversion after Io completion will
> > > cause this. Perhaps make the comment:
> > > 
> > > 	/*
> > > 	 * Filesystems can dirty the inode during writeback
> > > 	 * operations, such as delayed allocation during submission
> > > 	 * or metadata updates after data IO completion.
> > > 	 */
> > 
> > Thanks, comments updated accordingly.
> > 
> > ---
> > writeback: don't redirty tail an inode with dirty pages
> > 
> > This avoids delaying writeback for an expired (XFS) inode with lots of
> > dirty pages, but no active dirtier at the moment. Previously we only do
> > that for the kupdate case.
> > 
> 
> You didn't actually explain the _reason_ for making this change. 
> Please always do that.

OK. It's actually extending commit b3af9468ae from the kupdate-only case to
both kupdate and !kupdate cases.

The commit documented the reason:

    Debug traces show that in per-bdi writeback, the inode under writeback
    almost always get redirtied by a busy dirtier.  We used to call
    redirty_tail() in this case, which could delay inode for up to 30s.
    
    This is unacceptable because it now happens so frequently for plain cp/dd,
    that the accumulated delays could make writeback of big files very slow.

    So let's distinguish between data redirty and metadata only redirty.
    The first one is caused by a busy dirtier, while the latter one could
    happen in XFS, NFS, etc. when they are doing delalloc or updating isize.

Commit b3af9468ae only does that for kupdate case because requeue_io() was
only called in the kupdate case. Now we are merging the kupdate and !kupdate
cases in patch 6/6 (why not?), so is this patch.

> The patch is...  surprisingly complicated, although the end result
> looks OK.  This is not aided by the partial duplication between
> mapping_tagged(PAGECACHE_TAG_DIRTY) and I_DIRTY_PAGES.  I don't think
> we can easily remove I_DIRTY_PAGES because it's used for the
> did-someone-just-dirty-a-page test here.

I double checked I_DIRTY_PAGES. The main difference to PAGECACHE_TAG_DIRTY is:
I_DIRTY_PAGES (at the line removed by this patch) means there are _new_ pages
get dirtied during writeback, while PAGECACHE_TAG_DIRTY means there are dirty
pages. In this sense, if the I_DIRTY_PAGES handling is the same as
PAGECACHE_TAG_DIRTY, the code can be merged into PAGECACHE_TAG_DIRTY, as this
patch does.

The other minor differences are

- in *_set_page_dirty*(), PAGECACHE_TAG_DIRTY is set racelessly, while
  I_DIRTY_PAGES might be set on the inode for a page just truncated.
  The difference has no real impact on this patch (it's actually
  slightly better now).

- afs_fsync() always set I_DIRTY_PAGES after calling afs_writepages().
  The call was there in the first day (introduce by David Howells).
  What was the intention, hmm..?

> This code is way too complex and fragile and I fear that anything we do
> to it will break something :(

Agreed. Let's try to simplify it :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
