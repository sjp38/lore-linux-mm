Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6066B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:50:45 -0400 (EDT)
Date: Wed, 28 Jul 2010 16:50:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 16415] New: Show_Memory/Shift-ScrollLock triggers "unable
	to handle kernel paging request at 00021c6e"
Message-ID: <20100728155026.GJ5300@csn.ul.ie>
References: <bug-16415-27@https.bugzilla.kernel.org/> <20100722153443.e266b2d6.akpm@linux-foundation.org> <20100727125428.GY5300@csn.ul.ie> <4C50233A.4090304@xs4all.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C50233A.4090304@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: The Nimble Byte <tnimble@xs4all.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 02:31:54PM +0200, The Nimble Byte wrote:
> On 27/07/2010 14:54, Mel Gorman wrote
>> BUG: unable to handle kernel paging request at 00021c6e
>>
>> I was unable to reproduce this on qemu at least (my test machines are
>> all occupied). Test case was to force use of highmem (vmalloc=) and
>> mount tmpfs with a swapfile in place. A heavy mix off dd writing to
>> on-disk and tmpfs-files over the course of 15 minutes triggered nothing
>> out of the ordinary. So, whatever is going on here, it's not immediately
>> obvious and so I'm afraid I have to make wild stabs in the dark.
>> Relevant people cc'd.
>
> This bug (activating show_mem) can be reproduced without the dd on  
> tmpfs. From a initial ramdisk containing only a shell, some libraries  
> and the following init script:
> : #!/bin/sh
> : echo Loading....
> : sleep 60
>
> Pressing shift+scroll lock during the sleep generates an oops at the  
> beginning of the show_mem function also. The issue does thereby not seem  
> to be related to any of the kernel code compiled as modules. It pretty  
> much rules out tmpfs itself.
>

A reasonable assessment.

>> Theory 1
>> --------
>> Can we eliminate bad hardware as an option? What modules are loaded in this
>> machine (lsmod and lspci -v)? Can memtest be run on this machine for a number
>> of hours to eliminate bad memory as a possibility? I recognise that 2.6.12.6
>> was fine on this machine but it's possible that 2.6.34.1 is stressing the
>> machine more for some reason.
>
> The kernel has been run on multiple hardware (similar (not fully  
> identical) type though) and memtest86+ has been run for several hours  
> without any trouble.
>

Ok.

> $ lspci -v
> :00:00.0 Class 0600: 8086:27ac (rev 03)

No pciutils for translating the vendor codes and ID's?

> :    Subsystem: 8086:27ac
> :    Flags: bus master, fast devsel, latency 0
> :    Capabilities: [e0] #09 [5109]
> :
> :00:02.0 Class 0300: 8086:27ae (rev 03)
> :    Subsystem: 8086:27ae
> :    Flags: bus master, fast devsel, latency 0, IRQ 16
> :    Memory at fdf00000 (32-bit, non-prefetchable) [size=512K]
> :    I/O ports at ff00 [size=8]
> :    Memory at d0000000 (32-bit, prefetchable) [size=256M]
> :    Memory at fdf80000 (32-bit, non-prefetchable) [size=256K]
> :    Expansion ROM at <unassigned> [disabled]
> :    Capabilities: [90] Message Signalled Interrupts: 64bit- Queue=0/0  Enable-
> :    Capabilities: [d0] Power Management version 2
> :

I think this is a "Intel Mobile 945GME Express Integrated Graphics Controller"
which is of some relevance later.

