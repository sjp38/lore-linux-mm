Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3E3F86B008A
	for <linux-mm@kvack.org>; Tue, 21 May 2013 18:39:21 -0400 (EDT)
Message-ID: <519BF796.1010403@sr71.net>
Date: Tue, 21 May 2013 15:39:18 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 24/39] thp, mm: truncate support for transparent huge
 page cache
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-25-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> If we starting position of truncation is in tail page we have to spilit
> the huge page page first.

That's a very interesting sentence sentence. :)

> We also have to split if end is within the huge page. Otherwise we can
> truncate whole huge page at once.

How about something more like this as a description?

Splitting a huge page is relatively expensive.  If at all possible, we
would like to do truncation without first splitting a page.  However, if
the truncation request starts or ends in the middle of a huge page, we
have no choice and must split it.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/truncate.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index c75b736..0152feb 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -231,6 +231,17 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			if (index > end)
>  				break;
>  
> +			/* split page if we start from tail page */
> +			if (PageTransTail(page))
> +				split_huge_page(compound_trans_head(page));

I know it makes no logical difference, but should this be an "else if"?
 It would make it more clear to me that PageTransTail() and
PageTransHead() are mutually exclusive.

> +			if (PageTransHuge(page)) {
> +				/* split if end is within huge page */
> +				if (index == (end & ~HPAGE_CACHE_INDEX_MASK))

How about:

	if ((end - index) > HPAGE_CACHE_NR)

That seems a bit more straightforward, to me at least.

> +					split_huge_page(page);
> +				else
> +					/* skip tail pages */
> +					i += HPAGE_CACHE_NR - 1;
> +			}


Hmm..  This is all inside a loop, right?

                for (i = 0; i < pagevec_count(&pvec); i++) {
                        struct page *page = pvec.pages[i];

PAGEVEC_SIZE is only 14 here, so it seems a bit odd to be incrementing i
by 512-1.  We'll break out of the pagevec loop, but won't 'index' be set
to the wrong thing on the next iteration of the loop?  Did you want to
be incrementing 'index' instead of 'i'?

This is also another case where I wonder about racing split_huge_page()
operations.

>  			if (!trylock_page(page))
>  				continue;
>  			WARN_ON(page->index != index);
> @@ -280,6 +291,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			if (index > end)
>  				break;
>  
> +			if (PageTransHuge(page))
> +				split_huge_page(page);
>  			lock_page(page);
>  			WARN_ON(page->index != index);
>  			wait_on_page_writeback(page);

This seems to imply that we would have taken care of the case where we
encountered a tail page in the first pass.  Should we put a comment in
to explain that assumption?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
