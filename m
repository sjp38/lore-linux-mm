Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A12FA6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 16:57:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so23267877pfb.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 13:57:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p66si11234653pga.87.2017.02.09.13.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 13:57:14 -0800 (PST)
Date: Thu, 9 Feb 2017 13:55:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 08/37] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20170209215505.GW2267@bombadil.infradead.org>
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
> +++ b/mm/filemap.c
> @@ -1886,6 +1886,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
>  			if (unlikely(page == NULL))
>  				goto no_cached_page;
>  		}
> +		page = compound_head(page);

We got this page from find_get_page(), which gets it from
pagecache_get_page(), which gets it from find_get_entry() ... which
(unless I'm lost in your patch series) returns the head page.  So this
line is redundant, right?

But then down in filemap_fault, we have:

        VM_BUG_ON_PAGE(page->index != offset, page);

... again, maybe I'm lost somewhere in your patch series, but I don't see
anywhere you remove that line (or modify it).  So are you not testing
with VM debugging enabled, or are you not doing a test which includes
mapping a file with huge pages, reading from it (to get the page in cache),
then faulting on an address that is not in the first 4kB of that 2MB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
