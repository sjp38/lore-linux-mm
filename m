Date: Sun, 13 Apr 2003 15:12:32 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: 2.5.67-mm2
Message-ID: <20030413151232.D672@nightmaster.csn.tu-chemnitz.de>
References: <20030412180852.77b6c5e8.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030412180852.77b6c5e8.akpm@digeo.com>; from akpm@digeo.com on Sat, Apr 12, 2003 at 06:08:52PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
hi lists readers,

On Sat, Apr 12, 2003 at 06:08:52PM -0700, Andrew Morton wrote:
> +gfp_repeat.patch
> 
>  Implement __GFP_REPEAT: so we can consolidate lots of alloc-with-retry code.

What about reworking the semantics of kmalloc()?

Many users of kmalloc get the flags and size reversed (major
source of hard to find bugs), so wouldn't it be simpler to have:

__kmalloc() /* The old kmalloc()*/

kmalloc()               /* kmalloc(, GFP_KERNEL) */
kmalloc_user()          /* kmalloc(, GFP_USER) */
kmalloc_dma()           /* kmalloc(, GFP_KERNEL | GFP_DMA) */
kmalloc_dma_repeat()    /* kmalloc(, GFP_KERNEL | GFP_DMA | __GFP_REPEAT) */
kmalloc_repeat()        /* kmalloc(, GFP_KERNEL | __GFP_REPEAT) */
kmalloc_atomic()        /* kmalloc(, GFP_ATOMIC) */
kmalloc_atomic_dma()    /* kmalloc(, GFP_ATOMIC | GFP_DMA) */

an so on? These functions will of course just be static inline
wrappers for __kmalloc().

These functions above would just take a size and not confuse
programmers anymore (as prototypes with compatible arguments
usally do).

If it's just a matter of "nobody had the time do do it, yet",
than this is doable, if only slowly.

If this is considered nonsense, then I will shut-up.

What do you think?

Regards

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
