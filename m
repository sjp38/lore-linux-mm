Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 743486B005A
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 19:21:27 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so728320ana.26
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 16:21:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A85E0DC.9040101@rtr.ca>
References: <200908122007.43522.ngupta@vflare.org>
	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
	 <20090813151312.GA13559@linux.intel.com>
	 <20090813162621.GB1915@phenom2.trippelsdorf.de>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
	 <4A85E0DC.9040101@rtr.ca>
Date: Fri, 14 Aug 2009 17:21:32 -0600
Message-ID: <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
From: Chris Worley <worleys@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mark Lord <liml@rtr.ca>
Cc: Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 4:10 PM, Mark Lord<liml@rtr.ca> wrote:
> Bryan Donlan wrote:
> ..
>>
>> Perhaps an interface (ioctl, etc) can be added to ask a filesystem to
>> discard all unused blocks in a certain range? (That is, have the
>> filesystem validate the request under any necessary locks before
>> passing it to the block IO layer)
>
> ..
>
> While possibly TRIM-specific, this approach has the lowest overhead
> and probably the greatest gain-for-pain ratio.
>
> But it may not be as nice for enterprise (?).
>
> On the Indilinx-based SSDs (eg. OCZ Vertex), TRIM seems to trigger an
> internal garbage-collection/erase cycle. =A0As such, the drive really pre=
fers
> a few LARGE trim lists, rather than many smaller ones.
>
> Here's some information that a vendor has observed from the Win7 use of
> TRIM:
>
>> TRIM command is sent:
>> - =A0 =A0 =A0 About 2/3 of partition is filled up, when file is deleted.
>> =A0 =A0 =A0 =A0(I am not talking about send file to trash bin.)
>> - =A0 =A0 =A0 In the above case, when trash bin gets emptied.
>> - =A0 =A0 =A0 In the above case, when partition is deleted.
>>
>> TRIM command is not sent:-
>> - =A0 =A0 =A0 When file is moved to trash bin
>> - =A0 =A0 =A0 When partition is formatted. (Both quick and full format)
>> - =A0 =A0 =A0 When empty partition is deleted
>> - =A0 =A0 =A0 When file is deleted while there is big remaining free spa=
ce
>
> ..
>
> His words, not mine. =A0But the idea seems to be to batch them in large
> chunks.

Sooner is better than waiting to coalesce.  The longer an LBA is
inactive, the better for any management scheme.  If you wait until
it's reused, you might as well forgo the advantages of TRIM/UNMAP.  If
a the controller wants to coalesce, let it coalesce.

Chris
>
> My wiper.sh "trim script" is packaged with the latest hdparm (currently
> 9.24)
> on sourceforge, for those who want to try this stuff for real. =A0No spec=
ial
> kernel support is required to use it.
>
> Cheers
>
> Mark
> --
> To unsubscribe from this list: send the line "unsubscribe linux-raid" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
