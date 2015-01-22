Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 791286B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 20:44:56 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so56666582pad.3
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:44:56 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id hc9si10085385pbc.228.2015.01.21.17.44.53
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 17:44:54 -0800 (PST)
Date: Thu, 22 Jan 2015 10:45:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages'
 on PPC builds
Message-ID: <20150122014550.GA21444@js1304-P5Q-DELUXE>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
 <20150120230150.GA14475@cloud>
 <20150120160738.edfe64806cc8b943beb1dfa0@linux-foundation.org>
 <CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC5umyieZn7ppXkKb45O=C=BF+iv6R_A1Dwfhro=cBJzFeovrA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, josh@joshtriplett.org, Kim Phillips <kim.phillips@freescale.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, Jan 21, 2015 at 09:57:59PM +0900, Akinobu Mita wrote:
> 2015-01-21 9:07 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> > On Tue, 20 Jan 2015 15:01:50 -0800 josh@joshtriplett.org wrote:
> >
> >> On Tue, Jan 20, 2015 at 02:02:00PM -0600, Kim Phillips wrote:
> >> > It's possible to configure DEBUG_PAGEALLOC without PAGE_POISONING on
> >> > ppc.  Fix building the generic kernel_map_pages() implementation in
> >> > this case:
> >> >
> >> >   LD      init/built-in.o
> >> > mm/built-in.o: In function `free_pages_prepare':
> >> > mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
> >> > mm/built-in.o: In function `prep_new_page':
> >> > mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
> >> > mm/built-in.o: In function `map_pages':
> >> > mm/compaction.c:61: undefined reference to `.kernel_map_pages'
> >> > make: *** [vmlinux] Error 1
> 
> kernel_map_pages() is static inline function since commit 031bc5743f15
> ("mm/debug-pagealloc: make debug-pagealloc boottime configurable").
> 
> But there is old declaration in 'arch/powerpc/include/asm/cacheflush.h'.
> Removing it or changing s/kernel_map_pages/__kernel_map_pages/ in this
> header file or something can fix this problem?
> 
> The architecture which has ARCH_SUPPORTS_DEBUG_PAGEALLOC
> including PPC should not build mm/debug-pagealloc.o

Yes, architecture with ARCH_SUPPORTS_DEBUG_PAGEALLOC should not build
mm/debug-pagealloc.o. I attach the patch to remove old declaration.
I hope it will fix Kim's problem.

-------------->8------------------
