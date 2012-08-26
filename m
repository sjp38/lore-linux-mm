Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id D07D56B002B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 18:26:14 -0400 (EDT)
Date: Mon, 27 Aug 2012 08:26:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep
 AS_HWPOISON sticky
Message-ID: <20120826222607.GD19235@dastard>
References: <20120824043916.GC19235@dastard>
 <1345829056-7591-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345829056-7591-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 24, 2012 at 01:24:16PM -0400, Naoya Horiguchi wrote:
> On Fri, Aug 24, 2012 at 02:39:17PM +1000, Dave Chinner wrote:
> > On Thu, Aug 23, 2012 at 10:39:32PM -0400, Naoya Horiguchi wrote:
> > > On Fri, Aug 24, 2012 at 11:31:18AM +1000, Dave Chinner wrote:
> > > > On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> > > > > "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> > > > > where we have possibilities of data lost. This is because in this fix
> > > > > AS_HWPOISON is cleared when the inode cache is dropped.
> > ....
> > > > > --- v3.6-rc1.orig/mm/truncate.c
> > > > > +++ v3.6-rc1/mm/truncate.c
> > > > > @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
> > > > >  
> > > > >  	oldsize = inode->i_size;
> > > > >  	i_size_write(inode, newsize);
> > > > > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> > > > > +		mapping_clear_hwpoison(inode->i_mapping);
> > > > 
> > > > So only a truncate to zero size will clear the poison flag?
> > > 
> > > Yes, this is because we only know if the file is affected by hwpoison,
> > > but not where the hwpoisoned page is in the file. We could remember it,
> > > but I did not do it for simplicity.
> > 
> > Surely the page has flags on it to say it is poisoned? That is,
> > after truncating the page cache, if the address space is poisoned,
> > then you can do a pass across the mapping tree checking if there are
> > any poisoned pages left? Or perhaps adding a new mapping tree tag so
> > that the poisoned status is automatically determined by the presence
> > of the poisoned page in the mapping tree?
> 
> The answer for the first question is yes. And for the second question,
> I don't think it's easy because the mapping tree has no reference to
> the error page (I explain more about this below, please see also it,)
> and it can cost too much to search poisoned pages over page cache in
> each request.

Which is my point about a radix tree tag - that's very efficient.

> And for the third question, I think we could do this, but to do it
> we need an additional space (8 bytes) in struct radix_tree_node.
> Considering that this new tag is not used so frequently, so I'm not
> sure that it's worth the cost.

A radix tree node is currently 560 bytes on x86_64, packed 7 to a
page. i.e. using 3920 bytes. We can add another 8 bytes to it
without increasing memory usage at all. So, no cost at all.

> > > > What happens if it is the last page in the mapping that is poisoned,
> > > > and we truncate that away? Shouldn't that clear the poisoned bit?
> > > 
> > > When we handle the hwpoisoned inode, the error page should already
> > > be removed from pagecache, so the remaining pages are not related
> > > to the error and we need not care about them when we consider bit
> > > clearing.
> > 
> > Sorry, I don't follow. What removed the page from the page cache?
> > The truncate_page_cache() call that follows the above code hunk is
> > what does that, so I don't see how it can already be removed from
> > the page cache....
> 
> Memory error handler (memory_failure() in mm/memory-failure.c) has
> removed the error page from the page cache.
> And truncate_page_cache() that follows this hunk removes all pages
> belonging to the page cache of the poisoned file (where the error
> page itself is not included in them.)
> 
> Let me explain more to clarify my whole scenario. If a memory error
> hits on a dirty pagecache, kernel works like below:
> 
>   1. handles a MCE interrupt (logging MCE events,)
>   2. calls memory error handler (doing 3 to 6,)
>   3. sets PageHWPoison flag on the error page,
>   4. unmaps all mappings to processes' virtual addresses,

So nothing in userspace sees the bad page after this.

>   5. sets AS_HWPOISON on mappings to which the error page belongs
>   6. invalidates the error page (unlinks it from LRU list and removes
>      it from pagecache,)
>   (memory error handler finished)

Ok, so the moment a memory error is handled, the page has been
removed from the inode's mapping, and it will never be seen by
aplications again. It's a transient error....

>   7. later accesses to the file returns -EIO,
>   8. AS_HWPOISON is cleared when the file is removed or completely
>      truncated.

.... so why do we have to keep an EIO on the inode forever?

If the page is not dirty, then just tossing it from the cache (as
is already done) and rereading it from disk next time it is accessed
removes the need for any error to be reported at all. It's
effectively a transient error at this point, and as such no errors
should be visible from userspace.

If the page is dirty, then it needs to be treated just like any
other failed page write - the page is invalidated and the address
space is marked with AS_EIO, and that is reported to the next
operation that waits on IO on that file (i.e. fsync)

If you have a second application that reads the files that depends
on a guarantee of good data, then the first step in that process is
that application that writes it needs to use fsync to check the data
was written correctly. That ensures that you only have clean pages
in the cache before the writer closes the file, and any h/w error
then devolves to the above transient clean page invalidation case.

Hence I fail to see why this type of IO error needs to be sticky.
The error on the mapping is transient - it is gone as soon as the
page is removed from the mapping. Hence the error can be dropped as
soon as it is reported to userspace because the mapping is now error
free.

> You may think it strange that the condition of clearing AS_HWPOISON
> is checked with file granularity.

I don't think it is strange, I think it is *wrong*.

> This is because currently userspace
> applications know the memory errors only with file granularity for
> simplicity, when they access via read(), write() and/or fsync().

Trying to report this error to every potential future access
regardless of whether the error still exists or the access is to the
poisoned range with magical sticky errors on inode address spaces
and hacks to memory the reclaim subsystems smells to me like a really
bad hack to work around applications that use bad data integrity
practices.

As such, I think you probably need to rethink the approach you are
taking to handling this error. The error is transient w.r.t. to the
mapping and page cache, and needs to be addressed consistently
compared to other transient IO errors that are reported through the
mapping....

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
