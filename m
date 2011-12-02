Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F3F6A6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 15:48:29 -0500 (EST)
Date: Fri, 2 Dec 2011 21:48:20 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111202204820.GB1603@x4.trippels.de>
References: <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
 <20111201084437.GA1529@x4.trippels.de>
 <20111202194309.GA12057@homer.localdomain>
 <20111202200649.GA1603@x4.trippels.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111202200649.GA1603@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Dave Airlie <airlied@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>, Robert Richter <robert.richter@amd.com>

On 2011.12.02 at 21:06 +0100, Markus Trippelsdorf wrote:
> On 2011.12.02 at 14:43 -0500, Jerome Glisse wrote:
> > On Thu, Dec 01, 2011 at 09:44:37AM +0100, Markus Trippelsdorf wrote:
> > > On 2011.11.24 at 09:50 +0100, Markus Trippelsdorf wrote:
> > > > On 2011.11.23 at 10:06 -0600, Christoph Lameter wrote:
> > > > > On Wed, 23 Nov 2011, Markus Trippelsdorf wrote:
> > > > > 
> > > > > > > FIX idr_layer_cache: Marking all objects used
> > > > > >
> > > > > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > > > > > exactly the same spot again. (CCing the drm list)
> > > > > 
> > > > > Well this is looks like write after free.
> > > > > 
> > > > > > =============================================================================
> > > > > > BUG idr_layer_cache: Poison overwritten
> > > > > > -----------------------------------------------------------------------------
> > > > > > Object ffff8802156487c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > > > Object ffff8802156487d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > > > Object ffff8802156487e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > > > Object ffff8802156487f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > > > Object ffff880215648800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> > > > > > Object ffff880215648810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > > > 
> > > > > And its an integer sized write of 0. If you look at the struct definition
> > > > > and lookup the offset you should be able to locate the field that
> > > > > was modified.
> > > 
> > > It also happens with CONFIG_SLAB. 
> > > (If someone wants to reproduce the issue, just run a kexec boot loop and
> > > the bug will occur after a few (~10) iterations.)
> > > 
> > 
> > Can you provide the kexec command line you are using and full kernel
> > log (mostly interested in kernel option).
> 
> /usr/sbin/kexec -l "/usr/src/linux/arch/x86/boot/bzImage" --append="root=PARTUUID=6d6a4009-3a90-40df-806a-e63f48189719 init=/sbin/minit rootflags=logbsize=262144 fbcon=rotate:3 drm_kms_helper.poll=0 quiet"
> /usr/sbin/kexec -e
> 
> (The loop happens after autologin in .zprofile:
> sleep 4 && sudo /etc/minit/ctrlaltdel/run
> (the last script kills, unmounts and then runs the two kexec commands
> above))

BTW I always see (mostly only on screen, sometimes in the logs):

[Firmware Bug]: cpu 2, try to use APIC500 (LVT offset 0) for vector 0x10400, but the register is already in use for vector 0xf9 on another cpu
[Firmware Bug]: cpu 2, IBS interrupt offset 0 not available (MSRC001103A=0x0000000000000100)
[Firmware Bug]: using offset 1 for IBS interrupts
[Firmware Bug]: workaround enabled for IBS LVT offset
perf: AMD IBS detected (0x0000001f) 

But I hope that it is only a harmless warning. 
(perf Instruction-Based Sampling)

Robert?

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
