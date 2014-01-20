From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Mon, 20 Jan 2014 17:10:05 +0800
Message-ID: <26182.9819334254$1390209072@news.gmane.org>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20140107074136.GA4011@lge.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: cl@linux-foundation.org, nacc@linux.vnet.ibm.com, penberg@kernel.org, linux-mm@kvack.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org
List-Id: linux-mm.kvack.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joonsoo,
On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
[...]
>
>------------->8--------------------
>diff --git a/mm/slub.c b/mm/slub.c
>index c3eb3d3..a1f6dfa 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1672,7 +1672,19 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> {
>        void *object;
>        int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
>+       struct zonelist *zonelist;
>+       struct zoneref *z;
>+       struct zone *zone;
>+       enum zone_type high_zoneidx = gfp_zone(flags);
>
>+       if (!node_present_pages(searchnode)) {
>+               zonelist = node_zonelist(searchnode, flags);
>+               for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>+                       searchnode = zone_to_nid(zone);
>+                       if (node_present_pages(searchnode))
>+                               break;
>+               }
>+       }
>        object = get_partial_node(s, get_node(s, searchnode), c, flags);
>        if (object || node != NUMA_NO_NODE)
>                return object;
>

The patch fix the bug. However, the kernel crashed very quickly after running 
stress tests for a short while:


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=oops

[  287.464285] Unable to handle kernel paging request for data at address 0x00000001
[  287.464289] Faulting instruction address: 0xc000000000445af8
[  287.464294] Oops: Kernel access of bad area, sig: 11 [#1]
[  287.464296] SMP NR_CPUS=2048 NUMA pSeries
[  287.464301] Modules linked in: btrfs raid6_pq xor dm_service_time sg nfsv3 arc4 md4 rpcsec_gss_krb5 nfsv4 nls_utf8 cifs nfs fscache dns_resolver nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter ip_tables ext4 mbcache jbd2 ibmvfc scsi_transport_fc ibmveth nx_crypto pseries_rng nfsd auth_rpcgss nfs_acl lockd binfmt_misc sunrpc uinput dm_multipath xfs libcrc32c sd_mod crc_t10dif crct10dif_common ibmvscsi scsi_tran
 sport_srp scsi_tgt dm_mirror dm_region_hash dm_log dm_mod
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


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--XsQoSWH+UP9D9v3l--
