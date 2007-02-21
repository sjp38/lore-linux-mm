Date: Wed, 21 Feb 2007 21:52:16 +0000 (GMT)
From: James Simmons <jsimmons@infradead.org>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0702212151190.20620@pentafluge.infradead.org>
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
  <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
 <20070217135922.GA15373@linux-sh.org>  <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
  <20070218235741.GA22298@linux-sh.org>  <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
  <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
 <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Frame Buffer Device Development <linux-fbdev-devel@lists.sourceforge.net>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Could you make it work without the framebuffer. There are embedded LCD 
displays that have internal memory that need data flushed to them.

On Wed, 21 Feb 2007, Jaya Kumar wrote:

> On 2/20/07, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > Don't you need a way to specify the maximum deferral time? E.g. a field in
> > fb_info.
> > 
> 
> You are right. I will need that. I could put that into struct
> fb_deferred_io. So drivers would setup like:
> 
> static struct fb_deferred_io hecubafb_defio = {
>        .delay          = HZ,
>        .deferred_io    = hecubafb_dpy_update,
> };
> 
> where that would be:
> struct fb_deferred_io {
>        unsigned long delay;    /* delay between mkwrite and deferred handler
> */
>        struct mutex lock;      /* mutex that protects the page list */
>        struct list_head pagelist;      /* list of touched pages */
>        struct delayed_work deferred_work;
>        void (*deferred_io)(struct fb_info *info, struct list_head
> *pagelist); /* callback */
> };
> 
> and the driver would do:
> ...
> info->fbdefio = hecubafb_defio;
> register_framebuffer...
> 
> When the driver calls register_framebuffer and unregister_framebuffer,
> I can then do the init and destruction of the other members of that
> struct. Does this sound okay?
> 
> Thanks,
> jaya
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
