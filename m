Message-ID: <44CC99C1.40507@superbug.co.uk>
Date: Sun, 30 Jul 2006 12:36:33 +0100
From: James Courtier-Dutton <James@superbug.co.uk>
MIME-Version: 1.0
Subject: Re: swsusp regression (s2dsk) [Was: 2.6.18-rc2-mm1]
References: <20060727015639.9c89db57.akpm@osdl.org> <44CBA1AD.4060602@gmail.com> <200607292059.59106.rjw@sisk.pl> <44CBE9D5.9030707@gmail.com> <20060729232216.GB1983@elf.ucw.cz> <44CBF60C.3090508@gmail.com>
In-Reply-To: <44CBF60C.3090508@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-pm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jiri Slaby wrote:
> Pavel Machek napsal(a):
>> Hi!
>>
>>>>> I have problems with swsusp again. While suspending, the very last thing kernel
>>>>> writes is 'restoring higmem' and then hangs, hardly. No sysrq response at all.
>>>>> Here is a snapshot of the screen:
>>>>> http://www.fi.muni.cz/~xslaby/sklad/swsusp_higmem.gif
>>>>>
>>>>> It's SMP system (HT), higmem enabled (1 gig of ram).
>>>> Most probably it hangs in device_power_up(), so the problem seems to be
>>>> with one of the devices that are resumed with IRQs off.
>>>>
>>>> Does vanila .18-rc2 work?
>>> Yup, it does.
>> Can you try up kernel, no highmem? (mem=512M)?
> 
> It writes then:
> p16v: status 0xffffffff, mask 0x00001000, pvoice f7c04a20, use 0
> in endless loop when resuming -- after reading from swap.
> 
> regards,

The p16v chip is present on some creative sound cards, so this is an
ALSA snd-emu10k1 driver that is causing the endless loop. I will change
the code to force it to recover from the unexpected status 0xffffffff
value. The recovery will just consist of reducing the message to a
single message, instead of an endless loop. That value is never present
during normal operations, and the only case of it occurring that I know
about was during a pcmcia card unplug. If it occurs during insertion or
power resume, then I will have to think about some work around.
Is there any reason that an IRQ routine will be called before the
associated PCI IOPORTs have been configured. I did not think it was the
responsibility of the driver to redo all the initialisation PCI calls to
claim DMA and IOPORTs at power resume. To me it seems that the IRQ
routine is being called before PCI DMA and IOPORTs have been initialised.

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
