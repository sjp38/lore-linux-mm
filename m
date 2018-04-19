Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C05866B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:08:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 127so1859630pge.10
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:08:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a9si2954156pgu.454.2018.04.19.07.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 07:08:44 -0700 (PDT)
Date: Thu, 19 Apr 2018 07:08:43 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 08/14] mm: Combine first three unions in struct page
Message-ID: <20180419140843.GA25406@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-9-willy@infradead.org>
 <72eecf42-202e-0c6f-06bc-9c5c07814e24@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <72eecf42-202e-0c6f-06bc-9c5c07814e24@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 19, 2018 at 03:46:42PM +0200, Vlastimil Babka wrote:
> > +		struct {	/* slab and slob */
> > +			struct kmem_cache *slab_cache;
> > +			void *freelist;		/* first free object */
> > +			void *s_mem;		/* first object */
> > +		};
> > +		struct {	/* slub also uses some of the slab fields */
> > +			struct kmem_cache *slub_cache;
> > +			/* Double-word boundary */
> > +			void *slub_freelist;
> 
> Is slub going to switch to use those? Or maybe this is an overkill and
> we could merge the two sl*b structs and just have an union for s_mem and
> the 3 counters?

It ends up looking pretty cruddy if you do that:

		struct {
			union {
				struct list_head slab_list;
				struct {
					struct page *next;
					unsigned int pobjects;
					unsigned int pages;
				};
			};
			struct kmem_cache *slab_cache;
			void *freelist;		/* first free object */
			union {
				void *s_mem;		/* first object */
				struct {
					unsigned inuse:16;
					unsigned objects:15;
					unsigned frozen:1;
				};
			};
		};

At least I don't enjoy the five layers of indentation ...
