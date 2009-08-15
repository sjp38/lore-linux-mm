Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BD0396B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 09:20:00 -0400 (EDT)
Message-ID: <4A86B605.5060701@rtr.ca>
Date: Sat, 15 Aug 2009 09:20:05 -0400
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 	slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>	 <4A85E0DC.9040101@rtr.ca>	 <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>	 <20090814234539.GE27148@parisc-linux.org>	 <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>	 <87f94c370908141730y3ddcb7bbj65d24b612fc0e96d@mail.gmail.com> <f3177b9e0908141738n5f99b85dx3de0f620180a4b46@mail.gmail.com>
In-Reply-To: <f3177b9e0908141738n5f99b85dx3de0f620180a4b46@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Worley <worleys@gmail.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Chris Worley wrote:
..
> So erase blocks are 512 bytes (if I write 512 bytes, an erase block is
> now freed)?  Not true.
..

No, erase blocks are typically 512 KILO-bytes, or 1024 sectors.
Logical write blocks are only 512 bytes, but most drives out there
now actually use 4096 bytes as the native internal write size.

Lots of issues there.

The only existing "in the wild" TRIM-capable SSDs today all incur
large overheads from TRIM --> they seem to run a garbage-collection
and erase cycle for each TRIM command, typically taking 100s of milliseconds
regardless of the amount being trimmed.

So it makes send to gather small TRIMs into single larger TRIMs.

But I think, even better, is to just not bother with the bookkeeping,
and instead have the filesystem periodically just issue a TRIM for all
free blocks within a block group, cycling through the block groups
one by one over time.

That's how I'd like it to work on my own machine here.
Server/enterprise users very likely want something different.

Pluggable architecture, anyone?  :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
