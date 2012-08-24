Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CED106B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 22:39:43 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep AS_HWPOISON sticky
Date: Thu, 23 Aug 2012 22:39:32 -0400
Message-Id: <1345775972-1134-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120824013118.GZ19235@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 24, 2012 at 11:31:18AM +1000, Dave Chinner wrote:
> On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> > "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> > where we have possibilities of data lost. This is because in this fix
> > AS_HWPOISON is cleared when the inode cache is dropped.
> > 
> > For example, consider an application in which a process periodically
> > (every 10 minutes) writes some logs on a file (and closes it after
> > each writes,) and at the end of each day some batch programs run using
> > the log file. If a memory error hits on dirty pagecache of this log file
> > just after periodic write/close and the inode cache is cleared before the
> > next write, then this application is not aware of the error and the batch
> > programs will work wrongly.
> > 
> > To avoid this, this patch makes us pin the hwpoisoned inode on memory
> > until we remove or completely truncate the hwpoisoned file.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  fs/inode.c              | 12 ++++++++++++
> >  include/linux/pagemap.h | 11 +++++++++++
> >  mm/memory-failure.c     |  2 +-
> >  mm/truncate.c           |  2 ++
> >  4 files changed, 26 insertions(+), 1 deletion(-)
> > 
> > diff --git v3.6-rc1.orig/fs/inode.c v3.6-rc1/fs/inode.c
> > index ac8d904..8742397 100644
> > --- v3.6-rc1.orig/fs/inode.c
> > +++ v3.6-rc1/fs/inode.c
> > @@ -717,6 +717,15 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
> >  		}
> >  
> >  		/*
> > +		 * Keep inode caches on memory for user processes to certainly
> > +		 * be aware of memory errors.
> > +		 */
> > +		if (unlikely(mapping_hwpoison(inode->i_mapping))) {
> > +			spin_unlock(&inode->i_lock);
> > +			continue;
> > +		}
> > +
> > +		/*
> >  		 * Referenced or dirty inodes are still in use. Give them
> >  		 * another pass through the LRU as we canot reclaim them now.
> >  		 */
> 
> I don't think you tested this at all. Have a look at what the loop
> does more closely - inodes with poisoned mappings will get stuck
> and reclaim doesn't make progress past them.

Sorry, I overlooked something important in my testing. I'll correct it.
Maybe we need list_move_tail() in this block.

> I think you also need to document this inode lifecycle change....

OK, I'll do it.

> > diff --git v3.6-rc1.orig/mm/truncate.c v3.6-rc1/mm/truncate.c
> > index 75801ac..82a994f 100644
> > --- v3.6-rc1.orig/mm/truncate.c
> > +++ v3.6-rc1/mm/truncate.c
> > @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
> >  
> >  	oldsize = inode->i_size;
> >  	i_size_write(inode, newsize);
> > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> > +		mapping_clear_hwpoison(inode->i_mapping);
> 
> So only a truncate to zero size will clear the poison flag?

Yes, this is because we only know if the file is affected by hwpoison,
but not where the hwpoisoned page is in the file. We could remember it,
but I did not do it for simplicity.

> What happens if it is the last page in the mapping that is poisoned,
> and we truncate that away? Shouldn't that clear the poisoned bit?

When we handle the hwpoisoned inode, the error page should already
be removed from pagecache, so the remaining pages are not related
to the error and we need not care about them when we consider bit
clearing.

> What about a hole punch over the poisoned range?

For the same reason, this is also not related to when to clear the bit.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
