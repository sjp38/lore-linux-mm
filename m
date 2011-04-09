Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E61C8D003B
	for <linux-mm@kvack.org>; Sat,  9 Apr 2011 08:18:26 -0400 (EDT)
Date: Sat, 9 Apr 2011 14:17:24 +0200
From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: BUG in vb_alloc() (was: [Bug 31572] New: firewire crash at
 boot)
Message-ID: <20110409141724.0ed24cc6@stein>
In-Reply-To: <4D884EBC.1040307@ladisch.de>
References: <bug-31572-4803@https.bugzilla.kernel.org/>
	<20110321143203.0fb19bee@stein>
	<20110321145002.5aa8114d@stein>
	<4D8761D1.6010605@ladisch.de>
	<4D884EBC.1040307@ladisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux1394-devel@lists.sourceforge.net, Pavel Kysilka <goldenfish@linuxsoft.cz>, bugzilla-daemon@bugzilla.kernel.org, "Matias A.
 Fonzo" <selk@dragora.org>

On Mar 22 Clemens Ladisch wrote:
> Stefan Richter wrote:
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=31572
> > > > Created an attachment (id=51502)
> > > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=51502)
> > > > photo of oops
> > 
> > EIP is at vm_map_ram+0xff/0x363.
> 
> This is in some inlined part of vb_alloc (which means that the FireWire
> code is not directly at fault, it's just the first one that happens to
> use this code).
> 
> > Clemens, does the hex dump tell you anything?
> 
> Half of it is missing.  (What's going on with that video output?
> This GPU works fine in my machine, with a 64-bit kernel.  (And why
> is an 8 GB machine using a 32-bit kernel?))
> 
> Anyway, the part immediately before the crashing instruction is:
> c109c993:   31 d2                   xor    %edx,%edx
> c109c995:   f7 f1                   div    %ecx
> c109c997:   31 d2                   xor    %edx,%edx
> c109c999:   89 c7                   mov    %eax,%edi
> c109c99b:   8b 45 cc                mov    -0x34(%ebp),%eax
> c109c99e:   f7 f1                   div    %ecx
> c109c9a0:   39 c7                   cmp    %eax,%edi
> c109c9a2:   74 04                   je     0xc109c9a8
> c109c9a4:   ??...                   ???                   <-- crash here
> 
> This looks as if this check in vb_alloc triggered:
> 
>                 BUG_ON(addr_to_vb_idx(addr) !=
>                                 addr_to_vb_idx(vb->va->va_start));

This is it indeed.  Matias posted at
https://bugzilla.kernel.org/show_bug.cgi?id=32842 :

>>>
Sometimes I receive this error while I am booting:

[    7.227814] kernel BUG at mm/vmalloc.c:893!
[    7.227909] invalid opcode: 0000 [#1] SMP 
[    7.228001] last sysfs file: /sys/devices/pci0000:00/0000:00:04.0/host6/target6:0:0/6:0:0:0/type
[    7.228001] Modules linked in: i2c_nforce2(+) firewire_ohci(+) ehci_hcd(+) processor pcmcia_core forcedeth(+) firewire_core soundcore rtc_lib i2c_core evdev fan button snd_page_alloc k10temp thermal asus_atk0110 sg serio_raw thermal_sys pcspkr hwmon
[    7.228001] 
[    7.228001] Pid: 1176, comm: modprobe Not tainted 2.6.38.2-smp #1 System manufacturer System Product Name/M2N-SLI DELUXE
[    7.228001] EIP: 0060:[<c10b3033>] EFLAGS: 00010202 CPU: 0
[    7.228001] EIP is at vm_map_ram+0xd9/0x312
[    7.228001] EAX: 00000017 EBX: f4a0a8a0 ECX: 00055000 EDX: 00054000
[    7.228001] ESI: f6003318 EDI: f87b1000 EBP: f4bd1d94 ESP: f4bd1d64
[    7.228001]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    7.228001] Process modprobe (pid: 1176, ti=f4bd0000 task=f44cb670 task.ti=f4bd0000)
[    7.228001] Stack:
[    7.228001]  f87a1000 f4bd1db0 00000000 0000000a 00000010 00000004 0000a000 00000018
[    7.228001]  f4a0a8cc 34479000 f44805d4 00000008 f4bd1de4 f8772bdb 00000163 f6e85f20
[    7.228001]  f5227060 00000400 f4480000 f6e86de0 f6e86e20 f6e94180 f6e941a0 f6e85880
[    7.228001] Call Trace:
[    7.228001]  [<f8772bdb>] ar_context_init+0xee/0x15e [firewire_ohci]
[    7.228001]  [<f877469b>] pci_probe+0x1bf/0x42d [firewire_ohci]
[    7.228001]  [<c12f6754>] ? pm_runtime_enable+0x55/0x5d
[    7.228001]  [<c1294663>] local_pci_probe+0x34/0x5f
[    7.228001]  [<c1294b07>] pci_device_probe+0x4a/0x6d
[    7.228001]  [<c12f18cf>] driver_probe_device+0x9b/0x11f
[    7.228001]  [<c12f199b>] __driver_attach+0x48/0x64
[    7.228001]  [<c12f0d56>] bus_for_each_dev+0x42/0x65
[    7.228001]  [<c12f1636>] driver_attach+0x19/0x1b
[    7.228001]  [<c12f1953>] ? __driver_attach+0x0/0x64
[    7.228001]  [<c12f130d>] bus_add_driver+0x8d/0x1c5
[    7.228001]  [<c12f1b75>] driver_register+0x7c/0xdb
[    7.228001]  [<c107a9b8>] ? tracepoint_module_notify+0x22/0x26
[    7.228001]  [<c1294ce1>] __pci_register_driver+0x3d/0x9a
[    7.228001]  [<f8779017>] fw_ohci_init+0x17/0x19 [firewire_ohci]
[    7.228001]  [<c100123f>] do_one_initcall+0x76/0x11b
[    7.228001]  [<f8779000>] ? fw_ohci_init+0x0/0x19 [firewire_ohci]
[    7.228001]  [<c105eab0>] sys_init_module+0x12ed/0x14eb
[    7.228001]  [<c144fdf4>] syscall_call+0x7/0xb
[    7.228001] Code: 58 0f 0b 8b 53 04 89 c7 c1 e7 0c 8b 12 01 d7 89 f8 89 55 d0 e8 79 f0 ff ff 8b 55 d0 89 45 ec 89 d0 e8 6c f0 ff ff 39 45 ec 74 02 <0f> 0b 8b 43 0c 2b 45 e0 85 c0 89 43 0c 75 1b 89 f0 e8 7e c9 39 
[    7.228001] EIP: [<c10b3033>] vm_map_ram+0xd9/0x312 SS:ESP 0068:f4bd1d64
<<<

> On x86, we call vm_map_ram() with 8+2 pages, so the parameters here
> are vb_alloc(40960, GFP_KERNEL).
> 
> I've never tested this code during bootup; I always loaded firewire-ohci
> later.

Today I tried an i686 alias x86-32 kernel v2.6.39-rc2 on a Core 2 Duo with 
2 GB RAM with firewire-ohci statically linked in, booting it twenty times
or so.  Could not reproduce it so far.

I also got an x86-64 box with 8 GB RAM but reboot it rarely.  (It still
runs 2.6.38-rc7.)  I do unload and reload modular firewire-ohci on it very
often, but this did not reproduce the bug either.
-- 
Stefan Richter
-=====-==-== -=-- -=--=
http://arcgraph.de/sr/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
