Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 391646B0039
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:40:35 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e53so4352435eek.41
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:40:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y5si12173385eee.123.2014.01.22.10.40.33
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 10:40:34 -0800 (PST)
Message-ID: <52E0106B.5010604@redhat.com>
Date: Wed, 22 Jan 2014 13:39:39 -0500
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>		 <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>		 <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>		 <20140122151913.GY4963@suse.de>		 <1390410233.1198.7.camel@ret.masoncoding.com>		 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>		 <1390413819.1198.20.camel@ret.masoncoding.com>	 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>	 <52E00B28.3060609@redhat.com> <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On 01/22/2014 01:35 PM, James Bottomley wrote:
> On Wed, 2014-01-22 at 13:17 -0500, Ric Wheeler wrote:
>> On 01/22/2014 01:13 PM, James Bottomley wrote:
>>> On Wed, 2014-01-22 at 18:02 +0000, Chris Mason wrote:
>>>> On Wed, 2014-01-22 at 09:21 -0800, James Bottomley wrote:
>>>>> On Wed, 2014-01-22 at 17:02 +0000, Chris Mason wrote:
>>>> [ I like big sectors and I cannot lie ]
>>> I think I might be sceptical, but I don't think that's showing in my
>>> concerns ...
>>>
>>>>>> I really think that if we want to make progress on this one, we need
>>>>>> code and someone that owns it.  Nick's work was impressive, but it was
>>>>>> mostly there for getting rid of buffer heads.  If we have a device that
>>>>>> needs it and someone working to enable that device, we'll go forward
>>>>>> much faster.
>>>>> Do we even need to do that (eliminate buffer heads)?  We cope with 4k
>>>>> sector only devices just fine today because the bh mechanisms now
>>>>> operate on top of the page cache and can do the RMW necessary to update
>>>>> a bh in the page cache itself which allows us to do only 4k chunked
>>>>> writes, so we could keep the bh system and just alter the granularity of
>>>>> the page cache.
>>>>>
>>>> We're likely to have people mixing 4K drives and <fill in some other
>>>> size here> on the same box.  We could just go with the biggest size and
>>>> use the existing bh code for the sub-pagesized blocks, but I really
>>>> hesitate to change VM fundamentals for this.
>>> If the page cache had a variable granularity per device, that would cope
>>> with this.  It's the variable granularity that's the VM problem.
>>>
>>>>   From a pure code point of view, it may be less work to change it once in
>>>> the VM.  But from an overall system impact point of view, it's a big
>>>> change in how the system behaves just for filesystem metadata.
>>> Agreed, but only if we don't do RMW in the buffer cache ... which may be
>>> a good reason to keep it.
>>>
>>>>> The other question is if the drive does RMW between 4k and whatever its
>>>>> physical sector size, do we need to do anything to take advantage of
>>>>> it ... as in what would altering the granularity of the page cache buy
>>>>> us?
>>>> The real benefit is when and how the reads get scheduled.  We're able to
>>>> do a much better job pipelining the reads, controlling our caches and
>>>> reducing write latency by having the reads done up in the OS instead of
>>>> the drive.
>>> I agree with all of that, but my question is still can we do this by
>>> propagating alignment and chunk size information (i.e. the physical
>>> sector size) like we do today.  If the FS knows the optimal I/O patterns
>>> and tries to follow them, the odd cockup won't impact performance
>>> dramatically.  The real question is can the FS make use of this layout
>>> information *without* changing the page cache granularity?  Only if you
>>> answer me "no" to this do I think we need to worry about changing page
>>> cache granularity.
>>>
>>> Realistically, if you look at what the I/O schedulers output on a
>>> standard (spinning rust) workload, it's mostly large transfers.
>>> Obviously these are misalgned at the ends, but we can fix some of that
>>> in the scheduler.  Particularly if the FS helps us with layout.  My
>>> instinct tells me that we can fix 99% of this with layout on the FS + io
>>> schedulers ... the remaining 1% goes to the drive as needing to do RMW
>>> in the device, but the net impact to our throughput shouldn't be that
>>> great.
>>>
>>> James
>>>
>> I think that the key to having the file system work with larger
>> sectors is to
>> create them properly aligned and use the actual, native sector size as
>> their FS
>> block size. Which is pretty much back the original challenge.
> Only if you think laying out stuff requires block size changes.  If a 4k
> block filesystem's allocation algorithm tried to allocate on a 16k
> boundary for instance, that gets us a lot of the performance without
> needing a lot of alteration.

The key here is that we cannot assume that writes happen only during 
allocation/append mode.

Unless the block size enforces it, we will have non-aligned, small block IO done 
to allocated regions that won't get coalesced.
>
> It's not even obvious that an ignorant 4k layout is going to be so
> bad ... the RMW occurs only at the ends of the transfers, not in the
> middle.  If we say 16k physical block and average 128k transfers,
> probabalistically we misalign on 6 out of 31 sectors (or 19% of the
> time).  We can make that better by increasing the transfer size (it
> comes down to 10% for 256k transfers.

This really depends on the nature of the device. Some devices could produce very 
erratic performance or even (not today, but some day) reject the IO.

>
>> Teaching each and every file system to be aligned at the storage
>> granularity/minimum IO size when that is larger than the physical
>> sector size is
>> harder I think.
> But you're making assumptions about needing larger block sizes.  I'm
> asking what can we do with what we currently have?  Increasing the
> transfer size is a way of mitigating the problem with no FS support
> whatever.  Adding alignment to the FS layout algorithm is another.  When
> you've done both of those, I think you're already at the 99% aligned
> case, which is "do we need to bother any more" territory for me.
>

I would say no, we will eventually need larger file system block sizes.

Tuning and getting 95% (98%?) of the way there with alignment and IO scheduler 
does help a lot. That is what we do today and it is important when looking for 
high performance.

However, this is more of a short term work around for a lack of a fundamental 
ability to do the right sized file system block for a specific class of device. 
As such, not a crisis that must be solved today, but rather something that I 
think is definitely worth looking at so we can figure this out over the next 
year or so.

Ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
