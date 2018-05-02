Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D40E6B000C
	for <linux-mm@kvack.org>; Wed,  2 May 2018 13:26:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z24so6623648pfn.5
        for <linux-mm@kvack.org>; Wed, 02 May 2018 10:26:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m39-v6si12003810plg.570.2018.05.02.10.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 May 2018 10:26:40 -0700 (PDT)
Date: Wed, 2 May 2018 10:26:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
Message-ID: <20180502172639.GC2737@bombadil.infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-8-willy@infradead.org>
 <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue, May 01, 2018 at 11:48:53AM -0500, Christopher Lameter wrote:
> On Mon, 30 Apr 2018, Matthew Wilcox wrote:
> 
> > Use page->private instead, now that these two fields are in the same
> > location.  Include a compile-time assert that the fields don't get out
> > of sync.
> 
> Hrm. This makes the source code a bit less readable. Guess its ok.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Thanks for the ACK.  I'm not thrilled with this particular patch, but
I'm not thrilled with any of the other options we've come up with either.

Option 1:

Patch as written.
Pro: Keeps struct page simple
Con: Hidden dependency on page->private and page->inuse being in the same bits

Option 2:

@@ -113,9 +113,14 @@ struct page {
                        struct kmem_cache *slub_cache;  /* shared with slab */
                        /* Double-word boundary */
                        void *slub_freelist;            /* shared with slab */
-                       unsigned inuse:16;
-                       unsigned objects:15;
-                       unsigned frozen:1;
+                       union {
+                               unsigned long counters;
+                               struct {
+                                       unsigned inuse:16;
+                                       unsigned objects:15;
+                                       unsigned frozen:1;
+                               };
+                       };
                };
                struct {        /* Tail pages of compound page */
                        unsigned long compound_head;    /* Bit zero is set */

Pro: Expresses exactly what we do.
Con: Back to five levels of indentation in struct page

Option 3: Use -fms-extensions to create a slub_page structure.

Pro: Indentation reduced to minimum and no cross-union dependencies
Con: Nobody seemed interested in the idea

Option 4: Use explicit shifting-and-masking to combine the three counters
into one word.

Con: Lots of churn.
