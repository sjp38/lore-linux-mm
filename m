Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3233D6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 02:53:03 -0400 (EDT)
Message-ID: <4A811545.5090209@redhat.com>
Date: Tue, 11 Aug 2009 09:52:53 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Page allocation failures in guest
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>	<28c262360907130759w29c84117w635b21408090a06c@mail.gmail.com> <20090811083233.3b2be444@mjolnir.ossman.eu>
In-Reply-To: <20090811083233.3b2be444@mjolnir.ossman.eu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On 08/11/2009 09:32 AM, Pierre Ossman wrote:
> On Mon, 13 Jul 2009 23:59:52 +0900
> Minchan Kim<minchan.kim@gmail.com>  wrote:
>
>    
>> On Mon, Jul 13, 2009 at 6:51 PM, Pierre Ossman<drzeus-list@drzeus.cx>  wrote:
>>      
>>> Jul 12 23:04:54 loki kernel: Active_anon:14065 active_file:87384 inactive_anon:37480
>>> Jul 12 23:04:54 loki kernel: inactive_file:95821 unevictable:4 dirty:8 writeback:0 unstable:0
>>> Jul 12 23:04:54 loki kernel: free:1344 slab:7113 mapped:4283 pagetables:5656 bounce:0
>>> Jul 12 23:04:54 loki kernel: Node 0 DMA free:3988kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:3532kB inactive_file:1032kB unevictable:0kB present:6840kB pages_scanned:0 all_un
>>>        
>> I don't know why present is bigger than free + [in]active anon ?
>> Who know this ?
>>
>> There are 258 pages in inactive file.
>> Unfortunately, it seems we don't have any discardable pages.
>> The reclaimer can't sync dirty pages to reclaim them, too.
>> That's because we are going on GFP_ATOMIC as I mentioned.
>>
>>      
>
> Any ideas here? Is the virtio net driver very GFP_ATOMIC happy so it
> drains all those pages? And why is this triggered by a kernel upgrade
> in the host?
>
> Avi?
>
>    

Rusty?

>>> reclaimable? no
>>> Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 994 994 994
>>> Jul 12 23:04:54 loki kernel: Node 0 DMA32 free:1388kB min:4020kB low:5024kB high:6028kB active_anon:56260kB inactive_anon:149920kB active_file:346004kB inactive_file:382252kB unevictable:16kB present:1018016
>>>        
>> free : 1388KB min : 4020KB. In addtion, now GFP_HIGH. so calculation
>> is as follow for zone_watermark_ok.
>>
>> 1388<  (4020 / 2)
>>
>> So failed it in zone_watermark_ok.
>> AFAIU, it's fairy OOM problem.
>>
>>      
>
> I doesn't get out of it though, or at least the virtio net driver
> wedges itself.
>
> Rgds
>    


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
