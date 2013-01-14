Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 31B466B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 06:57:17 -0500 (EST)
Message-ID: <50F3F289.3090402@web.de>
Date: Mon, 14 Jan 2013 12:56:57 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Andrew Morton <akpm@linux-foundation.org>, Jason Cooper <jason@lakedaemon.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

On 20.11.2012 15:31, Marek Szyprowski wrote:
> dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag,
> regardless the flags provided by the caller. This causes excessive
> pruning of emergency memory pools without any good reason. Additionaly,
> on ARM architecture any driver which is using dmapools will sooner or
> later  trigger the following error:
> "ERROR: 256 KiB atomic DMA coherent pool is too small!
> Please increase it with coherent_pool= kernel parameter!".
> Increasing the coherent pool size usually doesn't help much and only
> delays such error, because all GFP_ATOMIC DMA allocations are always
> served from the special, very limited memory pool.
>
> This patch changes the dmapool code to correctly use gfp flags provided
> by the dmapool caller.
>
> Reported-by: Soeren Moch <smoch@web.de>
> Reported-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Tested-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Soeren Moch <smoch@web.de>

Now I tested linux-3.7.1 (this patch is included there) on my Marvell
Kirkwood system. I still see

   ERROR: 1024 KiB atomic DMA coherent pool is too small!
   Please increase it with coherent_pool= kernel parameter!

after several hours of runtime under heavy load with SATA and
DVB-Sticks (em28xx / drxk and dib0700).

As already reported earlier this patch improved the behavior compared to 
linux-3.6.x and 3.7.0 (error after several ten minutes runtime), but
I still see a regression compared to linux-3.5.x. With this kernel the
same system with same workload runs flawlessly.

Regards,
Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
