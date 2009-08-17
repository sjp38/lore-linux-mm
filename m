Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A02D06B004F
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 15:18:39 -0400 (EDT)
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
  slot is freed)
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <87f94c370908171121u5ee8016p253824b16851b48@mail.gmail.com>
References: <200908122007.43522.ngupta@vflare.org>
	 <20090816083434.2ce69859@infradead.org>
	 <1250437927.3856.119.camel@mulgrave.site> <4A8834B6.2070104@rtr.ca>
	 <1250446047.3856.273.camel@mulgrave.site> <4A884D9C.3060603@rtr.ca>
	 <1250447052.3856.294.camel@mulgrave.site> <4A898752.9000205@tmr.com>
	 <87f94c370908171008t44ff64ack2153e740128278e@mail.gmail.com>
	 <1250529575.7858.31.camel@mulgrave.site>
	 <87f94c370908171121u5ee8016p253824b16851b48@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 17 Aug 2009 14:18:29 -0500
Message-Id: <1250536709.7858.43.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Freemyer <greg.freemyer@gmail.com>
Cc: Bill Davidsen <davidsen@tmr.com>, Mark Lord <liml@rtr.ca>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-08-17 at 14:21 -0400, Greg Freemyer wrote:
> On Mon, Aug 17, 2009 at 1:19 PM, James Bottomley<James.Bottomley@suse.de> wrote:
> > On Mon, 2009-08-17 at 13:08 -0400, Greg Freemyer wrote:
> >> All,
> >>
> >> Seems like the high-level wrap-up of all this is:
> >>
> >> There are hopes that highly efficient SSDs will appear on the market
> >> that can leverage a passthru non-coalescing discard feature.  And that
> >> a whitelist should be created to allow those SSDs to see discards
> >> intermixed with the rest of the data i/o.
> >
> > That's not my conclusion.  Mine was the NCQ drain would still be
> > detremental to interleaved trim even if the drive could do it for zero
> > cost.
> 
> Maybe I misunderstood Jim Owens previous comment that designing for
> devices that only meet the spec. was not his / Linus'es preference.
> 
> Instead they want to have a whitelist enabled list of drives that
> support trim / ncq without having to drain the queue.

There's no way to do this.  The spec explicitly requires that you not
overlap tagged and untagged commands.  The reason is fairly obvious:
you wouldn't be able to separate the completions.

> I just re-read his post and he did not explicitly say that, so maybe
> I'm mis-representing it.
> 
> >> For the other known cases:
> >>
> >> SSDs that meet the ata-8 spec, but don't exceed it
> >> Enterprise SCSI
> >
> > No, SCSI will do WRITE_SAME/UNMAP as currently drafted in SBC3
> >
> >> mdraid with SSD storage used to build raid5 / raid6 arrays
> >>
> >> Non-coalescing is believed detrimental,
> >
> > It is?  Why?
> 
> For the only compliant SSD in the wild, Mark has shown it to be true
> via testing.

He only said larger trims take longer.  As I said previously, if it's a
X+nY relationship, then we still benefit from accumulation up to some
value of n.

> For Enterprise SCSI, I thought you said a coalescing solution is
> preferred.  (I took that to mean non-coalescing is detremental.  Not
> true?).

I'm trying to persuade the array vendors to speak for themselves, but it
seems that UNMAP takes time.  Of course, in SCSI, this is a taggable
command so we don't have the drain overhead ... but then we can't do
anything that would produce an undetermined state based on out of order
tag execution either.

> For mdraid, if the trims are not coalesced mdraid will have to either
> ignore them, or coalesce them themselves. Having them come in bigger
> discard ranges is clearly better.  (ie. At least the size of a stripe,
> so it can adjust the start / end sector to a stripe boundary.)

If we did discard accumulation in-kernel (a big if), it would likely be
at the request level; thus md and dm would automatically inherit it.
dm/md are a problem for a userspace accumulation solution, though
(although I suspect the request elevator can fix that).

> >>  but a regular flushing of the
> >> unused blocks/sectors via a tool like Mark Lord has written should be
> >> acceptable.
> >>
> >> Mark, I don't believe your tool really addresses the mdraid situation,
> >> do you agree.  ie. Since your bypassing most of the block stack,
> >> mdraid has no way of snooping on / adjusting the discards you are
> >> sending out.
> >>
> >> Thus the 2 solutions that have been worked on already seem to address
> >> the needs of everything but mdraid.
> >
> > I count three:  Mark Lord script via SG_IO.  hch enhanced script via
> > XFS_TRIM and willy current discard inline which he's considering
> > coalescing for.
> 
> I missed XFS_TRIM somehow.  What benefit does XFS_TRIM provide at a
> high level?  Is it part of the realtime delete file process, or an
> after the fact scanner?

It guarantees that trim does not overlap allocations and writes on a
running system, so it gives us safety of execution.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
