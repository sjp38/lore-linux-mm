Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26C1C828E8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 19:22:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dx6so130375233pad.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 16:22:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l74si3047284pfb.194.2016.04.21.16.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 16:22:11 -0700 (PDT)
Date: Thu, 21 Apr 2016 16:22:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] z3fold: the 3-fold allocator for compressed pages
Message-Id: <20160421162210.f4a50b74bc6ce886ac8c8e4e@linux-foundation.org>
In-Reply-To: <5715FEFD.9010001@gmail.com>
References: <5715FEFD.9010001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, 19 Apr 2016 11:48:45 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> This patch introduces z3fold, a special purpose allocator for storing
> compressed pages. It is designed to store up to three compressed pages per
> physical page. It is a ZBUD derivative which allows for higher compression
> ratio keeping the simplicity and determinism of its predecessor.
> 
> The main differences between z3fold and zbud are:
> * unlike zbud, z3fold allows for up to PAGE_SIZE allocations
> * z3fold can hold up to 3 compressed pages in its page
> 
> This patch comes as a follow-up to the discussions at the Embedded Linux
> Conference in San-Diego related to the talk [1]. The outcome of these
> discussions was that it would be good to have a compressed page allocator
> as stable and deterministic as zbud with with higher compression ratio.
> 
> To keep the determinism and simplicity, z3fold, just like zbud, always
> stores an integral number of compressed pages per page, but it can store
> up to 3 pages unlike zbud which can store at most 2. Therefore the
> compression ratio goes to around 2.5x while zbud's one is around 1.7x.
> 
> The patch is based on the latest linux.git tree.
> 
> This version of the patch has updates related to various concurrency fixes
> made after intensive testing on SMP/HMP platforms.
> 
> [1]https://openiotelc2016.sched.org/event/6DAC/swapping-and-embedded-compression-relieves-the-pressure-vitaly-wool-softprise-consulting-ou
> 

So...  why don't we just replace zbud with z3fold?  (Update the changelog
to answer this rather obvious question, please!)

Are there performance (ie speed) differences?  (Ditto).

There's no documentation.  zbud is covered a bit in
Documentation/vm/zswap.txt.  Maybe there, if appropriate.  Decent
end-user documentation is notably absent.

The code does stuff whether or not CONFG_ZPOOL is enabled.  Let's cover
both scenarios in that documentation please.

> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -565,6 +565,15 @@ config ZBUD
>   	  deterministic reclaim properties that make it preferable to a higher
>   	  density approach when reclaim will be used.
>   
> +config Z3FOLD
> +	tristate "Low density storage for compressed pages"

I don't really understand what "low density" means here.  I'd have
thought it was "high density" if anything.

> +	default n
> +	help
> +	  A special purpose allocator for storing compressed pages.
> +	  It is designed to store up to three compressed pages per physical
> +	  page. It is a ZBUD derivative so the simplicity and determinism are
> +	  still there.
> +
>   config ZSMALLOC
>   	tristate "Memory allocator for compressed pages"
>   	depends on MMU
> diff --git a/mm/Makefile b/mm/Makefile
> index deb467e..78c6f7d 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -89,6 +89,7 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
>   obj-$(CONFIG_ZPOOL)	+= zpool.o
>   obj-$(CONFIG_ZBUD)	+= zbud.o
>   obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
> +obj-$(CONFIG_Z3FOLD)	+= z3fold.o
>   obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o

Something is going on with your email client.  Space-stuffing.

>   obj-$(CONFIG_CMA)	+= cma.o
>   obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> new file mode 100644
> index 0000000..4b473d5
> --- /dev/null
> +++ b/mm/z3fold.c
> @@ -0,0 +1,806 @@
> +/*
> + * z3fold.c
> + *
> + * Copyright (C) 2016, Vitaly Wool <vitalywool@gmail.com>
> + *
> + * This implementation is heavily based on zbud written by Seth Jennings.
> + *
> + * z3fold is an special purpose allocator for storing compressed pages. It
> + * can store up to three compressed pages per page which improves the
> + * compression ratio of zbud while pertaining its concept and simplicity.

s/pertaining/retaining/

> + * It still has simple and deterministic reclaim properties that make it
> + * preferable to a higher density approach when reclaim is used.

Again, what's does a "higher density approach" mean?

> + * As in zbud, pages are divided into "chunks".  The size of the chunks is
> + * fixed at compile time and determined by NCHUNKS_ORDER below.

s/and/and is/

> + * The z3fold API doesn't differ from zbud API and zpool is also supported.
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/atomic.h>
> +#include <linux/list.h>
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/preempt.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/zpool.h>

The code itself looks nice.  It seems to compile so I'll put it in
there for a bit of exposure.

checkpatch complains a lot - please take a look at that.    These:

WARNING: externs should be avoided in .c files
#137: FILE: mm/z3fold.c:60:
+int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,

WARNING: externs should be avoided in .c files
#139: FILE: mm/z3fold.c:62:
+void z3fold_free(struct z3fold_pool *pool, unsigned long handle);

WARNING: externs should be avoided in .c files
#140: FILE: mm/z3fold.c:63:
+int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries);

WARNING: externs should be avoided in .c files
#142: FILE: mm/z3fold.c:65:
+void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle);


are weird.  If the symbol is exported to other .c files then it should
be declared in a header.  If not, it should be static.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
