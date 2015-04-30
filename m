Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE956B006E
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:12:56 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so32251529qcr.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 10:12:56 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id 144si10631376qhb.33.2015.04.30.10.12.55
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 10:12:55 -0700 (PDT)
Message-ID: <55426292.4030309@sgi.com>
Date: Thu, 30 Apr 2015 12:12:50 -0500
From: nzimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430410227.8193.0@cpanel21.proisp.no>
In-Reply-To: <1430410227.8193.0@cpanel21.proisp.no>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>, Mel Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On 04/30/2015 11:10 AM, Daniel J Blueman wrote:
> On Wed, Apr 29, 2015 at 2:38 AM, nzimmer <nzimmer@sgi.com> wrote:
>> On 04/28/2015 11:06 AM, Pekka Enberg wrote:
>>> On Tue, Apr 28, 2015 at 5:36 PM, Mel Gorman <mgorman@suse.de> wrote:
>>>> Struct page initialisation had been identified as one of the 
>>>> reasons why
>>>> large machines take a long time to boot. Patches were posted a long 
>>>> time ago
>>>> to defer initialisation until they were first used.  This was 
>>>> rejected on
>>>> the grounds it should not be necessary to hurt the fast paths. This 
>>>> series
>>>> reuses much of the work from that time but defers the 
>>>> initialisation of
>>>> memory to kswapd so that one thread per node initialises memory 
>>>> local to
>>>> that node.
>>>>
>>>> After applying the series and setting the appropriate Kconfig 
>>>> variable I
>>>> see this in the boot log on a 64G machine
>>>>
>>>> [    7.383764] kswapd 0 initialised deferred memory in 188ms
>>>> [    7.404253] kswapd 1 initialised deferred memory in 208ms
>>>> [    7.411044] kswapd 3 initialised deferred memory in 216ms
>>>> [    7.411551] kswapd 2 initialised deferred memory in 216ms
>>>>
>>>> On a 1TB machine, I see
>>>>
>>>> [    8.406511] kswapd 3 initialised deferred memory in 1116ms
>>>> [    8.428518] kswapd 1 initialised deferred memory in 1140ms
>>>> [    8.435977] kswapd 0 initialised deferred memory in 1148ms
>>>> [    8.437416] kswapd 2 initialised deferred memory in 1148ms
>>>>
>>>> Once booted the machine appears to work as normal. Boot times were 
>>>> measured
>>>> from the time shutdown was called until ssh was available again.  
>>>> In the
>>>> 64G case, the boot time savings are negligible. On the 1TB machine, 
>>>> the
>>>> savings were 16 seconds.
>
>> On an older 8 TB box with lots and lots of cpus the boot time, as 
>> measure from grub to login prompt, the boot time improved from 1484 
>> seconds to exactly 1000 seconds.
>>
>> I have time on 16 TB box tonight and a 12 TB box thursday and will 
>> hopefully have more numbers then.
>
> Neat, and a roughly similar picture here.
>
> On a 7TB, 1728-core NumaConnect system with 108 NUMA nodes, we're 
> seeing stock 4.0 boot in 7136s. This drops to 2159s, or a 70% 
> reduction with this patchset. Non-temporal PMD init [1] drops this to 
> 1045s.
>
> Nathan, what do you guys see with the non-temporal PMD patch [1]? Do 
> add a sfence at the ende label if you manually patch.
>

I have not tried the non-temporal patch yet, Daniel.
I will give that a go when I can grab more machine time but that 
probably won't be today.

> Thanks!
>  Daniel
>
> [1] https://lkml.org/lkml/2015/4/23/350
>

More numbers, including my first set.

My numbers are from grub prompt to login prompt.
All times are in seconds.
The configs are very much like the ones found in sles but with 
RCU_FANOUT_LEAF=64 instead of 16
     Large core count boxed benefit from this quite a bit.

Older 8 TB box (128 nodes)
1484s -> 1000s (yes exactly)

32TB box (128 nodes)
4890s -> 1240s

Recent 12 TB box (32 nodes)
598s -> 450s

I am inferring from these numbers and others that memory locality is a 
big part of the win.

Out of curiosity has anyone ran any tests post boot time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
