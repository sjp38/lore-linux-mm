Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D575F6B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 14:07:36 -0400 (EDT)
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <4A8834B6.2070104@rtr.ca>
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
	 <1250437927.3856.119.camel@mulgrave.site>  <4A8834B6.2070104@rtr.ca>
Content-Type: text/plain
Date: Sun, 16 Aug 2009 13:07:27 -0500
Message-Id: <1250446047.3856.273.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mark Lord <liml@rtr.ca>
Cc: Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-08-16 at 12:32 -0400, Mark Lord wrote:
> James Bottomley wrote:
> >
> > For SSDs, the FTL has to have a separate operation: erase.  Now, one
> > could see the correct implementation simply moving the sectors from the
> > in-use list to the to be cleaned list and still do the cleaning in the
> > background: that would be constant cost (but, again, likely expensive).
> > Of course, if SSD vendors decided to erase on the spot when seeing TRIM,
> > this wouldn't be true ...
> ..
> 
> The SSDs based upon the Indilinx Barefoot controller appear to do
> the erase on the spot, along with a fair amount of garbage collection.

Groan.  I'm with Jim on this one:  If trim is going to cost us in terms
of current fs performance, it's likely not worth it.  The whole point of
a TRIM/UNMAP is that we're just passing hints about storage use.  If the
drives make us pay the penalty of acting on the hints as we pass them
in, we may as well improve performance just by not hinting.  Or at least
it's detrimental hinting in real time.

So I think we've iterated to the conclusion that it has to be a user
space process which tries to identify idle periods and begin trimming.

> The overhead does vary by size of the TRIM operation (number of sectors
> and extents), but even a single-sector TRIM has very high overhead.

So it's something like X + nY (n == number of sectors).  If X is large,
it still argues for batching .. it's just there's likely an upper bound
to the batch where the benefit is no longer worth the cost.

> Samsung also now has SSDs at retail with TRIM.
> I don't have one of those here.

Heh, OS writers not having access to the devices is about par for the
current course.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
