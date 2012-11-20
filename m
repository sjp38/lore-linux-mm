Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5B1E26B0073
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 19:04:53 -0500 (EST)
Date: Tue, 20 Nov 2012 15:27:27 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20121120202727.GE22106@titan.lakedaemon.net>
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
 <20121120113325.dde266ed.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121120113325.dde266ed.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Soren Moch <smoch@web.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

On Tue, Nov 20, 2012 at 11:33:25AM -0800, Andrew Morton wrote:
> On Tue, 20 Nov 2012 15:31:45 +0100
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag,
> > regardless the flags provided by the caller. This causes excessive
> > pruning of emergency memory pools without any good reason. Additionaly,
> > on ARM architecture any driver which is using dmapools will sooner or
> > later  trigger the following error: 
> > "ERROR: 256 KiB atomic DMA coherent pool is too small!
> > Please increase it with coherent_pool= kernel parameter!".
> > Increasing the coherent pool size usually doesn't help much and only
> > delays such error, because all GFP_ATOMIC DMA allocations are always
> > served from the special, very limited memory pool.
> > 
> 
> Is this problem serious enough to justify merging the patch into 3.7? 
> And into -stable kernels?

kirkwood and orion5x currently have the following code in their early
init:

/*
 * Some Kirkwood devices allocate their coherent buffers from atomic
 * context. Increase size of atomic coherent pool to make sure such the
 * allocations won't fail.
 */
init_dma_coherent_pool_size(SZ_1M);

We have a pending patch to do the same for mvebu (new armv7 Marvell
SoCs).  There is at least one reported real world case where even the
above isn't sufficient [1].

thx,

Jason.

[1] http://www.spinics.net/lists/arm-kernel/msg205495.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
