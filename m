Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5206B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 01:47:37 -0400 (EDT)
Received: by qkx62 with SMTP id 62so143587718qkx.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 22:47:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h195si10684072qhc.116.2015.04.16.22.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 22:47:36 -0700 (PDT)
Date: Fri, 17 Apr 2015 07:44:46 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slub: bulk allocation from per cpu partial pages
Message-ID: <20150417074446.6dd16121@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1504161049030.8605@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
	<20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
	<alpine.DEB.2.11.1504090859560.19278@gentwo.org>
	<alpine.DEB.2.11.1504091215330.18198@gentwo.org>
	<20150416140638.684838a2@redhat.com>
	<alpine.DEB.2.11.1504161049030.8605@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, brouer@redhat.com

On Thu, 16 Apr 2015 10:54:07 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 16 Apr 2015, Jesper Dangaard Brouer wrote:
> 
> > On CPU E5-2630 @ 2.30GHz, the cost of kmem_cache_alloc +
> > kmem_cache_free, is a tight loop (most optimal fast-path), cost 22ns.
> > With elem size 256 bytes, where slab chooses to make 32 obj-per-slab.
> >
> > With this patch, testing different bulk sizes, the cost of alloc+free
> > per element is improved for small sizes of bulk (which I guess this the
> > is expected outcome).
> >
> > Have something to compare against, I also ran the bulk sizes through
> > the fallback versions __kmem_cache_alloc_bulk() and
> > __kmem_cache_free_bulk(), e.g. the none optimized versions.
> >
> >  size    --  optimized -- fallback
> >  bulk  8 --  15ns      --  22ns
> >  bulk 16 --  15ns      --  22ns
> 
> Good.
> 
> >  bulk 30 --  44ns      --  48ns
> >  bulk 32 --  47ns      --  50ns
> >  bulk 64 --  52ns      --  54ns
> 
> Hmm.... We are hittling the atomics I guess... What you got so far is only
> using the per cpu data. Wonder how many partial pages are available

Ups, I can see that this kernel don't have CONFIG_SLUB_CPU_PARTIAL,
I'll re-run tests with this enabled.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
