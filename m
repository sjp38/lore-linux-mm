Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1E26B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:38:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so54989012wms.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:38:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kk10si67921252wjc.3.2016.11.30.23.38.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 23:38:19 -0800 (PST)
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <9d6e922b-d853-f24d-353c-25fbac38115b@suse.cz>
 <20161201062142.GA25917@orbis-terrarum.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <48823c64-37b4-7ba4-f206-7cb86a4d5540@suse.cz>
Date: Thu, 1 Dec 2016 08:38:15 +0100
MIME-Version: 1.0
In-Reply-To: <20161201062142.GA25917@orbis-terrarum.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>
Cc: Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>

On 12/01/2016 07:21 AM, Robin H. Johnson wrote:
> On Wed, Nov 30, 2016 at 10:24:59PM +0100, Vlastimil Babka wrote:
>> [add more CC's]
>>
>> On 11/30/2016 09:19 PM, Robin H. Johnson wrote:
>> > Somewhere in the Radeon/DRM codebase, CMA page allocation has either
>> > regressed in the timeline of 4.5->4.9, and/or the drm/radeon code is
>> > doing something different with pages.
>>
>> Could be that it didn't use dma_generic_alloc_coherent() before, or you didn't
>> have the generic CMA pool configured.
> v4.9-rc7-23-gded6e842cf49:
> [    0.000000] cma: Reserved 16 MiB at 0x000000083e400000
> [    0.000000] Memory: 32883108K/33519432K available (6752K kernel code, 1244K
> rwdata, 4716K rodata, 1772K init, 2720K bss, 619940K reserved, 16384K
> cma-reserved)
>
>> What's the output of "grep CMA" on your
>> .config?
>
> # grep CMA .config |grep -v -e SECMARK= -e CONFIG_BCMA -e CONFIG_USB_HCD_BCMA -e INPUT_CMA3000 -e CRYPTO_CMAC
> CONFIG_CMA=y
> # CONFIG_CMA_DEBUG is not set
> # CONFIG_CMA_DEBUGFS is not set
> CONFIG_CMA_AREAS=7
> CONFIG_DMA_CMA=y
> CONFIG_CMA_SIZE_MBYTES=16
> CONFIG_CMA_SIZE_SEL_MBYTES=y
> # CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
> # CONFIG_CMA_SIZE_SEL_MIN is not set
> # CONFIG_CMA_SIZE_SEL_MAX is not set
> CONFIG_CMA_ALIGNMENT=8
>
>> Or any kernel boot options with cma in name?
> None.
>
>
>> By default config this should not be used on x86.
> What do you mean by that statement?

I mean that the 16 mbytes for generic CMA area is not a default on x86:

config CMA_SIZE_MBYTES
         int "Size in Mega Bytes"
         depends on !CMA_SIZE_SEL_PERCENTAGE
         default 0 if X86
         default 16

Which explains why it's rare to see these reports in the context such as yours.
I'd recommend just disabling it, as the primary use case for CMA are devices on 
mobile phones that don't have any other fallback (unlike the dma alloc).

> It should be disallowed to enable CONFIG_CMA? Radeon and CMA should be
> mutually exclusive?

I don't think this is a specific problem of radeon. But looks like it's a heavy 
user of the dma alloc. There might be others.

>> > Given that I haven't seen ANY other reports of this, I'm inclined to
>> > believe the problem is drm/radeon specific (if I don't start X, I can't
>> > reproduce the problem).
>>
>> It's rather CMA specific, the allocation attemps just can't be 100% reliable due
>> to how CMA works. The question is if it should be spewing in the log in the
>> context of dma-cma, which has a fallback allocation option. It even uses
>> __GFP_NOWARN, perhaps the CMA path should respect that?
> Yes, I'd say if there's a fallback without much penalty, nowarn makes
> sense. If the fallback just tries multiple addresses until success, then
> the warning should only be issued when too many attempts have been made.

On the other hand, if the warnings are correlated with high kernel CPU usage, 
it's arguably better to be warned.

>>
>> > The rate of the problem starts slow, and also is relatively low on an idle
>> > system (my screens blank at night, no xscreensaver running), but it still ramps
>> > up over time (to the point of generating 2.5GB/hour of "(timestamp)
>> > alloc_contig_range: [83e4d9, 83e4da) PFNs busy"), with various addresses (~100
>> > unique ranges for a day).
>> >
>> > My X workload is ~50 chrome tabs and ~20 terminals (over 3x 24" monitors w/ 9
>> > virtual desktops per monitor).
>> So IIUC, except the messages, everything actually works fine?
> There's high kernel CPU usage that seems to roughly correlate with the
> messages, but I can't yet tell if that's due to the syslog itself, or
> repeated alloc_contig_range requests.

You could try running perf top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
