Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 978A38D0008
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 17:31:09 -0400 (EDT)
Date: Tue, 30 Oct 2012 14:31:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm, highmem: remove useless pool_lock
Message-Id: <20121030143107.ee1f959b.akpm@linux-foundation.org>
In-Reply-To: <1351451576-2611-3-git-send-email-js1304@gmail.com>
References: <Yes>
	<1351451576-2611-1-git-send-email-js1304@gmail.com>
	<1351451576-2611-3-git-send-email-js1304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 29 Oct 2012 04:12:53 +0900
Joonsoo Kim <js1304@gmail.com> wrote:

> The pool_lock protects the page_address_pool from concurrent access.
> But, access to the page_address_pool is already protected by kmap_lock.
> So remove it.

Well, there's a set_page_address() call in mm/page_alloc.c which
doesn't have lock_kmap().  it doesn't *need* lock_kmap() because it's
init-time code and we're running single-threaded there.  I hope!

But this exception should be double-checked and mentioned in the
changelog, please.  And it's a reason why we can't add
assert_spin_locked(&kmap_lock) to set_page_address(), which is
unfortunate.


The irq-disabling in this code is odd.  If ARCH_NEEDS_KMAP_HIGH_GET=n,
we didn't need irq-safe locking in set_page_address().  I guess we'll
need to retain it in page_address() - I expect some callers have IRQs
disabled.


ARCH_NEEDS_KMAP_HIGH_GET is a nasty looking thing.  It's ARM:

/*
 * The reason for kmap_high_get() is to ensure that the currently kmap'd
 * page usage count does not decrease to zero while we're using its
 * existing virtual mapping in an atomic context.  With a VIVT cache this
 * is essential to do, but with a VIPT cache this is only an optimization
 * so not to pay the price of establishing a second mapping if an existing
 * one can be used.  However, on platforms without hardware TLB maintenance
 * broadcast, we simply cannot use ARCH_NEEDS_KMAP_HIGH_GET at all since
 * the locking involved must also disable IRQs which is incompatible with
 * the IPI mechanism used by global TLB operations.
 */
#define ARCH_NEEDS_KMAP_HIGH_GET
#if defined(CONFIG_SMP) && defined(CONFIG_CPU_TLB_V6)
#undef ARCH_NEEDS_KMAP_HIGH_GET
#if defined(CONFIG_HIGHMEM) && defined(CONFIG_CPU_CACHE_VIVT)
#error "The sum of features in your kernel config cannot be supported together"
#endif
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
