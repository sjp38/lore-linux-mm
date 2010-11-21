Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BC796B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 10:14:48 -0500 (EST)
From: "Li, Haicheng" <haicheng.li@intel.com>
Date: Sun, 21 Nov 2010 23:14:24 +0800
Subject: RE: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
Message-ID: <789F9655DD1B8F43B48D77C5D30659732FE95E6E@shsmsx501.ccr.corp.intel.com>
References: <20101117020759.016741414@intel.com>
 <20101117021000.568681101@intel.com>
 <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
 <20101117075128.GA30254@shaohui>
 <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org>
 <20101118052750.GD2408@shaohui>
 <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com>
 <20101119003225.GB3327@shaohui>
 <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Fri, 19 Nov 2010, Shaohui Zheng wrote:
>=20
>> nr_node_ids is the possible node number. when we do regular memory
>> online, it is oline to a possible node, and it is already counted in
>> to nr_node_ids.=20
>>=20
>> if you increment nr_node_ids dynamically when node online, it causes
>> a lot of problems. Many data are initialized according to
>> nr_node_ids. That is our experience when we debug the emulator.
>>=20
>=20
> I think what we'll end up wanting to do is something like this, which
> adds=20
> a numa=3Dpossible=3D<N> parameter for x86; this will add an additional N
> possible nodes to node_possible_map that we can use to online later.=20
> It=20
> also adds a new /sys/devices/system/memory/add_node file which takes a
> typical "size@start" value to hot-add an emulated node.  For example,
> using "mem=3D2G numa=3Dpossible=3D1" on the command line and doing
> echo 128M@0x80000000" > /sys/devices/system/memory/add_node would
> hot-add=20
> a node of 128M.
>=20
> Comments?

Sorry for the late response as I'm in a biz trip recently.

David, your original concern is just about powerful/flexibility. I'm sure o=
ur implementation can better meets such requirments.

IMHO, I don't see any powerful/flexibility from your patch, compared to our=
 original implementation. you just make things more complex and mess.

Why not use "numa=3Dhide=3DN*size" as originally implemented?
- later you just need to online the node once you want. And it naturally/ex=
actly emulates the behavior that current HW provides.
- N is the possible node number. And we can use 128M as the default size fo=
r each hidden node if user doesn't specify a size.
- If user wants more mem for hidden node, he just needs specify the "size".
- besides, user can also use "mem=3D" to hide more mem and later use mem-ad=
d i/f to freely attach more mem to the hidden node during runtime.

Your patch introduces additional dependency on "mem=3D", but ours is simple=
 and flexibly compatible with "mem=3D" and "numa=3Demu".=20


-haicheng=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
