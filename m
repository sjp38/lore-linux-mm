Date: Thu, 10 Jan 2008 18:16:43 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [vm] writing to UDF DVD+RW (/dev/sr0) while under memory
	pressure: box ==> doorstop
Message-ID: <20080110171643.GF12697@duck.suse.cz>
References: <1199642470.3927.12.camel@homer.simson.net> <20080106122954.d8f04c98.akpm@linux-foundation.org> <1199790316.4094.57.camel@homer.simson.net> <20080108033801.40d0043a.akpm@linux-foundation.org> <1199805713.3571.12.camel@homer.simson.net> <1199806071.4174.2.camel@homer.simson.net> <1199877080.4340.19.camel@homer.simson.net> <20080109150139.311f68d3.akpm@linux-foundation.org> <20080110144123.GA12331@atrey.karlin.mff.cuni.cz> <1199978990.4196.53.camel@homer.simson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199978990.4196.53.camel@homer.simson.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bfennema@falcon.csc.calpoly.edu
List-ID: <linux-mm.kvack.org>

On Thu 10-01-08 16:29:50, Mike Galbraith wrote:
> 
> On Thu, 2008-01-10 at 15:41 +0100, Jan Kara wrote:
> > > On Wed, 09 Jan 2008 12:11:20 +0100
> > > 
> > > 
> > > I wonder why UDF was doing a synchronous write in there.  In fact I wonder
> > > why it's writing the inode at all?  extN doesn't do that.  If for some
> > > reason it really does want to make the inode immediately reclaimable then
> > > simply shoving it down into the /dev/hda1 pagecache should be sufficient
> > > (ie: what you did)..
> >   Looking at the code, I think UDF change is correct. UDF has to call
> > write_inode_now() because by the time clear_inode() is called, inode is
> > already written by VFS and prepared to be freed. But then UDF modifies
> > it in udf_clear_inode() (removes preallocation) and for these changes to
> > get to disk you have to write the inode explicitely. 
> >   But there's really no need to wait on IO. We only have to copy all
> > data from inode structure into buffers and that happens even if we don't
> > wait on sync.
> 
> Perhaps I should go ahead and submit it then.  There are 5 other async
> callers as well, so VM/UDF reclaim buglet can die, and those others can
> get what they asked for with net diffstat of 0.
> 
> Fix udf_clear_inode() to request asynchronous writeout in icache reclaim
> path, and ensure that write_inore_now() honors that request, lest
> allocators needlessly block on iprune_mutex.
> 
> Signed-off-by: Mike Galbraith <efault@gmx.de>
  Acked-by: Jan Kara <jack@suse.cz>
  if it's worth anything ;)
									Honza

> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 0fca820..f1cce24 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -657,7 +657,7 @@ int write_inode_now(struct inode *inode, int sync)
>  	int ret;
>  	struct writeback_control wbc = {
>  		.nr_to_write = LONG_MAX,
> -		.sync_mode = WB_SYNC_ALL,
> +		.sync_mode = sync ? WB_SYNC_ALL : WB_SYNC_NONE,
>  		.range_start = 0,
>  		.range_end = LLONG_MAX,
>  	};
> diff --git a/fs/udf/inode.c b/fs/udf/inode.c
> index 6ff8151..d1fc116 100644
> --- a/fs/udf/inode.c
> +++ b/fs/udf/inode.c
> @@ -117,7 +117,7 @@ void udf_clear_inode(struct inode *inode)
>  		udf_discard_prealloc(inode);
>  		udf_truncate_tail_extent(inode);
>  		unlock_kernel();
> -		write_inode_now(inode, 1);
> +		write_inode_now(inode, 0);
>  	}
>  	kfree(UDF_I_DATA(inode));
>  	UDF_I_DATA(inode) = NULL;
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
