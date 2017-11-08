Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03E8344043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 15:26:21 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id q99so979084ota.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 12:26:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1si2256203oib.203.2017.11.08.12.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 12:26:20 -0800 (PST)
Date: Wed, 8 Nov 2017 15:26:16 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent
 memory
In-Reply-To: <20171108174747.GA12199@infradead.org>
Message-ID: <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com> <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com> <20171108150447.GA10374@infradead.org>
 <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com> <20171108153522.GB24548@infradead.org> <alpine.LRH.2.02.1711081236570.1168@file01.intranet.prod.int.rdu2.redhat.com> <20171108174747.GA12199@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nvdimm@lists.01.org, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>



On Wed, 8 Nov 2017, Christoph Hellwig wrote:

> Can you start by explaining what you actually need the vmap for?

It is possible to use lvm on persistent memory. You can create linear or 
striped logical volumes on persistent memory and these volumes still have 
the direct_access method, so they can be mapped with the function 
dax_direct_access().

If we create logical volumes on persistent memory, the method 
dax_direct_access() won't return the whole device, it will return only a 
part. When dax_direct_access() returns the whole device, my driver just 
uses it without vmap. When dax_direct_access() return only a part of the 
device, my driver calls it repeatedly to get all the parts and then 
assembles the parts into a linear address space with vmap.

See the function persistent_memory_claim() here: 
https://www.redhat.com/archives/dm-devel/2017-November/msg00026.html

> Going through a vmap for every I/O is certainly not going to be nice
> on NVDIMM-N or similar modules :)

It's just a call to vmalloc_to_page.

Though, if persistent memory is not page-backed, I have to copy the data 
before writing them.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
