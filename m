Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1BB8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:15:49 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a18so204285pga.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:15:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q14si60814741pgq.197.2019.01.07.06.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 06:15:48 -0800 (PST)
Date: Mon, 7 Jan 2019 06:15:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] drop_caches: Allow unmapping pages
Message-ID: <20190107141545.GX6310@bombadil.infradead.org>
References: <20190107130239.3417-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107130239.3417-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org, keescook@chromium.org, corbet@lwn.net, linux-doc@vger.kernel.org, Vincent Whitchurch <rabinv@axis.com>

On Mon, Jan 07, 2019 at 02:02:39PM +0100, Vincent Whitchurch wrote:
> +++ b/Documentation/sysctl/vm.txt
> @@ -222,6 +222,10 @@ To increase the number of objects freed by this operation, the user may run
>  number of dirty objects on the system and create more candidates to be
>  dropped.
>  
> +By default, pages which are currently mapped are not dropped from the
> +pagecache.  If you want to unmap and drop these pages too, echo 9 or 11 instead
> +of 1 or 3 respectively (set bit 4).

Typically we number bits from 0, so this would be bit 3, not 4.  I do see
elsewhere in this file somebody else got this wrong:

: with your system.  To disable them, echo 4 (bit 3) into drop_caches.

but that should also be fixed.

> +static int __invalidate_inode_page(struct page *page, bool unmap)
> +{
> +	struct address_space *mapping = page_mapping(page);
> +	if (!mapping)
> +		return 0;
> +	if (PageDirty(page) || PageWriteback(page))
> +		return 0;
> +	if (page_mapped(page)) {
> +		if (!unmap)
> +			return 0;
> +		if (!try_to_unmap(page, TTU_IGNORE_ACCESS))
> +			return 0;

You're going to get data corruption doing this.  try_to_unmap_one() does:

                /* Move the dirty bit to the page. Now the pte is gone. */
                if (pte_dirty(pteval))
                        set_page_dirty(page);

so PageDirty() can be false above, but made true by calling try_to_unmap().

I also think the way you've done this is expedient at the cost of
efficiency and layering violations.  I think you should first tear
down the mappings of userspace processes (which will reclaim a lot
of pages allocated to page tables), then you won't need to touch the
invalidate_inode_pages paths at all.
