Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 45E6D9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:59:36 -0400 (EDT)
Date: Tue, 26 Apr 2011 21:59:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110426135931.GA12147@localhost>
References: <20110420080336.441157866@intel.com>
 <20110420080918.383880412@intel.com>
 <20110420164005.e3925965.akpm@linux-foundation.org>
 <20110424031531.GA11220@localhost>
 <20110426121751.GB5114@quack.suse.cz>
 <20110426135130.GA5719@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426135130.GA5719@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 09:51:30PM +0800, Wu Fengguang wrote:
> On Tue, Apr 26, 2011 at 08:17:51PM +0800, Jan Kara wrote:
> > On Sun 24-04-11 11:15:31, Wu Fengguang wrote:
> > > > One of the many requirements for writeback is that if userspace is
> > > > continually dirtying pages in a particular file, that shouldn't cause
> > > > the kupdate function to concentrate on that file's newly-dirtied pages,
> > > > neglecting pages from other files which were less-recently dirtied. 
> > > > (and dirty nodes, etc).
> > > 
> > > Sadly I do find the old pages that the flusher never get a chance to
> > > catch and write them out.
> >   What kind of load do you use?
> 
> Sorry I was just thinking about it and then got a _theoretic_ case.
> 
> > > In the below case, if the task dirties pages fast enough at the end of
> > > file, writeback_index will never get a chance to wrap back. There may
> > > be various variations of this case.
> > > 
> > > file head
> > > [          ***                        ==>***************]==>
> > >            old pages          writeback_index            fresh dirties
> > > 
> > > Ironically the current kernel relies on pageout() to catch these
> > > old pages, which is not only inefficient, but also not reliable.
> > > If a full LRU walk takes an hour, the old pages may stay dirtied
> > > for an hour.
> >   Well, the kupdate behavior has always been just a best-effort thing. We
> > always tried to handle well common cases but didn't try to solve all of
> > them. Unless we want to track dirty-age of every page (which we don't
> > want because it's too expensive), there is really no way to make syncing
> > of old pages 100% working for all the cases unless we do data-integrity
> > type of writeback for the whole inode - but that could create new problems
> > with stalling other files for too long I suspect.
> 
> Yeah, it's a hard problem in general. The flusher works naturally in
> the coarse way..
> 
> > > We may have to do (conditional) tagged ->writepages to safeguard users
> > > from losing data he'd expect to be written hours ago.
> >   Well, if the file is continuously written (and in your case it must be
> > even continuosly grown) I'd be content if we handle well the common case of
> > linear append (that happens for log files etc.). If we can do well for more
> > cases, even better but I'd be cautious not to disrupt some other more
> > common cases.
> 
> I scratched a patch (totally untested) which will guarantee any kind
> of starvation inside an inode. Will this be too overweight?
> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: livelock prevention inside actively dirtied files
> Date: Tue Apr 26 21:35:47 CST 2011
> 
> - refresh dirtied_when on every full writeback_index cycle
>   (pages may be skipped on SYNC_NONE, but as long as they are retried in
>   next cycle..)
> 
> - do tagged sync when writeback_index not cycled for too long time
>   (the arbitrarily 60s may lead to more page tagging overheads in
>   "large dirty threshold but slow storage" system..)
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c       |    1 +
>  include/linux/fs.h      |    1 +
>  include/linux/pagemap.h |   16 ++++++++++++++++
>  mm/page-writeback.c     |   24 ++++++++++++++++++------
>  4 files changed, 36 insertions(+), 6 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-26 21:26:28.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-26 21:26:39.000000000 +0800
> @@ -1110,6 +1110,7 @@ void __mark_inode_dirty(struct inode *in
>  			spin_unlock(&inode->i_lock);
>  			spin_lock(&bdi->wb.list_lock);
>  			inode->dirtied_when = jiffies;
> +			inode->i_mapping->writeback_cycle_time = jiffies;
>  			list_move(&inode->i_wb_list, &bdi->wb.b_dirty);
>  			spin_unlock(&bdi->wb.list_lock);
>  
> --- linux-next.orig/include/linux/fs.h	2011-04-26 21:26:28.000000000 +0800
> +++ linux-next/include/linux/fs.h	2011-04-26 21:26:39.000000000 +0800
> @@ -639,6 +639,7 @@ struct address_space {
>  	unsigned int		truncate_count;	/* Cover race condition with truncate */
>  	unsigned long		nrpages;	/* number of total pages */
>  	pgoff_t			writeback_index;/* writeback starts here */
> +	unsigned long		writeback_cycle_time;
>  	const struct address_space_operations *a_ops;	/* methods */
>  	unsigned long		flags;		/* error bits/gfp mask */
>  	struct backing_dev_info *backing_dev_info; /* device readahead, etc */

> --- linux-next.orig/mm/page-writeback.c	2011-04-26 21:26:28.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-04-26 21:33:47.000000000 +0800
> @@ -835,6 +835,9 @@ void tag_pages_for_writeback(struct addr
>  		cond_resched();
>  		/* We check 'start' to handle wrapping when end == ~0UL */
>  	} while (tagged >= WRITEBACK_TAG_BATCH && start);
> +
> +	mapping_set_tagged_sync(mapping);
> +	mapping->writeback_cycle_time = jiffies;
>  }

Sorry the above "mapping->writeback_cycle_time = jiffies" is not
correct and shall be removed. It should be updated iff (index == 0).

Thanks,
Fengguang

>  EXPORT_SYMBOL(tag_pages_for_writeback);
>  
> @@ -872,7 +875,7 @@ int write_cache_pages(struct address_spa
>  	pgoff_t end;		/* Inclusive */
>  	pgoff_t done_index;
>  	int range_whole = 0;
> -	int tag;
> +	int tag = PAGECACHE_TAG_DIRTY;
>  
>  	pagevec_init(&pvec, 0);
>  	if (wbc->range_cyclic) {
> @@ -884,13 +887,19 @@ int write_cache_pages(struct address_spa
>  		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
>  			range_whole = 1;
>  	}
> -	if (wbc->sync_mode == WB_SYNC_ALL)
> -		tag = PAGECACHE_TAG_TOWRITE;
> -	else
> -		tag = PAGECACHE_TAG_DIRTY;
> +	if (!index)
> +		mapping->writeback_cycle_time = jiffies;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
