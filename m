Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0E56B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 03:44:45 -0500 (EST)
Date: Thu, 1 Dec 2011 09:44:37 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111201084437.GA1529@x4.trippels.de>
References: <1321836285.30341.554.camel@debian>
 <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124085040.GA1677@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org, dri-devel@lists.freedesktop.org, Alex Deucher <alexander.deucher@amd.com>, Dave Airlie <airlied@redhat.com>

On 2011.11.24 at 09:50 +0100, Markus Trippelsdorf wrote:
> On 2011.11.23 at 10:06 -0600, Christoph Lameter wrote:
> > On Wed, 23 Nov 2011, Markus Trippelsdorf wrote:
> > 
> > > > FIX idr_layer_cache: Marking all objects used
> > >
> > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > > exactly the same spot again. (CCing the drm list)
> > 
> > Well this is looks like write after free.
> > 
> > > =============================================================================
> > > BUG idr_layer_cache: Poison overwritten
> > > -----------------------------------------------------------------------------
> > > Object ffff8802156487c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff880215648800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> > > Object ffff880215648810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > 
> > And its an integer sized write of 0. If you look at the struct definition
> > and lookup the offset you should be able to locate the field that
> > was modified.

It also happens with CONFIG_SLAB. 
(If someone wants to reproduce the issue, just run a kexec boot loop and
the bug will occur after a few (~10) iterations.)

