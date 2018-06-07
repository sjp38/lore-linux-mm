Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2FF86B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:13:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d64-v6so5136166pfd.13
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:13:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m13-v6si31412813pls.70.2018.06.07.15.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:13:46 -0700 (PDT)
Date: Thu, 7 Jun 2018 15:13:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
Message-Id: <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
In-Reply-To: <20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
	<1525403506-6750-1-git-send-email-hejianet@gmail.com>
	<20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
	<2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
	<6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
	<20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <Suzuki.Poulose@arm.com>, Jia He <hejianet@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

On Thu, 24 May 2018 13:38:05 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > Jia, Andrew,
> > 
> > What is the status of this patch ?
> > 
> 
> I have it scheduled for 4.18-rc1, with a cc:stable for backporting.
> 
> I'd normally put such a fix into 4.17-rcX but I'd like to give Hugh
> time to review it and to generally give it a bit more time for review
> and test.
> 
> Have you tested it yourself?

I'll take your silence as a no.

This patch is quite urgent and is tagged for -stable backporting, yet
it remains in an unreviewed state.  Any takers?



From: Jia He <jia.he@hxt-semitech.com>
Subject: mm/ksm.c: ignore STABLE_FLAG of rmap_item->address in rmap_walk_ksm()

In our armv8a server(QDF2400), I noticed lots of WARN_ON caused by
PAGE_SIZE unaligned for rmap_item->address under memory pressure
tests(start 20 guests and run memhog in the host).

--------------------------begin--------------------------------------
[  410.853828] WARNING: CPU: 4 PID: 4641 at
arch/arm64/kvm/../../../virt/kvm/arm/mmu.c:1826
kvm_age_hva_handler+0xc0/0xc8
[  410.864518] Modules linked in: vhost_net vhost tap xt_CHECKSUM
ipt_MASQUERADE nf_nat_masquerade_ipv4 ip6t_rpfilter ipt_REJECT
nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink
ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security
ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw
ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter
rpcrdma ib_isert iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi
ib_srpt target_core_mod ib_srp scsi_transport_srp ib_ipoib rdma_ucm
ib_ucm ib_umad rdma_cm ib_cm iw_cm mlx5_ib vfat fat ib_uverbs dm_mirror
dm_region_hash ib_core dm_log dm_mod crc32_ce ipmi_ssif sg nfsd
[  410.935101]  auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs
libcrc32c mlx5_core ixgbe mlxfw devlink mdio ahci_platform
libahci_platform qcom_emac libahci hdma hdma_mgmt i2c_qup
[  410.951369] CPU: 4 PID: 4641 Comm: memhog Tainted: G        W
4.17.0-rc3+ #8
[  410.959104] Hardware name: <snip for confidential issues>
[  410.969791] pstate: 80400005 (Nzcv daif +PAN -UAO)
[  410.974575] pc : kvm_age_hva_handler+0xc0/0xc8
[  410.979012] lr : handle_hva_to_gpa+0xa8/0xe0
[  410.983274] sp : ffff801761553290
[  410.986581] x29: ffff801761553290 x28: 0000000000000000
[  410.991888] x27: 0000000000000002 x26: 0000000000000000
[  410.997195] x25: ffff801765430058 x24: ffff0000080b5608
[  411.002501] x23: 0000000000000000 x22: ffff8017ccb84000
[  411.007807] x21: 0000000003ff0000 x20: ffff8017ccb84000
[  411.013113] x19: 000000000000fe00 x18: ffff000008fb3c08
[  411.018419] x17: 0000000000000000 x16: 0060001645820bd3
[  411.023725] x15: ffff80176aacbc08 x14: 0000000000000000
[  411.029031] x13: 0000000000000040 x12: 0000000000000228
[  411.034337] x11: 0000000000000000 x10: 0000000000000000
[  411.039643] x9 : 0000000000000010 x8 : 0000000000000004
[  411.044949] x7 : 0000000000000000 x6 : 00008017f0770000
[  411.050255] x5 : 0000fffda59f0200 x4 : 0000000000000000
[  411.055561] x3 : 0000000000000000 x2 : 000000000000fe00
[  411.060867] x1 : 0000000003ff0000 x0 : 0000000020000000
[  411.066173] Call trace:
[  411.068614]  kvm_age_hva_handler+0xc0/0xc8
[  411.072703]  handle_hva_to_gpa+0xa8/0xe0
[  411.076619]  kvm_age_hva+0x4c/0xe8
[  411.080014]  kvm_mmu_notifier_clear_flush_young+0x54/0x98
[  411.085408]  __mmu_notifier_clear_flush_young+0x6c/0xa0
[  411.090627]  page_referenced_one+0x154/0x1d8
[  411.094890]  rmap_walk_ksm+0x12c/0x1d0
[  411.098632]  rmap_walk+0x94/0xa0
[  411.101854]  page_referenced+0x194/0x1b0
[  411.105770]  shrink_page_list+0x674/0xc28
[  411.109772]  shrink_inactive_list+0x26c/0x5b8
[  411.114122]  shrink_node_memcg+0x35c/0x620
[  411.118211]  shrink_node+0x100/0x430
[  411.121778]  do_try_to_free_pages+0xe0/0x3a8
[  411.126041]  try_to_free_pages+0xe4/0x230
[  411.130045]  __alloc_pages_nodemask+0x564/0xdc0
[  411.134569]  alloc_pages_vma+0x90/0x228
[  411.138398]  do_anonymous_page+0xc8/0x4d0
[  411.142400]  __handle_mm_fault+0x4a0/0x508
[  411.146489]  handle_mm_fault+0xf8/0x1b0
[  411.150321]  do_page_fault+0x218/0x4b8
[  411.154064]  do_translation_fault+0x90/0xa0
[  411.158239]  do_mem_abort+0x68/0xf0
[  411.161721]  el0_da+0x24/0x28
---------------------------end---------------------------------------

