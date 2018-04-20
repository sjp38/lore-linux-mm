Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A05C6B0006
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:43:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id i1-v6so1074399pld.11
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:43:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t125si5212359pgc.6.2018.04.20.13.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 13:43:29 -0700 (PDT)
Date: Fri, 20 Apr 2018 13:43:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 02/14] mm: Split page_type out from _mapcount
Message-ID: <20180420204328.GF10788@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-3-willy@infradead.org>
 <alpine.DEB.2.20.1804201014300.18006@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804201014300.18006@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Apr 20, 2018 at 10:17:32AM -0500, Christopher Lameter wrote:
> On Wed, 18 Apr 2018, Matthew Wilcox wrote:
> 
> > As suggested by Kirill, make page_type a bitmask.  Because it starts out
> > life as -1 (thanks to sharing the storage with _mapcount), setting a
> > page flag means clearing the appropriate bit.  This gives us space for
> > probably twenty or so extra bits (depending how paranoid we want to be
> > about _mapcount underflow).
> 
> Could we use bits in the page->flags for this? We could remove the node or
> something else from page->flags. And the slab bit could also be part of
> the page type.
> 
> The page field handling gets more and more bizarre.

I don't think I'm making it any more bizarre than it already is :-)

Indeed, I think this patch makes it *more* sane.  Before this patch, there
are three magic values that might sometimes be stored in ->_mapcount.
After this patch, that's split into its own field, and the magic values
are actually flags, so they can be combined.
