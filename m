Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 852476B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 00:37:33 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 10 Dec 2012 00:37:32 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8967138C8045
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 00:37:30 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBA5bUuv66846828
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 00:37:30 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBA5bSHt001500
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:37:29 -0200
Date: Mon, 10 Dec 2012 10:37:10 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210050710.GC22164@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20121209203630.GC1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> 
> Either way, last night I applied a patch on top of latest tip/master to
> remove the nr_cpus_allowed check so that numacore would be enabled again
> and tested that. In some places it has indeed much improved. In others
> it is still regressing badly and in two case, it's corrupting memory --
> specjbb when THP is enabled crashes when running for single or multiple
> JVMs. It is likely that a zero page is being inserted due to a race with
> migration and causes the JVM to throw a null pointer exception. Here is
> the comparison on the rough off-chance you actually read it this time.

I see this failure when running with THP and KSM enabled on 
Friday's Tip master. Not sure if Mel was talking about the same issue.

------------[ cut here ]------------
kernel BUG at ../kernel/sched/fair.c:2371!
invalid opcode: 0000 [#1] SMP
Modules linked in: ebtable_nat ebtables autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf bridge stp llc iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vhost_net macvtap macvlan tun iTCO_wdt iTCO_vendor_support kvm_intel kvm microcode cdc_ether usbnet mii serio_raw i2c_i801 i2c_core lpc_ich mfd_core shpchp ioatdma i7core_edac edac_core bnx2 sg ixgbe dca mdio ext4 mbcache jbd2 sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas dm_mirror dm_region_hash dm_log dm_mod
CPU 4
Pid: 116, comm: ksmd Not tainted 3.7.0-rc8-tip_master+ #5 IBM BladeCenter HS22V -[7871AC1]-/81Y5995
RIP: 0010:[<ffffffff8108c139>]  [<ffffffff8108c139>] task_numa_fault+0x1a9/0x1e0
RSP: 0018:ffff880372237ba8  EFLAGS: 00010246
RAX: 0000000000000074 RBX: 0000000000000001 RCX: 0000000000000001
RDX: 00000000000012ae RSI: 0000000000000004 RDI: 00007faf4fc01000
RBP: ffff880372237be8 R08: 0000000000000000 R09: ffff8803657463f0
R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000012
R13: ffff880372210d00 R14: 0000000000010088 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88037fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000001d26fec CR3: 000000000169f000 CR4: 00000000000027e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksmd (pid: 116, threadinfo ffff880372236000, task ffff880372210d00)
Stack:
 ffffea0016026c58 00007faf4fc00000 ffff880372237c48 0000000000000001
 00007faf4fc01000 ffffea000d6df928 0000000000000001 ffffea00166e9268
 ffff880372237c48 ffffffff8113cd0e ffff880300000001 0000000000000002
Call Trace:
 [<ffffffff8113cd0e>] __do_numa_page+0xde/0x160
 [<ffffffff8113de9e>] handle_pte_fault+0x32e/0xcd0
 [<ffffffffa01c22c0>] ? drop_large_spte+0x30/0x30 [kvm]
 [<ffffffffa01bf215>] ? kvm_set_spte_hva+0x25/0x30 [kvm]
 [<ffffffff8113eab9>] handle_mm_fault+0x279/0x760
 [<ffffffff8115c024>] break_ksm+0x74/0xa0
 [<ffffffff8115c222>] break_cow+0xa2/0xb0
 [<ffffffff8115e38c>] ksm_scan_thread+0xb5c/0xd50
 [<ffffffff810771c0>] ? wake_up_bit+0x40/0x40
 [<ffffffff8115d830>] ? run_store+0x340/0x340
 [<ffffffff8107692e>] kthread+0xce/0xe0
 [<ffffffff81076860>] ? kthread_freezable_should_stop+0x70/0x70
 [<ffffffff814fa7ac>] ret_from_fork+0x7c/0xb0
 [<ffffffff81076860>] ? kthread_freezable_should_stop+0x70/0x70
Code: 89 f0 41 bf 01 00 00 00 8b 1c 10 e9 d7 fe ff ff 8d 14 09 48 63 d2 eb bd 66 2e 0f 1f 84 00 00 00 00 00 49 8b 85 98 07 00 00 eb 91 <0f> 0b eb fe 80 3d 9c 3b 6b 00 01 0f 84 be fe ff ff be 42 09 00
RIP  [<ffffffff8108c139>] task_numa_fault+0x1a9/0x1e0
 RSP <ffff880372237ba8>
---[ end trace 9584c9b03fc0dbc0 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
