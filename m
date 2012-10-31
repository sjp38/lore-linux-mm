Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7290F6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 01:08:33 -0400 (EDT)
Date: Wed, 31 Oct 2012 14:14:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/5] mm, highmem: remove useless pool_lock
Message-ID: <20121031051426.GQ15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
 <1351451576-2611-3-git-send-email-js1304@gmail.com>
 <20121030143107.ee1f959b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121030143107.ee1f959b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,

On Tue, Oct 30, 2012 at 02:31:07PM -0700, Andrew Morton wrote:
> On Mon, 29 Oct 2012 04:12:53 +0900
> Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > The pool_lock protects the page_address_pool from concurrent access.
> > But, access to the page_address_pool is already protected by kmap_lock.
> > So remove it.
> 
> Well, there's a set_page_address() call in mm/page_alloc.c which
> doesn't have lock_kmap().  it doesn't *need* lock_kmap() because it's
> init-time code and we're running single-threaded there.  I hope!
> 
> But this exception should be double-checked and mentioned in the
> changelog, please.  And it's a reason why we can't add
> assert_spin_locked(&kmap_lock) to set_page_address(), which is
> unfortunate.
> 

The exception is vaild only in m68k and sparc and they will use not
set_page_address of highmem.c but page->virtual. So I think we can add
such lock check in set_page_address in highmem.c.

But I'm not sure we really need it because set_page_address is used in
few places so isn't it enough adding a just wording to avoid unnecessary
overhead?

/* NOTE : Caller should hold kmap_lock by lock_kmap() */

> 
> The irq-disabling in this code is odd.  If ARCH_NEEDS_KMAP_HIGH_GET=n,
> we didn't need irq-safe locking in set_page_address().  I guess we'll

What lock you mean in set_page_address?
We have two locks in there, pool_lock and pas->lock.
By this patchset, we don't need pool_lock any more.
Remained thing is pas->lock.

If we make the lock irq-unsafe, it would be deadlock with page_addresss
if it is called in irq context. Currenntly, page_address is used
lots of places and not sure it's called only process context.
Was there any rule that we have to use page_addresss in only
process context?

> need to retain it in page_address() - I expect some callers have IRQs
> disabled.
> 
> 
> ARCH_NEEDS_KMAP_HIGH_GET is a nasty looking thing.  It's ARM:
> 
> /*
>  * The reason for kmap_high_get() is to ensure that the currently kmap'd
>  * page usage count does not decrease to zero while we're using its
>  * existing virtual mapping in an atomic context.  With a VIVT cache this
>  * is essential to do, but with a VIPT cache this is only an optimization
>  * so not to pay the price of establishing a second mapping if an existing
>  * one can be used.  However, on platforms without hardware TLB maintenance
>  * broadcast, we simply cannot use ARCH_NEEDS_KMAP_HIGH_GET at all since
>  * the locking involved must also disable IRQs which is incompatible with
>  * the IPI mechanism used by global TLB operations.
>  */
> #define ARCH_NEEDS_KMAP_HIGH_GET
> #if defined(CONFIG_SMP) && defined(CONFIG_CPU_TLB_V6)
> #undef ARCH_NEEDS_KMAP_HIGH_GET
> #if defined(CONFIG_HIGHMEM) && defined(CONFIG_CPU_CACHE_VIVT)
> #error "The sum of features in your kernel config cannot be supported together"
> #endif
> #endif
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
