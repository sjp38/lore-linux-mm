Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 86F756B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 10:46:38 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so17524817wgg.15
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 07:46:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si24258447wjy.79.2014.12.02.07.46.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 07:46:35 -0800 (PST)
Message-ID: <547DDED9.6080105@suse.cz>
Date: Tue, 02 Dec 2014 16:46:33 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com> <20141119212013.GA18318@cucumber.anchor.net.au> <546D2366.1050506@suse.cz> <20141121023554.GA24175@cucumber.bridge.anchor.net.au> <20141123093348.GA16954@cucumber.anchor.net.au> <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com> <20141128080331.GD11802@js1304-P5Q-DELUXE> <54783FB7.4030502@suse.cz> <20141201083118.GB2499@js1304-P5Q-DELUXE> <20141202014724.GA22239@cucumber.bridge.anchor.net.au> <20141202045324.GC6268@js1304-P5Q-DELUXE>
In-Reply-To: <20141202045324.GC6268@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On 12/02/2014 05:53 AM, Joonsoo Kim wrote:
> On Tue, Dec 02, 2014 at 12:47:24PM +1100, Christian Marie wrote:
>> On 28.11.2014 9:03, Joonsoo Kim wrote:
>>> Hello,
>>>
>>> I didn't follow-up this discussion, but, at glance, this excessive CPU
>>> usage by compaction is related to following fixes.
>>>
>>> Could you test following two patches?
>>>
>>> If these fixes your problem, I will resumit patches with proper commit
>>> description.
>>>
>>> -------- 8< ---------
>>
>>
>> Thanks for looking into this. Running 3.18-rc5 kernel with your patches has
>> produced some interesting results.
>>
>> Load average still spikes to around 2000-3000 with the processors spinning 100%
>> doing compaction related things when min_free_kbytes is left at the default.
>>
>> However, unlike before, the system is now completely stable. Pre-patch it would
>> be almost completely unresponsive (having to wait 30 seconds to establish an
>> SSH connection and several seconds to send a character).
>>
>> Is it reasonable to guess that ipoib is giving compaction a hard time and
>> fixing this bug has allowed the system to at least not lock up?
>>
>> I will try back-porting this to 3.10 and seeing if it is stable under these
>> strange conditions also.
>
> Hello,
>
> Good to hear!

Indeed, although I somehow doubt your first patch could have made such 
difference. It only matters when you have a whole pageblock free. 
Without the patch, the particular compaction attempt that managed to 
free the block might not be terminated ASAP, but then the free pageblock 
is still allocatable by the following allocation attempts, so it 
shouldn't result in a stream of complete compactions.

So I would expect it's either a fluke, or the second patch made the 
difference, to either SLUB or something else making such fallback-able 
allocations.

But hmm, I've never considered the implications of compact_finished() 
migratetypes handling on unmovable allocations. Regardless of cc->order, 
it often has to free a whole pageblock to succeed, as it's unlikely it 
will succeed compacting within a pageblock already marked as UNMOVABLE. 
Guess it's to prevent further fragmentation and that makes sense, but it 
does make high-order unmovable allocations problematic. At least the 
watermark checks for allowing compaction in the first place are then 
wrong - we decide that based on cc->order, but in we fact need at least 
a pageblock worth of space free to actually succeed.

> Load average spike may be related to skip bit management. Currently, there is
> no way to maintain skip bit permanently. So, after one iteration of compaction
> is finished and skip bit is reset, all pageblocks should be re-scanned.

Shouldn't be "after one iteration of compaction", the bits are cleared 
only when compaction is restarting after being deferred, or when kswapd 
goes to sleep.

> Your system has mellanox driver and although I don't know exactly what it is,
> I heard that it allocates enormous pages and do get_user_pages() to
> pin pages in memory. These memory aren't available to compaction, but,
> compaction always scan it.
>
> This is just my assumption, so if possible, please check it with
> compaction tracepoint. If it is, we can make a solution for this
> problem.
>
> Anyway, could you test one more time without second patch?
> IMO, first patch is reasonable to backport, because it fixes a real bug.
> But, I'm not sure if second patch is needed to backport or not.
> One more testing will help us to understand the effect of patch.
>
> Thanks.
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
