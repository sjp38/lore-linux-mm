Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id 523406B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 17:13:35 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id df13so6472825qeb.27
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:13:35 -0800 (PST)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id ge8si1581554qab.146.2014.01.20.14.13.33
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 14:13:34 -0800 (PST)
Date: Mon, 20 Jan 2014 16:13:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.DEB.2.10.1401201612340.28048@nuc>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: MULTIPART/Mixed; BOUNDARY=XsQoSWH+UP9D9v3l
Content-ID: <alpine.DEB.2.10.1401201612341.28048@nuc>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, benh@kernel.crashing.org, paulus@samba.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Han Pingtian <hanpt@linux.vnet.ibm.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--XsQoSWH+UP9D9v3l
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.10.1401201612342.28048@nuc>
Content-Disposition: INLINE

On Mon, 20 Jan 2014, Wanpeng Li wrote:

> >+       enum zone_type high_zoneidx = gfp_zone(flags);
> >
> >+       if (!node_present_pages(searchnode)) {
> >+               zonelist = node_zonelist(searchnode, flags);
> >+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> >+                       searchnode = zone_to_nid(zone);
> >+                       if (node_present_pages(searchnode))
> >+                               break;
> >+               }
> >+       }
> >        object = get_partial_node(s, get_node(s, searchnode), c, flags);
> >        if (object || node != NUMA_NO_NODE)
> >                return object;
> >
>
> The patch fix the bug. However, the kernel crashed very quickly after running
> stress tests for a short while:

This is not a good way of fixing it. How about not asking for memory from
nodes that are memoryless? Use numa_mem_id() which gives you the next node
that has memory instead of numa_node_id() (gives you the current node
regardless if it has memory or not).

--XsQoSWH+UP9D9v3l
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Content-ID: <alpine.DEB.2.10.1401201612343.28048@nuc>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=oops

