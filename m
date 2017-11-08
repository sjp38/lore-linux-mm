Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC164403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 07:33:18 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id s144so1985859oih.5
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 04:33:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b79si1954195oii.90.2017.11.08.04.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 04:33:17 -0800 (PST)
Date: Wed, 8 Nov 2017 07:33:09 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] vmalloc: introduce vmap_pfn for persistent memory
In-Reply-To: <20171108095909.GA7390@infradead.org>
Message-ID: <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com> <20171108095909.GA7390@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, dm-devel@redhat.com, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@lst.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>



On Wed, 8 Nov 2017, Christoph Hellwig wrote:

> On Tue, Nov 07, 2017 at 05:03:11PM -0500, Mikulas Patocka wrote:
> > Hi
> > 
> > I am developing a driver that uses persistent memory for caching. A 
> > persistent memory device can be mapped in several discontiguous ranges.
> > 
> > The kernel has a function vmap that takes an array of pointers to pages 
> > and maps these pages to contiguous linear address space. However, it can't 
> > be used on persistent memory because persistent memory may not be backed 
> > by page structures.
> > 
> > This patch introduces a new function vmap_pfn, it works like vmap, but 
> > takes an array of pfn_t - so it can be used on persistent memory.
> 
> How is cache flushing going to work for this interface assuming
> that your write to/from the virtual address and expect it to be
> persisted on pmem?

We could use the function clwb() (or arch-independent wrapper dax_flush()) 
- that uses the clflushopt instruction on Broadwell or clwb on Skylake - 
but it is very slow, write performance on Broadwell is only 350MB/s.

So in practice I use the movnti instruction that bypasses cache. The 
write-combining buffer is flushed with sfence.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
