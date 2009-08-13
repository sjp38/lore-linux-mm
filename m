Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B09926B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 16:44:30 -0400 (EDT)
Date: Thu, 13 Aug 2009 13:44:11 -0700 (PDT)
From: david@lang.hm
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 	slot is freed)
In-Reply-To: <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
References: <200908122007.43522.ngupta@vflare.org>  <Pine.LNX.4.64.0908122312380.25501@sister.anvils>  <20090813151312.GA13559@linux.intel.com>  <20090813162621.GB1915@phenom2.trippelsdorf.de>  <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="680960-654879901-1250196252=:28013"
Sender: owner-linux-mm@kvack.org
To: Greg Freemyer <greg.freemyer@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--680960-654879901-1250196252=:28013
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Thu, 13 Aug 2009, Greg Freemyer wrote:

> On Thu, Aug 13, 2009 at 12:33 PM, <david@lang.hm> wrote:
>> On Thu, 13 Aug 2009, Markus Trippelsdorf wrote:
>>
>>> On Thu, Aug 13, 2009 at 08:13:12AM -0700, Matthew Wilcox wrote:
>>>>
>>>> I am planning a complete overhaul of the discard work.  Users can send
>>>> down discard requests as frequently as they like.  The block layer will
>>>> cache them, and invalidate them if writes come through.  Periodically,
>>>> the block layer will send down a TRIM or an UNMAP (depending on the
>>>> underlying device) and get rid of the blocks that have remained unwanted
>>>> in the interim.
>>>
>>> That is a very good idea. I've tested your original TRIM implementation on
>>> my Vertex yesterday and it was awful ;-). The SSD needs hundreds of
>>> milliseconds to digest a single TRIM command. And since your
>>> implementation
>>> sends a TRIM for each extent of each deleted file, the whole system is
>>> unusable after a short while.
>>> An optimal solution would be to consolidate the discard requests, bundle
>>> them and send them to the drive as infrequent as possible.
>>
>> or queue them up and send them when the drive is idle (you would need to
>> keep track to make sure the space isn't re-used)
>>
>> as an example, if you would consider spinning down a drive you don't hurt
>> performance by sending accumulated trim commands.
>>
>> David Lang
>
> An alternate approach is the block layer maintain its own bitmap of
> used unused sectors / blocks. Unmap commands from the filesystem just
> cause the bitmap to be updated.  No other effect.

how does the block layer know what blocks are unused by the filesystem?

or would it be a case of the filesystem generating discard/trim requests 
to the block layer so that it can maintain it's bitmap, and then the block 
layer generating the requests to the drive below it?

David Lang

> (Big unknown: Where will the bitmap live between reboots?  Require DM
> volumes so we can have a dedicated bitmap volume in the mix to store
> the bitmap to? Maybe on mount, the filesystem has to be scanned to
> initially populate the bitmap?   Other options?)
>
> Assuming we have a persistent bitmap in place, have a background
> scanner that kicks in when the cpu / disk is idle.  It just
> continuously scans the bitmap looking for contiguous blocks of unused
> sectors.  Each time it finds one, it sends the largest possible unmap
> down the block stack and eventually to the device.
>
> When normal cpu / disk activity kicks in, this process goes to sleep.
>
> That way much of the smarts are concentrated in the block layer, not
> in the filesystem code.  And it is being done when the disk is
> otherwise idle, so you don't have the ncq interference.
>
> Even laptop users should have enough idle cpu available to manage
> this.  Enterprise would get the large discards it wants, and
> unmentioned in the previous discussion, mdraid gets the large discards
> it also wants.
>
> ie. If a mdraid raid5/raid6 volume is built of SSDs, it will only be
> able to discard a full stripe at a time. Otherwise the P=D1 ^ D2 logic
> is lost.
>
> Another benefit of the above is the code should be extremely safe and testable.
>
> Greg
>
--680960-654879901-1250196252=:28013--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
