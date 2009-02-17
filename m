Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E1EDA6B00A5
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 13:10:28 -0500 (EST)
Date: Tue, 17 Feb 2009 19:11:57 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090217181157.GA2158@cmpxchg.org>
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi> <alpine.DEB.1.10.0902171120040.27813@qirst.com> <1234890096.11511.6.camel@penberg-laptop> <alpine.DEB.1.10.0902171204070.15929@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902171204070.15929@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2009 at 12:05:07PM -0500, Christoph Lameter wrote:
> Well yes you missed two locations (kmalloc_caches array has to be
> redimensioned) and I also was writing the same patch...
> 
> Here is mine:
> 
> Subject: SLUB: Do not pass 8k objects through to the page allocator
> 
> Increase the maximum object size in SLUB so that 8k objects are not
> passed through to the page allocator anymore. The network stack uses 8k
> objects for performance critical operations.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2009-02-17 10:45:51.000000000 -0600
> +++ linux-2.6/include/linux/slub_def.h	2009-02-17 11:06:53.000000000 -0600
> @@ -121,10 +121,21 @@
>  #define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
> 
>  /*
> + * Maximum kmalloc object size handled by SLUB. Larger object allocations
> + * are passed through to the page allocator. The page allocator "fastpath"
> + * is relatively slow so we need this value sufficiently high so that
> + * performance critical objects are allocated through the SLUB fastpath.
> + *
> + * This should be dropped to PAGE_SIZE / 2 once the page allocator
> + * "fastpath" becomes competitive with the slab allocator fastpaths.
> + */
> +#define SLUB_MAX_SIZE (2 * PAGE_SIZE)

This relies on PAGE_SIZE being 4k.  If you want 8k, why don't you say
so?  Pekka did this explicitely.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
