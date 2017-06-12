Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B19E16B02F4
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 10:06:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g76so23058515wrd.3
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 07:06:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k72si9619754wrc.86.2017.06.12.07.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 07:06:11 -0700 (PDT)
Subject: Re: [4.9.28] vmscan: shrink_slab: ext4_es_scan+0x0/0x150 negative
 objects to delete nr=-2147483624
References: <20170518052149.GA953@local.marc.ngoe.de>
 <20170612122336.GA17592@lnxrabinv.se.axis.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4b8451d7-4204-f201-3843-576ea1b21543@suse.cz>
Date: Mon, 12 Jun 2017 16:06:09 +0200
MIME-Version: 1.0
In-Reply-To: <20170612122336.GA17592@lnxrabinv.se.axis.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rabin Vincent <rabin@rab.in>, Marc Burkhardt <marc@marc.ngoe.de>, shli@fb.com, mhocko@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2017 02:23 PM, Rabin Vincent wrote:
> On Thu, May 18, 2017 at 07:21:49AM +0200, Marc Burkhardt wrote:
>> tonight my dmesg was flooded with mesages like 
>>
>> vmscan: shrink_slab: ext4_es_scan+0x0/0x150 negative objects to delete nr=-2147483624
>>
>> Is that an integer overflow happening in ext4?
>>
>> It's the first time I see this message. Any help on how to debug/reprocude this
>> are appreciated. Please advice if you want me to investigate this.
> 
> I haven't attempted to debug nor reproduce it, but what I can tell you
> is that it does not not have anything to with ext4.  I've seen similar
> messages with a completely different slab, on 4.9.26:

This alone looks suspicious in do_shrink_slab()?

       unsigned long long delta;
       long total_scan;
...
       total_scan += delta;

>  [367594.725081] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482285
>  [367595.046073] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147479427
>  [367595.279228] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482317
>  [367595.459529] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482353
>  [367595.497191] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482386
>  [367595.521578] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482413
>  [367595.551109] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482501
>  [367598.344400] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482458
>  [367598.369103] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482493
>  [367598.403148] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482521
>  [367598.422815] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482611
>  [367598.524128] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147483238
>  [367601.554775] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482245
>  [367601.582922] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482279
>  [367601.620175] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482307
>  [367602.958946] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147479516
>  [367603.630417] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482412
>  [367603.746885] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482512
>  [367603.769490] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482217
>  [367604.155461] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147479940
>  [367604.174624] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482635
>  [367604.197573] vmscan: shrink_slab: super_cache_scan+0x0/0x19c negative objects to delete nr=-2147482595
> 
> I don't see any fixes/changes to mm/vmscan.c in newer 4.9-stable kernels
> other than these ones which were already merged v4.9.14:
> 
>  $ git shortlog v4.9..v4.9.30 -- mm/vmscan.c
>  Michal Hocko (3):
>        mm, memcg: fix the active list aging for lowmem requests when memcg is enabled
>        mm, vmscan: cleanup lru size claculations
>        mm, vmscan: consider eligible zones in get_scan_count
>  
>  Shaohua Li (1):
>        mm/vmscan.c: set correct defer count for shrinker
> 
> Perhaps one of the above people or someone else in linux-mm recognizes this.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
