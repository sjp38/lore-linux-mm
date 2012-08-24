Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 194526B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 00:39:21 -0400 (EDT)
Date: Fri, 24 Aug 2012 14:39:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep
 AS_HWPOISON sticky
Message-ID: <20120824043916.GC19235@dastard>
References: <20120824013118.GZ19235@dastard>
 <1345775972-1134-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345775972-1134-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 23, 2012 at 10:39:32PM -0400, Naoya Horiguchi wrote:
> On Fri, Aug 24, 2012 at 11:31:18AM +1000, Dave Chinner wrote:
> > On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> > > "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> > > where we have possibilities of data lost. This is because in this fix
> > > AS_HWPOISON is cleared when the inode cache is dropped.
....
> > > --- v3.6-rc1.orig/mm/truncate.c
> > > +++ v3.6-rc1/mm/truncate.c
> > > @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
> > >  
> > >  	oldsize = inode->i_size;
> > >  	i_size_write(inode, newsize);
> > > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> > > +		mapping_clear_hwpoison(inode->i_mapping);
> > 
> > So only a truncate to zero size will clear the poison flag?
> 
> Yes, this is because we only know if the file is affected by hwpoison,
> but not where the hwpoisoned page is in the file. We could remember it,
> but I did not do it for simplicity.

Surely the page has flags on it to say it is poisoned? That is,
after truncating the page cache, if the address space is poisoned,
then you can do a pass across the mapping tree checking if there are
any poisoned pages left? Or perhaps adding a new mapping tree tag so
that the poisoned status is automatically determined by the presence
of the poisoned page in the mapping tree?

> > What happens if it is the last page in the mapping that is poisoned,
> > and we truncate that away? Shouldn't that clear the poisoned bit?
> 
> When we handle the hwpoisoned inode, the error page should already
> be removed from pagecache, so the remaining pages are not related
> to the error and we need not care about them when we consider bit
> clearing.

Sorry, I don't follow. What removed the page from the page cache?
The truncate_page_cache() call that follows the above code hunk is
what does that, so I don't see how it can already be removed from
the page cache....

> > What about a hole punch over the poisoned range?
> 
> For the same reason, this is also not related to when to clear the bit.

Sure it is - if you remove the poisoned pages from the mapping when
the hole is punched, then the mapping is no longer poisoned. Hence
the bit should be cleared at that time as nothing else will ever
clear it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
