Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BCCB56B0027
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 11:22:22 -0400 (EDT)
Message-ID: <514B25F5.7020207@sr71.net>
Date: Thu, 21 Mar 2013 08:23:33 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 02/30] mm: implement zero_huge_user_segment and
 friends
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-3-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> Let's add helpers to clear huge page segment(s). They provide the same
> functionallity as zero_user_segment{,s} and zero_user, but for huge
> pages
...
> +static inline void zero_huge_user_segments(struct page *page,
> +		unsigned start1, unsigned end1,
> +		unsigned start2, unsigned end2)
> +{
> +	zero_huge_user_segment(page, start1, end1);
> +	zero_huge_user_segment(page, start2, end2);
> +}

I'm not sure that this helper saves very much code.  The one call later
in these patches:

+                       zero_huge_user_segments(page, 0, from,
+                                       from + len, HPAGE_PMD_SIZE);

really only saves one line over this:

			zero_huge_user_segment(page, 0, from);
			zero_huge_user_segment(page, from + len,
					       HPAGE_PMD_SIZE);

and I think the second one is much more clear to read.

I do see that there's a small-page variant of this, but I think that one
was done to save doing two kmap_atomic() operations when you wanted to
zero two separate operations.  This variant doesn't have that kind of
optimization, so it makes much less sense.

> +void zero_huge_user_segment(struct page *page, unsigned start, unsigned end)
> +{
> +	int i;
> +	
> +	BUG_ON(end < start);
> +
> +	might_sleep();
> +
> +	if (start == end)
> +		return;

I've really got to wonder how much of an optimization this is in
practice.  Was there a specific reason this was added?

> +	/* start and end are on the same small page */
> +	if ((start & PAGE_MASK) == ((end - 1) & PAGE_MASK))
> +		return zero_user_segment(page + (start >> PAGE_SHIFT),
> +				start & ~PAGE_MASK,
> +				((end - 1) & ~PAGE_MASK) + 1);

It wasn't immediately obvious to me why we need to optimize the "on the
same page" case.  I _think_ it's because using zero_user_segments()
saves us a kmap_atomic() over the code below.  Is that right?  It might
be worth a comment.

> +	zero_user_segment(page + (start >> PAGE_SHIFT),
> +			start & ~PAGE_MASK, PAGE_SIZE);
> +	for (i = (start >> PAGE_SHIFT) + 1; i < (end >> PAGE_SHIFT) - 1; i++) {
> +		cond_resched();
> +		clear_highpage(page + i);

zero_user_segments() does a flush_dcache_page(), which wouldn't get done
on these middle pages.  Is that a problem?

> +	}
> +	zero_user_segment(page + i, 0, ((end - 1) & ~PAGE_MASK) + 1);
> +}

This code is dying for some local variables.  It could really use a
'start_pfn_offset' and 'end_pfn_offset' or something similar.  All of
the shifting and masking is a bit hard to read and it would be nice to
think of some real names for what it is doing.

It also desperately needs some comments about how it works.  Some
one-liners like:

	/* zero the first (possibly partial) page */
	for()..
		/* zero the full pages in the middle */
	/* zero the last (possibly partial) page */

would be pretty sweet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
