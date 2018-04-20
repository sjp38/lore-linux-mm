Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D843F6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:47:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h9so4133652pfn.22
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:47:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v13si4968403pgq.478.2018.04.20.04.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 04:47:17 -0700 (PDT)
Date: Fri, 20 Apr 2018 04:47:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180420114712.GB10788@bombadil.infradead.org>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 19, 2018 at 12:12:38PM -0400, Mikulas Patocka wrote:
> Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> code.

Maybe it's time to have the SG code handle vmalloced pages?  This is
becoming more and more common with vmapped stacks (and some of our
workarounds are hideous -- allocate 4 bytes with kmalloc because we can't
DMA onto the stack any more?).  We already have a few places which do
handle sgs of vmalloced addresses, such as the nx crypto driver:

        if (is_vmalloc_addr(start_addr))
                sg_addr = page_to_phys(vmalloc_to_page(start_addr))
                          + offset_in_page(sg_addr);
        else
                sg_addr = __pa(sg_addr);

and videobuf:

                pg = vmalloc_to_page(virt);
                if (NULL == pg)
                        goto err;
                BUG_ON(page_to_pfn(pg) >= (1 << (32 - PAGE_SHIFT)));
                sg_set_page(&sglist[i], pg, PAGE_SIZE, 0);

Yes, there's the potential that we have to produce two SG entries for a
virtually contiguous region if it crosses a page boundary, and our APIs
aren't set up right to make it happen.  But this is something we should
consider fixing ... otherwise we'll end up with dozens of driver hacks.
The videobuf implementation was already copy-and-pasted into the saa7146
driver, for example.
