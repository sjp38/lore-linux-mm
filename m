Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 273B66B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 09:39:22 -0500 (EST)
Message-ID: <50FFF5C0.60000@web.de>
Date: Wed, 23 Jan 2013 15:37:52 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <201301211855.25455.arnd@arndb.de> <20130121210150.GA9184@kroah.com> <201301221813.57741.arnd@arndb.de>
In-Reply-To: <201301221813.57741.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Jason Cooper <jason@lakedaemon.net>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 22.01.2013 19:13, Arnd Bergmann wrote:
> On Monday 21 January 2013, Greg KH wrote:
>>>
>>> I don't know a lot about USB, but I always assumed that this was not
>>> a normal condition and that there are only a couple of URBs per endpoint
>>> used at a time. Maybe Greg or someone else with a USB background can
>>> shed some light on this.
>>
>> There's no restriction on how many URBs a driver can have outstanding at
>> once, and if you have a system with a lot of USB devices running at the
>> same time, there could be lots of URBs in flight depending on the number
>> of host controllers and devices and drivers being used.

I only use one host controller and (in this test) two usb devices with
the same driver.

> Ok, thanks for clarifying that. I read some more of the em28xx driver,
> and while it does have a bunch of URBs in flight, there are only five
> audio and five video URBs that I see simultaneously being submitted,
> and then resubmitted from their completion handlers. I think this
> means that there should be 10 URBs active at any given time in this
> driver, which does not explain why we get 256 allocations.

I think the audio part of the em28xx bridge is not used in my DVB tests.

Are there other allocations from orion-ehci directly? Maybe something
special for isochronous transfers (since there is no problem with my 
other dvb sticks using bulk transfers)?

> I also noticed that the initial submissions are all atomic but don't
> need to, so it may be worth trying the patch below, which should also
> help in low-memory situations. We could also try moving the resubmission
> into a workqueue in order to let those be GFP_KERNEL, but I don't think
> that will help.

I built a linux-3.7.4 with the em28xx patch and both of your dma-mapping.c
patches. I still see the
   ERROR: 1024 KiB atomic DMA coherent pool is too small!

Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
