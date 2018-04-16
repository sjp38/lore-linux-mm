Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 857906B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:53:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x184so9479369pfd.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:53:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y2si10281177pfm.283.2018.04.16.06.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 06:53:22 -0700 (PDT)
Date: Mon, 16 Apr 2018 06:53:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slub: Remove use of page->counter
Message-ID: <20180416135321.GD26022@bombadil.infradead.org>
References: <20180410195429.GB21336@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake>
 <20180410205757.GD21336@bombadil.infradead.org>
 <alpine.DEB.2.20.1804101702240.30842@nuc-kabylake>
 <20180411182606.GA22494@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411182606.GA22494@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On Wed, Apr 11, 2018 at 11:26:06AM -0700, Matthew Wilcox wrote:
> I had a Thought.  And it seems to work:

Now I realised that slub doesn't use s_mem.  That gives us more space
to use for pages/pobjects.

struct page {
	unsigned long flags;
	union {		/* Five words */
		struct {	/* Page cache & anonymous pages */
			struct list_head lru;
			unsigned long private;
			struct address_space *mapping;
			pgoff_t index;
		};
		struct {	/* Slob */
			struct list_head slob_list;
			int units;
		};
		struct {	/* Slab */
			struct kmem_cache *slab_cache;
			void *freelist;
			void *s_mem;
			unsigned int active;
		};
		struct {	/* Slub */
			struct kmem_cache *slub_cache;
			/* Dword boundary */
			void *slub_freelist;
			unsigned short inuse;
			unsigned short objects:15;
			unsigned short frozen:1;
			struct page *next;
#ifdef CONFIG_64BIT
			int pobjects;
			int pages;
#endif
			short int pages;
			short int pobjects;
#endif
		};
		struct rcu_head rcu_head;
		... tail pages, page tables, etc, etc ...
	};
	union {
		atomic_t _mapcount;
		unsigned int page_type;
	};
	atomic_t _refcount;
	struct mem_cgroup *mem_cgroup;
};

> Now everybody gets 5 contiguous words to use as they want with the only
> caveat that they can't use bit 0 of the first word (PageTail).

^^^ still true ;-)

I'd want to change slob to use slob_list instead of ->lru.  Or maybe even do
something radical like _naming_ the struct in the union so we don't have to
manually namespace the names of the elements.
