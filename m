Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8630A6B0085
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 18:26:42 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Date: Fri, 18 Sep 2009 00:27:37 +0200
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909170118.53965.rjw@sisk.pl> <4AB29F4A.3030102@intel.com>
In-Reply-To: <4AB29F4A.3030102@intel.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909180027.37387.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: david.graham@intel.com
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 17 September 2009, Graham, David wrote:
> Rafael J. Wysocki wrote:
> > On Tuesday 15 September 2009, Karol Lewandowski wrote:
> >> Hello,
> >>
> >> I'm getting following oops sometimes during resume on my Thinkpad T21
> >> (where "sometimes" means about 10/1 good/bad ratio):
> >>
> >> ifconfig: page allocation failure. order:5, mode:0x8020
> > 
> > Well, this only tells you that an attempt to make order 5 allocation failed,
> > which is not unusual at all.
> > 
> > Allocations of this order are quite likely to fail if memory is fragmented,
> > the probability of which rises with the number of suspend-resume cycles already
> > carried out.
> > 
> > I guess the driver releases its DMA buffer during suspend and attempts to
> > allocate it back on resume, which is not really smart (if that really is the
> > case).
> > 
> Yes, we free a 70KB block (0x80 by 0x230 bytes) on suspend and 
> reallocate on resume, and so that's an Order 5 request. It looks 
> symmetric, and hasn't changed for years. I don't think we are leaking 
> memory, which points back to that the memory is too fragmented to 
> satisfy the request.
> 
> I also concur that Rafael's commit 6905b1f1 shouldn't change the logic 
> in the driver for systems with e100 (like yours Karol) that could 
> already sleep, and I don't see anything else in the driver that looks to 
> be relevant. I'm expecting that your test result without commit 6905b1f1 
> will still show the problem.
> 
> So I wonder if this new issue may be triggered by some other change in 
> the memory subsystem ?

I think so.  There have been reports about order 2 allocations failing for
2.6.31, so it looks like newer kernels are more likely to expose such problems.

Adding linux-mm to the CC list.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
