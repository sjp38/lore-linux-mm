Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A03F96B0092
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 08:34:45 -0500 (EST)
Date: Sun, 7 Nov 2010 14:34:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101107133442.GE5126@quack.suse.cz>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
 <20101105223038.GA16666@lst.de>
 <20101106025548.GA16378@localhost>
 <20101106163955.GA9340@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101106163955.GA9340@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sun 07-11-10 00:39:55, Wu Fengguang wrote:
> > It's supposed to sync files in a big loop
> > 
> >         for each dirty inode
> >             write_cache_pages()
> >                 (quickly) tag currently dirty pages
> >                 (maybe slowly) sync all tagged pages
> > 
> > Ideally the loop should call write_cache_pages() _once_ for each inode.
> > At least this is the assumption made by commit f446daaea (mm:
> > implement writeback livelock avoidance using page tagging).
> 
> The above scheme relies on the filesystems to not skip pages in
> WB_SYNC_ALL mode. It seems necessary to add an explicit check at
> least in the -mm tree.
> 
> Thanks,
> Fengguang
> ---
> writeback: check skipped pages on WB_SYNC_ALL 
> 
> In WB_SYNC_ALL mode, filesystems are not expected to skip dirty pages on
> temporal lock contentions or non fatal errors, otherwise sync() will
> return without actually syncing the skipped pages. Add a check to
> catch possible redirty_page_for_writepage() callers that violate this
> expectation.
  Yes, looks like a good debugging patch.

								Honza
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-11-07 00:20:43.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-11-07 00:29:29.000000000 +0800
> @@ -527,6 +527,7 @@ static int writeback_sb_inodes(struct su
>  			 * buffers.  Skip this inode for now.
>  			 */
>  			redirty_tail(inode);
> +			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
>  		}
>  		spin_unlock(&inode_lock);
>  		iput(inode);
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
