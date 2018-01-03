Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 383326B0384
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 15:33:19 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id x1so1400288plb.2
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 12:33:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f3si1038950pgn.718.2018.01.03.12.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jan 2018 12:33:18 -0800 (PST)
Date: Wed, 3 Jan 2018 12:33:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Heuristic for inode/dentry fragmentation prevention
Message-ID: <20180103203303.GA3228@bombadil.infradead.org>
References: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jan 03, 2018 at 01:39:27PM -0600, Christopher Lameter wrote:
> +/* How many objects left in slab page */
> +unsigned kobjects_left_in_slab_page(const void *object)
> +{
> +	struct page *page;
> +
> +	if (unlikely(ZERO_OR_NULL_PTR(object)))
> +		return 0;
> +
> +	page = virt_to_head_page(object);
> +
> +	if (unlikely(!PageSlab(page))) {
> +		WARN_ON(1);
> +		return 1;
> +	}

I see this construct all over the kernel.  Here's a better one:

	if (WARN_ON(!PageSlab(page)))
		return 1;

There's a built-in unlikely() in the definition of WARN_ON, so this
works nicely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