[  287.464285] Unable to handle kernel paging request for data at address 0x00000001
[  287.464289] Faulting instruction address: 0xc000000000445af8
[  287.464294] Oops: Kernel access of bad area, sig: 11 [#1]
[  287.464296] SMP NR_CPUS=2048 NUMA pSeries
[  287.464301] Modules linked in: btrfs raid6_pq xor dm_service_time sg nfsv3 arc4 md4 rpcsec_gss_krb5 nfsv4 nls_utf8 cifs nfs fscache dns_resolver nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter ip_tables ext4 mbcache jbd2 ibmvfc scsi_transport_fc ibmveth nx_crypto pseries_rng nfsd auth_rpcgss nfs_acl lockd binfmt_misc sunrpc uinput dm_multipath xfs libcrc32c sd_mod crc_t10dif crct10dif_common ibmvscsi scsi_transport_srp scsi_tgt dm_mirror dm_region_hash dm_log dm_mod
[  287.464374] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.0-71.el7.91831.ppc64 #1
[  287.464378] task: c000000000fde590 ti: c0000001fffd0000 task.ti: c0000000010a4000
[  287.464382] NIP: c000000000445af8 LR: c000000000445bcc CTR: c000000000445b90
[  287.464385] REGS: c0000001fffd38e0 TRAP: 0300   Not tainted  (3.10.0-71.el7.91831.ppc64)
[  287.464388] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 88002084  XER: 00000001
[  287.464397] SOFTE: 0
[  287.464398] CFAR: c00000000000908c
[  287.464401] DAR: 0000000000000001, DSISR: 40000000
[  287.464403]
GPR00: d000000003649a04 c0000001fffd3b60 c0000000010a94d0 0000000000000003
GPR04: c00000018d841048 c0000001fffd3bd0 0000000000000012 d00000000364eff0
GPR08: c0000001fffd3bd0 0000000000000001 d00000000364d688 c000000000445b90
GPR12: d00000000364b960 c000000007e00000 00000000042ac510 0000000000000060
GPR16: 0000000000200000 00000000fffffb19 c000000001122100 0000000000000000
GPR20: c000000000a94680 c000000001122180 c000000000a94680 000000000000000a
GPR24: 0000000000000100 0000000000000000 0000000000000001 c0000001ef900000
GPR28: c0000001d6c066f0 c0000001aea03520 c0000001bc9a2640 c00000018d841680
[  287.464447] NIP [c000000000445af8] .__dev_printk+0x28/0xc0
[  287.464450] LR [c000000000445bcc] .dev_printk+0x3c/0x50
[  287.464453] PACATMSCRATCH [8000000000009032]
[  287.464455] Call Trace:
[  287.464458] [c0000001fffd3b60] [c0000001fffd3c00] 0xc0000001fffd3c00 (unreliable)
[  287.464467] [c0000001fffd3bf0] [d000000003649a04] .ibmvfc_scsi_done+0x334/0x3e0 [ibmvfc]
[  287.464474] [c0000001fffd3cb0] [d0000000036495b8] .ibmvfc_handle_crq+0x2e8/0x320 [ibmvfc]
[  287.464488] [c0000001fffd3d30] [d000000003649fe4] .ibmvfc_tasklet+0xd4/0x250 [ibmvfc]
[  287.464494] [c0000001fffd3de0] [c00000000009b46c] .tasklet_action+0xcc/0x1b0
[  287.464498] [c0000001fffd3e90] [c00000000009a668] .__do_softirq+0x148/0x360
[  287.464503] [c0000001fffd3f90] [c0000000000218a8] .call_do_softirq+0x14/0x24
[  287.464507] [c0000001fffcfdf0] [c0000000000107e0] .do_softirq+0xd0/0x100
[  287.464511] [c0000001fffcfe80] [c00000000009aba8] .irq_exit+0x1b8/0x1d0
[  287.464514] [c0000001fffcff10] [c000000000010410] .__do_irq+0xc0/0x1e0
[  287.464518] [c0000001fffcff90] [c0000000000218cc] .call_do_irq+0x14/0x24
[  287.464522] [c0000000010a76d0] [c0000000000105bc] .do_IRQ+0x8c/0x100
[  287.464527] --- Exception: 501 at 0xffff
[  287.464527]     LR = .arch_local_irq_restore+0x74/0x90
[  287.464533] [c0000000010a7770] [c000000000002494] hardware_interrupt_common+0x114/0x180 (unreliable)
[  287.464540] --- Exception: 501 at .plpar_hcall_norets+0x84/0xd4
[  287.464540]     LR = .check_and_cede_processor+0x24/0x40
[  287.464546] [c0000000010a7a60] [0000000000000001] 0x1 (unreliable)
[  287.464550] [c0000000010a7ad0] [c000000000074ecc] .shared_cede_loop+0x2c/0x70
[  287.464555] [c0000000010a7b50] [c0000000005538f4] .cpuidle_enter_state+0x64/0x150
[  287.464559] [c0000000010a7c10] [c000000000553ad0] .cpuidle_idle_call+0xf0/0x300
[  287.464563] [c0000000010a7cc0] [c0000000000695c0] .pseries_lpar_idle+0x10/0x50
[  287.464568] [c0000000010a7d30] [c000000000016ee4] .arch_cpu_idle+0x64/0x150
[  287.464572] [c0000000010a7db0] [c0000000000f6504] .cpu_startup_entry+0x1a4/0x2d0
[  287.464577] [c0000000010a7e80] [c00000000000bd04] .rest_init+0x94/0xb0
[  287.464582] [c0000000010a7ef0] [c000000000a044d0] .start_kernel+0x4b0/0x4cc
[  287.464586] [c0000000010a7f90] [c000000000009d30] .start_here_common+0x20/0x70
[  287.464589] Instruction dump:
[  287.464591] 60000000 60420000 2c240000 7c6a1b78 41c20088 e9240090 88630001 7ca82b78
[  287.464598] 2fa90000 3863ffd0 7c6307b4 419e002c <e8c90000> e8e40050 2fa70000 419e004c
[  287.464606] ---[ end trace c469801a8c53d8f1 ]---
[  287.466576]
[  287.466582] Sending IPI to other CPUs
[  287.468526] IPI complete


--XsQoSWH+UP9D9v3l--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
