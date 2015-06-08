Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 89E396B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 06:13:08 -0400 (EDT)
Received: by qgf75 with SMTP id 75so44001475qgf.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 03:13:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g5si2065086qca.6.2015.06.08.03.13.07
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 03:13:07 -0700 (PDT)
Date: Mon, 8 Jun 2015 11:13:02 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
Message-ID: <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Liu, XinwuX" <xinwux.liu@intel.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On Mon, Jun 08, 2015 at 10:38:13AM +0100, Christoph Lameter wrote:
> On Mon, 8 Jun 2015, Liu, XinwuX wrote:
> 
> > when kernel uses kmalloc to allocate memory, slub/slab will find
> > a suitable kmem_cache. Ususally the cache's object size is often
> > greater than requested size. There is unused space which contains
> > dirty data. These dirty data might have pointers pointing to a block
> 
> dirty? In what sense?

I guess XinwuX meant uninitialised.

> > of leaked memory. Kernel wouldn't consider this memory as leaked when
> > scanning kmemleak object.
> 
> This has never been considered leaked memory before to my knowledge and
> the data is already initialized.

It's not the object being allocated that is considered leaked. But
uninitialised data in this object is scanned by kmemleak and it may look
like valid pointers to real leaked objects. So such data increases the
number of kmemleak false negatives.

As I replied already, I don't think this is that bad, or at least not
worse than what kmemleak already does (looking at all data whether it's
pointer or not). It also doesn't solve the kmem_cache_alloc() case where
the original object size is no longer available.

> F.e. The zeroing function in linux/mm/slub.c::slab_alloc_node() zeros the
> complete object and not only the number of bytes specified in the kmalloc
> call. Same thing is true for SLAB.

But that's only when __GFP_ZERO is passed.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
