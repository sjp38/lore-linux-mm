Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A43B66B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:09 -0500 (EST)
Message-ID: <50F61D86.4020801@web.de>
Date: Wed, 16 Jan 2013 04:24:54 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <1353421905-3112-1-git-send-email-m.szyprowski@samsung.com> <50F3F289.3090402@web.de> <20130115165642.GA25500@titan.lakedaemon.net> <20130115175020.GA3764@kroah.com> <20130115201617.GC25500@titan.lakedaemon.net> <20130115215602.GF25500@titan.lakedaemon.net> <50F5F1B7.3040201@web.de> <20130116024014.GH25500@titan.lakedaemon.net>
In-Reply-To: <20130116024014.GH25500@titan.lakedaemon.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 16.01.2013 03:40, Jason Cooper wrote:
> Soeren,
>
> On Wed, Jan 16, 2013 at 01:17:59AM +0100, Soeren Moch wrote:
>> On 15.01.2013 22:56, Jason Cooper wrote:
>>> On Tue, Jan 15, 2013 at 03:16:17PM -0500, Jason Cooper wrote:
>>>> If my understanding is correct, one of the drivers (most likely one)
>>>> either asks for too small of a dma buffer, or is not properly
>>>> deallocating blocks from the per-device pool.  Either case leads to
>>>> exhaustion, and falling back to the atomic pool.  Which subsequently
>>>> gets wiped out as well.
>>>
>>> If my hunch is right, could you please try each of the three dvb drivers
>>> in turn and see which one (or more than one) causes the error?
>>
>> In fact I use only 2 types of DVB sticks: em28xx usb bridge plus drxk
>> demodulator, and dib0700 usb bridge plus dib7000p demod.
>>
>> I would bet for em28xx causing the error, but this is not thoroughly
>> tested. Unfortunately testing with removed sticks is not easy, because
>> this is a production system and disabling some services for the long
>> time we need to trigger this error will certainly result in unhappy
>> users.
>
> Just out of curiosity, what board is it?

The kirkwood board? A modified Guruplug Server Plus.
>
>> I will see what I can do here. Is there an easy way to track the buffer
>> usage without having to wait for complete exhaustion?
>
> DMA_API_DEBUG

OK, maybe I can try this.
>
>> In linux-3.5.x there is no such problem. Can we use all available memory
>> for dma buffers here on armv5 architectures, in contrast to newer
>> kernels?
>
> Were the loads exactly the same when you tested 3.5.x?

Exactly the same, yes.

>I looked at the
> changes from v3.5 to v3.7.1 for all four drivers you mentioned as well
> as sata_mv.
>
> The biggest thing I see is that all of the media drivers got shuffled
> around into their own subdirectories after v3.5.  'git show -M 0c0d06c'
> shows it was a clean copy of all the files.
>
> What would be most helpful is if you could do a git bisect between
> v3.5.x (working) and the oldest version where you know it started
> failing (v3.7.1 or earlier if you know it).
>
I did not bisect it, but Marek mentioned earlier that commit
e9da6e9905e639b0f842a244bc770b48ad0523e9 in Linux v3.6-rc1 introduced
new code for dma allocations. This is probably the root cause for the
new (mis-)behavior (due to my tests 3.6.0 is not working anymore).
I'm not very familiar with arm mm code, and from the patch itself I
cannot understand what's different. Maybe CONFIG_CMA is default
also for armv5 (not only v6) now? But I might be totally wrong here,
maybe someone of the mm experts can explain the difference?

Regards,
Soeren





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