Dec  1 05:04:52 x4 kernel: [drm] Initialized drm 1.1.0 20060810
Dec  1 05:04:52 x4 kernel: [drm] radeon defaulting to kernel modesetting.
Dec  1 05:04:52 x4 kernel: [drm] radeon kernel modesetting enabled.
Dec  1 05:04:52 x4 kernel: radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
Dec  1 05:04:52 x4 kernel: radeon 0000:01:05.0: setting latency timer to 64
Dec  1 05:04:52 x4 kernel: [drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
Dec  1 05:04:52 x4 kernel: [drm] register mmio base: 0xFBEE0000
Dec  1 05:04:52 x4 kernel: [drm] register mmio size: 65536
Dec  1 05:04:52 x4 kernel: ATOM BIOS: 113
Dec  1 05:04:52 x4 kernel: radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
Dec  1 05:04:52 x4 kernel: radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
Dec  1 05:04:52 x4 kernel: [drm] Detected VRAM RAM=128M, BAR=128M
Dec  1 05:04:52 x4 kernel: [drm] RAM width 32bits DDR
Dec  1 05:04:52 x4 kernel: [TTM] Zone  kernel: Available graphics memory: 4090750 kiB.
Dec  1 05:04:52 x4 kernel: [TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
Dec  1 05:04:52 x4 kernel: [TTM] Initializing pool allocator.
Dec  1 05:04:52 x4 kernel: [drm] radeon: 128M of VRAM memory ready
Dec  1 05:04:52 x4 kernel: [drm] radeon: 512M of GTT memory ready.
Dec  1 05:04:52 x4 kernel: [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
Dec  1 05:04:52 x4 kernel: [drm] Driver supports precise vblank timestamp query.
Dec  1 05:04:52 x4 kernel: [drm] radeon: irq initialized.
Dec  1 05:04:52 x4 kernel: [drm] GART: num cpu pages 131072, num gpu pages 131072
Dec  1 05:04:52 x4 kernel: [drm] Loading RS780 Microcode
Dec  1 05:04:52 x4 kernel: [drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
Dec  1 05:04:52 x4 kernel: radeon 0000:01:05.0: WB enabled
Dec  1 05:04:52 x4 kernel: Slab corruption: size-1024 start=ffff880216cbc730, len=1024
Dec  1 05:04:52 x4 kernel: Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Dec  1 05:04:52 x4 kernel: Last user: [<          (null)>](0x0)
Dec  1 05:04:52 x4 kernel: 0d0: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
Dec  1 05:04:52 x4 kernel: Prev obj: start=ffff880216cbc318, len=1024
Dec  1 05:04:52 x4 kernel: Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Dec  1 05:04:52 x4 kernel: Last user: [<          (null)>](0x0)
Dec  1 05:04:52 x4 kernel: 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Dec  1 05:04:52 x4 kernel: 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Dec  1 05:04:52 x4 kernel: Next obj: start=ffff880216cbcb48, len=1024
Dec  1 05:04:52 x4 kernel: Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
Dec  1 05:04:52 x4 kernel: Last user: [<ffffffff81299874>](radeon_bo_create+0xb4/0x240)
Dec  1 05:04:52 x4 kernel: 000: 48 cb cb 16 02 88 ff ff 48 cb cb 16 02 88 ff ff  H.......H.......
Dec  1 05:04:52 x4 kernel: 010: 02 00 27 00 00 00 00 00 00 00 00 00 00 00 00 00  ..'.............
Dec  1 05:04:52 x4 kernel: [drm] ring test succeeded in 0 usecs
Dec  1 05:04:52 x4 kernel: [drm] radeon: ib pool ready.
Dec  1 05:04:52 x4 kernel: [drm] ib test succeeded in 0 usecs
Dec  1 05:04:52 x4 kernel: [drm] Radeon Display Connectors
Dec  1 05:04:52 x4 kernel: [drm] Connector 0:
Dec  1 05:04:52 x4 kernel: [drm]   VGA
Dec  1 05:04:52 x4 kernel: [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
Dec  1 05:04:52 x4 kernel: [drm]   Encoders:
Dec  1 05:04:52 x4 kernel: [drm]     CRT1: INTERNAL_KLDSCP_DAC1
Dec  1 05:04:52 x4 kernel: [drm] Connector 1:
Dec  1 05:04:52 x4 kernel: [drm]   DVI-D
Dec  1 05:04:52 x4 kernel: [drm]   HPD3
Dec  1 05:04:52 x4 kernel: [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
Dec  1 05:04:52 x4 kernel: [drm]   Encoders:
Dec  1 05:04:52 x4 kernel: [drm]     DFP3: INTERNAL_KLDSCP_LVTMA
Dec  1 05:04:52 x4 kernel: [drm] radeon: power management initialized
Dec  1 05:04:52 x4 kernel: [drm] fb mappable at 0xF0142000
Dec  1 05:04:52 x4 kernel: [drm] vram apper at 0xF0000000
Dec  1 05:04:52 x4 kernel: [drm] size 7299072
Dec  1 05:04:52 x4 kernel: [drm] fb depth is 24
Dec  1 05:04:52 x4 kernel: [drm]    pitch is 6912
Dec  1 05:04:52 x4 kernel: fbcon: radeondrmfb (fb0) is primary device
Dec  1 05:04:52 x4 kernel: Console: switching to colour frame buffer device 131x105
Dec  1 05:04:52 x4 kernel: fb0: radeondrmfb frame buffer device
Dec  1 05:04:52 x4 kernel: drm: registered panic notifier
Dec  1 05:04:52 x4 kernel: [drm] Initialized radeon 2.12.0 20080528 for 0000:01:05.0 on minor 0


Dec  1 05:09:35 x4 kernel: radeon 0000:01:05.0: WB enabled
Dec  1 05:09:35 x4 kernel: [drm] ring test succeeded in 1 usecs
Dec  1 05:09:35 x4 kernel: [drm] radeon: ib pool ready.
Dec  1 05:09:35 x4 kernel: [drm] ib test succeeded in 0 usecs
Dec  1 05:09:35 x4 kernel: Slab corruption: size-512 start=ffff880216f7e760, len=512
Dec  1 05:09:35 x4 kernel: Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Dec  1 05:09:35 x4 kernel: Last user: [<          (null)>](0x0)
Dec  1 05:09:35 x4 kernel: 0a0: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
Dec  1 05:09:35 x4 kernel: Prev obj: start=ffff880216f7e548, len=512
Dec  1 05:09:35 x4 kernel: Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Dec  1 05:09:35 x4 kernel: Last user: [<          (null)>](0x0)
Dec  1 05:09:35 x4 kernel: 000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Dec  1 05:09:35 x4 kernel: 010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Dec  1 05:09:35 x4 kernel: Next obj: start=ffff880216f7e978, len=512
Dec  1 05:09:35 x4 kernel: Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
Dec  1 05:09:35 x4 kernel: Last user: [<ffffffff812e519d>](radeon_add_atom_encoder+0x7d/0x280)
Dec  1 05:09:35 x4 kernel: 000: f8 d3 f6 16 02 88 ff ff 18 d8 f6 16 02 88 ff ff  ................
Dec  1 05:09:35 x4 kernel: 010: 18 d8 f6 16 02 88 ff ff 0c 00 00 00 e0 e0 e0 e0  ................
Dec  1 05:09:35 x4 kernel: [drm] Radeon Display Connectors
Dec  1 05:09:35 x4 kernel: [drm] Connector 0:
Dec  1 05:09:35 x4 kernel: [drm]   VGA
Dec  1 05:09:35 x4 kernel: [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
Dec  1 05:09:35 x4 kernel: [drm]   Encoders:
Dec  1 05:09:35 x4 kernel: [drm]     CRT1: INTERNAL_KLDSCP_DAC1
Dec  1 05:09:35 x4 kernel: [drm] Connector 1:
Dec  1 05:09:35 x4 kernel: [drm]   DVI-D
Dec  1 05:09:35 x4 kernel: [drm]   HPD3
Dec  1 05:09:35 x4 kernel: [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
Dec  1 05:09:35 x4 kernel: [drm]   Encoders:
Dec  1 05:09:35 x4 kernel: [drm]     DFP3: INTERNAL_KLDSCP_LVTMA
Dec  1 05:09:35 x4 kernel: [drm] radeon: power management initialized
Dec  1 05:09:35 x4 kernel: [drm] fb mappable at 0xF0142000
Dec  1 05:09:35 x4 kernel: [drm] vram apper at 0xF0000000
Dec  1 05:09:35 x4 kernel: [drm] size 7299072
Dec  1 05:09:35 x4 kernel: [drm] fb depth is 24
Dec  1 05:09:35 x4 kernel: [drm]    pitch is 6912
Dec  1 05:09:35 x4 kernel: fbcon: radeondrmfb (fb0) is primary device
Dec  1 05:09:35 x4 kernel: Console: switching to colour frame buffer device 131x105
Dec  1 05:09:35 x4 kernel: fb0: radeondrmfb frame buffer device
Dec  1 05:09:35 x4 kernel: drm: registered panic notifier
Dec  1 05:09:35 x4 kernel: [drm] Initialized radeon 2.12.0 20080528 for 0000:01:05.0 on minor 0

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
