Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 581406B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 17:07:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so3094661pgq.19
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 14:07:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si5610577pgj.128.2018.08.03.14.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 14:07:50 -0700 (PDT)
Date: Fri, 3 Aug 2018 14:07:45 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Message-ID: <20180803210745.GB9329@bombadil.infradead.org>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <20180803162212.GA4718@bombadil.infradead.org>
 <a2e9e4fd-2aab-bc7e-8dbb-db4ece8cd84f@cybernetics.com>
 <f0762902-8f28-82eb-b871-337c2da290cf@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0762902-8f28-82eb-b871-337c2da290cf@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 03, 2018 at 02:43:07PM -0400, Tony Battersby wrote:
> Out of curiosity, I just tried to create a dmapool with a NULL dev and
> it crashed on this:
> 
> static inline int dev_to_node(struct device *dev)
> {
> 	return dev->numa_node;
> }
> 
> struct dma_pool *dma_pool_create(const char *name, struct device *dev,
> 				 size_t size, size_t align, size_t boundary)
> {
> 	...
> 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
> 	...
> }
> 
> So either it needs more special cases for supporting a NULL dev, or the
> special cases can be removed since no one does that anyway.

Actually, it's worse.  dev_to_node() works with a NULL dev ... unless
CONFIG_NUMA is set.  So we're leaving a timebomb by pretending to
allow it.  Let's just 'if (!dev) return NULL;' early in create.
