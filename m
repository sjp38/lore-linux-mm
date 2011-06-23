Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F7ED900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:33:24 -0400 (EDT)
Date: Thu, 23 Jun 2011 10:33:20 +0000
From: Rick van Rein <rick@vanrein.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110623103320.GB2910@phantom.vanrein.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <4E023142.1080605@zytor.com> <4E0250F2.2010607@kpanic.de> <4E0251AB.8090702@zytor.com> <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org> <4E024E31.50901@kpanic.de> <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <4E023142.1080605@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E0251AB.8090702@zytor.com> <4E024E31.50901@kpanic.de> <4E023142.1080605@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

Hello,

> We already support the equivalent functionality with
> memmap=<address>$<length> for those with only a few ranges...

This is not a realistic option for people whose memory failed.
Google is quite right when they say they hit thousands of erroneous
pages.  If you have, say, a static discharge damaging the buffers
from the cell array to the outside world, then the entire row or
column behind that buffer will fail.  I've seen many such examples.

> For those with a lot of ranges,
> like Google, the command line is insufficient.

Not if you recognise that there is a pattern :-)

Google does not seem to have realised that, and is simply listing
the pages that are defected.  IMHO, but being the BadRAM author I
can hardly be called objective, this is the added value of BadRAM,
that it understands the nature of the problem and solves it with
an elegant concept at the right level of abstraction.

> So far the use case I had in mind wasn't "thousands of entries". However
> expanding the e820 table is probably an issue that could be dealt with
> separately ?

This could help with other approaches as well -- as mentioned,
there have been attempts to get BadRAM into GRUB, so that the
kernel needn't be aware of it.  But adding BadRAM or expanding
the e820 table are both cases of changing the kernel, and in that
case I thought it'd be best to actually solve the problem and
not upgrade the messenger.

> Well if too much low memory is bad, you're screwed anyway, not? :)

If the kernel is always loaded in a fixed location, yes.  That
is one assumption that the kernel makes (made?) that will only
work if all your memory is good.

> At the moment I don't see any arguments why this patchset couldn't play
> along nicely or get enhanced to support what Google needs, but I don't
> know Googles patches yet.

Changes to e820 should not interfere with setting flags (and
living by them) for failing memory pages.  One property of BadRAM,
namely that it does not slow down your system (you have less
pages on hand, but that's all) may or may not apply to an e820-based
approach.  I don't know if e820 is ever consulted after boot?

> How common are nontrivial patterns on real hardware?  This would be
> interesting to hear from Google or another large user.

Yes.  And "non-trivial" would mean that the patterns waste more space
than fair, *because of* the generalisation to patterns.

If you plug 10 DIMMs into your machine, and each has a faulty row
somewhere, then you will get into trouble if you stick to 5 patterns.
But if you happen to run into a faulty DIMM from time to time, the
patterns should be your way out.

> I have to say I think Google's point that truncating the list is
> unacceptable...

Of course, that is true.  This is why memmap=... does not work.
It has nothing to do with BadRAM however, there will never be more
than 5 patterns.

> that would mean running in a known-bad configuration,
> and even a hard crash would be better.

...which is so sensible that it was of course taken into account in
the BadRAM design!


Cheers,
 -Rick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
