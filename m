Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6266B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:42:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so497678wme.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 11:42:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sx20si6472958wjb.10.2016.10.11.11.42.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 11:42:30 -0700 (PDT)
Date: Tue, 11 Oct 2016 17:58:15 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 13/41] truncate: make sure invalidate_mapping_pages()
 can discard huge pages
Message-ID: <20161011155815.GM6952@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu 15-09-16 14:54:55, Kirill A. Shutemov wrote:
> invalidate_inode_page() has expectation about page_count() of the page
> -- if it's not 2 (one to caller, one to radix-tree), it will not be
> dropped. That condition almost never met for THPs -- tail pages are
> pinned to the pagevec.
> 
> Let's drop them, before calling invalidate_inode_page().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/truncate.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index a01cce450a26..ce904e4b1708 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -504,10 +504,21 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  				/* 'end' is in the middle of THP */
>  				if (index ==  round_down(end, HPAGE_PMD_NR))
>  					continue;
> +				/*
> +				 * invalidate_inode_page() expects
> +				 * page_count(page) == 2 to drop page from page
> +				 * cache -- drop tail pages references.
> +				 */
> +				get_page(page);
> +				pagevec_release(&pvec);

I'm not quite sure why this is needed. When you have multiorder entry in
the radix tree for your huge page, then you should not get more entries in
the pagevec for your huge page. What do I miss?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
