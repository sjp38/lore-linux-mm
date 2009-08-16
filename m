Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEAE6B005D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 11:52:16 -0400 (EDT)
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20090816083434.2ce69859@infradead.org>
References: <200908122007.43522.ngupta@vflare.org>
	 <20090813151312.GA13559@linux.intel.com>
	 <20090813162621.GB1915@phenom2.trippelsdorf.de>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
	 <4A85E0DC.9040101@rtr.ca>
	 <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>
	 <20090814234539.GE27148@parisc-linux.org>
	 <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>
	 <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca>
	 <1250344518.4159.4.camel@mulgrave.site>
	 <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>
	 <20090816083434.2ce69859@infradead.org>
Content-Type: text/plain
Date: Sun, 16 Aug 2009 10:52:07 -0500
Message-Id: <1250437927.3856.119.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-08-16 at 08:34 -0700, Arjan van de Ven wrote:
> On Sun, 16 Aug 2009 15:05:30 +0100
> Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> > On Sat, 15 Aug 2009 08:55:17 -0500
> > James Bottomley <James.Bottomley@suse.de> wrote:
> > 
> > > On Sat, 2009-08-15 at 09:22 -0400, Mark Lord wrote:
> > > > James Bottomley wrote:
> > > > >
> > > > > This means you have to drain the outstanding NCQ commands
> > > > > (stalling the device) before you can send a TRIM.   If we do
> > > > > this for every discard, the performance impact will be pretty
> > > > > devastating, hence the need to coalesce.  It's nothing really
> > > > > to do with device characteristics, it's an ATA protocol problem.
> > > > ..
> > > > 
> > > > I don't think that's really much of an issue -- we already have
> > > > to do that for cache-flushes whenever barriers are enabled.  Yes
> > > > it costs, but not too much.
> > > 
> > > That's not really what the enterprise is saying about flush
> > > barriers. True, not all the performance problems are NCQ queue
> > > drain, but for a steady workload they are significant.
> > 
> > Flush barriers are nightmare for more than enterprise. You drive
> > basically goes for a hike for a bit which trashes interactivity as
> > well. If the device can't do trim and the like without a drain I
> > don't see much point doing it at all, except maybe to wait for idle
> > devices and run a filesystem managed background 'strimmer' thread to
> > just weed out now idle blocks that have stayed idle - eg by adding an
> > inode of all the deleted untrimmed blocks and giving it an irregular
> > empty ? 
> 
> trim is mostly for ssd's though, and those tend to not have the "goes
> for a hike" behavior as much......

Well, yes and no ... a lot of SSDs don't actually implement NCQ, so the
impact to them will be less ... although I think enterprise class SSDs
do implement NCQ.

> I wonder if it's worse to batch stuff up, because then the trim itself
> gets bigger and might take longer.....

So this is where we're getting into the realms of speculation.  There
really are only about a couple of people out there with trim
implementing SSDs, so that's not really enough to make any judgement.

However, the enterprise has been doing UNMAP for a while, so we can draw
inferences from them since the SSD FTL will operate similarly.  For
them, UNMAP is the same cost in terms of time regardless of the number
of extents.  The reason is that it's moving the blocks from the global
in use list to the global free list.  Part of the problem is that this
involves locking and quiescing, so UNMAP ends up being quite expensive
to the array but constant in terms of cost (hence they want as few
unmaps for as many sectors as possible).

For SSDs, the FTL has to have a separate operation: erase.  Now, one
could see the correct implementation simply moving the sectors from the
in-use list to the to be cleaned list and still do the cleaning in the
background: that would be constant cost (but, again, likely expensive).
Of course, if SSD vendors decided to erase on the spot when seeing TRIM,
this wouldn't be true ...

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
