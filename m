Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B05A6B0087
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 20:23:02 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Mon, 6 Dec 2010 09:22:54 +0800
Subject: RE: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF28B3BB8C31@shsmsx502.ccr.corp.intel.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com>
 <20101202002716.GA13693@shaohui>
 <alpine.DEB.2.00.1012011807190.13942@chino.kir.corp.google.com>
 <A24AE1FFE7AEC5489F83450EE98351BF288D88D2B8@shsmsx502.ccr.corp.intel.com>
 <alpine.DEB.2.00.1012021528170.6878@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1012021528170.6878@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <gregkh@suse.de>, "Li, Haicheng" <haicheng.li@intel.com>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

After introduce the per-node interface, the following directive can be avoi=
ded.

	echo '0x80000000,3' > /sys/kernel/debug/mem_hotplug/add_memory
	echo 'physical_addr=3D0x80000000 node_id=3D3' > /sys/kernel/debug/mem_hotp=
lug/add_memory

I already implemented a draft in another thread, and waiting for comments, =
thanks for the proposal.

Thanks & Regards,
Shaohui


-----Original Message-----
From: David Rientjes [mailto:rientjes@google.com]=20
Sent: Friday, December 03, 2010 7:34 AM
To: Zheng, Shaohui
Cc: Andrew Morton; linux-mm@kvack.org; linux-kernel@vger.kernel.org; lethal=
@linux-sh.org; Andi Kleen; Dave Hansen; Greg KH; Li, Haicheng
Subject: RE: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface f=
or memory probe

On Thu, 2 Dec 2010, Zheng, Shaohui wrote:

> Why should we add so many interfaces for memory hotplug emulation?

Because they are functionally different from real memory hotplug and we=20
want to support different configurations such as mapping memory to a=20
different node id or onlining physical nodes that don't exist.

They are in debugfs because the emulation, unlike real memory hotplug, is=20
used only for testing and debugging.

> If so, we should create both sysfs and debugfs=20
> entries for an online node, we are trying to add redundant code logic.
>=20

We do not need sysfs triggers for onlining a node, that already happens=20
automatically if the memory that is being onlined has a hotpluggable node=20
entry in the SRAT that has an offline node id.

> We need not make a simple thing such complicated, Simple is beautiful, I'=
d prefer to rename the mem_hotplug/probe=20
> interface as mem_hotplug/add_memory.
>=20
> 	/sys/kernel/debug/mem_hotplug/add_node (already exists)
> 	/sys/kernel/debug/mem_hotplug/add_memory (rename probe as add_memory)
>=20

No, add_memory would then require these bizarre lines that you've been=20
parsing like

	echo 'physical_addr=3D0x80000000 node_id=3D3' > /sys/kernel/debug/mem_hotp=
lug/add_memory

which is unnecessary if you introduce my proposal for per-node debugfs=20
directories similar to that under /sys/devices/system/node that is=20
extendable later if we add additional per-node triggers under=20
CONFIG_DEBUG_FS.

Adding /sys/kernel/debug/mem_hotplug/node2/add_memory that you write a=20
physical address to is a much more robust, simple, and extendable=20
interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
