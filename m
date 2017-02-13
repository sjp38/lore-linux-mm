Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAA716B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 11:29:06 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id 123so163339042ybe.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 08:29:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j191si10489936pgd.132.2017.02.13.08.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 08:29:05 -0800 (PST)
Date: Mon, 13 Feb 2017 08:28:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 08/37] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20170213162856.GC6416@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-9-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-9-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:50PM +0300, Kirill A. Shutemov wrote:
> Most of work happans on head page. Only when we need to do copy data to
> userspace we find relevant subpage.
> 
> We are still limited by PAGE_SIZE per iteration. Lifting this limitation
> would require some more work.

Now that I debugged that bit of my brain, here's a more sensible suggestion.

> @@ -1886,6 +1886,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
>  			if (unlikely(page == NULL))
>  				goto no_cached_page;
>  		}
> +		page = compound_head(page);
>  		if (PageReadahead(page)) {
>  			page_cache_async_readahead(mapping,
>  					ra, filp, page,

We're going backwards and forwards a lot between subpages and page heads.
I'd like to see us do this:

static inline struct page *pagecache_get_page(struct address_space *mapping,
			pgoff_t offset, int fgp_flags, gfp_t cache_gfp_mask)
{
	struct page *page = pagecache_get_head(mapping, offset, fgp_flags,
								cache_gfp_mask);
	return page ? find_subpage(page, offset) : NULL;
}

static inline struct page *find_get_head(struct address_space *mapping,
					pgoff_t offset)
{
	return pagecache_get_head(mapping, offset, 0, 0);
}

and then we can switch do_generic_file_read() to call find_get_head(),
eliminating the conversion back and forth between subpages and head pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
