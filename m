Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEA316B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 11:15:56 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b13-v6so13956820pgw.1
        for <linux-mm@kvack.org>; Fri, 04 May 2018 08:15:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 68si16275841pfq.172.2018.05.04.08.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 08:15:55 -0700 (PDT)
Date: Fri, 4 May 2018 08:15:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
Message-ID: <20180504151550.GA29829@bombadil.infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-8-willy@infradead.org>
 <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
 <20180502172639.GC2737@bombadil.infradead.org>
 <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
 <20180503005223.GB21199@bombadil.infradead.org>
 <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake>
 <20180503182823.GB1562@bombadil.infradead.org>
 <alpine.DEB.2.21.1805040953540.10847@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1805040953540.10847@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Fri, May 04, 2018 at 09:55:30AM -0500, Christopher Lameter wrote:
> On Thu, 3 May 2018, Matthew Wilcox wrote:
> 
> > OK.  Do you want the conversion of slub to using slub_freelist and slub_list
> > as part of this patch series as well, then?
> 
> Not sure if that is needed. Dont like allocator specific names.

So you'd rather have one union that's used for slab/slob/slub?  Like this?

                struct {        /* slab, slob and slub */
                        union {
                                struct list_head slab_list;
                                struct {        /* Partial pages */
                                        struct page *next;
#ifdef CONFIG_64BIT
                                        int pages;      /* Nr of pages left */
                                        int pobjects;   /* Approximate count */
#else
                                        short int pages;
                                        short int pobjects;
#endif
                                };
                        };
                        struct kmem_cache *slab_cache;
                        /* Double-word boundary */
                        void *freelist;         /* first free object */
                        union {
                                void *s_mem;    /* first object (slab only) */
                                unsigned long counters; /* slub */
                                struct {
                                        unsigned inuse:16;
                                        unsigned objects:15;
                                        unsigned frozen:1;
                                };
                        };
                };
