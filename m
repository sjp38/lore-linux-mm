Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 667D06B004A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 18:39:15 -0500 (EST)
Date: Wed, 24 Nov 2010 15:38:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 20702] New: Kernel bug, possible double free,
 effecting kernel.org machines
Message-Id: <20101124153839.57d2cdda.akpm@linux-foundation.org>
In-Reply-To: <4CED9EDC.9080306@kernel.org>
References: <bug-20702-10286@https.bugzilla.kernel.org/>
	<20101018134856.07478c0d.akpm@linux-foundation.org>
	<20101018211106.GA8912@core2.telecom.by>
	<4CED9EDC.9080306@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "J.H." <warthog9@kernel.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Kyle McMartin <kyle@mcmartin.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Nov 2010 15:25:16 -0800
"J.H." <warthog9@kernel.org> wrote:

> On 10/18/2010 02:11 PM, Alexey Dobriyan wrote:
> > On Mon, Oct 18, 2010 at 01:48:56PM -0700, Andrew Morton wrote:
> >>> Modules linked in: ocfs2 mptctl mptbase drbd lru_cache nfsd lockd nfs_acl
> >>> auth_rpcgss sunrpc ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm ocfs2_nodemanager
> >>> ocfs2_stackglue configfs cpufreq_ondemand powernow_k8 freq_table 8021q garp stp
> >>> llc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 xfs exportfs
> >>> tg3 hpwdt amd64_edac_mod i2c_amd756 i2c_core edac_core shpchp k8temp amd_rng
> >>> edac_mce_amd microcode pata_acpi ata_generic cciss pata_amd [last unloaded:
> >>> scsi_wait_scan]
> >>>
> >>> Pid: 1713, comm: snmpd Not tainted 2.6.34.7-56.fc13.x86_64 #1 /ProLiant DL385
> >>> G1
> >>> RIP: 0010:[<ffffffff811006d6>]  [<ffffffff811006d6>] kfree+0x5e/0xcb
> >>> RSP: 0018:ffff8801f6433df8  EFLAGS: 00010246
> >>> RAX: 0040000000000400 RBX: ffff8803ed0eb9b0 RCX: ffff8803e9c92340
> >>> RDX: ffffea0000000000 RSI: ffffea0003800000 RDI: ffff880100000002
> >>> RBP: ffff8801f6433e18 R08: ffff8803e9c92958 R09: 0000000000000000
> >>> R10: 0000000000000011 R11: 0000000000000246 R12: ffff880100000002
> >>> R13: ffffffff81125e27 R14: ffffffff8115dbdc R15: ffff8803dd19ea80
> >>> FS:  00007ff4a31917a0(0000) GS:ffff880207400000(0000) knlGS:00000000f76fa6d0
> >>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>> CR2: 00007ff4a31b2000 CR3: 00000001f6455000 CR4: 00000000000006e0
> >>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >>> Process snmpd (pid: 1713, threadinfo ffff8801f6432000, task ffff8801f5688000)
> >>> Stack:
> >>>  ffff8801f6433e18 ffff8803ed0eb9b0 ffff8803f61ec480 ffff8803ed0eb9b0
> >>> <0> ffff8801f6433e48 ffffffff81125e27 ffff8801f6433e38 ffff8803dd19ea80
> >>> <0> ffff8803ed0eb9b0 ffff8803e9c92940 ffff8801f6433e78 ffffffff8115dc10
> >>> Call Trace:
> >>>  [<ffffffff81125e27>] seq_release_private+0x28/0x44
> >>>  [<ffffffff8115dc10>] seq_release_net+0x34/0x3d
> >>>  [<ffffffff81155ada>] proc_reg_release+0xd3/0xf0
> >>>  [<ffffffff8110efbb>] __fput+0x12a/0x1dc
> >>>  [<ffffffff8110f087>] fput+0x1a/0x1c
> >>>  [<ffffffff8110c0f7>] filp_close+0x68/0x72
> >>>  [<ffffffff8110c19e>] sys_close+0x9d/0xd2
> >>>  [<ffffffff81009c72>] system_call_fastpath+0x16/0x1b
> >>> Code: ef ff 13 48 83 c3 08 48 83 3b 00 eb ec 49 83 fc 10 76 7d 4c 89 e7 e8 67
> >>> e4 ff ff 48 89 c6 48 8b 00 84 c0 78 14 66 a9 00 c0 75 04 <0f> 0b eb fe 48 89 f7
> >>> e8 66 36 fd ff eb 57 48 8b 4d 08 48 8b 7e 
> >>> RIP  [<ffffffff811006d6>] kfree+0x5e/0xcb
> >>>  RSP <ffff8801f6433df8>
> >>> ---[ end trace 1a4b1fd758dd1fdb ]---
> >>
> >> But then again, that's a procfs trace, not a sysfs trace.
> >>
> >> proc_reg_release() makes my brain hurt.
> > 
> > That complex code triggers only when module unloads and removes
> > its /proc entries.
> > 
> > Just to confirm, rmmod wasn't executed, last module still is
> > scsi_wait_scan from boot sequence?
> 
> Bumping on this as I'm still seeing this, and hit it again today.  Since
> this seems to be happening more, is there anything I can add for
> debugging to help with this?
> 
> Getting back to Alexey's comments.  No there were not modules loaded or
> unloaded, and I have no idea why scsi_wait_scan would have been loaded
> or unloaded.
> 
> Is today's trace (From D2):
> 
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:2835!

