Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 586666B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:33 -0500 (EST)
Date: Thu, 16 Feb 2012 22:06:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120216140625.GA26138@localhost>
References: <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
 <20120213154313.GD6478@quack.suse.cz>
 <20120214100348.GA7000@localhost>
 <20120214132950.GE1934@quack.suse.cz>
 <20120216040019.GB17597@localhost>
 <20120216124445.GB18613@quack.suse.cz>
 <20120216133233.GA13369@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120216133233.GA13369@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Feb 16, 2012 at 09:32:33PM +0800, Wu Fengguang wrote:
> On Thu, Feb 16, 2012 at 01:44:45PM +0100, Jan Kara wrote:
> > On Thu 16-02-12 12:00:19, Wu Fengguang wrote:
> > > On Tue, Feb 14, 2012 at 02:29:50PM +0100, Jan Kara wrote:
> 
> > > > > > > +/*
> > > > > > > + * schedule writeback on a range of inode pages.
> > > > > > > + */
> > > > > > > +static struct wb_writeback_work *
> > > > > > > +bdi_flush_inode_range(struct backing_dev_info *bdi,
> > > > > > > +		      struct inode *inode,
> > > > > > > +		      pgoff_t offset,
> > > > > > > +		      pgoff_t len,
> > > > > > > +		      bool wait)
> > > > > > > +{
> > > > > > > +	struct wb_writeback_work *work;
> > > > > > > +
> > > > > > > +	if (!igrab(inode))
> > > > > > > +		return ERR_PTR(-ENOENT);
> > > > > >   One technical note here: If the inode is deleted while it is queued, this
> > > > > > reference will keep it living until flusher thread gets to it. Then when
> > > > > > flusher thread puts its reference, the inode will get deleted in flusher
> > > > > > thread context. I don't see an immediate problem in that but it might be
> > > > > > surprising sometimes. Another problem I see is that if you try to
> > > > > > unmount the filesystem while the work item is queued, you'll get EBUSY for
> > > > > > no apparent reason (for userspace).
> > > > > 
> > > > > Yeah, we need to make umount work.
> > > >   The positive thing is that if the inode is reaped while the work item is
> > > > queue, we know all that needed to be done is done. So we don't really need
> > > > to pin the inode.
> > > 
> > > But I do need to make sure the *inode pointer does not point to some
> > > invalid memory at work exec time. Is this possible without raising
> > > ->i_count?
> >   I was thinking about it and what should work is that we have inode
> > reference in work item but in generic_shutdown_super() we go through
> > the worklist and drop all work items for superblock before calling
> > evict_inodes()...
> 
> Good point!
> 
> This diff removes the works after the sync_filesystem(sb) call.  After
> which, no more dirty pages are expected on that sb (otherwise the
> umount will fail anyway), hence no more pageout works will be queued
> for that sb.
> 
> +static void wb_free_work(struct wb_writeback_work *work)
> +{
> +	/*
> +	 * Notify the caller of completion if this is a synchronous
> +	 * work item, otherwise just free it.
> +	 */
> +	if (work->done)
> +		complete(work->done);
> +	else
> +		mempool_free(work, wb_work_mempool);
> +}
> +
> +/*
> + * Remove works for @sb; or if (@sb == NULL), remove all works on @bdi.
> + */
> +void bdi_remove_works(struct backing_dev_info *bdi, struct super_block *sb)
> +{
> +	struct inode *inode = mapping->host;
> +	struct wb_writeback_work *work;
> +
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_safe(work, &bdi->work_list, list) {
> +		if (work->inode && work->inode->i_sb == sb) {
> +			iput(inode);
> +		} else if (sb && work->sb != sb)
> +			continue;
> +
> +		list_del_init(&work->list);
> +		wb_free_work(work);
> +	}
> +	spin_unlock_bh(&bdi->wb_lock);
> +}

Sorry, this corrected function actually compiles:

+/* 
+ * Remove works for @sb; or if (@sb == NULL), remove all works on @bdi. 
+ */ 
+void bdi_remove_works(struct backing_dev_info *bdi, struct super_block *sb) 
+{ 
+       struct wb_writeback_work *work, *tmp; 
+       LIST_HEAD(works); 
+ 
+       spin_lock_bh(&bdi->wb_lock); 
+       list_for_each_entry_safe(work, tmp, &bdi->work_list, list) { 
+               if (sb) { 
+                       if (work->sb && work->sb != sb) 
+                               continue; 
+                       if (work->inode && work->inode->i_sb != sb) 
+                               continue; 
+               } 
+               list_move(&work->list, &works); 
+       } 
+       spin_unlock_bh(&bdi->wb_lock); 
+ 
+       while (!list_empty(&works)) { 
+               work = list_entry(works.next, 
+                                 struct wb_writeback_work, list); 
+               list_del_init(&work->list); 
+               if (work->inode) 
+                       iput(work->inode); 
+               wb_free_work(work); 
+       } 
+} 

> --- linux.orig/fs/super.c	2012-02-16 21:08:09.000000000 +0800
> +++ linux/fs/super.c	2012-02-16 21:22:19.000000000 +0800
> @@ -389,6 +389,7 @@ void generic_shutdown_super(struct super
>  
>  		fsnotify_unmount_inodes(&sb->s_inodes);
>  
> +		bdi_remove_works(sb->s_bdi, sb);
>  		evict_inodes(sb);
>  
>  		if (sop->put_super)
> 
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
