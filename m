Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE08A6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:00:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id cf17-v6so17909926plb.2
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 14:00:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f62-v6si33357633pfg.165.2018.07.16.14.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Jul 2018 14:00:18 -0700 (PDT)
Date: Mon, 16 Jul 2018 14:00:14 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 05/14] mm, memremap: Up-level foreach_order_pgoff()
Message-ID: <20180716210014.GA1607@bombadil.infradead.org>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153176044796.12695.10692625606054072713.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153176044796.12695.10692625606054072713.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>, vishal.l.verma@intel.com, hch@lst.de, linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Mon, Jul 16, 2018 at 10:00:48AM -0700, Dan Williams wrote:
> The foreach_order_pgoff() helper takes advantage of the ability to
> insert multi-order entries into a radix. It is currently used by
> devm_memremap_pages() to minimize the number of entries in the pgmap
> radix. Instead of dividing a range by a constant power-of-2 sized unit
> and inserting an entry for each unit, it determines the maximum
> power-of-2 sized entry (subject to alignment offset) that can be
> inserted at each iteration.
> 
> Up-level this helper so it can be used for populating other radix
> instances. For example asynchronous-memmap-initialization-thread lookups
> arriving in a follow on change.

Hopefully by the time you're back, I'll have this code replaced with
the XArray.  Here's my proposed API:

	old = xa_store_range(xa, first, last, ptr, GFP_KERNEL);

and then you'd simply use xa_for_each() as an iterator.  You'd do one
iteration for each range in the XArray, not for each entry occupied.
So there's a difference between:

	xa_store(xa, 1, ptr, GFP_KERNEL);
	xa_store(xa, 2, ptr, GFP_KERNEL);
	xa_store(xa, 3, ptr, GFP_KERNEL);

and

	xa_store_range(xa, 1, 3, ptr, GFP_KERNEL);

	index = 0; i = 0;
	xa_for_each(xa, p, index, ULONG_MAX, XA_PRESENT)
		i++;

will return i = 3 for the first case and i = 1 for the second.
