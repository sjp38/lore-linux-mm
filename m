Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id AC47E6B0002
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 13:52:26 -0400 (EDT)
Message-ID: <514C9C84.2010806@sr71.net>
Date: Fri, 22 Mar 2013 11:01:40 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 15/30] thp, libfs: initial support of thp in simple_read/write_begin/write_end
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-16-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> @@ -383,7 +383,10 @@ EXPORT_SYMBOL(simple_setattr);
>  
>  int simple_readpage(struct file *file, struct page *page)
>  {
> -	clear_highpage(page);
> +	if (PageTransHuge(page))
> +		zero_huge_user(page, 0, HPAGE_PMD_SIZE);
> +	else
> +		clear_highpage(page);

This makes me really wonder on which level we want to be hooking in this
code.  The fact that we're doing it in simple_readpage() seems to mean
that we'll have to go explicitly and widely modify every fs that wants
to support this.

It seems to me that we either want to hide this behind clear_highpage()
itself, _or_ make a clear_pagecache_page() function that does it.

BTW, didn't you have a HUGE_PAGE_CACHE_SIZE macro somewhere?  Shouldn't
that get used here?

>  	flush_dcache_page(page);
>  	SetPageUptodate(page);
>  	unlock_page(page);
> @@ -394,21 +397,41 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned flags,
>  			struct page **pagep, void **fsdata)
>  {
> -	struct page *page;
> +	struct page *page = NULL;
>  	pgoff_t index;
>  
>  	index = pos >> PAGE_CACHE_SHIFT;
>  
> -	page = grab_cache_page_write_begin(mapping, index, flags);
> +	/* XXX: too weak condition. Good enough for initial testing */
> +	if (mapping_can_have_hugepages(mapping)) {
> +		page = grab_cache_huge_page_write_begin(mapping,
> +				index & ~HPAGE_CACHE_INDEX_MASK, flags);
> +		/* fallback to small page */
> +		if (!page || !PageTransHuge(page)) {
> +			unsigned long offset;
> +			offset = pos & ~PAGE_CACHE_MASK;
> +			len = min_t(unsigned long,
> +					len, PAGE_CACHE_SIZE - offset);
> +		}
> +	}
> +	if (!page)
> +		page = grab_cache_page_write_begin(mapping, index, flags);

Same thing goes here.  Can/should we hide the
grab_cache_huge_page_write_begin() call inside
grab_cache_page_write_begin()?

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
> +			zero_huge_user_segments(page, 0, from,
> +					from + len, HPAGE_PMD_SIZE);
> +		} else if (len != PAGE_CACHE_SIZE) {
> +			from = pos & ~PAGE_CACHE_MASK;
> +			zero_user_segments(page, 0, from,
> +					from + len, PAGE_CACHE_SIZE);
> +		}
>  	}

Let's say you introduced two new functions:  page_cache_size(page) and
page_cache_mask(page), and hid the zero_huge_user_segments() inside
zero_user_segments().  This code would end up looking like this:

	if (len != page_cache_size(page)) {
		from = pos & ~page_cache_mask(page)
		zero_user_segments(page, 0, from,
				from + len, page_cache_size(page));
	}

It would also compile down to exactly what was there before without
having to _explicitly_ put a case in for THP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
