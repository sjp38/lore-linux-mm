Received: from mail.ccr.net (ccr@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA18322
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 01:23:32 -0500
Subject: Re: Linux-2.1.129..
References: <Pine.LNX.3.96.981123215719.6004B-100000@mirkwood.dummy.home>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Nov 1998 00:28:16 -0600
In-Reply-To: Rik van Riel's message of "Mon, 23 Nov 1998 22:18:07 +0100 (CET)"
Message-ID: <m13e79eha7.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> On 23 Nov 1998, Eric W. Biederman wrote:
>> The simplest model (and what we use for disk writes) is after
>> something becomes dirty to wait a little bit (in case of more
>> writes, (so we don't flood the disk)) and write the data to disk. 

RR> This waiting is also a good thing if we want to do proper
RR> I/O clustering. I believe DU has a switch to only write
RR> dirty data when there's more than XX kB of contiguous data
RR> at that place on the disk (or the data is old).

I can tell who has been reading Digital Unix literature latetly.

>> Ideally/Theoretically I think that is what we should be doing for
>> swap as well, as it would spread out the swap writes across evenly
>> across time.  And should leave most of our pages clean. 

RR> Something like this is easily accomplished by pushing the
RR> non-accessed pages into swap cache and swap simultaneously,
RR> remapping the page from swap cache when we want to access
RR> it again.

RR> In order to spread out the disk I/O evenly (why would we
RR> want to do this?

Imagine a machine with 1 Gigabyte of RAM and 8 Gigabyte of swap,
in heavy use.  Swapping but not thrashing.

You can't swap out several hundred megabytes all at once.
They need to be swapped out over time.   For pages that are not likely to change
you want them to hit the disk soon after they get set, so you have
more clean memory,  and don't need to write all of the data out when
you get busy.  

You can handle a suddne flurry of network traffic much better this way
for example.


>> The correct ratio (of pages to free from each source) (compuated
>> dynamically) would be:  (# of process pages)/(# of pages) 
>> 
>> Basically for every page kswapd frees shrink_mmap must also free one
>> page.  Plus however many pages shrink_mmap used to return. 

RR> This is clearly wrong.  

No. If for each page we schedule to be swapped, we reclaim a different
page with shrink_mmap immediately.... so we have free ram.

That should keep the balance between swapping and mm as it has
always been.  But I doubt we need to go even that far, to get a working balance.


As far as fixed percentages.  It's a loose every time, and I
won't drop a working feature for an older lesser design.   Having tuneable
fixed percentages is only a win on a 1 application, 1 load pattern box.


Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
