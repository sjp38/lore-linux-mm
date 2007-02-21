Received: by ug-out-1314.google.com with SMTP id s2so1112586uge
        for <linux-mm@kvack.org>; Wed, 21 Feb 2007 08:55:18 -0800 (PST)
Message-ID: <45a44e480702210855t344441c1xf8e081c82ece4e63@mail.gmail.com>
Date: Wed, 21 Feb 2007 11:55:17 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
	 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
	 <20070217135922.GA15373@linux-sh.org>
	 <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
	 <20070218235741.GA22298@linux-sh.org>
	 <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
	 <Pine.LNX.4.62.0702200906070.2082@pademelon.sonytel.be>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Frame Buffer Device Development <linux-fbdev-devel@lists.sourceforge.net>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Simmons <jsimmons@infradead.org>
List-ID: <linux-mm.kvack.org>

On 2/20/07, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Don't you need a way to specify the maximum deferral time? E.g. a field in
> fb_info.
>

You are right. I will need that. I could put that into struct
fb_deferred_io. So drivers would setup like:

static struct fb_deferred_io hecubafb_defio = {
        .delay          = HZ,
        .deferred_io    = hecubafb_dpy_update,
};

where that would be:
struct fb_deferred_io {
        unsigned long delay;    /* delay between mkwrite and deferred handler */
        struct mutex lock;      /* mutex that protects the page list */
        struct list_head pagelist;      /* list of touched pages */
        struct delayed_work deferred_work;
        void (*deferred_io)(struct fb_info *info, struct list_head
*pagelist); /* callback */
};

and the driver would do:
...
info->fbdefio = hecubafb_defio;
register_framebuffer...

When the driver calls register_framebuffer and unregister_framebuffer,
I can then do the init and destruction of the other members of that
struct. Does this sound okay?

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
