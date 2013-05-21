Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 270AD6B0080
	for <linux-mm@kvack.org>; Tue, 21 May 2013 17:49:44 -0400 (EDT)
Message-ID: <519BEBF5.4060309@sr71.net>
Date: Tue, 21 May 2013 14:49:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 21/39] thp, libfs: initial support of thp in simple_read/write_begin/write_end
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-22-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> For now we try to grab a huge cache page if gfp_mask has __GFP_COMP.
> It's probably to weak condition and need to be reworked later.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/libfs.c              |   50 ++++++++++++++++++++++++++++++++++++-----------
>  include/linux/pagemap.h |    8 ++++++++
>  2 files changed, 47 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/libfs.c b/fs/libfs.c
> index 916da8c..ce807fe 100644
> --- a/fs/libfs.c
> +++ b/fs/libfs.c
> @@ -383,7 +383,7 @@ EXPORT_SYMBOL(simple_setattr);
>  
>  int simple_readpage(struct file *file, struct page *page)
>  {
> -	clear_highpage(page);
> +	clear_pagecache_page(page);
>  	flush_dcache_page(page);
>  	SetPageUptodate(page);
>  	unlock_page(page);
> @@ -394,21 +394,44 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned flags,
>  			struct page **pagep, void **fsdata)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
>  	pgoff_t index;

I know ramfs uses simple_write_begin(), but it's not the only one.  I
think you probably want to create a new ->write_begin() function just
for ramfs rather than modifying this one.

The optimization that you just put in a few patches ago:

>> +static inline struct page *grab_cache_page_write_begin(
>> +{
>> +	if (!transparent_hugepage_pagecache() && (flags & AOP_FLAG_TRANSHUGE))
>> +		return NULL;
>> +	return __grab_cache_page_write_begin(mapping, index, flags);


is now worthless for any user of simple_readpage().

>  	index = pos >> PAGE_CACHE_SHIFT;
>  
> -	page = grab_cache_page_write_begin(mapping, index, flags);
> +	/* XXX: too weak condition? */

Why would it be too weak?

> +	if (mapping_can_have_hugepages(mapping)) {
> +		page = grab_cache_page_write_begin(mapping,
> +				index & ~HPAGE_CACHE_INDEX_MASK,
> +				flags | AOP_FLAG_TRANSHUGE);
> +		/* fallback to small page */
> +		if (!page) {
> +			unsigned long offset;
> +			offset = pos & ~PAGE_CACHE_MASK;
> +			len = min_t(unsigned long,
> +					len, PAGE_CACHE_SIZE - offset);
> +		}

Why does this have to muck with 'len'?  It doesn't appear to be undoing
anything from earlier in the function.  What is it fixing up?

> +		BUG_ON(page && !PageTransHuge(page));
> +	}

So, those semantics for AOP_FLAG_TRANSHUGE are actually pretty strong.
They mean that you can only return a transparent pagecache page, but you
better not return a small page.

Would it have been possible for a huge page to get returned from
grab_cache_page_write_begin(), but had it split up between there and the
BUG_ON()?

Which reminds me... under what circumstances _do_ we split these huge
pages?  How are those circumstances different from the anonymous ones?

> +	if (!page)
> +		page = grab_cache_page_write_begin(mapping, index, flags);
>  	if (!page)
>  		return -ENOMEM;
> -
>  	*pagep = page;
>  
> -	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
> -		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
> -
> -		zero_user_segments(page, 0, from, from + len, PAGE_CACHE_SIZE);
> +	if (!PageUptodate(page)) {
> +		unsigned from;
> +
> +		if (PageTransHuge(page) && len != HPAGE_PMD_SIZE) {
> +			from = pos & ~HPAGE_PMD_MASK;
> +			zero_huge_user_segment(page, 0, from);
> +			zero_huge_user_segment(page,
> +					from + len, HPAGE_PMD_SIZE);
> +		} else if (len != PAGE_CACHE_SIZE) {
> +			from = pos & ~PAGE_CACHE_MASK;
> +			zero_user_segments(page, 0, from,
> +					from + len, PAGE_CACHE_SIZE);
> +		}
>  	}
>  	return 0;
>  }
> @@ -443,9 +466,14 @@ int simple_write_end(struct file *file, struct address_space *mapping,
>  
>  	/* zero the stale part of the page if we did a short copy */
>  	if (copied < len) {
> -		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
> -
> -		zero_user(page, from + copied, len - copied);
> +		unsigned from;
> +		if (PageTransHuge(page)) {
> +			from = pos & ~HPAGE_PMD_MASK;
> +			zero_huge_user(page, from + copied, len - copied);
> +		} else {
> +			from = pos & ~PAGE_CACHE_MASK;
> +			zero_user(page, from + copied, len - copied);
> +		}
>  	}

When I see stuff going in to the simple_* functions, I fear that this
code will end up getting copied in to each and every one of the
filesystems that implement these on their own.

I guess this works for now, but I'm worried that the the next fs is just
going to copy-and-paste these.  Guess I'll yell at them when they do it. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
