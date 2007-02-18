Date: Mon, 19 Feb 2007 08:57:41 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
Message-ID: <20070218235741.GA22298@linux-sh.org>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy> <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com> <20070217135922.GA15373@linux-sh.org> <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 18, 2007 at 06:31:23AM -0500, Jaya Kumar wrote:
> On 2/17/07, Paul Mundt <lethal@linux-sh.org> wrote:
> >This would also provide an interesting hook for setting up chained DMA
> >for the real framebuffer updates when there's more than a couple of pages
> >that have been touched, which would also be nice to have. There's more
> >than a few drivers that could take advantage of that.
> 
> I could benefit from knowing which driver and display device you are
> considering to be applicable.
> 
> I was thinking the method used in hecubafb would only be useful to
> devices with very slow update paths, where "losing" some of the
> display activity is not an issue since the device would not have been
> able to update fast enough to show that activity anyway.
> 
> What you described with chained DMA sounds different to this. I
> suppose one could use this technique to coalesce framebuffer IO to get
> better performance/utilization even for fast display devices. Sounds
> interesting to try. Did I understand you correctly?
> 
Yes, that's what I'm interested in trying. In the SH case we can
basically make use of the on-chip DMAC for any non-PCI device. Some of
these permit scatterlists and chained DMA in hardware, others do not. The
general problem is that since we have to go and poke at the dcache prior
to kicking off the DMA, it's rarely a win for a small number of pages,
memory bursts just end up being faster.

The other issue is that most of the "big" writers are doing so via mmap()
anyways, so it's futile to attempt to handle the DMA case in the
->write() path. Your approach seems like it might be an appropriate
interface for building something like this on top of.

Given that, this would have to be something that's dealt with at the
subsystem level rather than in individual drivers, hence the desire to
see something like this more generically visible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
