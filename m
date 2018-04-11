Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFDF6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 14:26:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e14so1223053pfi.9
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 11:26:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v9-v6si1601501plp.614.2018.04.11.11.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Apr 2018 11:26:07 -0700 (PDT)
Date: Wed, 11 Apr 2018 11:26:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slub: Remove use of page->counter
Message-ID: <20180411182606.GA22494@bombadil.infradead.org>
References: <20180410195429.GB21336@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake>
 <20180410205757.GD21336@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101702240.30842@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804101702240.30842@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On Tue, Apr 10, 2018 at 05:03:17PM -0500, Christopher Lameter wrote:
> On Tue, 10 Apr 2018, Matthew Wilcox wrote:
> 
> > > Is this aligned on a doubleword boundary? Maybe move the refcount below
> > > the flags field?
> >
> > You need freelist and _mapcount to be in the same dword.  There's no
> > space to put them both in dword 0, so that's used for flags and mapping
> > / s_mem.  Then freelist, mapcount and refcount are in dword 1 (on 64-bit),
> > or freelist & mapcount are in dword 1 on 32-bit.  After that, 32 and 64-bit
> > no longer line up on the same dword boundaries.
> 
> Well its no longer clear from the definitions that this must be the case.
> Clarify that in the next version?

I had a Thought.  And it seems to work:

struct page {
	unsigned long flags;
	union {		/* Five words */
		struct {	/* Page cache & anonymous pages */
			struct list_head lru;
			unsigned long private;
			struct address_space *mapping;
			pgoff_t index;
		};
		struct {	/* Slab / Slob / Slub */
			struct page *next;
			void *freelist;
			union {
				unsigned int active;		/* slab */
				struct {			/* slub */
					unsigned inuse:16;
					unsigned objects:15;
					unsigned frozen:1;
				};
				int units;			/* slob */
			};
#ifdef CONFIG_64BIT
			int pages;
#endif
			void *s_mem;
			struct kmem_cache *slab_cache;
		};
		struct rcu_head rcu_head;
		... tail pages, page tables, etc, etc ...
	};
	union {
		atomic_t _mapcount;
		unsigned int page_type;
#ifdef CONFIG_64BIT
		unsigned int pobjects;			/* slab */
#else
		struct {
			short int pages;
			short int pobjects;
		};
#endif
	};
	atomic_t _refcount;
	struct mem_cgroup *mem_cgroup;
};

Now everybody gets 5 contiguous words to use as they want with the only
caveat that they can't use bit 0 of the first word (PageTail).  It looks
a little messy to split up pages & pobjects like that -- as far as I
can see there's no reason we couldn't make them unsigned short on 64BIT?
pages is always <= pobjects, and pobjects is limited to 2^15.
