Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 703256B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:33:46 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id v186so44488752lfa.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:33:46 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id f78si5961917wmd.44.2017.02.13.07.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 07:33:45 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id 89so24664300wrr.1
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:33:45 -0800 (PST)
Date: Mon, 13 Feb 2017 18:33:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv6 08/37] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20170213153342.GE20394@node.shutemov.name>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-9-kirill.shutemov@linux.intel.com>
 <20170209215505.GW2267@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209215505.GW2267@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 09, 2017 at 01:55:05PM -0800, Matthew Wilcox wrote:
> On Thu, Jan 26, 2017 at 02:57:50PM +0300, Kirill A. Shutemov wrote:
> > +++ b/mm/filemap.c
> > @@ -1886,6 +1886,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
> >  			if (unlikely(page == NULL))
> >  				goto no_cached_page;
> >  		}
> > +		page = compound_head(page);
> 
> We got this page from find_get_page(), which gets it from
> pagecache_get_page(), which gets it from find_get_entry() ... which
> (unless I'm lost in your patch series) returns the head page.  So this
> line is redundant, right?

No. pagecache_get_page() returns subpage. See description of the first
patch.

> But then down in filemap_fault, we have:
> 
>         VM_BUG_ON_PAGE(page->index != offset, page);
> 
> ... again, maybe I'm lost somewhere in your patch series, but I don't see
> anywhere you remove that line (or modify it).

This should be fine as find_get_page() returns subpage.

> So are you not testing
> with VM debugging enabled, or are you not doing a test which includes
> mapping a file with huge pages, reading from it (to get the page in cache),
> then faulting on an address that is not in the first 4kB of that 2MB?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