> :00:1b.0 Class 0403: 8086:27d8 (rev 02)
> :    Subsystem: 8086:27d8
> :    Flags: bus master, fast devsel, latency 0, IRQ 32
> :    Memory at fdff8000 (64-bit, non-prefetchable) [size=16K]
> :    Capabilities: [50] Power Management version 2
> :    Capabilities: [60] Message Signalled Interrupts: 64bit+ Queue=0/0  Enable+
> :    Capabilities: [70] #10 [0091]
> :
> :00:1c.0 Class 0604: 8086:27d0 (rev 02)
> :    Flags: bus master, fast devsel, latency 0
> :    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> :    I/O behind bridge: 0000b000-0000bfff
> :    Memory behind bridge: fd800000-fd8fffff
> :    Prefetchable memory behind bridge: 00000000fd500000-00000000fd500000
> :    Capabilities: [40] #10 [0141]
> :    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0  Enable+
> :    Capabilities: [90] #0d [0000]
> :    Capabilities: [a0] Power Management version 2
> :
> :00:1c.1 Class 0604: 8086:27d2 (rev 02)
> :    Flags: bus master, fast devsel, latency 0
> :    Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> :    I/O behind bridge: 0000a000-0000afff
> :    Memory behind bridge: fde00000-fdefffff
> :    Prefetchable memory behind bridge: 00000000fdd00000-00000000fdd00000
> :    Capabilities: [40] #10 [0141]
> :    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0  Enable+
> :    Capabilities: [90] #0d [0000]
> :    Capabilities: [a0] Power Management version 2
> :
> :00:1c.2 Class 0604: 8086:27d4 (rev 02)
> :    Flags: bus master, fast devsel, latency 0
> :    Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> :    I/O behind bridge: 0000e000-0000efff
> :    Memory behind bridge: fdc00000-fdcfffff
> :    Prefetchable memory behind bridge: 00000000fdb00000-00000000fdb00000
> :    Capabilities: [40] #10 [0141]
> :    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0  Enable+
> :    Capabilities: [90] #0d [0000]
> :    Capabilities: [a0] Power Management version 2
> :
> :00:1c.3 Class 0604: 8086:27d6 (rev 02)
> :    Flags: bus master, fast devsel, latency 0
> :    Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
> :    I/O behind bridge: 0000d000-0000dfff
> :    Memory behind bridge: fda00000-fdafffff
> :    Prefetchable memory behind bridge: 00000000fd900000-00000000fd900000
> :    Capabilities: [40] #10 [0141]
> :    Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0  Enable+
> :    Capabilities: [90] #0d [0000]
> :    Capabilities: [a0] Power Management version 2
> :
> :00:1d.0 Class 0c03: 8086:27c8 (rev 02)
> :    Subsystem: 8086:27c8
> :    Flags: bus master, medium devsel, latency 0, IRQ 23
> :    I/O ports at fe00 [size=32]
> :
> :00:1d.1 Class 0c03: 8086:27c9 (rev 02)
> :    Subsystem: 8086:27c9
> :    Flags: bus master, medium devsel, latency 0, IRQ 19
> :    I/O ports at fd00 [size=32]
> :
> :00:1d.2 Class 0c03: 8086:27ca (rev 02)
> :    Subsystem: 8086:27ca
> :    Flags: bus master, medium devsel, latency 0, IRQ 18
> :    I/O ports at fc00 [size=32]
> :
> :00:1d.3 Class 0c03: 8086:27cb (rev 02)
> :    Subsystem: 8086:27cb
> :    Flags: bus master, medium devsel, latency 0, IRQ 16
> :    I/O ports at fb00 [size=32]
> :
> :00:1d.7 Class 0c03: 8086:27cc (rev 02) (prog-if 20)
> :    Subsystem: 8086:27cc
> :    Flags: bus master, medium devsel, latency 0, IRQ 23
> :    Memory at fdfff000 (32-bit, non-prefetchable) [size=1K]
> :    Capabilities: [50] Power Management version 2
> :    Capabilities: [58] #0a [20a0]
> :
> :00:1e.0 Class 0604: 8086:2448 (rev e2) (prog-if 01)
> :    Flags: bus master, fast devsel, latency 0
> :    Bus: primary=00, secondary=05, subordinate=05, sec-latency=32
> :    I/O behind bridge: 0000c000-0000cfff
> :    Memory behind bridge: fd700000-fd7fffff
> :    Prefetchable memory behind bridge: 00000000fd600000-00000000fd600000
> :    Capabilities: [50] #0d [0000]
> :
> :00:1f.0 Class 0601: 8086:27b9 (rev 02)
> :    Subsystem: 8086:27b9
> :    Flags: bus master, medium devsel, latency 0
> :    Capabilities: [e0] #09 [100c]
> :
> :00:1f.1 Class 0101: 8086:27df (rev 02) (prog-if 8a [Master SecP PriP])
> :    Subsystem: 8086:27df
> :    Flags: bus master, medium devsel, latency 0, IRQ 18
> :    I/O ports at 01f0 [size=8]
> :    I/O ports at 03f4
> :    I/O ports at 0170 [size=8]
> :    I/O ports at 0374
> :    I/O ports at fa00 [size=16]
> :
> :00:1f.2 Class 0101: 8086:27c4 (rev 02) (prog-if 8f [Master SecP SecO  
> PriP PriO])
> :    Subsystem: 8086:27c4
> :    Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 19
> :    I/O ports at f900 [size=8]
> :    I/O ports at f800 [size=4]
> :    I/O ports at f700 [size=8]
> :    I/O ports at f600 [size=4]
> :    I/O ports at f500 [size=16]
> :    Memory at fdffe000 (32-bit, non-prefetchable) [size=1K]
> :    Capabilities: [70] Power Management version 2
> :
> :00:1f.3 Class 0c05: 8086:27da (rev 02)
> :    Subsystem: 8086:27da
> :    Flags: medium devsel, IRQ 19
> :    I/O ports at 0500 [size=32]
> :
> :01:00.0 Class 0200: 8086:109a
> :    Subsystem: 8086:0000
> :    Flags: bus master, fast devsel, latency 0, IRQ 28
> :    Memory at fd8e0000 (32-bit, non-prefetchable) [size=128K]
> :    I/O ports at bf00 [size=32]
> :    Capabilities: [c8] Power Management version 2
> :    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0  Enable+
> :    Capabilities: [e0] #10 [0001]
> :
> :02:00.0 Class 0200: 8086:109a
> :    Subsystem: 8086:0000
> :    Flags: bus master, fast devsel, latency 0, IRQ 29
> :    Memory at fdee0000 (32-bit, non-prefetchable) [size=128K]
> :    I/O ports at af00 [size=32]
> :    Capabilities: [c8] Power Management version 2
> :    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0  Enable+
> :    Capabilities: [e0] #10 [0001]
> :
> :03:00.0 Class 0200: 8086:109a
> :    Subsystem: 8086:0000
> :    Flags: bus master, fast devsel, latency 0, IRQ 30
> :    Memory at fdce0000 (32-bit, non-prefetchable) [size=128K]
> :    I/O ports at ef00 [size=32]
> :    Capabilities: [c8] Power Management version 2
> :    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0  Enable+
> :    Capabilities: [e0] #10 [0001]
> :
> :04:00.0 Class 0200: 8086:109a
> :    Subsystem: 8086:0000
> :    Flags: bus master, fast devsel, latency 0, IRQ 31
> :    Memory at fdae0000 (32-bit, non-prefetchable) [size=128K]
> :    I/O ports at df00 [size=32]
> :    Capabilities: [c8] Power Management version 2
> :    Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0  Enable+
> :    Capabilities: [e0] #10 [0001]
>
> $ lsmod
> <SNIP, didn't spot anything unusual>
>
>> Theory 2
>> --------
>> To catch early mistakes in the memory model, can the machine be booted with
>> mminit_loglevel=4 and CONFIG_DEBUG_VM set in .config? I am not optimistic
>> this is where the problem is though. If we were making mistakes in early
>> setup, I'd expect a large volume of bug reports on it.
>>    
> [    0.000000] Linux version 2.6.34.1  
> (root@doeblin.development.xafax.nl) (gcc version 4.2.4) #26 SMP Wed Jul  

