Date: Tue, 20 Feb 2007 09:07:56 +0100 (CET)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
 <20070217135922.GA15373@linux-sh.org> <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
 <20070218235741.GA22298@linux-sh.org> <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Frame Buffer Device Development <linux-fbdev-devel@lists.sourceforge.net>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Simmons <jsimmons@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Feb 2007, Jaya Kumar wrote:
> On 2/18/07, Paul Mundt <lethal@linux-sh.org> wrote:
> > Given that, this would have to be something that's dealt with at the
> > subsystem level rather than in individual drivers, hence the desire to
> > see something like this more generically visible.
> > 
> 
> Hi Peter, Paul, fbdev folk,
> 
> Ok. Here's what I'm thinking for abstracting this:
> 
> fbdev drivers would setup fb_mmap with their own_mmap as usual. In
> own_mmap, they would do what they normally do and setup a vm_ops. They
> are free to have their own nopage handler but would set the
> page_mkwrite handler to be fbdev_deferred_io_mkwrite().
> fbdev_deferred_io_mkwrite would build up the list of touched pages and
> pass it to a delayed workqueue which would then mkclean on each page
> and then pass a copy of that page list down to a driver's callback
> function. The fbdev driver's callback function can then do the actual
> IO to the framebuffer or coalesce DMA based on the provided page list.
> 
> I would like to add something like the following to struct fb_info:
> 
> #ifdef CONFIG_FB_DEFERRED_IO
> struct fb_deferred_io *defio;
> #endif

Don't you need a way to specify the maximum deferral time? E.g. a field in
fb_info.

> to store the mutex (to protect the page list), the touched page list,
> and the driver's callback function.
> 
> I hope this sounds sufficiently generic to meet everyone's (the two of
> us? :) needs.

Looks fine!

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
