Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2B56B006E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 04:46:35 -0500 (EST)
Received: by ggnq1 with SMTP id q1so1785ggn.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 01:46:30 -0800 (PST)
Message-ID: <1321955185.2474.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 10:46:25 +0100
In-Reply-To: <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	 <alpine.DEB.2.00.1111212105330.19606@router.home>
	 <20111122084513.GA1688@x4.trippels.de>
	 <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Christoph Lameter <cl@linux.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Le mardi 22 novembre 2011 A  10:38 +0100, Eric Dumazet a A(C)crit :

> Wait a minute
> 
> You trigger this using slabinfo looping or something ?
> 
> Bug is in slabinfo then, dont use it, and see if bug triggers.
> 
> Given slub is now lockless, validate_slab_slab() is probably very wrong
> these days.
> 

I trigger a bug in less than 10 secondes, with this running while a
"make -j16 " kernel build is run.

while :; do slabinfo -v; done


[42593.070289] =============================================================================
[42593.070445] BUG kmalloc-192: Wrong object count. Counter is 12 but counted were 13
[42593.070599] -----------------------------------------------------------------------------
[42593.070600] 
[42593.070822] INFO: Slab 0xffffea00046f4400 objects=42 used=12 fp=0xffff88011bd10f00 flags=0x60000000004081
[42593.070977] Pid: 5632, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42593.070979] Call Trace:
[42593.070987]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42593.070990]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42593.070993]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42593.071000]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42593.071003]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42593.071005]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42593.071010]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42593.071013]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42593.071015]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42593.071019]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42593.071021] FIX kmalloc-192: Object count adjusted.
[42605.106241] =============================================================================
[42605.106405] BUG kmalloc-32: Wrong object count. Counter is 53 but counted were 59
[42605.106558] -----------------------------------------------------------------------------
[42605.106560] 
[42605.106787] INFO: Slab 0xffffea00046f8c00 objects=128 used=49 fp=0xffff88011be30660 flags=0x60000000000081
[42605.106950] Pid: 8545, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42605.106952] Call Trace:
[42605.106962]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42605.106967]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42605.106970]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42605.106974]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42605.106977]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42605.106983]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42605.106988]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42605.106991]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42605.106998]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42605.107001] FIX kmalloc-32: Object count adjusted.
[42605.109228] =============================================================================
[42605.109389] BUG kmalloc-192: Wrong object count. Counter is 19 but counted were 25
[42605.109541] -----------------------------------------------------------------------------
[42605.109543] 
[42605.109785] INFO: Slab 0xffffea0001ef2600 objects=42 used=13 fp=0xffff88007bc98300 flags=0x10000000004081
[42605.109944] Pid: 8545, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42605.109946] Call Trace:
[42605.109956]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42605.109961]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42605.109965]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42605.109969]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42605.109972]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42605.109977]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42605.109982]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42605.109985]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42605.109991]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42605.109994] FIX kmalloc-192: Object count adjusted.
[42605.165152] =============================================================================
[42605.165316] BUG kmalloc-32: Wrong object count. Counter is 51 but counted were 41
[42605.165472] -----------------------------------------------------------------------------
[42605.165474] 
[42605.165704] INFO: Slab 0xffffea00046f8c00 objects=128 used=51 fp=0xffff88011be304c0 flags=0x60000000000081
[42605.165866] Pid: 8588, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42605.165869] Call Trace:
[42605.165879]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42605.165884]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42605.165888]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42605.165892]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42605.165895]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42605.165901]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42605.165906]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42605.165909]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42605.165916]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42605.165919] FIX kmalloc-32: Object count adjusted.
[42605.694221] =============================================================================
[42605.694381] BUG shared_policy_node: Wrong object count. Counter is 55 but counted were 56
[42605.694537] -----------------------------------------------------------------------------
[42605.694540] 
[42605.694781] INFO: Slab 0xffffea00046f0200 objects=85 used=55 fp=0xffff88011bc08510 flags=0x60000000000081
[42605.694942] Pid: 8812, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42605.694944] Call Trace:
[42605.694952]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42605.694957]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42605.694960]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42605.694967]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42605.694971]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42605.694975]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42605.694980]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42605.694985]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42605.694988]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42605.694993]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42605.694996] FIX shared_policy_node: Object count adjusted.
[42605.767360] =============================================================================
[42605.767521] BUG shared_policy_node: Wrong object count. Counter is 56 but counted were 55
[42605.767676] -----------------------------------------------------------------------------
[42605.767677] 
[42605.767903] INFO: Slab 0xffffea00046f0200 objects=85 used=56 fp=0xffff88011bc08510 flags=0x60000000000081
[42605.768063] Pid: 8833, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42605.768065] Call Trace:
[42605.768075]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42605.768079]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42605.768083]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42605.768086]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42605.768090]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42605.768094]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42605.768099]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42605.768101]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42605.768106]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42605.768109] FIX shared_policy_node: Object count adjusted.
[42606.357049] =============================================================================
[42606.357208] BUG vm_area_struct: Wrong object count. Counter is 20 but counted were 26
[42606.357365] -----------------------------------------------------------------------------
[42606.357367] 
[42606.357600] INFO: Slab 0xffffea00046f6d00 objects=46 used=20 fp=0xffff88011bdb53f0 flags=0x60000000004081
[42606.357762] Pid: 9146, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42606.357764] Call Trace:
[42606.357772]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42606.357776]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42606.357780]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42606.357783]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42606.357787]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42606.357791]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42606.357796]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42606.357799]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42606.357805]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42606.357808] FIX vm_area_struct: Object count adjusted.
[42607.719968] =============================================================================
[42607.720123] BUG kmalloc-128: Wrong object count. Counter is 15 but counted were 16
[42607.720271] -----------------------------------------------------------------------------
[42607.720272] 
[42607.720495] INFO: Slab 0xffffea00046f5980 objects=32 used=15 fp=0xffff88011bd66400 flags=0x60000000000081
[42607.720649] Pid: 9403, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42607.720651] Call Trace:
[42607.720657]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42607.720660]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42607.720663]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42607.720665]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42607.720667]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42607.720671]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42607.720674]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42607.720676]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42607.720680]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42607.720682] FIX kmalloc-128: Object count adjusted.
[42607.788584] =============================================================================
[42607.788749] BUG kmalloc-128: Wrong object count. Counter is 15 but counted were 14
[42607.788915] -----------------------------------------------------------------------------
[42607.788917] 
[42607.789148] INFO: Slab 0xffffea00046f5980 objects=32 used=15 fp=0xffff88011bd66d00 flags=0x60000000000081
[42607.789312] Pid: 9425, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42607.789314] Call Trace:
[42607.789325]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42607.789330]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42607.789334]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42607.789338]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42607.789341]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42607.789347]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42607.789352]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42607.789355]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42607.789362]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42607.789365] FIX kmalloc-128: Object count adjusted.
[42607.995101] =============================================================================
[42607.995267] BUG shared_policy_node: Wrong object count. Counter is 69 but counted were 70
[42607.995426] -----------------------------------------------------------------------------
[42607.995428] 
[42607.995659] INFO: Slab 0xffffea0001e97880 objects=85 used=69 fp=0xffff88007a5e2270 flags=0x10000000000081
[42607.995819] Pid: 9429, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42607.995822] Call Trace:
[42607.995833]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42607.995838]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42607.995842]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42607.995847]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42607.995850]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42607.995856]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42607.995861]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42607.995864]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42607.995871]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42607.995874] FIX shared_policy_node: Object count adjusted.
[42610.796510] =============================================================================
[42610.796675] BUG kmalloc-32: Wrong object count. Counter is 72 but counted were 78
[42610.796833] -----------------------------------------------------------------------------
[42610.796835] 
[42610.797068] INFO: Slab 0xffffea0001f59880 objects=128 used=71 fp=0xffff88007d6625c0 flags=0x10000000000081
[42610.797231] Pid: 10020, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42610.797234] Call Trace:
[42610.797244]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42610.797249]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42610.797253]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42610.797256]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42610.797260]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42610.797265]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42610.797271]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42610.797274]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42610.797280]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42610.797283] FIX kmalloc-32: Object count adjusted.
[42610.867763] =============================================================================
[42610.867928] BUG kmalloc-32: Wrong object count. Counter is 52 but counted were 45
[42610.868084] -----------------------------------------------------------------------------
[42610.868086] 
[42610.868325] INFO: Slab 0xffffea0001f59880 objects=128 used=52 fp=0xffff88007d662580 flags=0x10000000000081
[42610.868489] Pid: 10037, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42610.868491] Call Trace:
[42610.868501]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42610.868505]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42610.868509]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42610.868513]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42610.868516]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42610.868522]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42610.868527]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42610.868530]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42610.868537]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42610.868540] FIX kmalloc-32: Object count adjusted.
[42613.580115] =============================================================================
[42613.580285] BUG kmalloc-192: Wrong object count. Counter is 7 but counted were 16
[42613.580436] -----------------------------------------------------------------------------
[42613.580438] 
[42613.580667] INFO: Slab 0xffffea0001ef0c80 objects=42 used=7 fp=0xffff88007bc32600 flags=0x10000000004081
[42613.580825] Pid: 10700, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42613.580827] Call Trace:
[42613.580837]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42613.580842]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42613.580845]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42613.580849]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42613.580852]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42613.580857]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42613.580862]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42613.580865]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42613.580870]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42613.580873] FIX kmalloc-192: Object count adjusted.
[42614.157835] =============================================================================
[42614.157992] BUG kmalloc-192: Wrong object count. Counter is 1 but counted were 4
[42614.159747] -----------------------------------------------------------------------------
[42614.159749] 
[42614.159978] INFO: Slab 0xffffea0001e98980 objects=42 used=1 fp=0xffff88007a626900 flags=0x10000000004081
[42614.160135] Pid: 10879, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42614.160138] Call Trace:
[42614.160146]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42614.160149]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42614.160153]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42614.160156]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42614.160159]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42614.160164]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42614.160168]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42614.160171]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42614.160176]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42614.160179] FIX kmalloc-192: Object count adjusted.
[42614.870334] =============================================================================
[42614.870497] BUG kmalloc-64: Wrong object count. Counter is 55 but counted were 56
[42614.870651] -----------------------------------------------------------------------------
[42614.870653] 
[42614.870884] INFO: Slab 0xffffea0001ec7400 objects=64 used=54 fp=0xffff88007b1d0800 flags=0x10000000000081
[42614.871046] Pid: 11064, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42614.871048] Call Trace:
[42614.871058]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42614.871063]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42614.871067]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42614.871071]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42614.871075]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42614.871081]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42614.871086]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42614.871090]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42614.871096]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42614.871099] FIX kmalloc-64: Object count adjusted.
[42615.644506] =============================================================================
[42615.644668] BUG shared_policy_node: Wrong object count. Counter is 52 but counted were 55
[42615.644824] -----------------------------------------------------------------------------
[42615.644826] 
[42615.645055] INFO: Slab 0xffffea0001f02340 objects=85 used=51 fp=0xffff88007c08da20 flags=0x10000000000081
[42615.645229] Pid: 11349, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42615.645231] Call Trace:
[42615.645239]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42615.645243]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42615.645247]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42615.645251]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42615.645255]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42615.645259]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42615.645264]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42615.645267]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42615.645272]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42615.645275] FIX shared_policy_node: Object count adjusted.
[42615.714092] =============================================================================
[42615.714255] BUG shared_policy_node: Wrong object count. Counter is 33 but counted were 29
[42615.714413] -----------------------------------------------------------------------------
[42615.714415] 
[42615.714646] INFO: Slab 0xffffea0001f02340 objects=85 used=33 fp=0xffff88007c08d0c0 flags=0x10000000000081
[42615.714808] Pid: 11376, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42615.714810] Call Trace:
[42615.714820]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42615.714825]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42615.714829]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42615.714833]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42615.714836]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42615.714841]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42615.714845]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42615.714848]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42615.714853]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42615.714856] FIX shared_policy_node: Object count adjusted.
[42616.120500] =============================================================================
[42616.120660] BUG anon_vma: Wrong object count. Counter is 37 but counted were 38
[42616.120812] -----------------------------------------------------------------------------
[42616.120814] 
[42616.121040] INFO: Slab 0xffffea0001f56440 objects=56 used=29 fp=0xffff88007d591dc8 flags=0x10000000000081
[42616.121200] Pid: 11487, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42616.121202] Call Trace:
[42616.121210]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42616.121214]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42616.121218]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42616.121222]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42616.121225]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42616.121230]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42616.121234]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42616.121237]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42616.121243]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42616.121246] FIX anon_vma: Object count adjusted.
[42616.187602] =============================================================================
[42616.187763] BUG anon_vma: Wrong object count. Counter is 38 but counted were 29
[42616.187920] -----------------------------------------------------------------------------
[42616.187922] 
[42616.188154] INFO: Slab 0xffffea0001f56440 objects=56 used=38 fp=0xffff88007d591dc8 flags=0x10000000000081
[42616.188318] Pid: 11554, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42616.188320] Call Trace:
[42616.188328]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42616.188332]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42616.188335]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42616.188339]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42616.188343]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42616.188347]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42616.188352]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42616.188355]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42616.188361]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42616.188364] FIX anon_vma: Object count adjusted.
[42616.615663] =============================================================================
[42616.615829] BUG files_cache: Wrong object count. Counter is 4 but counted were 5
[42616.615983] -----------------------------------------------------------------------------
[42616.615985] 
[42616.616214] INFO: Slab 0xffffea0001e27000 objects=46 used=4 fp=0xffff8800789c0b00 flags=0x10000000004081
[42616.616377] Pid: 11643, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42616.616380] Call Trace:
[42616.616391]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42616.616396]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42616.616400]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42616.616404]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42616.616407]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42616.616413]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42616.616419]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42616.616423]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42616.616430]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42616.616433] FIX files_cache: Object count adjusted.
[42618.356527] =============================================================================
[42618.356689] BUG mm_struct: Wrong object count. Counter is 3 but counted were 4
[42618.356848] -----------------------------------------------------------------------------
[42618.356850] 
[42618.357083] INFO: Slab 0xffffea00046f3800 objects=23 used=3 fp=0xffff88011bce1b80 flags=0x60000000004081
[42618.357244] Pid: 12232, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42618.357247] Call Trace:
[42618.357255]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42618.357259]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42618.357263]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42618.357267]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42618.357271]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42618.357276]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42618.357281]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42618.357284]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42618.357290]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42618.357293] FIX mm_struct: Object count adjusted.
[42618.427688] =============================================================================
[42618.427849] BUG mm_struct: Wrong object count. Counter is 4 but counted were 3
[42618.428018] -----------------------------------------------------------------------------
[42618.428019] 
[42618.428250] INFO: Slab 0xffffea00046f3800 objects=23 used=4 fp=0xffff88011bce1b80 flags=0x60000000004081
[42618.428414] Pid: 12255, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42618.428416] Call Trace:
[42618.428424]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42618.428429]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42618.428433]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42618.428437]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42618.428441]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42618.428446]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42618.428451]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42618.428454]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42618.428458]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42618.428461] FIX mm_struct: Object count adjusted.
[42619.289348] =============================================================================
[42619.289514] BUG files_cache: Wrong object count. Counter is 4 but counted were 5
[42619.289670] -----------------------------------------------------------------------------
[42619.289671] 
[42619.289903] INFO: Slab 0xffffea000472e000 objects=46 used=3 fp=0xffff88011cb87bc0 flags=0x60000000004081
[42619.290066] Pid: 12491, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42619.290069] Call Trace:
[42619.290076]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42619.290081]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42619.290084]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42619.290088]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42619.290092]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42619.290096]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42619.290101]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42619.290104]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42619.290109]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42619.290112] FIX files_cache: Object count adjusted.
[42619.358478] =============================================================================
[42619.358655] BUG files_cache: Wrong object count. Counter is 5 but counted were 3
[42619.358810] -----------------------------------------------------------------------------
[42619.358812] 
[42619.359043] INFO: Slab 0xffffea000472e000 objects=46 used=5 fp=0xffff88011cb87bc0 flags=0x60000000004081
[42619.359205] Pid: 12517, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42619.359208] Call Trace:
[42619.359215]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42619.359219]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42619.359223]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42619.359227]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42619.359230]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42619.359235]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42619.359240]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42619.359243]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42619.359248]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42619.359251] FIX files_cache: Object count adjusted.
[42620.247231] =============================================================================
[42620.247390] BUG vm_area_struct: Wrong object count. Counter is 33 but counted were 34
[42620.247542] -----------------------------------------------------------------------------
[42620.247544] 
[42620.247771] INFO: Slab 0xffffea0001f27d80 objects=46 used=30 fp=0xffff88007c9f6bb0 flags=0x10000000004081
[42620.247928] Pid: 12799, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42620.247930] Call Trace:
[42620.247937]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42620.247941]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42620.247944]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42620.247947]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42620.247950]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42620.247955]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42620.247958]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42620.247961]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42620.247966]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42620.247968] FIX vm_area_struct: Object count adjusted.
[42620.316231] =============================================================================
[42620.316394] BUG vm_area_struct: Wrong object count. Counter is 34 but counted were 30
[42620.316550] -----------------------------------------------------------------------------
[42620.316552] 
[42620.316786] INFO: Slab 0xffffea0001f27d80 objects=46 used=34 fp=0xffff88007c9f6bb0 flags=0x10000000004081
[42620.316949] Pid: 12836, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42620.316952] Call Trace:
[42620.316962]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42620.316966]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42620.316970]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42620.316973]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42620.316977]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42620.316982]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42620.316987]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42620.316990]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42620.316997]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42620.316999] FIX vm_area_struct: Object count adjusted.
[42620.873381] =============================================================================
[42620.873545] BUG Acpi-Namespace: Wrong object count. Counter is 1 but counted were 2
[42620.873701] -----------------------------------------------------------------------------
[42620.873703] 
[42620.873936] INFO: Slab 0xffffea00046f08c0 objects=102 used=1 fp=0xffff88011bc23fc8 flags=0x60000000000081
[42620.874100] Pid: 12988, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42620.874103] Call Trace:
[42620.874110]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42620.874117]  [<ffffffff8128bd99>] ? free_cpumask_var+0x9/0x10
[42620.874121]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42620.874124]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42620.874127]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42620.874131]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42620.874135]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42620.874140]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42620.874143]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42620.874148]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42620.874151] FIX Acpi-Namespace: Object count adjusted.
[42620.924386] =============================================================================
[42620.924541] BUG Acpi-Namespace: Wrong object count. Counter is 2 but counted were 1
[42620.924692] -----------------------------------------------------------------------------
[42620.924693] 
[42620.924915] INFO: Slab 0xffffea00046f08c0 objects=102 used=2 fp=0xffff88011bc23fc8 flags=0x60000000000081
[42620.925069] Pid: 13027, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42620.925071] Call Trace:
[42620.925078]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42620.925083]  [<ffffffff8128bd99>] ? free_cpumask_var+0x9/0x10
[42620.925085]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42620.925088]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42620.925090]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42620.925093]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42620.925096]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42620.925100]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42620.925102]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42620.925106]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42620.925108] FIX Acpi-Namespace: Object count adjusted.
[42622.286888] =============================================================================
[42622.287046] BUG kmalloc-32: Wrong object count. Counter is 35 but counted were 36
[42622.287208] -----------------------------------------------------------------------------
[42622.287209] 
[42622.287429] INFO: Slab 0xffffea0001f54500 objects=128 used=22 fp=0xffff88007d514ae0 flags=0x10000000000081
[42622.287584] Pid: 13338, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42622.287585] Call Trace:
[42622.287592]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42622.287595]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42622.287597]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42622.287600]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42622.287602]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42622.287606]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42622.287609]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42622.287611]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42622.287615]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42622.287617] FIX kmalloc-32: Object count adjusted.
[42622.345596] =============================================================================
[42622.345757] BUG kmalloc-32: Wrong object count. Counter is 32 but counted were 18
[42622.345912] -----------------------------------------------------------------------------
[42622.345914] 
[42622.346144] INFO: Slab 0xffffea0001f54500 objects=128 used=31 fp=0xffff88007d514a80 flags=0x10000000000081
[42622.346309] Pid: 13352, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42622.346311] Call Trace:
[42622.346319]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42622.346323]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42622.346327]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42622.346330]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42622.346334]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42622.346339]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42622.346343]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42622.346346]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42622.346352]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42622.346355] FIX kmalloc-32: Object count adjusted.
[42622.414077] =============================================================================
[42622.414240] BUG kmalloc-32: Wrong object count. Counter is 17 but counted were 16
[42622.414397] -----------------------------------------------------------------------------
[42622.414399] 
[42622.414636] INFO: Slab 0xffffea0001f54500 objects=128 used=17 fp=0xffff88007d514200 flags=0x10000000000081
[42622.414798] Pid: 13379, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42622.414801] Call Trace:
[42622.414810]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42622.414814]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42622.414818]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42622.414822]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42622.414826]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42622.414831]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42622.414835]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42622.414839]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42622.414844]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42622.414847] FIX kmalloc-32: Object count adjusted.
[42628.657791] =============================================================================
[42628.657953] BUG kmalloc-192: Wrong object count. Counter is 6 but counted were 8
[42628.659705] -----------------------------------------------------------------------------
[42628.659708] 
[42628.659939] INFO: Slab 0xffffea0004251d00 objects=42 used=4 fp=0xffff8801094755c0 flags=0x60000000004081
[42628.660103] Pid: 14941, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42628.660105] Call Trace:
[42628.660113]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42628.660118]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42628.660121]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42628.660125]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42628.660129]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42628.660134]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42628.660139]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42628.660142]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42628.660148]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42628.660151] FIX kmalloc-192: Object count adjusted.
[42628.878121] =============================================================================
[42628.878293] BUG kmalloc-256: Wrong object count. Counter is 23 but counted were 24
[42628.878450] -----------------------------------------------------------------------------
[42628.878452] 
[42628.878684] INFO: Slab 0xffffea0001f3e900 objects=32 used=23 fp=0xffff88007cfa4600 flags=0x10000000004081
[42628.878848] Pid: 14996, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42628.878850] Call Trace:
[42628.878860]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42628.878865]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42628.878869]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42628.878872]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42628.878875]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42628.878881]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42628.878887]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42628.878890]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42628.878896]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42628.878899] FIX kmalloc-256: Object count adjusted.
[42635.424636] =============================================================================
[42635.424797] BUG selinux_inode_security: Wrong object count. Counter is 44 but counted were 45
[42635.424955] -----------------------------------------------------------------------------
[42635.424957] 
[42635.425202] INFO: Slab 0xffffea0001ef31c0 objects=56 used=44 fp=0xffff88007bcc7438 flags=0x10000000000081
[42635.425373] Pid: 16327, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42635.425375] Call Trace:
[42635.425385]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42635.425392]  [<ffffffff8128bd99>] ? free_cpumask_var+0x9/0x10
[42635.425396]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42635.425400]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42635.425404]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42635.425408]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42635.425413]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42635.425418]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42635.425422]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42635.425427]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42635.425430] FIX selinux_inode_security: Object count adjusted.
[42640.824909] =============================================================================
[42640.825068] BUG kmalloc-192: Wrong object count. Counter is 5 but counted were 6
[42640.825221] -----------------------------------------------------------------------------
[42640.825222] 
[42640.825447] INFO: Slab 0xffffea00046fa100 objects=42 used=5 fp=0xffff88011be85a40 flags=0x60000000004081
[42640.825606] Pid: 17630, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42640.825609] Call Trace:
[42640.825617]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42640.825621]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42640.825625]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42640.825628]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42640.825632]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42640.825637]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42640.825642]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42640.825645]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42640.825650]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42640.825653] FIX kmalloc-192: Object count adjusted.
[42648.728040] =============================================================================
[42648.728199] BUG kmalloc-64: Wrong object count. Counter is 39 but counted were 40
[42648.728347] -----------------------------------------------------------------------------
[42648.728348] 
[42648.728579] INFO: Slab 0xffffea0004723400 objects=64 used=37 fp=0xffff88011c8d0ec0 flags=0x60000000000081
[42648.728735] Pid: 19370, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42648.728737] Call Trace:
[42648.728745]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42648.728748]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42648.728751]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42648.728753]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42648.728756]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42648.728760]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42648.728764]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42648.728766]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42648.728771]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42648.728772] FIX kmalloc-64: Object count adjusted.
[42648.774479] =============================================================================
[42648.774638] BUG kmalloc-64: Wrong object count. Counter is 39 but counted were 36
[42648.774790] -----------------------------------------------------------------------------
[42648.774792] 
[42648.775018] INFO: Slab 0xffffea0004723400 objects=64 used=39 fp=0xffff88011c8d0600 flags=0x60000000000081
[42648.775174] Pid: 19381, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42648.775176] Call Trace:
[42648.775187]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42648.775191]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42648.775195]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42648.775198]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42648.775202]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42648.775208]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42648.775212]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42648.775215]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42648.775222]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42648.775224] FIX kmalloc-64: Object count adjusted.
[42650.005252] =============================================================================
[42650.005415] BUG kmalloc-16: Wrong object count. Counter is 62 but counted were 63
[42650.005583] -----------------------------------------------------------------------------
[42650.005585] 
[42650.005817] INFO: Slab 0xffffea0001f57c80 objects=256 used=47 fp=0xffff88007d5f23e0 flags=0x10000000000081
[42650.005981] Pid: 19669, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42650.005983] Call Trace:
[42650.005991]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42650.005996]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42650.005999]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42650.006003]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42650.006006]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42650.006011]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42650.006015]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42650.006018]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42650.006023]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42650.006026] FIX kmalloc-16: Object count adjusted.
[42650.283404] =============================================================================
[42650.283571] BUG kmalloc-16: Wrong object count. Counter is 19 but counted were 21
[42650.283724] -----------------------------------------------------------------------------
[42650.283726] 
[42650.283954] INFO: Slab 0xffffea0004728a80 objects=256 used=14 fp=0xffff88011ca2a6a0 flags=0x60000000000081
[42650.284116] Pid: 19698, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42650.284118] Call Trace:
[42650.284129]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42650.284134]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42650.284138]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42650.284141]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42650.284144]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42650.284150]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42650.284156]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42650.284159]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42650.284166]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42650.284169] FIX kmalloc-16: Object count adjusted.
[42650.700060] =============================================================================
[42650.700219] BUG kmalloc-64: Wrong object count. Counter is 32 but counted were 33
[42650.700372] -----------------------------------------------------------------------------
[42650.700373] 
[42650.700601] INFO: Slab 0xffffea00044fe380 objects=64 used=32 fp=0xffff880113f8e700 flags=0x60000000000081
[42650.700761] Pid: 19863, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42650.700764] Call Trace:
[42650.700773]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42650.700778]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42650.700782]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42650.700786]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42650.700790]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42650.700795]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42650.700801]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42650.700803]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42650.700810]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42650.700813] FIX kmalloc-64: Object count adjusted.
[42650.770200] =============================================================================
[42650.770364] BUG kmalloc-64: Wrong object count. Counter is 33 but counted were 32
[42650.770520] -----------------------------------------------------------------------------
[42650.770522] 
[42650.770753] INFO: Slab 0xffffea00044fe380 objects=64 used=33 fp=0xffff880113f8e700 flags=0x60000000000081
[42650.770933] Pid: 19872, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42650.770935] Call Trace:
[42650.770946]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42650.770951]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42650.770954]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42650.770963]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42650.770967]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42650.770971]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42650.770977]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42650.770982]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42650.770985]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42650.770991]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42650.770994] FIX kmalloc-64: Object count adjusted.
[42651.712140] =============================================================================
[42651.712302] BUG kmalloc-16: Wrong object count. Counter is 9 but counted were 10
[42651.712456] -----------------------------------------------------------------------------
[42651.712458] 
[42651.712686] INFO: Slab 0xffffea0001f158c0 objects=256 used=3 fp=0xffff88007c563070 flags=0x10000000000081
[42651.712848] Pid: 20076, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42651.712851] Call Trace:
[42651.712859]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42651.712863]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42651.712867]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42651.712870]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42651.712873]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42651.712878]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42651.712882]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42651.712886]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42651.712891]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42651.712894] FIX kmalloc-16: Object count adjusted.
[42652.605163] =============================================================================
[42652.605329] BUG kmalloc-128: Wrong object count. Counter is 27 but counted were 28
[42652.605486] -----------------------------------------------------------------------------
[42652.605488] 
[42652.605719] INFO: Slab 0xffffea00047299c0 objects=32 used=27 fp=0xffff88011ca67c80 flags=0x60000000000081
[42652.605882] Pid: 20247, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42652.605884] Call Trace:
[42652.605893]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42652.605897]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42652.605901]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42652.605905]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42652.605908]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42652.605913]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42652.605918]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42652.605921]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42652.605926]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42652.605929] FIX kmalloc-128: Object count adjusted.
[42652.675463] =============================================================================
[42652.675626] BUG kmalloc-128: Wrong object count. Counter is 28 but counted were 27
[42652.675782] -----------------------------------------------------------------------------
[42652.675784] 
[42652.676014] INFO: Slab 0xffffea00047299c0 objects=32 used=28 fp=0xffff88011ca67c80 flags=0x60000000000081
[42652.676186] Pid: 20268, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42652.676189] Call Trace:
[42652.676197]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42652.676201]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42652.676205]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42652.676208]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42652.676212]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42652.676216]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42652.676221]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42652.676224]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42652.676229]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42652.676232] FIX kmalloc-128: Object count adjusted.
[42653.190925] =============================================================================
[42653.191102] BUG files_cache: Wrong object count. Counter is 5 but counted were 6
[42653.191259] -----------------------------------------------------------------------------
[42653.191261] 
[42653.191493] INFO: Slab 0xffffea000472b600 objects=46 used=5 fp=0xffff88011caddd80 flags=0x60000000004081
[42653.191655] Pid: 20391, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42653.191658] Call Trace:
[42653.191668]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42653.191673]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42653.191677]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42653.191685]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42653.191689]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42653.191693]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42653.191699]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42653.191704]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42653.191707]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42653.191712]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42653.191716] FIX files_cache: Object count adjusted.
[42653.596810] =============================================================================
[42653.596973] BUG kmalloc-256: Wrong object count. Counter is 6 but counted were 7
[42653.597130] -----------------------------------------------------------------------------
[42653.597132] 
[42653.597366] INFO: Slab 0xffffea00046ea400 objects=32 used=5 fp=0xffff88011ba91d00 flags=0x60000000004081
[42653.597530] Pid: 20487, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42653.597533] Call Trace:
[42653.597541]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42653.597545]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42653.597548]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42653.597552]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42653.597555]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42653.597560]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42653.597564]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42653.597567]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42653.597572]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42653.597574] FIX kmalloc-256: Object count adjusted.
[42653.642975] =============================================================================
[42653.643130] BUG kmalloc-256: Wrong object count. Counter is 7 but counted were 5
[42653.643293] -----------------------------------------------------------------------------
[42653.643294] 
[42653.643530] INFO: Slab 0xffffea00046ea400 objects=32 used=7 fp=0xffff88011ba91d00 flags=0x60000000004081
[42653.643685] Pid: 20507, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42653.643687] Call Trace:
[42653.643693]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42653.643698]  [<ffffffff8128bd99>] ? free_cpumask_var+0x9/0x10
[42653.643701]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42653.643704]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42653.643706]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42653.643709]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42653.643712]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42653.643715]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42653.643717]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42653.643721]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42653.643723] FIX kmalloc-256: Object count adjusted.
[42657.456254] =============================================================================
[42657.456414] BUG mm_struct: Wrong object count. Counter is 9 but counted were 10
[42657.456567] -----------------------------------------------------------------------------
[42657.456569] 
[42657.456804] INFO: Slab 0xffffea0001f12e00 objects=23 used=9 fp=0xffff88007c4bd280 flags=0x10000000004081
[42657.456968] Pid: 21495, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42657.456970] Call Trace:
[42657.456978]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42657.456983]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42657.456987]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42657.456991]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42657.456995]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42657.456999]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42657.457005]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42657.457008]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42657.457013]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42657.457016] FIX mm_struct: Object count adjusted.
[42657.524588] =============================================================================
[42657.524749] BUG mm_struct: Wrong object count. Counter is 9 but counted were 8
[42657.524902] -----------------------------------------------------------------------------
[42657.524904] 
[42657.525138] INFO: Slab 0xffffea0001f12e00 objects=23 used=9 fp=0xffff88007c4bf380 flags=0x10000000004081
[42657.525298] Pid: 21519, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42657.525301] Call Trace:
[42657.525309]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42657.525313]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42657.525317]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42657.525321]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42657.525324]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42657.525329]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42657.525333]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42657.525337]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42657.525342]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42657.525345] FIX mm_struct: Object count adjusted.
[42657.996274] =============================================================================
[42657.996438] BUG selinux_inode_security: Wrong object count. Counter is 43 but counted were 44
[42657.998199] -----------------------------------------------------------------------------
[42657.998201] 
[42657.998432] INFO: Slab 0xffffea0004706f00 objects=56 used=40 fp=0xffff88011c1bc5a0 flags=0x60000000000081
[42657.998595] Pid: 21688, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42657.998597] Call Trace:
[42657.998604]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42657.998609]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42657.998613]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42657.998616]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42657.998620]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42657.998625]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42657.998629]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42657.998632]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42657.998637]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42657.998641] FIX selinux_inode_security: Object count adjusted.
[42658.066185] =============================================================================
[42658.066344] BUG selinux_inode_security: Wrong object count. Counter is 44 but counted were 40
[42658.066500] -----------------------------------------------------------------------------
[42658.066501] 
[42658.066729] INFO: Slab 0xffffea0004706f00 objects=56 used=44 fp=0xffff88011c1bc5a0 flags=0x60000000000081
[42658.066887] Pid: 21705, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42658.066890] Call Trace:
[42658.066898]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42658.066902]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42658.066906]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42658.066910]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42658.066913]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42658.066918]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42658.066923]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42658.066925]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42658.066930]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42658.066933] FIX selinux_inode_security: Object count adjusted.
[42663.708769] =============================================================================
[42663.708926] BUG kmalloc-512: Wrong object count. Counter is 9 but counted were 10
[42663.709078] -----------------------------------------------------------------------------
[42663.709080] 
[42663.709312] INFO: Slab 0xffffea00046f0e00 objects=32 used=9 fp=0xffff88011bc39e00 flags=0x60000000004081
[42663.709478] Pid: 22908, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42663.709481] Call Trace:
[42663.709489]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42663.709493]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42663.709496]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42663.709499]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42663.709503]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42663.709509]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42663.709514]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42663.709517]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42663.709524]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42663.709527] FIX kmalloc-512: Object count adjusted.
[42663.774783] =============================================================================
[42663.774941] BUG kmalloc-512: Wrong object count. Counter is 8 but counted were 7
[42663.775093] -----------------------------------------------------------------------------
[42663.775095] 
[42663.775330] INFO: Slab 0xffffea00046f0e00 objects=32 used=8 fp=0xffff88011bc39c00 flags=0x60000000004081
[42663.775488] Pid: 22957, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42663.775490] Call Trace:
[42663.775498]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42663.775502]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42663.775506]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42663.775513]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42663.775516]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42663.775520]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42663.775525]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42663.775529]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42663.775532]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42663.775537]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42663.775539] FIX kmalloc-512: Object count adjusted.
[42665.867898] =============================================================================
[42665.868058] BUG kmalloc-192: Wrong object count. Counter is 4 but counted were 5
[42665.868222] -----------------------------------------------------------------------------
[42665.868223] 
[42665.868454] INFO: Slab 0xffffea0001d00600 objects=42 used=4 fp=0xffff880074018840 flags=0x10000000004081
[42665.868612] Pid: 23309, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42665.868615] Call Trace:
[42665.868625]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42665.868629]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42665.868633]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42665.868637]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42665.868640]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42665.868645]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42665.868649]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42665.868652]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42665.868657]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42665.868660] FIX kmalloc-192: Object count adjusted.
[42667.279030] =============================================================================
[42667.279201] BUG kmalloc-32: Wrong object count. Counter is 48 but counted were 49
[42667.279356] -----------------------------------------------------------------------------
[42667.279358] 
[42667.279584] INFO: Slab 0xffffea0001f56480 objects=128 used=30 fp=0xffff88007d5925e0 flags=0x10000000000081
[42667.279744] Pid: 23597, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42667.279747] Call Trace:
[42667.279754]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42667.279759]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42667.279763]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42667.279767]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42667.279770]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42667.279774]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42667.279779]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42667.279782]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42667.279787]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42667.279790] FIX kmalloc-32: Object count adjusted.
[42667.349500] =============================================================================
[42667.349661] BUG kmalloc-32: Wrong object count. Counter is 45 but counted were 26
[42667.349819] -----------------------------------------------------------------------------
[42667.349820] 
[42667.350054] INFO: Slab 0xffffea0001f56480 objects=128 used=45 fp=0xffff88007d592900 flags=0x10000000000081
[42667.350216] Pid: 23667, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42667.350218] Call Trace:
[42667.350226]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42667.350230]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42667.350234]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42667.350237]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42667.350241]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42667.350245]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42667.350250]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42667.350253]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42667.350257]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42667.350260] FIX kmalloc-32: Object count adjusted.
[42670.139647] =============================================================================
[42670.139809] BUG kmalloc-32: Wrong object count. Counter is 11 but counted were 12
[42670.139967] -----------------------------------------------------------------------------
[42670.139968] 
[42670.140201] INFO: Slab 0xffffea0001f57280 objects=128 used=11 fp=0xffff88007d5cae40 flags=0x10000000000081
[42670.140365] Pid: 24137, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42670.140368] Call Trace:
[42670.140378]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42670.140382]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42670.140386]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42670.140390]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42670.140393]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42670.140398]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42670.140403]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42670.140406]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42670.140412]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42670.140415] FIX kmalloc-32: Object count adjusted.
[42674.564500] =============================================================================
[42674.564663] BUG kmalloc-192: Wrong object count. Counter is 3 but counted were 4
[42674.564820] -----------------------------------------------------------------------------
[42674.564822] 
[42674.565054] INFO: Slab 0xffffea0001f10000 objects=42 used=3 fp=0xffff88007c401080 flags=0x10000000004081
[42674.565218] Pid: 24985, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42674.565221] Call Trace:
[42674.565231]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42674.565236]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42674.565240]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42674.565244]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42674.565247]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42674.565253]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42674.565258]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42674.565261]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42674.565268]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42674.565271] FIX kmalloc-192: Object count adjusted.
[42678.865745] =============================================================================
[42678.865900] BUG vm_area_struct: Wrong object count. Counter is 20 but counted were 34
[42678.866051] -----------------------------------------------------------------------------
[42678.866052] 
[42678.866274] INFO: Slab 0xffffea000472fb00 objects=46 used=19 fp=0xffff88011cbed760 flags=0x60000000004081
[42678.866428] Pid: 25978, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42678.866430] Call Trace:
[42678.866436]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42678.866439]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42678.866442]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42678.866444]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42678.866447]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42678.866450]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42678.866454]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42678.866456]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42678.866460]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42678.866461] FIX vm_area_struct: Object count adjusted.
[42678.911513] =============================================================================
[42678.911668] BUG vm_area_struct: Wrong object count. Counter is 34 but counted were 19
[42678.911819] -----------------------------------------------------------------------------
[42678.911820] 
[42678.912042] INFO: Slab 0xffffea000472fb00 objects=46 used=34 fp=0xffff88011cbed760 flags=0x60000000004081
[42678.912196] Pid: 25983, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42678.912197] Call Trace:
[42678.912204]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42678.912207]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42678.912209]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42678.912215]  [<ffffffff816c923e>] ? _raw_spin_unlock_irqrestore+0xe/0x20
[42678.912218]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42678.912220]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42678.912224]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42678.912227]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42678.912229]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42678.912233]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42678.912235] FIX vm_area_struct: Object count adjusted.
[42680.366372] =============================================================================
[42680.366548] BUG kmalloc-96: Wrong object count. Counter is 32 but counted were 33
[42680.366702] -----------------------------------------------------------------------------
[42680.366704] 
[42680.366931] INFO: Slab 0xffffea0001f27080 objects=42 used=32 fp=0xffff88007c9c2c60 flags=0x10000000000081
[42680.367091] Pid: 26276, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42680.367094] Call Trace:
[42680.367103]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42680.367108]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42680.367112]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42680.367116]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42680.367120]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42680.367126]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42680.367131]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42680.367134]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42680.367141]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42680.367144] FIX kmalloc-96: Object count adjusted.
[42680.435088] =============================================================================
[42680.435246] BUG kmalloc-96: Wrong object count. Counter is 31 but counted were 30
[42680.435397] -----------------------------------------------------------------------------
[42680.435398] 
[42680.435630] INFO: Slab 0xffffea0001f27080 objects=42 used=31 fp=0xffff88007c9c2ea0 flags=0x10000000000081
[42680.435788] Pid: 26277, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42680.435791] Call Trace:
[42680.435801]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42680.435805]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42680.435809]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42680.435812]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42680.435815]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42680.435822]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42680.435827]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42680.435830]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42680.435836]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42680.435839] FIX kmalloc-96: Object count adjusted.
[42680.990846] =============================================================================
[42680.991011] BUG kmalloc-16: Wrong object count. Counter is 221 but counted were 223
[42680.991168] -----------------------------------------------------------------------------
[42680.991169] 
[42680.991402] INFO: Slab 0xffffea0001f28800 objects=256 used=220 fp=0xffff88007ca20510 flags=0x10000000000081
[42680.991574] Pid: 26401, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42680.991576] Call Trace:
[42680.991587]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42680.991592]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42680.991596]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42680.991600]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42680.991604]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42680.991610]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42680.991616]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42680.991619]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42680.991625]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42680.991628] FIX kmalloc-16: Object count adjusted.
[42681.344221] =============================================================================
[42681.344384] BUG kmalloc-192: Wrong object count. Counter is 3 but counted were 4
[42681.344541] -----------------------------------------------------------------------------
[42681.344543] 
[42681.344775] INFO: Slab 0xffffea0001ef4580 objects=42 used=3 fp=0xffff88007bd16cc0 flags=0x10000000004081
[42681.344939] Pid: 26485, comm: slabinfo Not tainted 3.2.0-rc2+ #142
[42681.344942] Call Trace:
[42681.344952]  [<ffffffff81127c66>] slab_err+0x76/0x90
[42681.344957]  [<ffffffff811293a4>] on_freelist+0x1c4/0x270
[42681.344961]  [<ffffffff8112a655>] validate_slab_slab+0x85/0x210
[42681.344965]  [<ffffffff8112be46>] validate_store+0xe6/0x210
[42681.344969]  [<ffffffff811272c1>] slab_attr_store+0x21/0x40
[42681.344974]  [<ffffffff811a8d19>] sysfs_write_file+0xf9/0x180
[42681.344980]  [<ffffffff81135c63>] vfs_write+0xb3/0x180
[42681.344983]  [<ffffffff81135f8a>] sys_write+0x4a/0x90
[42681.344989]  [<ffffffff816d112b>] system_call_fastpath+0x16/0x1b
[42681.344992] FIX kmalloc-192: Object count adjusted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
