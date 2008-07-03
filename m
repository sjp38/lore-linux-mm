From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 3 Jul 2008 23:42:00 +0200
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <486D3E88.9090900@garzik.org> <486D4596.60005@infradead.org>
In-Reply-To: <486D4596.60005@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807032342.01292.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jeff Garzik <jeff@garzik.org>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday, 3 of July 2008, David Woodhouse wrote:
> Jeff Garzik wrote:
> > David Woodhouse wrote:
> >> Although it does make me wonder if it was better the way I had it
> >> originally, with individual options like TIGON3_FIRMWARE_IN_KERNEL
> >> attached to each driver, rather than a single FIRMWARE_IN_KERNEL option
> >> which controls them all.
> > 
> > IMO, individual options would be better.
> 
> They had individual options for a long time, but the consensus was that 
> I should remove them -- a consensus which was probably right. It was 
> moderately inconvenient going back through it all and recommitting it 
> without that, but it was worth it to get it right...
> 
> > Plus, unless I am misunderstanding, the firmware is getting built into 
> > the kernel image not the tg3 module?
> 
> That's right, although it doesn't really matter when they're both in the 
> vmlinux.
> 
> When it's actually a module, there really is no good reason not to let 
> request_firmware() get satisfied from userspace. If you can load 
> modules, then you can load firmware too -- the required udev stuff has 
> been there as standard for a _long_ time, as most modern drivers 
> _require_ it without even giving you the built-in-firmware option at all.
> 
> It makes no more sense to object to that than it does to object to the 
> module depending on _other_ modules. Both those other modules, and the 
> required firmware, are _installed_ by the kernel Makefiles, after all.
> 
> It wouldn't be _impossible_ to put firmware blobs into the foo.ko files 
> themselves and find them there. The firmware blobs in the kernel are 
> done in a separate section (like initcalls, exceptions tables, pci 
> fixups, and a bunch of other stuff). It'd just take some work in 
> module.c to link them into a global list, and some locking shenanigans 
> in the lookups (and lifetime issues to think about). But it just isn't 
> worth the added complexity, given that userspace is known to be alive 
> and working. It's pointless not to just use request_firmware() normally, 
> from a module.

Still, maybe we can add some kbuild magic to build the blobs along with
their modules and to install them under /lib/firmware (by default) when the
modules are installed in /lib/modules/... ?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