In rmap_walk_ksm, the rmap_item->address might still have the STABLE_FLAG,
then the start and end in handle_hva_to_gpa might not be PAGE_SIZE
aligned.  Thus it will cause exceptions in handle_hva_to_gpa on arm64.

This patch fixes it by ignoring (not removing) the low bits of address
when doing rmap_walk_ksm.

IMO, it should be backported to stable tree.  the stom of WARN_ONs is
very easy for me to reproduce.  More than that, I watched a panic (not
reproducible) as follows:

[35380.805825] page:ffff7fe003742d80 count:-4871 mapcount:-2126053375 
mapping: (null) index:0x0
[35380.815024] flags: 0x1fffc00000000000()
[35380.818845] raw: 1fffc00000000000 0000000000000000 0000000000000000 
ffffecf981470000
[35380.826569] raw: dead000000000100 dead000000000200 ffff8017c001c000 
0000000000000000
[35380.834294] page dumped because: nonzero _refcount
[35380.839069] Modules linked in: vhost_net vhost tap ebtable_filter ebtables 
ip6table_filter ip6_tables iptable_filter fcoe libfcoe libfc 8021q garp mrp stp 
llc scsi_transport_fc openvswitch nf_conntrack_ipv6 nf_nat_ipv6 
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_defrag_ipv6 nf_nat nf_conntrack 
vfat fat rpcrdma ib_isert iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi 
ib_srpt target_core_mod ib_srp scsi_transport_srp ib_ipoib rdma_ucm ib_ucm 
ib_uverbs ib_umad rdma_cm ib_cm iw_cm mlx5_ib ib_core crc32_ce ipmi_ssif tpm_tis 
tpm_tis_core sg nfsd auth_rpcgss nfs_acl lockd grace sunrpc dm_multipath 
ip_tables xfs libcrc32c mlx5_core mlxfw devlink ahci_platform libahci_platform 
libahci qcom_emac sdhci_acpi sdhci hdma mmc_core hdma_mgmt i2c_qup dm_mirror 
dm_region_hash dm_log dm_mod
[35380.908341] CPU: 29 PID: 18323 Comm: qemu-kvm Tainted: G W 
4.14.15-5.hxt.aarch64 #1
[35380.917107] Hardware name: <snip for confidential issues>
[35380.930909] Call trace:
[35380.933345] [<ffff000008088f00>] dump_backtrace+0x0/0x22c
[35380.938723] [<ffff000008089150>] show_stack+0x24/0x2c
[35380.943759] [<ffff00000893c078>] dump_stack+0x8c/0xb0
[35380.948794] [<ffff00000820ab50>] bad_page+0xf4/0x154
[35380.953740] [<ffff000008211ce8>] free_pages_check_bad+0x90/0x9c
[35380.959642] [<ffff00000820c430>] free_pcppages_bulk+0x464/0x518
[35380.965545] [<ffff00000820db98>] free_hot_cold_page+0x22c/0x300
[35380.971448] [<ffff0000082176fc>] __put_page+0x54/0x60
[35380.976484] [<ffff0000080b1164>] unmap_stage2_range+0x170/0x2b4
[35380.982385] [<ffff0000080b12d8>] kvm_unmap_hva_handler+0x30/0x40
[35380.988375] [<ffff0000080b0104>] handle_hva_to_gpa+0xb0/0xec
[35380.994016] [<ffff0000080b2644>] kvm_unmap_hva_range+0x5c/0xd0
[35380.999833] [<ffff0000080a8054>] 

