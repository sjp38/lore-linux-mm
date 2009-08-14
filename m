Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7830B6B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 18:54:05 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so598371qwf.44
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 15:54:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A85DF1E.3050801@rtr.ca>
References: <200908122007.43522.ngupta@vflare.org>
	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
	 <20090813151312.GA13559@linux.intel.com>
	 <20090813162621.GB1915@phenom2.trippelsdorf.de>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <1250191095.3901.116.camel@mulgrave.site> <4A85DF1E.3050801@rtr.ca>
Date: Fri, 14 Aug 2009 18:54:11 -0400
Message-ID: <87f94c370908141554ia447f5fo87c74d5d8c517c1c@mail.gmail.com>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mark Lord <liml@rtr.ca>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 6:03 PM, Mark Lord<liml@rtr.ca> wrote:
> James Bottomley wrote:
>>
>> On Thu, 2009-08-13 at 14:15 -0400, Greg Freemyer wrote:
>>>
>>> On Thu, Aug 13, 2009 at 12:33 PM, <david@lang.hm> wrote:
>>>>
>>>> On Thu, 13 Aug 2009, Markus Trippelsdorf wrote:
>>>>
>>>>> On Thu, Aug 13, 2009 at 08:13:12AM -0700, Matthew Wilcox wrote:
>>>>>>
>>>>>> I am planning a complete overhaul of the discard work. =A0Users can =
send
>>>>>> down discard requests as frequently as they like. =A0The block layer
>>>>>> will
>>>>>> cache them, and invalidate them if writes come through. =A0Periodica=
lly,
>>>>>> the block layer will send down a TRIM or an UNMAP (depending on the
>>>>>> underlying device) and get rid of the blocks that have remained
>>>>>> unwanted
>>>>>> in the interim.
>>>>>
>>>>> That is a very good idea. I've tested your original TRIM implementati=
on
>>>>> on
>>>>> my Vertex yesterday and it was awful ;-). The SSD needs hundreds of
>>>>> milliseconds to digest a single TRIM command. And since your
>>>>> implementation
>>>>> sends a TRIM for each extent of each deleted file, the whole system i=
s
>>>>> unusable after a short while.
>>>>> An optimal solution would be to consolidate the discard requests,
>>>>> bundle
>>>>> them and send them to the drive as infrequent as possible.
>>>>
>>>> or queue them up and send them when the drive is idle (you would need =
to
>>>> keep track to make sure the space isn't re-used)
>>>>
>>>> as an example, if you would consider spinning down a drive you don't
>>>> hurt
>>>> performance by sending accumulated trim commands.
>>>>
>>>> David Lang
>>>
>>> An alternate approach is the block layer maintain its own bitmap of
>>> used unused sectors / blocks. Unmap commands from the filesystem just
>>> cause the bitmap to be updated. =A0No other effect.
>>>
>>> (Big unknown: Where will the bitmap live between reboots? =A0Require DM
>>> volumes so we can have a dedicated bitmap volume in the mix to store
>>> the bitmap to? Maybe on mount, the filesystem has to be scanned to
>>> initially populate the bitmap? =A0 Other options?)
>>
>> I wouldn't really have it live anywhere. =A0Discard is best effort; it's
>> not required for fs integrity. =A0As long as we don't discard an in-use
>> block we're free to do anything else (including forget to discard,
>> rediscard a discarded block etc).
>>
>> It is theoretically possible to run all of this from user space using
>> the fs mappings, a bit like a defrag command.
>
> ..
>
> Already a work-in-progress -- see my wiper.sh script on the hdparm page
> at sourceforge. =A0Trimming 50+GB of free space on a 120GB Vertex
> (over 100 million sectors) takes a *single* TRIM command,
> and completes in only a couple of seconds.
>
> Cheers
>
Mark,

What filesystems does your script support?  Running a tool like this
in the middle of the night makes a lot of since to me even from the
perspective of many / most enterprise users.

How do prevent a race where a block becomes used between userspace
asking status and it sending the discard request?

ps: I tried to pull wiper.sh straight from sourceforge, but I'm
getting some crazy page asking all sorts of questions and not letting
me bypass it.  I hope sourceforge is broken.  The other option is they
meant to do this. :(

Greg
--=20
Greg Freemyer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
