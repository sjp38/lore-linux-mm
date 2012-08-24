Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 98ED06B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 13:24:26 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep AS_HWPOISON sticky
Date: Fri, 24 Aug 2012 13:24:16 -0400
Message-Id: <1345829056-7591-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120824043916.GC19235@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 24, 2012 at 02:39:17PM +1000, Dave Chinner wrote:
> On Thu, Aug 23, 2012 at 10:39:32PM -0400, Naoya Horiguchi wrote:
> > On Fri, Aug 24, 2012 at 11:31:18AM +1000, Dave Chinner wrote:
> > > On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> > > > "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> > > > where we have possibilities of data lost. This is because in this fix
> > > > AS_HWPOISON is cleared when the inode cache is dropped.
> ....
> > > > --- v3.6-rc1.orig/mm/truncate.c
> > > > +++ v3.6-rc1/mm/truncate.c
> > > > @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
> > > >  
> > > >  	oldsize = inode->i_size;
> > > >  	i_size_write(inode, newsize);
> > > > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> > > > +		mapping_clear_hwpoison(inode->i_mapping);
> > > 
> > > So only a truncate to zero size will clear the poison flag?
> > 
> > Yes, this is because we only know if the file is affected by hwpoison,
> > but not where the hwpoisoned page is in the file. We could remember it,
> > but I did not do it for simplicity.
> 
> Surely the page has flags on it to say it is poisoned? That is,
> after truncating the page cache, if the address space is poisoned,
> then you can do a pass across the mapping tree checking if there are
> any poisoned pages left? Or perhaps adding a new mapping tree tag so
> that the poisoned status is automatically determined by the presence
> of the poisoned page in the mapping tree?

The answer for the first question is yes. And for the second question,
I don't think it's easy because the mapping tree has no reference to
the error page (I explain more about this below, please see also it,)
and it can cost too much to search poisoned pages over page cache in
each request.
And for the third question, I think we could do this, but to do it
we need an additional space (8 bytes) in struct radix_tree_node.
Considering that this new tag is not used so frequently, so I'm not
sure that it's worth the cost.

> > > What happens if it is the last page in the mapping that is poisoned,
> > > and we truncate that away? Shouldn't that clear the poisoned bit?
> > 
> > When we handle the hwpoisoned inode, the error page should already
> > be removed from pagecache, so the remaining pages are not related
> > to the error and we need not care about them when we consider bit
> > clearing.
> 
> Sorry, I don't follow. What removed the page from the page cache?
> The truncate_page_cache() call that follows the above code hunk is
> what does that, so I don't see how it can already be removed from
> the page cache....

Memory error handler (memory_failure() in mm/memory-failure.c) has
removed the error page from the page cache.
And truncate_page_cache() that follows this hunk removes all pages
belonging to the page cache of the poisoned file (where the error
page itself is not included in them.)

Let me explain more to clarify my whole scenario. If a memory error
hits on a dirty pagecache, kernel works like below:

  1. handles a MCE interrupt (logging MCE events,)
  2. calls memory error handler (doing 3 to 6,)
  3. sets PageHWPoison flag on the error page,
  4. unmaps all mappings to processes' virtual addresses,
  5. sets AS_HWPOISON on mappings to which the error page belongs
  6. invalidates the error page (unlinks it from LRU list and removes
     it from pagecache,)
  (memory error handler finished)
  7. later accesses to the file returns -EIO,
  8. AS_HWPOISON is cleared when the file is removed or completely
     truncated.

This patchset tries to fix the problem in 7 and add a new behavior 8,
where I have an assumption that 1-6 has already worked out.

You may think it strange that the condition of clearing AS_HWPOISON
is checked with file granularity. This is because currently userspace
applications know the memory errors only with file granularity for
simplicity, when they access via read(), write() and/or fsync().
(Only for access via mmap(), error reporting is with page granularity.)
We can do it with page granularity, and I tried 2 approaches:

  a. "adding a new tag in mapping tree" approach
     as I explained above, this needs an additional space on heavily
     used data structure,
  b. "adding a new data structure specific to dirty pagecache error
     management" approach
     I did this in the 1st version of this patchset, but found that
     it's too complicated as the first step.

But I think both of these are some difficulty to be accepted,
so at first I try to start with simpler one.

> > > What about a hole punch over the poisoned range?
> > 
> > For the same reason, this is also not related to when to clear the bit.
> 
> Sure it is - if you remove the poisoned pages from the mapping when
> the hole is punched, then the mapping is no longer poisoned. Hence
> the bit should be cleared at that time as nothing else will ever
> clear it.

If we achieve error reporting with the page granularity, I hope we can
also do this easily.

Do I answer all your questions? If not, please let me know.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
