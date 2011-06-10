Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 623F26B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 18:09:31 -0400 (EDT)
Date: Fri, 10 Jun 2011 23:07:48 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
	instead of failing
Message-ID: <20110610220748.GO24424@n2100.arm.linux.org.uk>
References: <alpine.LFD.2.02.1106012043080.3078@ionos> <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com> <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org> <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, Jun 10, 2011 at 03:01:15PM -0700, David Rientjes wrote:
> On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:
> > See Linus' reply.  I quote again "on platforms where it doesn't matter it
> > should be a no-op".  If _you_ have a problem with that _you_ need to
> > discuss it with _Linus_, not me.  I'm not going to be a middle-man sitting
> > between two people with different opinions.
> 
> We're talking about two different things.  Linus is saying that if GFP_DMA 
> should be a no-op if the hardware doesn't require DMA memory because the 
> kernel was correctly compiled without CONFIG_ZONE_DMA.  I'm asking about a 
> kernel that was incorrectly compiled without CONFIG_ZONE_DMA and now we're 
> returning memory from anywhere even though we actually require GFP_DMA.

How do you distinguish between the two states?  Answer: you can't.

> If you don't want to form an opinion of your own, then I have no problem 
> cc'ing Linus on it.

I think I've made my position in this fairly clear with our previous
discussions on this.  The fact of the matter is that there are some
drivers which use GFP_DMA because they need that on _some_ platforms
but not all.

Not all platforms are _broken_ with respect to DMA, and those which
aren't broken don't provide a DMA zone.

Therefore, it is _perfectly_ _legal_ to honor a GFP_DMA allocation on
a kernel without CONFIG_ZONE_DMA set.

That position appears to be reflected by Linus' response, so

>  I don't think he'd object to a
> 
> 	#ifndef CONFIG_ZONE_DMA
> 	WARN_ON_ONCE(1, "%s (%d): allocating DMA memory without DMA support -- "
> 			"enable CONFIG_ZONE_DMA if needed.\n",
> 			current->comm, current->pid);
> 	#endif

I think he will definitely object to this on the grounds that its
adding useless noise for conditions which are _perfectly_ _valid_.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
