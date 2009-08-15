Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 86AA36B004D
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 13:39:52 -0400 (EDT)
Message-ID: <4A86F2E1.8080002@hp.com>
Date: Sat, 15 Aug 2009 13:39:45 -0400
From: jim owens <jowens@hp.com>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	 <20090813151312.GA13559@linux.intel.com>	 <20090813162621.GB1915@phenom2.trippelsdorf.de>	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>	 <4A85E0DC.9040101@rtr.ca>	 <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>	 <20090814234539.GE27148@parisc-linux.org>	 <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>	 <1250341176.4159.2.camel@mulgrave.site>  <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site>
In-Reply-To: <1250344518.4159.4.camel@mulgrave.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

James Bottomley wrote:
> 
> That's not really what the enterprise is saying about flush barriers.
> True, not all the performance problems are NCQ queue drain, but for a
> steady workload they are significant.

OK, we now know that SSDs designed only to the letter of the ATA
spec will suck doing discards if we send them down as we are
doing today.

Having finally caught up with this thread, I'm going to add some
comments that James already knows but were not stated that some
of the others apparently don't know :

- The current filesystem/blockdev behavior with discard TRIM was
   argued and added quickly because this design was what the
   Intel SSD architect told us was "the right thing" in Sept 08.

- In the same workshop, Linus said "I'm tired of hardware
   vendors telling me to fix it because they are cheap and lazy",
   or something close to that, my memory gets bit-errors :)

- We decided not to track and coalesce the discards in the block
   or filesystem layer because of the high memory/performance cost.
   There is no cheap way to do this, all of the space management
   in filesystems is accepting some cost for some user benefit.

- Many people who live in filesystems (like me) are unconvinced
   that discard to SSD or an array will help in real world use,
   but the current discard design didn't seem to hurt us either.

***begin rant***

I have not seen any analysis of the benefit and cost to the
end user of the TRIM or array UNMAP.  We now see that TRIM
as implemented by some (all?) SSDs will come at high cost.
The cost is all born by the host.  Do we get any benefit, or
is it all for the device vendor.  And when we subtract the cost
from the benefit, does the user actually benefit and how?

I'm tired of working around shit storage products and broken
device protocols from the "T" committees.  I suggest we just
add a "white list" of devices that handle the discard fast
and without us needing NCQ queue drain.  Then only send TRIM
to devices that are on the white list and throw the others
away in the block device layer.

I do enterprise systems and the cost of RAM in those systems
is awful.  And the databases and applications are always big
memory pigs.  Our customers always complain about the kernel
using too much memory and they will go ballistic if we take
1GB from their 512GB system unless we can really show them
significant benefit in their production.  And so far all
we have is "this is all good stuff" from array vendors.
[and yes, our hardware guys always give me the most pain]

If continuous discard is going to be a PITA for us, then
I say don't do it.  Just let a user-space tool do it when
the admin wants.  IMO is no different than defragment,
where my experience with a kernel continuous defragment
was that it made a great sales gimmick, but in real production
most people saw no benefit and some had to shut it off
because it actually hurt them.  It is all about workload.

jim

P.S. Matthew, that SSD architect told me personally
that the trim of each 512 byte block before rewrite
will be a performance benefit, so if Intel SSDs are
not on the white list, please slap him for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