That's

	BUG_ON(!PageCompound(page));

?

> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/kernel/mm/ksm/run
> CPU 0
> Modules linked in: ocfs2 mptctl mptbase ipmi_devintf drbd lru_cache nfsd
> lockd nfs_acl auth_rpcgss sunrpc ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm
> ocfs2_nodemanager ocfs2_stackglue configfs 8021q garp stp llc
> ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 xfs
> exportfs bnx2 ipmi_si ipmi_msghandler iTCO_wdt power_meter
> iTCO_vendor_support microcode hpwdt serio_raw cciss hpsa radeon ttm
> drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: speedstep_lib]
> 
> Pid: 2375, comm: snmpd Not tainted 2.6.34.7-61.korg.fc13.x86_64 #1
> /ProLiant DL380 G6
> RIP: 0010:[<ffffffff811006d6>]  [<ffffffff811006d6>] kfree+0x5e/0xcb
> RSP: 0018:ffff88080c12fdf8  EFLAGS: 00010246
> RAX: 004000000010003c RBX: ffff8803e5a26e30 RCX: ffff880400d40c40
> RDX: ffffea0000000000 RSI: ffffea000e000000 RDI: ffff880400000001
> RBP: ffff88080c12fe18 R08: ffff880400d405d8 R09: 0000000000000000
> R10: 0000000000000013 R11: 0000000000000246 R12: ffff880400000001
> R13: ffffffff81125daf R14: ffffffff8115db64 R15: ffff8803f9da4b40
> FS:  00007fd3dda897a0(0000) GS:ffff880002000000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007fd3ddaab000 CR3: 000000080ce01000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process snmpd (pid: 2375, threadinfo ffff88080c12e000, task
> ffff88080b58ddc0)
> Stack:
>  ffff88080c12fe18 ffff8803e5a26e30 ffff88040c4a3e80 ffff8803e5a26e30
> <0> ffff88080c12fe48 ffffffff81125daf ffff88080c12fe38 ffff8803f9da4b40
> <0> ffff8803e5a26e30 ffff880400d405c0 ffff88080c12fe78 ffffffff8115db98
> Call Trace:
>  [<ffffffff81125daf>] seq_release_private+0x28/0x44
>  [<ffffffff8115db98>] seq_release_net+0x34/0x3d
>  [<ffffffff81155a62>] proc_reg_release+0xd3/0xf0
>  [<ffffffff8110efb3>] __fput+0x12a/0x1d4
>  [<ffffffff8110f077>] fput+0x1a/0x1c
>  [<ffffffff8110c0f7>] filp_close+0x68/0x72
>  [<ffffffff8110c19e>] sys_close+0x9d/0xd2
>  [<ffffffff81009c72>] system_call_fastpath+0x16/0x1b
> Code: ef ff 13 48 83 c3 08 48 83 3b 00 eb ec 49 83 fc 10 76 7d 4c 89 e7
> e8 67 e4 ff ff 48 89 c6 48 8b 00 84 c0 78 14 66 a9 00 c0 75 04 <0f> 0b
> eb fe 48 89 f7 e8 66 36 fd ff eb 57 48 8b 4d 08 48 8b 7e
> RIP  [<ffffffff811006d6>] kfree+0x5e/0xcb
>  RSP <ffff88080c12fdf8>
> ---[ end trace 60a902368ad4d4fe ]---
> 
> It seems to claim speedstep_lib was the last unloaded, which I wouldn't
> be able to explain why that would have been unloaded at all, the running
> system itself doesn't seem to be using it, so I can only assume it got
> loaded on startup somewhere and was subsequently removed.
> 
> On D1 yesterday I saw the following:
> 
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:2835!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/kernel/mm/ksm/run
> CPU 1
> Modules linked in: ocfs2 mptctl mptbase drbd lru_cache nfsd lockd
> nfs_acl auth_rpcgss sunrpc ocfs2_dlmfs ocfs2_stack_o2cb ocfs2_dlm
> ocfs2_nodemanager ocfs2_stackglue configfs cpufreq_ondemand powernow_k8
> freq_table 8021q garp stp llc ip6t_REJECT nf_conntrack_ipv6
> ip6table_filter ip6_tables ipv6 xfs exportfs amd64_edac_mod tg3
> edac_core i2c_amd756 i2c_core hpwdt amd_rng k8temp shpchp edac_mce_amd
> microcode pata_acpi ata_generic pata_amd cciss [last unloaded:
> scsi_wait_scan]
> Nov 23 06:50:04 demeter kernel:
> Pid: 1737, comm: snmpd Not tainted 2.6.34.7-61.korg.fc13.x86_64 #1
> /ProLiant DL385 G1
> RIP: 0010:[<ffffffff811006d6>]  [<ffffffff811006d6>] kfree+0x5e/0xcb
> RSP: 0018:ffff8801eef2ddf8  EFLAGS: 00010246
> RAX: 0040000000000400 RBX: ffff8803effe74b0 RCX: ffff8803e18ec6c0
> RDX: ffffea0000000000 RSI: ffffea0003800000 RDI: ffff880100000002
> RBP: ffff8801eef2de18 R08: ffff8803e18ec918 R09: 0000000000000000
> R10: 0000000000000011 R11: 0000000000000246 R12: ffff880100000002
> R13: ffffffff81125daf R14: ffffffff8115db64 R15: ffff880044570540
> FS:  00007f0fadd727a0(0000) GS:ffff880207400000(0000) knlGS:00000000f4f9bb70
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f0fadd93000 CR3: 00000001efbb6000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process snmpd (pid: 1737, threadinfo ffff8801eef2c000, task
> ffff8801ecf2c650)
> Stack:
> ffff8801eef2de18 ffff8803effe74b0 ffff8803d645ac00 ffff8803effe74b0
> <0> ffff8801eef2de48 ffffffff81125daf ffff8801eef2de38 ffff880044570540
> <0> ffff8803effe74b0 ffff8803e18ec900 ffff8801eef2de78 ffffffff8115db98
> Call Trace:
> [<ffffffff81125daf>] seq_release_private+0x28/0x44
> [<ffffffff8115db98>] seq_release_net+0x34/0x3d
> [<ffffffff81155a62>] proc_reg_release+0xd3/0xf0
> [<ffffffff8110efb3>] __fput+0x12a/0x1d4
> [<ffffffff8110f077>] fput+0x1a/0x1c
> [<ffffffff8110c0f7>] filp_close+0x68/0x72
> [<ffffffff8110c19e>] sys_close+0x9d/0xd2
> [<ffffffff81009c72>] system_call_fastpath+0x16/0x1b
> Code: ef ff 13 48 83 c3 08 48 83 3b 00 eb ec 49 83 fc 10 76 7d 4c 89 e7
> e8 67 e4 ff ff 48 89 c6 48 8b 00 84 c0 78 14 66 a9 00 c0 75 04 <0f> 0b
> eb fe 48 89 f7 e8 66 36 fd ff eb 57 48 8b 4d 08 48 8b 7e
> RIP  [<ffffffff811006d6>] kfree+0x5e/0xcb
> RSP <ffff8801eef2ddf8>
> ---[ end trace 34b1e268e13a43a5 ]---
> 
> Which claims the last unloaded module was scsi_wait_scan.  The module
> unloads I'm going to assume are coming from random normal boot code, and
> the errors are happening a significant time later anywhere from hours to
> days after boot.
> 
> Considering I'm seeing this on completely different hardware, completely
> different CPU's (AMD vs. Intel)
> 
> It's been suggested that I setup kmemleak on the boxes, despite the
> overhead that will incur, but it might help point out the problem.  Is
> there anything else?
> 
> Note: I'm not seeing this on any other box I have deployed, just these.
>  Now the load patterns are completely different here, and these are the
> only two boxes with drbd & ocfs2 on them as well.  Not trying to throw
> those under the bus, but it's worth pointing out any differences in my
> setup that might be helpful for debugging.
> 

I can't begin to think what could have caused this :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
