Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 11F7D6B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 17:28:16 -0400 (EDT)
Received: by qyk36 with SMTP id 36so928402qyk.12
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 14:28:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
References: <200908122007.43522.ngupta@vflare.org>
	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
	 <20090813151312.GA13559@linux.intel.com>
	 <20090813162621.GB1915@phenom2.trippelsdorf.de>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
Date: Thu, 13 Aug 2009 17:28:24 -0400
Message-ID: <87f94c370908131428u75dfe496x1b7d90b94833bf80@mail.gmail.com>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: david@lang.hm
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 13, 2009 at 4:44 PM, <david@lang.hm> wrote:
> On Thu, 13 Aug 2009, Greg Freemyer wrote:
>
>> On Thu, Aug 13, 2009 at 12:33 PM, <david@lang.hm> wrote:
>>>
>>> On Thu, 13 Aug 2009, Markus Trippelsdorf wrote:
>>>
>>>> On Thu, Aug 13, 2009 at 08:13:12AM -0700, Matthew Wilcox wrote:
>>>>>
>>>>> I am planning a complete overhaul of the discard work. =A0Users can s=
end
>>>>> down discard requests as frequently as they like. =A0The block layer =
will
>>>>> cache them, and invalidate them if writes come through. =A0Periodical=
ly,
>>>>> the block layer will send down a TRIM or an UNMAP (depending on the
>>>>> underlying device) and get rid of the blocks that have remained
>>>>> unwanted
>>>>> in the interim.
>>>>
>>>> That is a very good idea. I've tested your original TRIM implementatio=
n
>>>> on
>>>> my Vertex yesterday and it was awful ;-). The SSD needs hundreds of
>>>> milliseconds to digest a single TRIM command. And since your
>>>> implementation
>>>> sends a TRIM for each extent of each deleted file, the whole system is
>>>> unusable after a short while.
>>>> An optimal solution would be to consolidate the discard requests, bund=
le
>>>> them and send them to the drive as infrequent as possible.
>>>
>>> or queue them up and send them when the drive is idle (you would need t=
o
>>> keep track to make sure the space isn't re-used)
>>>
>>> as an example, if you would consider spinning down a drive you don't hu=
rt
>>> performance by sending accumulated trim commands.
>>>
>>> David Lang
>>
>> An alternate approach is the block layer maintain its own bitmap of
>> used unused sectors / blocks. Unmap commands from the filesystem just
>> cause the bitmap to be updated. =A0No other effect.
>
> how does the block layer know what blocks are unused by the filesystem?
>
> or would it be a case of the filesystem generating discard/trim requests =
to
> the block layer so that it can maintain it's bitmap, and then the block
> layer generating the requests to the drive below it?
>
> David Lang

Yes, my thought.was that block layer would consume the discard/trim
requests from the filesystem in realtime to maintain the bitmap, then
at some later point in time when the system has extra resources it
would generate the calls down to the lower layers and eventually the
drive.

I highlight the lower layers because mdraid is also going to have to
be in the mix if raid5/6 is in use.  ie. At a minimum it will have to
adjust the block range to align with the stripe boundaries.

Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
