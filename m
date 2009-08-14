Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 724316B005A
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 18:10:36 -0400 (EDT)
Message-ID: <4A85E0DC.9040101@rtr.ca>
Date: Fri, 14 Aug 2009 18:10:36 -0400
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 	slot is freed)
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> 	<20090813151312.GA13559@linux.intel.com> <20090813162621.GB1915@phenom2.trippelsdorf.de> 	<alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm> <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com> 	<alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm> <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
In-Reply-To: <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bryan Donlan <bdonlan@gmail.com>
Cc: david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Bryan Donlan wrote:
..
> Perhaps an interface (ioctl, etc) can be added to ask a filesystem to
> discard all unused blocks in a certain range? (That is, have the
> filesystem validate the request under any necessary locks before
> passing it to the block IO layer)
..

While possibly TRIM-specific, this approach has the lowest overhead
and probably the greatest gain-for-pain ratio.

But it may not be as nice for enterprise (?).

On the Indilinx-based SSDs (eg. OCZ Vertex), TRIM seems to trigger an
internal garbage-collection/erase cycle.  As such, the drive really prefers
a few LARGE trim lists, rather than many smaller ones.

Here's some information that a vendor has observed from the Win7 use of TRIM:

> TRIM command is sent:
> -	About 2/3 of partition is filled up, when file is deleted.
>         (I am not talking about send file to trash bin.)
> -	In the above case, when trash bin gets emptied.
> -	In the above case, when partition is deleted.
> 
> TRIM command is not sent:-	
> -	When file is moved to trash bin
> -	When partition is formatted. (Both quick and full format)
> -	When empty partition is deleted
> -	When file is deleted while there is big remaining free space
..

His words, not mine.  But the idea seems to be to batch them in large chunks.

My wiper.sh "trim script" is packaged with the latest hdparm (currently 9.24)
on sourceforge, for those who want to try this stuff for real.  No special
kernel support is required to use it.

Cheers

Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
