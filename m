Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB946B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 10:11:12 -0400 (EDT)
Date: Sun, 16 Aug 2009 15:05:30 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
Message-ID: <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>
In-Reply-To: <1250344518.4159.4.camel@mulgrave.site>
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
	<1250341176.4159.2.camel@mulgrave.site>
	<4A86B69C.7090001@rtr.ca>
	<1250344518.4159.4.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Aug 2009 08:55:17 -0500
James Bottomley <James.Bottomley@suse.de> wrote:

> On Sat, 2009-08-15 at 09:22 -0400, Mark Lord wrote:
> > James Bottomley wrote:
> > >
> > > This means you have to drain the outstanding NCQ commands (stalling the
> > > device) before you can send a TRIM.   If we do this for every discard,
> > > the performance impact will be pretty devastating, hence the need to
> > > coalesce.  It's nothing really to do with device characteristics, it's
> > > an ATA protocol problem.
> > ..
> > 
> > I don't think that's really much of an issue -- we already have to do
> > that for cache-flushes whenever barriers are enabled.  Yes it costs,
> > but not too much.
> 
> That's not really what the enterprise is saying about flush barriers.
> True, not all the performance problems are NCQ queue drain, but for a
> steady workload they are significant.

Flush barriers are nightmare for more than enterprise. You drive
basically goes for a hike for a bit which trashes interactivity as well.
If the device can't do trim and the like without a drain I don't see much
point doing it at all, except maybe to wait for idle devices and run a
filesystem managed background 'strimmer' thread to just weed out now idle
blocks that have stayed idle - eg by adding an inode of all the deleted
untrimmed blocks and giving it an irregular empty ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
