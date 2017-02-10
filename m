Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8B036B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:46:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so58359857pgd.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:46:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 34si2279819plz.118.2017.02.10.09.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 09:46:36 -0800 (PST)
Date: Fri, 10 Feb 2017 09:46:10 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 13/37] mm: make write_cache_pages() work on huge pages
Message-ID: <20170210174610.GC2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:55PM +0300, Kirill A. Shutemov wrote:
> We writeback whole huge page a time. Let's adjust iteration this way.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I think a lot of the complexity in this patch is from pagevec_lookup_tag
giving you subpages rather than head pages...

> @@ -2268,7 +2273,8 @@ int write_cache_pages(struct address_space *mapping,
>  					 * not be suitable for data integrity
>  					 * writeout).
>  					 */
> -					done_index = page->index + 1;
> +					done_index = compound_head(page)->index
> +						+ hpage_nr_pages(page);
>  					done = 1;
>  					break;
>  				}

you'd still need this line, but it'd only be:

					done_index = page->index +
						(1 << compound_order(page));

I think we want:

#define	nr_pages(page)	(1 << compound_order(page))

because we seem to be repeating that idiom quite a lot in these patches.

					done_index = page->index +
								nr_pages(page);

Still doesn't quite fit on one line, but it's closer, and it's the
ridiculous indentation in that function that's the real problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
