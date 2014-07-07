Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B35C66B0038
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 15:39:27 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so5891806pdj.1
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 12:39:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ex14si41783363pac.42.2014.07.07.12.39.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 12:39:26 -0700 (PDT)
Date: Mon, 7 Jul 2014 12:39:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage
 correctly
Message-Id: <20140707123923.5e42983d6123ebfd79c8cf4c@linux-foundation.org>
In-Reply-To: <20140702043057.GA19813@nhori.redhat.com>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20140701180739.GA4985@node.dhcp.inet.fi>
	<20140701185021.GA10356@nhori.bos.redhat.com>
	<20140701201540.GA5953@node.dhcp.inet.fi>
	<20140702043057.GA19813@nhori.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, 2 Jul 2014 00:30:57 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Subject: [PATCH v2] rmap: fix pgoff calculation to handle hugepage correctly
> 
> I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
> hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
> calculation in rmap_walk_anon() fails to consider compound_order() only to
> have an incorrect value.
> 
> This patch introduces page_to_pgoff(), which gets the page's offset in
> PAGE_CACHE_SIZE. Kirill pointed out that page cache tree should natively
> handle hugepages, and in order to make hugetlbfs fit it, page->index of
> hugetlbfs page should be in PAGE_CACHE_SIZE. This is beyond this patch,
> but page_to_pgoff() contains the point to be fixed in a single function.
> 
> ...
>
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -399,6 +399,18 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
>  }
>  
>  /*
> + * Get the offset in PAGE_SIZE.
> + * (TODO: hugepage should have ->index in PAGE_SIZE)
> + */
> +static inline pgoff_t page_to_pgoff(struct page *page)
> +{
> +	if (unlikely(PageHeadHuge(page)))
> +		return page->index << compound_order(page);
> +	else
> +		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +}
> +

This is all a bit of a mess.

We have page_offset() which only works for regular pagecache pages and
not for huge pages.

We have page_file_offset() which works for regular pagecache as well
as swapcache but not for huge pages.

We have page_index() and page_file_index() which differ in undocumented
ways which I cannot be bothered working out.  The latter calls
__page_file_index() which is grossly misnamed.

Now we get a new page_to_pgoff() which in inconsistently named but has
a similarly crappy level of documentation and which works for hugepages
and regular pagecache pages but not for swapcache pages.


Sigh.

I'll merge this patch because it's a bugfix but could someone please
drive a truck through all this stuff and see if we can come up with
something tasteful and sane?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
