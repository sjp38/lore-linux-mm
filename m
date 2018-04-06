Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8FF56B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 14:02:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e185so1293411wmg.5
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 11:02:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o76sor1109436wrb.52.2018.04.06.11.02.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 11:02:27 -0700 (PDT)
Date: Fri, 6 Apr 2018 21:02:20 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 23/25] slub: make struct kmem_cache_order_objects::x
 unsigned int
Message-ID: <20180406180220.GA32149@avx2>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-23-adobriyan@gmail.com>
 <alpine.DEB.2.20.1803061248540.29393@nuc-kabylake>
 <20180405145108.e1a9f788bea329653505cadc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405145108.e1a9f788bea329653505cadc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Thu, Apr 05, 2018 at 02:51:08PM -0700, Andrew Morton wrote:
> On Tue, 6 Mar 2018 12:51:47 -0600 (CST) Christopher Lameter <cl@linux.com> wrote:
> 
> > On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> > 
> > > struct kmem_cache_order_objects is for mixing order and number of objects,
> > > and orders aren't bit enough to warrant 64-bit width.
> > >
> > > Propagate unsignedness down so that everything fits.
> > >
> > > !!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!
> > 
> > PAGE_SIZE could be a couple of megs on some platforms (256 or so on
> > Itanium/PowerPC???) . So what are the worst case scenarios here?
> > 
> > I think both order and # object should fit in a 32 bit number.
> > 
> > A page with 256M size and 4 byte objects would have 64M objects.
> 
> Another dangling review comment.  Alexey, please respond?

PowerPC is 256KB, IA64 is 64KB.

So "PAGE_SIZE << order" overflows if order is 14 (or 13 if signed int
slips in somewhere. Highest safe order is 12, which should be enough.

When was the last time you saw 2GB slab?
It never happenes as costly order is 3(?).
