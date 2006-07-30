Date: Sun, 30 Jul 2006 02:06:53 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: swsusp regression (s2dsk) [Was: 2.6.18-rc2-mm1]
Message-ID: <20060730000652.GA2057@elf.ucw.cz>
References: <20060727015639.9c89db57.akpm@osdl.org> <44CBA1AD.4060602@gmail.com> <200607292059.59106.rjw@sisk.pl> <44CBE9D5.9030707@gmail.com> <20060729232216.GB1983@elf.ucw.cz> <44CBF60C.3090508@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44CBF60C.3090508@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-pm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> >>>> I have problems with swsusp again. While suspending, the very last thing kernel
> >>>> writes is 'restoring higmem' and then hangs, hardly. No sysrq response at all.
> >>>> Here is a snapshot of the screen:
> >>>> http://www.fi.muni.cz/~xslaby/sklad/swsusp_higmem.gif
> >>>>
> >>>> It's SMP system (HT), higmem enabled (1 gig of ram).
> >>> Most probably it hangs in device_power_up(), so the problem seems to be
> >>> with one of the devices that are resumed with IRQs off.
> >>>
> >>> Does vanila .18-rc2 work?
> >> Yup, it does.
> > 
> > Can you try up kernel, no highmem? (mem=512M)?
> 
> It writes then:
> p16v: status 0xffffffff, mask 0x00001000, pvoice f7c04a20, use 0
> in endless loop when resuming -- after reading from swap.

Okay, so we have two different problems here.

One is "hang during suspend" with smp/highmem mode, and one is
probably driver problem with p16v (whatever it is).

/data/l/linux/sound/pci/emu10k1/irq.c:
snd_printk(KERN_ERR "p16v: status: 0x%08x, mask=0x%08x, pvoice=%p,
use=%d\n", status2, mask, pvoice, pvoice->use);

...aha, so you may want to unload emu10k1 for testing.

Since you mention radeon in one of your other mails, just try it in
vesafb mode...
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
