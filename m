Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F00CE6B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 22:58:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e20so430928pff.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 19:58:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a33-v6si335281pli.275.2018.04.26.19.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Apr 2018 19:58:15 -0700 (PDT)
Date: Thu, 26 Apr 2018 19:58:11 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v11 19/63] page cache: Convert page deletion to XArray
Message-ID: <20180427025811.GA14502@bombadil.infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-20-willy@infradead.org>
 <979c1602-42e3-349d-a5e4-d28de14112dd@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <979c1602-42e3-349d-a5e4-d28de14112dd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Apr 20, 2018 at 07:00:57AM -0500, Goldwyn Rodrigues wrote:
> On 04/14/2018 09:12 AM, Matthew Wilcox wrote:
> >  
> > -	for (i = 0; i < nr; i++) {
> > -		struct radix_tree_node *node;
> > -		void **slot;
> > -
> > -		__radix_tree_lookup(&mapping->i_pages, page->index + i,
> > -				    &node, &slot);
> > -
> > -		VM_BUG_ON_PAGE(!node && nr != 1, page);
> > -
> > -		radix_tree_clear_tags(&mapping->i_pages, node, slot);
> > -		__radix_tree_replace(&mapping->i_pages, node, slot, shadow,
> > -				workingset_lookup_update(mapping));
> > +	i = nr;
> > +repeat:
> > +	xas_store(&xas, shadow);
> > +	xas_init_tags(&xas);
> > +	if (--i) {
> > +		xas_next(&xas);
> > +		goto repeat;
> >  	}
> 
> Can this be converted into a do {} while (or even for) loop instead?
> Loops are easier to read and understand in such a situation.

I wish I'd fixed this up earlier because our peers made fun of me at
LSFMM for this loop ;-)

The obvious way to write this loop is:

        for (i = 0; i < nr; i++) {
-               struct radix_tree_node *node;
-               void **slot;
-
-               __radix_tree_lookup(&mapping->i_pages, page->index + i,
-                                   &node, &slot);
-
-               VM_BUG_ON_PAGE(!node && nr != 1, page);
-
-               radix_tree_clear_tags(&mapping->i_pages, node, slot);
-               __radix_tree_replace(&mapping->i_pages, node, slot, shadow,
-                               workingset_lookup_update(mapping));
+               xas_store(&xas, shadow);
+               xas_init_tags(&xas);
+               xas_next(&xas);
        }

But since we're storing the same value to every entry and the range is
a power of two, there's a better way to rewrite this:

 {
-       int i, nr;
+       XA_STATE(xas, &mapping->i_pages, page->index);
+       unsigned int nr = 1;

-       /* hugetlb pages are represented by one entry in the radix tree */
-       nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+       mapping_set_update(&xas, mapping);
+
+       /* hugetlb pages are represented by a single entry in the xarray */
+       if (!PageHuge(page)) {
+               xas_set_order(&xas, page->index, compound_order(page));
+               nr = 1U << compound_order(page);
+       }

        VM_BUG_ON_PAGE(!PageLocked(page), page);
        VM_BUG_ON_PAGE(PageTail(page), page);
        VM_BUG_ON_PAGE(nr != 1 && shadow, page);

-       for (i = 0; i < nr; i++) {
-               struct radix_tree_node *node;
-               void **slot;
-
-               __radix_tree_lookup(&mapping->i_pages, page->index + i,
-                                   &node, &slot);
-
-               VM_BUG_ON_PAGE(!node && nr != 1, page);
-
-               radix_tree_clear_tags(&mapping->i_pages, node, slot);
-               __radix_tree_replace(&mapping->i_pages, node, slot, shadow,
-                               workingset_lookup_update(mapping));
-       }
+       xas_store(&xas, shadow);
+       xas_init_tags(&xas);
