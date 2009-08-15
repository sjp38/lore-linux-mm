Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 92F866B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 08:59:57 -0400 (EDT)
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
  slot is freed)
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>
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
Content-Type: text/plain
Date: Sat, 15 Aug 2009 07:59:36 -0500
Message-Id: <1250341176.4159.2.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Worley <worleys@gmail.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Mark Lord <liml@rtr.ca>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-08-14 at 18:19 -0600, Chris Worley wrote:
> On Fri, Aug 14, 2009 at 5:45 PM, Matthew Wilcox<matthew@wil.cx> wrote:
> > On Fri, Aug 14, 2009 at 05:21:32PM -0600, Chris Worley wrote:
> >> Sooner is better than waiting to coalesce.  The longer an LBA is
> >> inactive, the better for any management scheme.  If you wait until
> >> it's reused, you might as well forgo the advantages of TRIM/UNMAP.  If
> >> a the controller wants to coalesce, let it coalesce.
> >
> > I'm sorry, you're wrong.  There is a tradeoff point, and it's different
> > for each drive model.  Sending down a steady stream of tiny TRIMs is
> > going to give terrible performance.
> 
> Sounds like you might be using junk for a device?
> 
> For junk, a little coalescing may be warranted... like in the I/O
> schedular, but no more than 100usecs wait before posting, or then you
> effect high performing devices too.

Um, I think you missed the original point in all of this at the
beginning of the thread:  On ATA TRIM commands cannot be tagged.  This
means you have to drain the outstanding NCQ commands (stalling the
device) before you can send a TRIM.   If we do this for every discard,
the performance impact will be pretty devastating, hence the need to
coalesce.  It's nothing really to do with device characteristics, it's
an ATA protocol problem.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