I even injected a fault on purpose in kvm_unmap_hva_range by seting
size=size-0x200, the call trace is similar as above.  So I thought the
panic is similarly caused by the root cause of WARN_ON.

Link: http://lkml.kernel.org/r/1525403506-6750-1-git-send-email-hejianet@gmail.com
Signed-off-by: Jia He <jia.he@hxt-semitech.com>
Cc: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jia He <hejianet@gmail.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/ksm.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff -puN mm/ksm.c~mm-ksm-ignore-stable_flag-of-rmap_item-address-in-rmap_walk_ksm mm/ksm.c
--- a/mm/ksm.c~mm-ksm-ignore-stable_flag-of-rmap_item-address-in-rmap_walk_ksm
+++ a/mm/ksm.c
@@ -216,6 +216,8 @@ struct rmap_item {
 #define SEQNR_MASK	0x0ff	/* low bits of unstable tree seqnr */
 #define UNSTABLE_FLAG	0x100	/* is a node of the unstable tree */
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
+#define KSM_FLAG_MASK	(SEQNR_MASK|UNSTABLE_FLAG|STABLE_FLAG)
+				/* to mask all the flags */
 
 /* The stable and unstable tree heads */
 static struct rb_root one_stable_tree[1] = { RB_ROOT };
@@ -2598,10 +2600,15 @@ again:
 		anon_vma_lock_read(anon_vma);
 		anon_vma_interval_tree_foreach(vmac, &anon_vma->rb_root,
 					       0, ULONG_MAX) {
+			unsigned long addr;
+
 			cond_resched();
 			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
+
+			/* Ignore the stable/unstable/sqnr flags */
+			addr = rmap_item->address & ~KSM_FLAG_MASK;
+
+			if (addr < vma->vm_start || addr >= vma->vm_end)
 				continue;
 			/*
 			 * Initially we examine only the vma which covers this
@@ -2615,8 +2622,7 @@ again:
 			if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 				continue;
 
-			if (!rwc->rmap_one(page, vma,
-					rmap_item->address, rwc->arg)) {
+			if (!rwc->rmap_one(page, vma, addr, rwc->arg)) {
 				anon_vma_unlock_read(anon_vma);
 				return;
 			}
_
