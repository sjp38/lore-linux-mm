Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2837E6B008A
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 08:26:07 -0500 (EST)
Date: Sun, 7 Nov 2010 00:39:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101106163955.GA9340@localhost>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
 <20101105223038.GA16666@lst.de>
 <20101106025548.GA16378@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101106025548.GA16378@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2010 at 10:55:48AM +0800, Wu Fengguang wrote:
> [add CC to linux-mm list]
> 
> On Sat, Nov 06, 2010 at 06:30:38AM +0800, Christoph Hellwig wrote:
> > > +	/*
> > > +	 * In WB_SYNC_ALL mode, we just want to ignore nr_to_write as
> > > +	 * we need to write everything and livelock avoidance is implemented
> > > +	 * differently.
> > > +	 */
> > > +       if (wbc.sync_mode == WB_SYNC_NONE)
> > > +               write_chunk = MAX_WRITEBACK_PAGES;
> > > +       else
> > > +               write_chunk = LONG_MAX;
> 
> Good catch!
> 
> > 
> > I think it would be useful to elaborate here on how livelock avoidance
> > is supposed to work.
> 
> It's supposed to sync files in a big loop
> 
>         for each dirty inode
>             write_cache_pages()
>                 (quickly) tag currently dirty pages
>                 (maybe slowly) sync all tagged pages
> 
> Ideally the loop should call write_cache_pages() _once_ for each inode.
> At least this is the assumption made by commit f446daaea (mm:
> implement writeback livelock avoidance using page tagging).

The above scheme relies on the filesystems to not skip pages in
WB_SYNC_ALL mode. It seems necessary to add an explicit check at
least in the -mm tree.

Thanks,
Fengguang
---
writeback: check skipped pages on WB_SYNC_ALL 

In WB_SYNC_ALL mode, filesystems are not expected to skip dirty pages on
temporal lock contentions or non fatal errors, otherwise sync() will
return without actually syncing the skipped pages. Add a check to
catch possible redirty_page_for_writepage() callers that violate this
expectation.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next.orig/fs/fs-writeback.c	2010-11-07 00:20:43.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-07 00:29:29.000000000 +0800
@@ -527,6 +527,7 @@ static int writeback_sb_inodes(struct su
 			 * buffers.  Skip this inode for now.
 			 */
 			redirty_tail(inode);
+			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
 		}
 		spin_unlock(&inode_lock);
 		iput(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
