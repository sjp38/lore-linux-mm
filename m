Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 372A66B0035
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 02:24:13 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id k14so2865306wgh.23
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 23:24:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bb9si5439789wjb.139.2014.03.14.23.24.10
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 23:24:11 -0700 (PDT)
Date: Sat, 15 Mar 2014 02:23:41 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5323f20b.e957c20a.599b.ffffbf83SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140315031759.GC22728@two.firstfloor.org>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1394746786-6397-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140315031759.GC22728@two.firstfloor.org>
Subject: Re: [PATCH 2/6] mm/memory-failure.c: report and recovery for memory
 error on dirty pagecache
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andi@firstfloor.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, tony.luck@intel.com, liwanp@linux.vnet.ibm.com, david@fromorbit.com, j-nomura@ce.jp.nec.com, linux-mm@kvack.org

On Sat, Mar 15, 2014 at 04:17:59AM +0100, Andi Kleen wrote:
> On Thu, Mar 13, 2014 at 05:39:42PM -0400, Naoya Horiguchi wrote:
> > Unifying error reporting between memory error and normal IO errors is ideal
> > in a long run, but at first let's solve it separately. I hope that some code
> > in this patch will be helpful when thinking of the unification.
> 
> The mechanisms should be very similar, right? 

Yes.

> It may be better to do both at the same time.

Yes, it's better, but it's not trivial to test and confirm that patches
work fine (and I must learn more about IO error.)
But anyway, I'll try this maybe in next post.

> > index 60829565e552..1e8966919044 100644
> > --- v3.14-rc6.orig/include/linux/fs.h
> > +++ v3.14-rc6/include/linux/fs.h
> > @@ -475,6 +475,9 @@ struct block_device {
> >  #define PAGECACHE_TAG_DIRTY	0
> >  #define PAGECACHE_TAG_WRITEBACK	1
> >  #define PAGECACHE_TAG_TOWRITE	2
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +#define PAGECACHE_TAG_HWPOISON	3
> > +#endif
> 
> No need to ifdef defines

OK, I found that if CONFIG_MEMORY_FAILURE is n no one sets/checks this flag,
so it's not problematic that the number of PAGECACHE_TAG_* is more than
RADIX_TREE_MAX_TAGS (3 if !CONFIG_MEMORY_FAILURE). I'll remove this ifdef.

> > @@ -1133,6 +1139,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
> >  			if (unlikely(page == NULL))
> >  				goto no_cached_page;
> >  		}
> > +		if (unlikely(PageHWPoison(page))) {
> > +			error = -EHWPOISON;
> > +			goto readpage_error;
> > +		}
> 
> Didn't we need this check before independent of the rest of the patch?

I think this check should come with the rest of this patch, because before
this patchset, we have no page with PageHWPoison on pagecache (memory_failure()
removes it from pagecache via me_pagecache_clean(),) so the above check can't
detect error-affected address. Dummy hwpoison page introduced by this patch
makes it detectable.

> >  		if (PageReadahead(page)) {
> >  			page_cache_async_readahead(mapping,
> >  					ra, filp, page,
> > @@ -2100,6 +2110,10 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
> >          if (unlikely(*pos < 0))
> >                  return -EINVAL;
> >  
> > +	if (unlikely(mapping_hwpoisoned_range(file->f_mapping, *pos,
> > +					      *pos + *count)))
> > +		return -EHWPOISON;
> 
> How expensive is that check? This will happen on every write.
> Can it be somehow combined with the normal page cache lookup?

OK, so it's better to put this check just after a_ops->write_begin in
generic_perform_write(). If we find PageHWPoison, we break the do-while loop,
then we can do write correctly for healthy address before the error address.

> >   * Dirty pagecache page
> > + *
> > + * Memory error reporting (important especially on dirty pagecache error
> > + * because dirty data is lost) with AS_EIO flag has some problems:
> 
> It doesn't make sense to have changelogs in comments. That is what
> git is for.  At some point noone will care about the previous code.

Right, I'll remove this.

> > + * To solve these, we handle dirty pagecache errors by replacing the error
> 
> This part of the comment is good.
> 
> > +	pgoff_t index;
> > +	struct inode *inode = NULL;
> > +	struct page *new;
> >  
> >  	SetPageError(p);
> > -	/* TBD: print more information about the file. */
> >  	if (mapping) {
> > +		index = page_index(p);
> > +		/*
> > +		 * we take inode refcount to keep it's pagecache or mapping
> > +		 * on the memory until the error is resolved.
> 
> How does that work? Who "resolves" the error? 

This comment should have come with patch 3 which adds the resolver.
# I at first wrote a patch with patch 2 and 3 merged and after separated it,
# and my splitting was poor. I'll fix this.

> > +		 */
> > +		inode = igrab(mapping->host);
> > +		pr_info("MCE %#lx: memory error on dirty pagecache (page offset:%lu, inode:%lu, dev:%s)\n",
> 
> Add the word file somewhere, you need to explain this in terms normal
> sysadmins and not only kernel hackers can understand.

OK, so "MCE %#lx: memory error on dirty file cache (page offset:%lu, inode:%lu, dev:%s)\n"
looks better to me.

Thank you very much for close looking.
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
