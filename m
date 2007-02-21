Received: by py-out-1112.google.com with SMTP id n24so1286863pyh
        for <linux-mm@kvack.org>; Wed, 21 Feb 2007 15:40:59 -0800 (PST)
Subject: Re: [Linux-fbdev-devel] [PATCH 2.6.20 1/1] fbdev, mm: hecuba/E-Ink
	fbdev driver
From: "Antonino A. Daplas" <adaplas@gmail.com>
In-Reply-To: <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
References: <20070217104215.GB25512@localhost>
	 <1171715652.5186.7.camel@lappy>
	 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
	 <20070217135922.GA15373@linux-sh.org>
	 <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
	 <20070218235741.GA22298@linux-sh.org>
	 <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
	 <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
	 <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 07:43:36 +0800
Message-Id: <1172101416.4217.19.camel@daplas>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fbdev-devel@lists.sourceforge.net
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, James Simmons <jsimmons@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 11:55 -0500, Jaya Kumar wrote: 
> On 2/20/07, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> > Don't you need a way to specify the maximum deferral time? E.g. a field in
> > fb_info.
> >
> 
> You are right. I will need that. I could put that into struct
> fb_deferred_io. So drivers would setup like:
> 

Is it also possible to let the drivers do the 'deferred_io'
themselves?  Say, a driver that would flush the dirty pages on
every VBLANK interrupt.

> static struct fb_deferred_io hecubafb_defio = {
>         .delay          = HZ,
>         .deferred_io    = hecubafb_dpy_update,
> };
> 
> where that would be:
> struct fb_deferred_io {
>         unsigned long delay;    /* delay between mkwrite and deferred handler */
>         struct mutex lock;      /* mutex that protects the page list */
>         struct list_head pagelist;      /* list of touched pages */
>         struct delayed_work deferred_work;
>         void (*deferred_io)(struct fb_info *info, struct list_head
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

It would be better if separate registering functions are created for
this functionality (ie deferred_io_register/unregister).

Tony


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
