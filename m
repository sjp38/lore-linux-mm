Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 53BD96B008A
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 03:01:46 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Fri, 10 Dec 2010 16:01:39 +0800
Subject: RE: [5/7,v8] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED8E3@shsmsx502.ccr.corp.intel.com>
References: <20101207010033.280301752@intel.com>
 <20101207010140.092555703@intel.com>
 <alpine.DEB.2.00.1012081334160.15658@chino.kir.corp.google.com>
 <4D00A345.6070100@kernel.org>
In-Reply-To: <4D00A345.6070100@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Ingo Molnar <mingo@elte.hu>, "Brown, Len" <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@sun.com>, "Li, Haicheng" <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

The unification numa code of 32 and 64 bit make the codes much simpler to m=
aintain. It is good direction.

I already rework this patch based on your unification numa code, add I add =
you in the CC list in my patch.

Thanks & Regards,
Shaohui


-----Original Message-----
From: Tejun Heo [mailto:tj@kernel.org]=20
Sent: Thursday, December 09, 2010 5:37 PM
To: David Rientjes
Cc: Zheng, Shaohui; Andrew Morton; linux-mm@kvack.org; linux-kernel@vger.ke=
rnel.org; haicheng.li@linux.intel.com; lethal@linux-sh.org; Andi Kleen; dav=
e@linux.vnet.ibm.com; Greg Kroah-Hartman; Ingo Molnar; Brown, Len; Yinghai =
Lu; Li, Haicheng
Subject: Re: [5/7,v8] NUMA Hotplug Emulator: Support cpu probe/release in x=
86_64

Hello,

On 12/08/2010 10:36 PM, David Rientjes wrote:
> On Tue, 7 Dec 2010, shaohui.zheng@intel.com wrote:
>=20
>> From: Shaohui Zheng <shaohui.zheng@intel.com>
>>
>> CPU physical hot-add/hot-remove are supported on some hardwares, and it=
=20
>> was already supported in current linux kernel. NUMA Hotplug Emulator pro=
vides
>> a mechanism to emulate the process with software method. It can be used =
for
>> testing or debuging purpose.
>>
>> CPU physical hotplug is different with logical CPU online/offline. Logic=
al
>> online/offline is controled by interface /sys/device/cpu/cpuX/online. CP=
U
>> hotplug emulator uses probe/release interface. It becomes possible to do=
 cpu
>> hotplug automation and stress
>>
>> Add cpu interface probe/release under sysfs for x86_64. User can use thi=
s
>> interface to emulate the cpu hot-add and hot-remove process.
>>
>> Directive:
>> *) Reserve CPU thru grub parameter like:
>> 	maxcpus=3D4
>>
>> the rest CPUs will not be initiliazed.=20
>>
>> *) Probe CPU
>> we can use the probe interface to hot-add new CPUs:
>> 	echo nid > /sys/devices/system/cpu/probe
>>
>> *) Release a CPU
>> 	echo cpu > /sys/devices/system/cpu/release
>>
>> A reserved CPU will be hot-added to the specified node.
>> 1) nid =3D=3D 0, the CPU will be added to the real node which the CPU
>> should be in
>> 2) nid !=3D 0, add the CPU to node nid even through it is a fake node.
>>
>=20
> This patch is undoubtedly going to conflict with Tejun's unification of=20
> the 32 and 64 bit NUMA boot paths, specifically the patch at=20
> http://marc.info/?l=3Dlinux-kernel&m=3D129087151912379.

Oh yeah, it definitely looks like it will collide with the unification
patch.  The problem is more fundamental than the actual patch
collisions tho.  During x86_32/64 merge, some parts were left unmerged
- some reflect actual differences between 32 and 64 but more were
probably because it was too much work.

These subtle diversions make the code unnecessarily complicated,
fragile and difficult to maintain, so, in general, I think we should
be heading toward unifying 32 and 64 unless the difference is caused
by actual hardware even when the feature or code might not be too
useful for 32bit.

So, the same thing holds for NUMA hotplug emulator.  32bit supports
NUMA and there already is 64bit only NUMA emulator.  I think it would
be much better if we take this chance to unify 32 and 64bit code paths
on this area rather than going further toward the wrong direction.

> Tejun, what's the status of that patchset posted on November 27?  Any=20
> comments about this change?

I don't know.  I pinged Ingo yesterday.  Ingo?

Thanks.

--=20
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
