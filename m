Date: Fri, 4 Jan 2008 00:10:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] i386: avoid expensive ppro ordering workaround for default 686 kernels
Message-ID: <20080103231017.GA25880@wotan.suse.de>
References: <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <alpine.LFD.0.9999.0712230900310.21557@woody.linux-foundation.org> <20080101234133.4a744329@the-village.bc.nu> <20080102110225.GA16154@wotan.suse.de> <20080102134433.6ca82011@the-village.bc.nu> <20080103041708.GB26487@wotan.suse.de> <20080103142330.111d4067@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080103142330.111d4067@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 02:23:30PM +0000, Alan Cox wrote:
> > Hmm, I don't understand what you mean. Obviously other busmasters aren't
> > participating in any locking or smp_*mb() ordering protocols.
> 
> The unlock paths are visible to busmasters
> 
> 		write to DMA buffer
> 		unlock
> can turn into
> 
> 		unlock
> 		write to DMA buffer
> 
> Whether that actually matters in any code we have I don't know.

These actually require wmb() anyway, because we only guarantee that spinlocks
contain operations to cacheable memory.

Observe that when !CONFIG_SMP, smp_*mb and spin_*lock are basically noops, even
when the existing pentiumpro workaround is in place.

Though wmb() will actually provide the correct ordering.


> > > - re-order the assumed processor generations supported to put VIA C3/C5
> > > above Preventium Pro
> > 
> > Adrian Bunk's patch to make each CPU type explicitly selectable IMO is the
> > best way to do this.
> 
> If you get to pick the combination you want then yes.
> 
> > > to 586 < 686 < PPro < C3 < PII < ...
> > > 
> > > then selecting VIA C3 support will get you a kernel with the properties
> > > all the distribution vendors want for their higher end mainstream kernel -
> > > "runs on modern systems".
> > 
> > I don't agree. If we support those options, we should support them properly.
> > And if you build an SMP kernel for a 586 for example, you should not get lumped
> > with those pentiumpro workarounds.
> 
> The cost on a 586 SMP box (ie pentium) is basically nil. All cross CPU
> transactions are hideously slow anyway locked or not.

That's wrong. Firstly, spinlocks are very often retaken by the same CPU, and they
are also often released while the lock word is still in the cache of the acquiring
CPU. Secondly, the extra code and lock ops in smp_* barriers is fairly expensive.

On 586 SMP systems, didn't lock ops actually go out on the bus, and hence are much
more expensive than they are today (although today they are still one or two orders
of magnitude more expensive than regular memory ops).


> On a PII or later I
> agree entirely you don't want them by default.

And if you build a kernel which is to support 686, PII, and later, you don't want
them by default either, most probably.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
