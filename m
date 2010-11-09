Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E7CB96B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:16:31 -0500 (EST)
Date: Wed, 10 Nov 2010 07:16:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: check skipped pages on WB_SYNC_ALL
Message-ID: <20101109231627.GA8348@localhost>
References: <20101108230916.826791396@intel.com>
 <20101108231727.275529265@intel.com>
 <20101109144728.d405453d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109144728.d405453d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 06:47:28AM +0800, Andrew Morton wrote:
> On Tue, 09 Nov 2010 07:09:21 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > In WB_SYNC_ALL mode, filesystems are not expected to skip dirty pages on
> > temporal lock contentions or non fatal errors, otherwise sync() will
> > return without actually syncing the skipped pages. Add a check to
> > catch possible redirty_page_for_writepage() callers that violate this
> > expectation.
> > 
> > I'd recommend to keep this check in -mm tree for some time and fixup the
> > possible warnings before pushing it to upstream.
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/fs-writeback.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > --- linux-next.orig/fs/fs-writeback.c	2010-11-07 22:01:06.000000000 +0800
> > +++ linux-next/fs/fs-writeback.c	2010-11-07 22:01:15.000000000 +0800
> > @@ -527,6 +527,7 @@ static int writeback_sb_inodes(struct su
> >  			 * buffers.  Skip this inode for now.
> >  			 */
> >  			redirty_tail(inode);
> > +			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);
> >  		}
> >  		spin_unlock(&inode_lock);
> >  		iput(inode);
> 
> This is quite kernel-developer-unfriendly.
> 
> Suppose the warning triggers.  Now some poor schmuck looks at the
> warning and doesn't have a *clue* why it was added.  He has to run off
> and grovel through git trees finding changelogs, which is a real pain
> if the code has been trivially altered since it was first added.
> 
> As a general rule, a kernel developer should be able to look at a
> warning callsite and then work out why the warning was emitted!
> 
> 
> IOW, you owe us a code comment, please.

Good point!

I'll add this comment.

+			/*
+			 * There's no logic to retry skipped pages for sync(),
+			 * filesystems are assumed not to skip dirty pages on
+			 * temporal lock contentions or non fatal errors.
+			 */
+			WARN_ON_ONCE(wbc->sync_mode == WB_SYNC_ALL);

IOW, if some FS triggers this warning and it's non-trivial to fix the
FS, we'll have to work out a sync retry scheme for skipped pages.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
