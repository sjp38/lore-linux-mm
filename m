Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 476586B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 09:49:11 -0400 (EDT)
Date: Sun, 12 Jun 2011 14:48:09 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110612134809.GG10283@n2100.arm.linux.org.uk>
References: <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com> <20110610220748.GO24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com> <20110610222020.GP24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101526390.24646@chino.kir.corp.google.com> <20110611094500.GA2356@debian.cable.virginmedia.net> <4DF3A376.1000601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DF3A376.1000601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Hancock <hancockrwd@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Sat, Jun 11, 2011 at 11:18:46AM -0600, Robert Hancock wrote:
> It sounds to me like these drivers using GFP_DMA should really be fixed  
> to use the proper DMA API. That's what it's there for. The problem is  
> that GFP_DMA doesn't really mean anything generically other than "memory  
> suitable for DMA according to some criteria".

It would be really nice to have an allocation interface which takes a
DMA mask and returns memory which satisfies that DMA mask, but that's
a pipedream I've had for the last 12 years or so.

GFP_DMA is not about the DMA API - the DMA API does _not_ deal with
memory allocation for streaming transfers at all.  It only deals with
coherent DMA memory allocation which is something completely different.

So it really isn't about "these drivers should be fixed to use the
proper DMA API" because there isn't one.

If the concensus is to remove GFP_DMA, there would need to be some ground
work done first:

(a) audit whether GFP_DMA is really needed (iow, is the allocated
structure actually DMA'd from/to, or did the driver writer just slap
GFP_DMA on it without thinking?)

(b) audit whether we have a DMA mask available at the GFP_DMA allocator
call site

That should reveal whether it is even possible to move to a different
solution.

Depending on (b), provide a new allocation API which takes the DMA mask
and internally calls the standard allocator with GFP_DMA if the DMA mask
is anything less than "all memory".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
