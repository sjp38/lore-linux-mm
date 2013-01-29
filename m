Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E09616B0027
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 19:14:02 -0500 (EST)
Date: Mon, 28 Jan 2013 19:13:54 -0500
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130129001354.GN1758@titan.lakedaemon.net>
References: <50F800EB.6040104@web.de>
 <201301172026.45514.arnd@arndb.de>
 <50FABBED.1020905@web.de>
 <20130119185907.GA20719@lunn.ch>
 <5100022D.9050106@web.de>
 <20130123162515.GK13482@lunn.ch>
 <510018B4.9040903@web.de>
 <51001BEE.9020201@web.de>
 <20130123181029.GE20719@lunn.ch>
 <5106E6A6.7010207@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5106E6A6.7010207@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>, gennarone@gmail.com, mchehab@redhat.com
Cc: Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Mon, Jan 28, 2013 at 09:59:18PM +0100, Soeren Moch wrote:
> On 23.01.2013 19:10, Andrew Lunn wrote:
> >>>>
> >>>
> >>>Now (in the last hour) stable, occasionally lower numbers:
> >>>3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396
> >>>3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396
> >>>3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396
> >>>3396 3396 3396 3396 3396 3396 3396 3396 3396 3365 3396 3394 3396 3396
> >>>3396 3396 3373 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396
> >>>3396 3353 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396 3396
> >>>3394 3396 3396 3396 3396 3396 3396 3396
> >>>
> >>>Before the last pool exhaustion going down:
> >>>3395 3395 3389 3379 3379 3374 3367 3360 3352 3343 3343 3343 3342 3336
> >>>3332 3324 3318 3314 3310 3307 3305 3299 3290 3283 3279 3272 3266 3265
> >>>3247 3247 3247 3242 3236 3236
> >>>
> >>Here I stopped vdr (and so closed all dvb_demux devices), the number
> >>was remaining the same 3236, even after restart of vdr (and restart
> >>of streaming).
> >
> >So it does suggest a leak. Probably somewhere on an error path,
> >e.g. its lost video sync.
> >
> 
> Now I activated the debug messages in em28xx. From the messages I
> see no correlation of the pool exhaustion and lost sync. Also I
> cannot see any error messages from the em28xx driver.
> I see a lot of init_isoc/stop_urbs (maybe EPG scan?) without
> draining the coherent pool (checked with 'cat
> /debug/dma-api/num_free_entries', which gave stable numbers), but
> after half an hour there are only init_isoc messages without
> corresponding stop_urbs messages and num_free_entries decreased
> until coherent pool exhaustion.
> 
> Any idea where the memory leak is? What is allocating coherent
> buffers for orion-ehci?

Keeping in mind that I am completely unfamiliar with usb dvb, my best
guess is that the problem is in em28xx-core.c:1131

According to your log messages, it is in mode 2, which is
EM28XX_DIGITAL_MODE.

There seem to be good hints in

86d38d1e [media] em28xx: pre-allocate DVB isoc transfer buffers

I added the relevant parties to the To:...

For Gianluca and Mauro, the whole thread may be found at:

http://markmail.org/message/wm4wlgzoudixd4so#query:+page:1+mid:o7phz7cosmwpcsrz+state:results

thx,

Jason.

> 
>   Soeren
> 
> 
> Jan 28 20:46:03 guruvdr kernel: em28xx #0/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:03 guruvdr kernel: em28xx #0 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:46:03 guruvdr kernel: em28xx #1/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:03 guruvdr kernel: em28xx #1 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:46:23 guruvdr kernel: em28xx #0 em28xx_stop_urbs :em28xx:
> called em28xx_stop_urbs
> Jan 28 20:46:23 guruvdr kernel: em28xx #1 em28xx_stop_urbs :em28xx:
> called em28xx_stop_urbs
> Jan 28 20:46:24 guruvdr kernel: em28xx #0/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:24 guruvdr kernel: em28xx #0 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:46:24 guruvdr kernel: em28xx #1/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:24 guruvdr kernel: em28xx #1 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:46:44 guruvdr kernel: em28xx #1 em28xx_stop_urbs :em28xx:
> called em28xx_stop_urbs
> Jan 28 20:46:44 guruvdr kernel: em28xx #0 em28xx_stop_urbs :em28xx:
> called em28xx_stop_urbs
> Jan 28 20:46:45 guruvdr kernel: em28xx #1/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:45 guruvdr kernel: em28xx #1 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:46:45 guruvdr kernel: em28xx #0/2-dvb: Using 5 buffers
> each with 64 x 940 bytes
> Jan 28 20:46:45 guruvdr kernel: em28xx #0 em28xx_init_isoc :em28xx:
> called em28xx_init_isoc in mode 2
> Jan 28 20:54:33 guruvdr kernel: ERROR: 1024 KiB atomic DMA coherent
> pool is too small!
> Jan 28 20:54:33 guruvdr kernel: Please increase it with
> coherent_pool= kernel parameter!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
