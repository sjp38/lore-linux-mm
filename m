Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC556B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:15:23 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so20166043pfx.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:15:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 85si11010074pfq.219.2017.02.09.12.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 12:15:22 -0800 (PST)
Date: Thu, 9 Feb 2017 12:14:16 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 05/37] thp: try to free page's buffers before attempt
 split
Message-ID: <20170209201416.GS2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-6-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-6-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:47PM +0300, Kirill A. Shutemov wrote:
> @@ -2146,6 +2146,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			goto out;
>  		}
>  
> +		/* Try to free buffers before attempt split */
> +		if (!PageSwapBacked(head) && PagePrivate(page)) {
> +			/*
> +			 * We cannot trigger writeback from here due possible
> +			 * recursion if triggered from vmscan, only wait.
> +			 *
> +			 * Caller can trigger writeback it on its own, if safe.
> +			 */

It took me a few reads to get this.  May I suggest:

		/*
		 * Cannot split a page with buffers.  If the caller has
		 * already started writeback, we can wait for it to finish,
		 * but we cannot start writeback if we were called from vmscan
		 */
> +		if (!PageSwapBacked(head) && PagePrivate(page)) {

Also, it looks weird to test PageSwapBacked of *head* and PagePrivate
of *page*.  I think it's correct, but it still looks weird.

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
