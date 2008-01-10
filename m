Date: Thu, 10 Jan 2008 15:41:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [vm] writing to UDF DVD+RW (/dev/sr0) while under memory pressure: box ==> doorstop
Message-ID: <20080110144123.GA12331@atrey.karlin.mff.cuni.cz>
References: <1199447212.4529.13.camel@homer.simson.net> <1199612533.4384.54.camel@homer.simson.net> <1199642470.3927.12.camel@homer.simson.net> <20080106122954.d8f04c98.akpm@linux-foundation.org> <1199790316.4094.57.camel@homer.simson.net> <20080108033801.40d0043a.akpm@linux-foundation.org> <1199805713.3571.12.camel@homer.simson.net> <1199806071.4174.2.camel@homer.simson.net> <1199877080.4340.19.camel@homer.simson.net> <20080109150139.311f68d3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080109150139.311f68d3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Galbraith <efault@gmx.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 09 Jan 2008 12:11:20 +0100
> Mike Galbraith <efault@gmx.de> wrote:
> 
> > 
> > On Tue, 2008-01-08 at 16:27 +0100, Mike Galbraith wrote:
> > > On Tue, 2008-01-08 at 16:21 +0100, Mike Galbraith wrote:
> > > > On Tue, 2008-01-08 at 03:38 -0800, Andrew Morton wrote:
> > > > > 
> > > > > Well.  From your earlier trace it appeared that something was causing
> > > > > the filesystem to perform synchronous inode writes - sync_dirty_buffer() was
> > > > > called.
> > > > > 
> > > > > This will cause many more seeks than would occur if we were doing full
> > > > > delayed writing, with obvious throughput implications.
> > > > 
> > > > Yes, with UDF, the IO was _incredibly_ slow.  With ext2, it was better,
> > > > though still very bad.  I tested with that other OS, and it gets ~same
> > > > throughput with UDF as I got with ext2 (ick).
> > > > 
> > > > UDF does udf_clear_inode() -> write_inode_now(inode, 1)
> > > > 
> > > > I suppose I could try write_inode_now(inode, 0).  Might unstick the box.
> > > 
> > > (nope, still sync, UDF still deadly)
> > 
> > write_inode_now() is a fibber.
> 
> Sure is.  Looks like it was busted by:
> 
> commit fa94396d2792f5093aab7cf66e1fc1da0c9fc442
> Author: akpm <akpm>
> Date:   Tue Feb 4 17:01:43 2003 +0000
> 
>     [PATCH] Remove unneeded code in fs/fs-writeback.c
>     
>     We do not need to pass the `wait' argument down to __sync_single_inode().
>     That information is now present at wbc->sync_mode.
>     
> 
> > The below seems to fix it in that writes dribbling to the DVD+RW at the
> > whopping 1 to 10 pages/sec I'm seeing no longer turn box into a
> > doorstop.  It's probably busted as heck.
> 
> The VFS change looks good.  Not sure about the UDF details.
> 
> > Think I'll cc linux-mm, and go find something safer to play with.
> > 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 0fca820..f1cce24 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -657,7 +657,7 @@ int write_inode_now(struct inode *inode, int sync)
> >  	int ret;
> >  	struct writeback_control wbc = {
> >  		.nr_to_write = LONG_MAX,
> > -		.sync_mode = WB_SYNC_ALL,
> > +		.sync_mode = sync ? WB_SYNC_ALL : WB_SYNC_NONE,
> >  		.range_start = 0,
> >  		.range_end = LLONG_MAX,
> >  	};
> > diff --git a/fs/udf/inode.c b/fs/udf/inode.c
> > index 6ff8151..d1fc116 100644
> > --- a/fs/udf/inode.c
> > +++ b/fs/udf/inode.c
> > @@ -117,7 +117,7 @@ void udf_clear_inode(struct inode *inode)
> >  		udf_discard_prealloc(inode);
> >  		udf_truncate_tail_extent(inode);
> >  		unlock_kernel();
> > -		write_inode_now(inode, 1);
> > +		write_inode_now(inode, 0);
> >  	}
> >  	kfree(UDF_I_DATA(inode));
> >  	UDF_I_DATA(inode) = NULL;
> > 
> 
> WB_SYNC_* should die.
> 
> I wonder why UDF was doing a synchronous write in there.  In fact I wonder
> why it's writing the inode at all?  extN doesn't do that.  If for some
> reason it really does want to make the inode immediately reclaimable then
> simply shoving it down into the /dev/hda1 pagecache should be sufficient
> (ie: what you did)..
  Looking at the code, I think UDF change is correct. UDF has to call
write_inode_now() because by the time clear_inode() is called, inode is
already written by VFS and prepared to be freed. But then UDF modifies
it in udf_clear_inode() (removes preallocation) and for these changes to
get to disk you have to write the inode explicitely. 
  But there's really no need to wait on IO. We only have to copy all
data from inode structure into buffers and that happens even if we don't
wait on sync.

								Honza
-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
