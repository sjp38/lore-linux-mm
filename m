Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id F02B46B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:36:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k62so1225446oia.6
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:36:01 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id f4si4772700oib.427.2017.08.10.09.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 09:36:00 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id g71so11454417ioe.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:36:00 -0700 (PDT)
Date: Thu, 10 Aug 2017 10:35:58 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v5 08/10] arm64/mm: Add support for XPFO to swiotlb
Message-ID: <20170810163558.6u7ep5xdeufyluna@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-9-tycho@docker.com>
 <20170810131111.GC2413@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170810131111.GC2413@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

Hi Konrad,

Thanks for taking a look!

On Thu, Aug 10, 2017 at 09:11:12AM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Aug 09, 2017 at 02:07:53PM -0600, Tycho Andersen wrote:
> > +
> > +inline void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
> 
> And inline? You sure about that? It is quite a lot of code to duplicate
> in all of those call-sites.
>
> > +				    int dir)
> 
> Not enum dma_data_direction ?

I'll fix both of these, thanks.

> > +{
> > +	unsigned long flags;
> > +	struct page *page = virt_to_page(addr);
> > +
> > +	/*
> > +	 * +2 here because we really want
> > +	 * ceil(size / PAGE_SIZE), not floor(), and one extra in case things are
> > +	 * not page aligned
> > +	 */
> > +	int i, possible_pages = size / PAGE_SIZE + 2;
> 
> Could you use the PAGE_SHIFT macro instead? Or PFN_UP ?
> 
> And there is also the PAGE_ALIGN macro...
> 
> > +	void *buf[possible_pages];
> 
> What if you just did 'void *buf[possible_pages] = { };'
> 
> Wouldn't that eliminate the need for the memset?

gcc doesn't seem to like that:

arch/arm64//mm/xpfo.c: In function a??xpfo_dma_map_unmap_areaa??:
arch/arm64//mm/xpfo.c:80:2: error: variable-sized object may not be initialized
  void *buf[possible_pages] = {};
  ^~~~

I thought about putting this on the heap, but there's no real way to return
errors here if e.g. the kmalloc fails. I'm open to suggestions though, because
this is ugly.

> > +
> > +	memset(buf, 0, sizeof(void *) * possible_pages);
> > +
> > +	local_irq_save(flags);
> 
> ?? Why?

I'm afraid I don't really know. I'll drop it for the next version, thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
