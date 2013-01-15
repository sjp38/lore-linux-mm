Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id CCECB6B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 15:05:55 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id w5so305719bku.25
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 12:05:54 -0800 (PST)
Message-ID: <50F5B69E.1070101@gmail.com>
Date: Tue, 15 Jan 2013 21:05:50 +0100
From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com> <50F3F289.3090402@web.de> <20130115165642.GA25500@titan.lakedaemon.net>
In-Reply-To: <20130115165642.GA25500@titan.lakedaemon.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Soeren Moch <smoch@web.de>, Greg KH <gregkh@linuxfoundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-arm-kernel@lists.infradead.org

On 01/15/2013 05:56 PM, Jason Cooper wrote:
> Greg,
>
> I've added you to the this thread hoping for a little insight into USB
> drivers and their use of coherent and GFP_ATOMIC.  Am I barking up the
> wrong tree by looking a the drivers?
>
> On Mon, Jan 14, 2013 at 12:56:57PM +0100, Soeren Moch wrote:
>> On 20.11.2012 15:31, Marek Szyprowski wrote:
>>> dmapool always calls dma_alloc_coherent() with GFP_ATOMIC flag,
>>> regardless the flags provided by the caller. This causes excessive
>>> pruning of emergency memory pools without any good reason. Additionaly,
>>> on ARM architecture any driver which is using dmapools will sooner or
>>> later  trigger the following error:
>>> "ERROR: 256 KiB atomic DMA coherent pool is too small!
>>> Please increase it with coherent_pool= kernel parameter!".
>>> Increasing the coherent pool size usually doesn't help much and only
>>> delays such error, because all GFP_ATOMIC DMA allocations are always
>>> served from the special, very limited memory pool.
>>>
>>> This patch changes the dmapool code to correctly use gfp flags provided
>>> by the dmapool caller.
>>>
>>> Reported-by: Soeren Moch<smoch@web.de>
>>> Reported-by: Thomas Petazzoni<thomas.petazzoni@free-electrons.com>
>>> Signed-off-by: Marek Szyprowski<m.szyprowski@samsung.com>
>>> Tested-by: Andrew Lunn<andrew@lunn.ch>
>>> Tested-by: Soeren Moch<smoch@web.de>
>>
>> Now I tested linux-3.7.1 (this patch is included there) on my Marvell
>> Kirkwood system. I still see
>>
>>    ERROR: 1024 KiB atomic DMA coherent pool is too small!
>>    Please increase it with coherent_pool= kernel parameter!
>>
>> after several hours of runtime under heavy load with SATA and
>> DVB-Sticks (em28xx / drxk and dib0700).
>
> Could you try running the system w/o the em28xx stick and see how it
> goes with v3.7.1?

Jason,

can you point out what you think we should be looking for?

I grep'd for 'GFP_' in  drivers/media/usb and especially for dvb-usb
(dib0700) it looks like most of the buffers in usb-urb.c are allocated
GFP_ATOMIC. em28xx also allocates some of the buffers atomic.

If we look for a mem leak in one of the above drivers (including sata_mv),
is there an easy way to keep track of allocated and freed kernel memory?

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
