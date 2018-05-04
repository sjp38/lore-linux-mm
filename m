Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37D516B0010
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:29:09 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t24-v6so16215673qtn.7
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:29:09 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id c14-v6si2455255qtn.116.2018.05.04.09.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:29:08 -0700 (PDT)
Date: Fri, 4 May 2018 11:29:06 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
In-Reply-To: <20180504151550.GA29829@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.21.1805041128350.12676@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-8-willy@infradead.org> <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake> <20180502172639.GC2737@bombadil.infradead.org> <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
 <20180503005223.GB21199@bombadil.infradead.org> <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake> <20180503182823.GB1562@bombadil.infradead.org> <alpine.DEB.2.21.1805040953540.10847@nuc-kabylake> <20180504151550.GA29829@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Fri, 4 May 2018, Matthew Wilcox wrote:

> So you'd rather have one union that's used for slab/slob/slub?  Like this?

Yup that looks better.
>
>                 struct {        /* slab, slob and slub */
>                         union {
>                                 struct list_head slab_list;
>                                 struct {        /* Partial pages */
>                                         struct page *next;
> #ifdef CONFIG_64BIT
>                                         int pages;      /* Nr of pages left */
>                                         int pobjects;   /* Approximate count */
> #else
>                                         short int pages;
>                                         short int pobjects;
> #endif
>                                 };
>                         };
>                         struct kmem_cache *slab_cache;
>                         /* Double-word boundary */
>                         void *freelist;         /* first free object */
>                         union {
>                                 void *s_mem;    /* first object (slab only) */
>                                 unsigned long counters; /* slub */
>                                 struct {
>                                         unsigned inuse:16;
>                                         unsigned objects:15;
>                                         unsigned frozen:1;
>                                 };
>                         };
>                 };
>
