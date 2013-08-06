Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D20156B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 17:55:41 -0400 (EDT)
Message-ID: <520170CA.4040409@sr71.net>
Date: Tue, 06 Aug 2013 14:55:22 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 19/23] truncate: support huge pages
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com> <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/03/2013 07:17 PM, Kirill A. Shutemov wrote:
> If a huge page is only partly in the range we zero out the part,
> exactly like we do for partial small pages.

What's the logic behind this behaviour?  Seems like the kind of place
that we would really want to be splitting pages.

> +	if (partial_thp_start || lstart & ~PAGE_CACHE_MASK) {
> +		pgoff_t off;
> +		struct page *page;
> +		unsigned pstart, pend;
> +		void (*zero_segment)(struct page *page,
> +				unsigned start, unsigned len);
> +retry_partial_start:
> +		if (partial_thp_start) {
> +			zero_segment = zero_huge_user_segment;

That's a pretty hackish way to conditionally call a function, especially
since its done twice in one function. :)

I seem to recall zero_user_segment() vs. zero_huge_user_segment() being
something that caused some ugliness in the previous versions too.
What's the barrier to just having a smart zero_..._user_segment()
function that can conditionally perform huge or base page-zeroing?

> +		if (partial_thp_end) {
> +			zero_segment = zero_huge_user_segment;
> +			off = end & ~HPAGE_CACHE_INDEX_MASK;
> +			pend = (lend - 1) & ~HPAGE_PMD_MASK;
> +		} else {
> +			zero_segment = zero_user_segment;
> +			off = end;
> +			pend = (lend - 1) & ~PAGE_CACHE_MASK;
> +		}

We went though a similar exercise for the fault code (I think), but I
really think you need to refactor this.  Way too much of the code is in
the style:

	if (thp) {
		// new behavior
	} else {
		// old behavior
	}

To me, that's just a recipe that makes it hard to review, and I also bet
it'll make the thp much more prone to bitrot.  Maybe something like this?

	size_t page_cache_mask = PAGE_CACHE_MASK;
	unsigned long end_mask = 0UL;
	
	if (partial_thp_end) {
		page_cache_mask = HPAGE_PMD_MASK;
		end_mask = HPAGE_CACHE_INDEX_MASK;
	}
	...
	magic_zero_user_segment(...);
	off = end & ~end_mask;
	pend = (lend - 1) & ~page_cache_mask;

Like I said before, I somehow like to rewrite your code. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
