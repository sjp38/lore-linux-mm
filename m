Message-ID: <486D511A.9020405@garzik.org>
Date: Thu, 03 Jul 2008 18:22:18 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <486CC440.9030909@garzik.org>	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>	 <486CCFED.7010308@garzik.org>	 <1215091999.10393.556.camel@pmac.infradead.org>	 <486CD654.4020605@garzik.org>	 <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <486D3E88.9090900@garzik.org> <486D4596.60005@infradead.org>
In-Reply-To: <486D4596.60005@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> Jeff Garzik wrote:
>> David Woodhouse wrote:
>>> Although it does make me wonder if it was better the way I had it
>>> originally, with individual options like TIGON3_FIRMWARE_IN_KERNEL
>>> attached to each driver, rather than a single FIRMWARE_IN_KERNEL option
>>> which controls them all.
>>
>> IMO, individual options would be better.
> 
> They had individual options for a long time, but the consensus was that 
> I should remove them -- a consensus which was probably right. It was 
> moderately inconvenient going back through it all and recommitting it 
> without that, but it was worth it to get it right...
> 
>> Plus, unless I am misunderstanding, the firmware is getting built into 
>> the kernel image not the tg3 module?
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

It is pointless -- if you assume everybody wants to run their distro and 
universe your way.

If a firmware is built-in, then 'make firmware_install' is clearly 
optional and may be omitted.  That invalidates several of your 
assumptions above.

Further, all current kernel build and test etc. scripts are unaware of 
'make firmware_install', and it is unfair to everybody to force a 
flag-day build process change on people, just to keep their drivers in 
the same working state today as it was yesterday.


Conclusion - kernel build process must produce a working driver after 
your changes are applied, even in absence of 'make firmware_install'.

That does not, repeat /not/ exclude the desired end goal of course -- 
separating the firmware from the driver, installing in /lib/firmware via 
'make firmware_install', etc.


I support your end goal, I really do.  But I continue to feel there is a 
lack of regard for breakage and regressions.  You are either ignoring or 
apparently just not seeing
	* how many new ways this can produce a non-working driver
	* how important it is in this specific case to fail-safe,
	  and avoid a broken driver at all costs.

As a concrete example, in the above quoted text you assume that a user 
will never copy kernel modules around.  I can tell you that, with tg3.ko 
being nice and self-contained, yes it does get copied around (to 
multiple machines, etc.).  With the firmware newly separated from 
tg3.ko, you have introduced breakage for any user that is unaware of 
this new requirement (kernel module == requires additional file now).

Scripts that build install disks must be updated, otherwise a script 
that builds a boot image will include the drivers it knows about, but 
/not/ include the crucial firmware.

None of this stuff is "pointless", none of this stuff may be dismissed 
as "making no sense".  All these are real world examples where users 
FOLLOWING THEIR NORMAL, PROSCRIBED KERNEL PROCESSES will produce 
non-working drivers.

The only valid assumption here is to assume that the user is /unaware/ 
of these new steps they must take in order to continue to have a working 
system.

Regards,

	Jeff




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