There are a few vague reports that gcc
4.2.x were not great for some kernel builds. See
http://www.mail-archive.com/debian-gcc@lists.debian.org/msg25246.html for
example but there were others later such as what is corrected by commit
3730793.  I thought they were ironed out but does anyone know if gcc 4.2.4
is a known good gcc version for kernel builds? It worked here but can another
gcc version be tried in case there is some unknown quirk?

> 28 13:24:34 CEST 2010
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
> [    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
> [    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000007f690000 (usable)
> [    0.000000]  BIOS-e820: 000000007f690000 - 000000007f6e0000 (reserved)
> [    0.000000]  BIOS-e820: 000000007f6e0000 - 000000007f6e3000 (ACPI NVS)
> [    0.000000]  BIOS-e820: 000000007f6e3000 - 000000007f6f0000 (ACPI data)
> [    0.000000]  BIOS-e820: 000000007f6f0000 - 000000007f700000 (reserved)
> [    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
> [    0.000000] NX (Execute Disable) protection: active
> [    0.000000] DMI 2.2 present.
> [    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.

I faked the Phoenix BIOS workaround locally and got nothing so it's not
the reservation itself that is the problem

> [    0.000000] last_pfn = 0x7f690 max_arch_pfn = 0x1000000
> [    0.000000] PAT not supported by CPU.
> [    0.000000] found SMP MP-table at [c00f38d0] f38d0
> [    0.000000] init_memory_mapping: 0000000000000000-0000000037bfe000
> [    0.000000] RAMDISK: 37d29000 - 37ff0000
> [    0.000000] Allocated new RAMDISK: 00493000 - 007596bb
> [    0.000000] Move RAMDISK from 0000000037d29000 - 0000000037fef6ba to  
> 00493000 - 007596ba

Where did this ramdisk come out of? There is no mention of it in your .config
or the boot parameters.


> <SNIP, could not spot anything out of teh ordinary>
> [   17.182169] BUG: unable to handle kernel paging request at 4c4fe4ad
> [   17.182169] IP: [<c01d8a07>] show_mem+0xbf/0x15c

In both boot logs, the bad request was very close to 0x4c4fe400. It
doesn't look like any poison pattern but does it look like any sort of
relevant sequence to anyone else? I'm wondering if there is some piece
of hardware writing where it shouldn't similar to what this bug was
about http://lkml.org/lkml/2010/6/6/172 .

The 0x4c4f pattern is very similar to the value for R300_ZB_HIZ_DWORD
which 0x4f4c but the graphics card is an Intel 945GME so that can't be
it.

> <SNIP>
>
>> Theory 3
>> --------
>> I see this message early in boot
>> Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.
>>
>> Is there any possibility that the wrong range of memory is being reserved
>> and in fact the BIOS is screwing with the region of memory memmap is stored in?
>
> Can't be fully ruled out indeed, since during memtest86+ no kernel with  
> ACPI loaded has been loaded the BIOS may very well be less active or be  
> inactive. And thus not showing any memory changes caused by BIOS RAM 
> usage.

Not sure how to eliminate this as a possibility.

>>
>> Theory 4
>> --------
>>
>> with the early boot changes, is there any possibility that bootmem used the
>> low 64K? To test the theory, can the kernel be rebuilt with CONFIG_NO_BOOTMEM
>> *not* set to use the older bootmem logic?
>
> <SNIP, failure looks the same>
>
>>
>> Theory 5
>> --------
>> What are the consequences of the following message?
>>
>> pcieport 0000:00:1c.0: Requesting control of PCIe PME from ACPI BIOS
>> pcieport 0000:00:1c.0: Failed to receive control of PCIe PME service: no _OSC support
>> pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
>> pcieport 0000:00:1c.1: Requesting control of PCIe PME from ACPI BIOS
>> pcieport 0000:00:1c.1: Failed to receive control of PCIe PME service: no _OSC support
>> pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
>> pcieport 0000:00:1c.2: Requesting control of PCIe PME from ACPI BIOS
>> pcieport 0000:00:1c.2: Failed to receive control of PCIe PME service: no _OSC support
>> pcie_pme: probe of 0000:00:1c.2:pcie01 failed with error -13
>> pcieport 0000:00:1c.3: Requesting control of PCIe PME from ACPI BIOS
>> pcieport 0000:00:1c.3: Failed to receive control of PCIe PME service: no _OSC support
>> pcie_pme: probe of 0000:00:1c.3:pcie01 failed with error -13
>>
>> Is there any possibility when this fails that the device is writing to
>> some location in memory thinking the OS has taken proper control of it
>> and reserved those physicaly address? (reaching I know, but have to
>> eliminate it as a possibility)
>
> Tried aerdriver.forceload=y without success. Suggestions welcome on how  
> to rule this out.
>
>> Sorry to spread the possibilities all over the place but without a local
>> reproduction case, there isn't much to go on yet.
>
> If it helps I can sent or attach the vmlinuz or even complete kernel  
> build dir
>

I'm afraid it won't help me at least. I currently suspect it's some
quirk in the hardware or I'd see something similar under qemu so the
vmlinuz file itself won't tell me anything.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
