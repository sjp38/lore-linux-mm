Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 42BC56B0092
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:23:13 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8395348iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 11:23:12 -0700 (PDT)
Date: Mon, 9 Apr 2012 11:22:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: v3.4 BUG: Bad rss-counter state
In-Reply-To: <4F83114E.30106@openvz.org>
Message-ID: <alpine.LSU.2.00.1204091052590.1430@eggly.anvils>
References: <20120408113925.GA292@x4> <20120409055814.GA292@x4> <4F83114E.30106@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 9 Apr 2012, Konstantin Khlebnikov wrote:
> Markus Trippelsdorf wrote:
> > On 2012.04.08 at 13:39 +0200, Markus Trippelsdorf wrote:
> > > I've hit the following warning after I've tried to link Firofox's libxul
> > > with "-flto -lto-partition=none" on my machine with 8GB memory. I've

I've no notion of what's unusual in that link.

> > > killed the process after it used all the memory and 90% of my swap

Does doing that link push you well into swap on 3.3?

There's a separate mail thread which implicates
CONFIG_ANDROID_LOW_MEMORY_KILLER (how appropriately named!) in memory
leaks on 3.4, so please switch that off if you happened to have it on -
unless you're keen to reproduce these rss-counter messages for us.

> > > space. Before the machine was rebooted I saw these messages:
> > > 
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380
> > > idx:2 val:1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80
> > > idx:2 val:1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80
> > > idx:2 val:1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800
> > > idx:2 val:1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00
> > > idx:2 val:1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680
> > > idx:1 val:-1
> > > Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680
> > > idx:2 val:1

Bringing back some text from Markus's original posting:

> > > These warnings were introduced by c3f0327f8e9d7. Wouldn't it make sense to hide
> > > them under some debugging option? AFAICS they contain no information that could
> > > be of any use to a casual user.

Yes, I agree, I would prefer it under CONFIG_DEBUG_VM (as I said at the
time); and KERN_ALERT is way over the top, KERN_WARNING more appropriate.

However, it is very interesting that they have revealed something,
which would have been missed if they hadn't annoyed Markus in this way:
a patch around -rc7 to make it KERN_WARNING under CONFIG_DEBUG_VM would
be good, but until then let's see what else comes up.

> > 
> > BTW, I'm not the only one that sees these messages. Here are two more
> > reports from Ubuntu beta testers:
> > 
> > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/963672
> > BUG: Bad rss-counter state mm:ffff88022107fb80 idx:1 val:-14
> > BUG: Bad rss-counter state mm:ffff88022107fb80 idx:2 val:14
> > 
> > 
> > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/965709
> > BUG: Bad rss-counter state mm:c8fd9dc0 idx:1 val:-2
> > BUG: Bad rss-counter state mm:c8fd9dc0 idx:2 val:2
> > usb 5-1: USB disconnect, device number 2
> > usb 5-1: new low-speed USB device number 3 using uhci_hcd
> > input: Mega World Thrustmaster dual analog 3.2 as
> > /devices/pci0000:00/0000:00:1d.0/usb5/5-1/5-1:1.0/input/input13
> > generic-usb 0003:044F:B315.0004: input,hidraw1: USB HID v1.10 Gamepad
> > [Mega World Thrustmaster dual analog 3.2] on usb-0000:00:1d.0-1/input0
> > BUG: Bad rss-counter state mm:c8fd9dc0 idx:1 val:-2
> > BUG: Bad rss-counter state mm:c8fd9dc0 idx:2 val:2
> > BUG: Bad rss-counter state mm:dea3cc40 idx:1 val:-1
> > BUG: Bad rss-counter state mm:dea3cc40 idx:2 val:1
> > 
> > The pattern seem to be:
> > ... idx:1 val:-x
> > ... idx:2 val:x
> > for x=1,2,14
> > 
> 
> Ok, thanks. I'll try to figure out how this is happened.

Thanks: I looked around but didn't find it.

All the numbers, of course, indicate a ptentry being counted as swap
when it's inserted, but anon when it's removed.

I was suspicious of the mm_counter args stuff in fs/exec.c at first;
but I think that that is self-consistent (doesn't matter if entries
get swapped out), despite being an unusual way of using the counters.

zap_pte()'s else block in mm/fremap.c looks ignorant of migration
entries and mm_counters, and ought to be updated; but I think it's
very unlikely to be the cause of the cases seen (sys_remap_file_pages
is unusual in itself, applying it to an already populated area even
more unusual, finding anon-or-swap entries in a VM_SHARED area even
more unusual).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
