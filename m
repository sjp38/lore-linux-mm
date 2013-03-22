Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 89FAA6B006C
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 05:20:07 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514B25F5.7020207@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-3-git-send-email-kirill.shutemov@linux.intel.com>
 <514B25F5.7020207@sr71.net>
Subject: Re: [PATCHv2, RFC 02/30] mm: implement zero_huge_user_segment and
 friends
Content-Transfer-Encoding: 7bit
Message-Id: <20130322092150.5DD29E0085@blue.fi.intel.com>
Date: Fri, 22 Mar 2013 11:21:50 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > Let's add helpers to clear huge page segment(s). They provide the same
> > functionallity as zero_user_segment{,s} and zero_user, but for huge
> > pages
> ...
> > +static inline void zero_huge_user_segments(struct page *page,
> > +		unsigned start1, unsigned end1,
> > +		unsigned start2, unsigned end2)
> > +{
> > +	zero_huge_user_segment(page, start1, end1);
> > +	zero_huge_user_segment(page, start2, end2);
> > +}
> 
> I'm not sure that this helper saves very much code.  The one call later
> in these patches:
> 
> +                       zero_huge_user_segments(page, 0, from,
> +                                       from + len, HPAGE_PMD_SIZE);
> 
> really only saves one line over this:
> 
> 			zero_huge_user_segment(page, 0, from);
> 			zero_huge_user_segment(page, from + len,
> 					       HPAGE_PMD_SIZE);
> 
> and I think the second one is much more clear to read.

I've tried to mimic non-huge zero_user*, but, yeah, this is silly.
Will drop.

> I do see that there's a small-page variant of this, but I think that one
> was done to save doing two kmap_atomic() operations when you wanted to
> zero two separate operations.  This variant doesn't have that kind of
> optimization, so it makes much less sense.
> 
> > +void zero_huge_user_segment(struct page *page, unsigned start, unsigned end)
> > +{
> > +	int i;
> > +	
> > +	BUG_ON(end < start);
> > +
> > +	might_sleep();
> > +
> > +	if (start == end)
> > +		return;
> 
> I've really got to wonder how much of an optimization this is in
> practice.  Was there a specific reason this was added?

It's likely for simple_write_begin() to call zero[_huge]_user_segments()
with one of two segments start == end.

But, honestly, it was just easier to cut the corner case first and don't
bother about it in following code. ;)

> > +	/* start and end are on the same small page */
> > +	if ((start & PAGE_MASK) == ((end - 1) & PAGE_MASK))
> > +		return zero_user_segment(page + (start >> PAGE_SHIFT),
> > +				start & ~PAGE_MASK,
> > +				((end - 1) & ~PAGE_MASK) + 1);
> 
> It wasn't immediately obvious to me why we need to optimize the "on the
> same page" case.  I _think_ it's because using zero_user_segments()
> saves us a kmap_atomic() over the code below.  Is that right?  It might
> be worth a comment.

The code below will call zero_user_segment() twice for the same small
page, but here we can use just one.

I'll document it.

> > +	zero_user_segment(page + (start >> PAGE_SHIFT),
> > +			start & ~PAGE_MASK, PAGE_SIZE);
> > +	for (i = (start >> PAGE_SHIFT) + 1; i < (end >> PAGE_SHIFT) - 1; i++) {
> > +		cond_resched();
> > +		clear_highpage(page + i);
> 
> zero_user_segments() does a flush_dcache_page(), which wouldn't get done
> on these middle pages.  Is that a problem?

I think, it is. Will fix.

> > +	}
> > +	zero_user_segment(page + i, 0, ((end - 1) & ~PAGE_MASK) + 1);
> > +}
> 
> This code is dying for some local variables.  It could really use a
> 'start_pfn_offset' and 'end_pfn_offset' or something similar.  All of
> the shifting and masking is a bit hard to read and it would be nice to
> think of some real names for what it is doing.
> 
> It also desperately needs some comments about how it works.  Some
> one-liners like:
> 
> 	/* zero the first (possibly partial) page */
> 	for()..
> 		/* zero the full pages in the middle */
> 	/* zero the last (possibly partial) page */
> 
> would be pretty sweet.

Okay, will rework it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
