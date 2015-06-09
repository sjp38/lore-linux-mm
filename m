Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 63DFF6B0038
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 11:03:10 -0400 (EDT)
Received: by qgfa66 with SMTP id a66so6595730qgf.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 08:03:10 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b132si5657828qka.45.2015.06.09.08.03.08
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 08:03:09 -0700 (PDT)
Date: Tue, 9 Jun 2015 16:03:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
Message-ID: <20150609150303.GB4808@e104818-lin.cambridge.arm.com>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
 <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
 <55769F85.5060909@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55769F85.5060909@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, "Liu, XinwuX" <xinwux.liu@intel.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On Tue, Jun 09, 2015 at 09:10:45AM +0100, Zhang, Yanmin wrote:
> On 2015/6/8 18:13, Catalin Marinas wrote:
> > As I replied already, I don't think this is that bad, or at least not
> > worse than what kmemleak already does (looking at all data whether it's
> > pointer or not).
> 
> It depends. As for memleak, developers prefers there are false alarms instead
> of missing some leaked memory.

Lots of false positives aren't that nice, you spend a lot of time
debugging them (I've been there in the early kmemleak days). Anyway,
your use case is not about false positives vs. negatives but just false
negatives.

My point is that there is a lot of random, pointer-like data read by
kmemleak even without this memset (e.g. thread stacks, non-pointer data
in kmalloc'ed structures, data/bss sections). Just doing this memset may
reduce the chance of false negatives a bit but I don't think it would be
noticeable.

If there is some serious memory leak (lots of objects), they would
likely show up at some point. Even if it's a one-off leak, it's possible
that it shows up after some time (e.g. the object pointing to this
memory block is freed).

> >  It also doesn't solve the kmem_cache_alloc() case where
> > the original object size is no longer available.
> 
> Such issue around kmem_cache_alloc() case happens only when the
> caller doesn't initialize or use the full object, so the object keeps
> old dirty data.

The kmem_cache blocks size would be aligned to a cache line, so you
still have some extra bytes never touched by the caller.

> This patch is to resolve the redundant unused space (more than object size)
> although the full object is used by kernel.

So this solves only the cases where the original object size is still
known (e.g. kmalloc). It could also be solved by telling kmemleak the
actual object size.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
