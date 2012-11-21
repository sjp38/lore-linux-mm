Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7155E6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:08:57 -0500 (EST)
Received: from eusync2.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDT006RXVZE3M50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Nov 2012 08:09:14 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync2.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MDT00HGNVYT5880@eusync2.samsung.com> for linux-mm@kvack.org;
 Wed, 21 Nov 2012 08:08:55 +0000 (GMT)
Message-id: <50AC8C14.5050204@samsung.com>
Date: Wed, 21 Nov 2012 09:08:52 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
 <20121120113325.dde266ed.akpm@linux-foundation.org>
In-reply-to: <20121120113325.dde266ed.akpm@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Soren Moch <smoch@web.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

Hello,

On 11/20/2012 8:33 PM, Andrew Morton wrote:
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

I wonder if it is a good idea to merge such change at the end of current
-rc period. It changes the behavior of dma pool allocations and I bet there
might be some drivers which don't care much about passed gfp flags, as for
ages it simply worked for them, even if the allocations were done from
atomic context. What do You think? Technically it is also not a pure bugfix,
so imho it shouldn't be considered for -stable.

On the other hand at least for ARM users of sata_mv driver (which is just
an innocent client of dma pool, correctly passing GFP_KERNEL flag) it would
solve the issues related to shortage of atomic pool for dma allocations what
might justify pushing it to 3.7.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
