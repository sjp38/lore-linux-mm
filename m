Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC0736B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 19:26:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so10206118pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 16:26:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f3-v6si4393392plf.446.2018.03.26.16.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 16:26:37 -0700 (PDT)
Date: Mon, 26 Mar 2018 16:26:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 00/61] XArray v9
Message-ID: <20180326232634.GA10054@bombadil.infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180326153648.27f53e9a1398812203745257@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326153648.27f53e9a1398812203745257@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Mon, Mar 26, 2018 at 03:36:48PM -0700, Andrew Morton wrote:
> I looked at this from a for-4.17 POV and ran out of nerve at "[PATCH v9
> 09/61] xarray: Replace exceptional entries".  It's awfully late.

I did post v7 five weeks ago ... it wasn't late at the time.

> "[PATCH v9 08/61] page cache: Use xa_lock" looks sufficiently
> mechanical to be if-it-compiles-it-works, although perhaps that
> shouldn't be in 4.17 either.  Mainly because it commits us to merging
> the rest of XArray and there hasn't been a ton of review and test
> activity.

I think we should commit to that.  The API has had a pretty thorough
review, and nobody's stepped up to say "Hey, no, I prefer the old API,
I don't want to see it change".  Merging patch 8 would move us a good
chunk of the way towards getting the IDA in a position where it can
be converted.  Patch 9 would get us even further, but I'm willing to
respin in order to build on just patch 8.

> It looks like btrfs has changed in -next:
> 
> --- a/fs/btrfs/inode.c~page-cache-use-xa_lock-fix
> +++ a/fs/btrfs/inode.c
> @@ -7445,7 +7445,7 @@ out:
>  
>  bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
>  {
> -	struct radix_tree_root *root = &inode->i_mapping->page_tree;
> +	struct radix_tree_root *root = &inode->i_mapping->i_pages;
>  	bool found = false;
>  	void **pagep = NULL;
>  	struct page *page = NULL;

btrfs_page_exists_in_range() has been deleted -- David Sterba merged the
patch v8-0006-btrfs-Use-filemap_range_has_page.patch ... which was dropped
from v9 of the patchset, so I'm not sure what you're actually looking at?
