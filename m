Date: Tue, 20 Feb 2007 13:38:48 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
Message-ID: <20070220043848.GA4092@linux-sh.org>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy> <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com> <20070217135922.GA15373@linux-sh.org> <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com> <20070218235741.GA22298@linux-sh.org> <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jsimmons@infradead.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 19, 2007 at 11:13:04PM -0500, Jaya Kumar wrote:
> On 2/18/07, Paul Mundt <lethal@linux-sh.org> wrote:
> >Given that, this would have to be something that's dealt with at the
> >subsystem level rather than in individual drivers, hence the desire to
> >see something like this more generically visible.
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

The vast majority of drivers do not implement ->fb_mmap(), and with
proper abstraction, this should be something that's possible as a direct
alternative to drivers/video/fbmem.c:fb_mmap() for the people that want
it. Of course it's just as easy to do something like the sbuslib.c route
and then have drivers set their ->fb_mmap() from that too.

> fbdev_deferred_io_mkwrite would build up the list of touched pages and
> pass it to a delayed workqueue which would then mkclean on each page
> and then pass a copy of that page list down to a driver's callback
> function. The fbdev driver's callback function can then do the actual
> IO to the framebuffer or coalesce DMA based on the provided page list.
> 
That works for me, though I'd prefer for struct page_list to be done with
a scatterlist, then it's trivial to setup from the workqueue context
without having to shuffle things around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
