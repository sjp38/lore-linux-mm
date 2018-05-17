Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008136B038F
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:12:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b3-v6so1357042pga.6
        for <linux-mm@kvack.org>; Wed, 16 May 2018 23:12:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17-v6sor3067010plj.121.2018.05.16.23.12.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 23:12:06 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH] KVM: arm/arm64: add WARN_ON if size is not PAGE_SIZE aligned in unmap_stage2_range
Date: Thu, 17 May 2018 14:11:27 +0800
Message-Id: <1526537487-14804-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu
Cc: Suzuki K Poulose <suzuki.poulose@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, "David S. Miller" <davem@davemloft.net>, Minchan Kim <minchan@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>, jia.he@hxt-semitech.com

I ever met a panic under memory pressure tests(start 20 guests and run
memhog in the host).
---------------------------------begin--------------------------------
[35380.800950] BUG: Bad page state in process qemu-kvm  pfn:dd0b6
[35380.805825] page:ffff7fe003742d80 count:-4871 mapcount:-2126053375
mapping:          (null) index:0x0
[35380.815024] flags: 0x1fffc00000000000()
[35380.818845] raw: 1fffc00000000000 0000000000000000 0000000000000000
ffffecf981470000
[35380.826569] raw: dead000000000100 dead000000000200 ffff8017c001c000
0000000000000000
[35380.805825] page:ffff7fe003742d80 count:-4871 mapcount:-2126053375
mapping:          (null) index:0x0
[35380.815024] flags: 0x1fffc00000000000()
[35380.818845] raw: 1fffc00000000000 0000000000000000 0000000000000000
ffffecf981470000
[35380.826569] raw: dead000000000100 dead000000000200 ffff8017c001c000
0000000000000000
[35380.834294] page dumped because: nonzero _refcount
[35380.839069] Modules linked in: vhost_net vhost tap ebtable_filter
ebtables ip6table_filter ip6_tables iptable_filter fcoe libfcoe libfc
8021q garp mrp stp llc scsi_transport_fc openvswitch nf_conntrack_ipv6
nf_nat_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_defrag_ipv6
nf_nat nf_conntrack vfat fat rpcrdma ib_isert iscsi_target_mod ib_iser
libiscsi scsi_transport_iscsi ib_srpt target_core_mod ib_srp
scsi_transport_srp ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm
ib_cm iw_cm mlx5_ib ib_core crc32_ce ipmi_ssif tpm_tis tpm_tis_core sg
nfsd auth_rpcgss nfs_acl lockd grace sunrpc dm_multipath ip_tables xfs
libcrc32c mlx5_core mlxfw devlink ahci_platform libahci_platform libahci
qcom_emac sdhci_acpi sdhci hdma mmc_core hdma_mgmt i2c_qup dm_mirror
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
kvm_mmu_notifier_invalidate_range_start+0x60/0xb0
[35381.007387] [<ffff000008271f44>]
__mmu_notifier_invalidate_range_start+0x64/0x8c
[35381.014765] [<ffff0000082547c8>] try_to_unmap_one+0x78c/0x7a4
[35381.020493] [<ffff000008276d04>] rmap_walk_ksm+0x124/0x1a0
[35381.025961] [<ffff0000082551b4>] rmap_walk+0x94/0x98
[35381.030909] [<ffff0000082555e4>] try_to_unmap+0x100/0x124
[35381.036293] [<ffff00000828243c>] unmap_and_move+0x480/0x6fc
[35381.041847] [<ffff000008282b6c>] migrate_pages+0x10c/0x288
[35381.047318] [<ffff00000823c164>] compact_zone+0x238/0x954
[35381.052697] [<ffff00000823c944>] compact_zone_order+0xc4/0xe8
[35381.058427] [<ffff00000823d25c>] try_to_compact_pages+0x160/0x294
[35381.064503] [<ffff00000820f074>]
__alloc_pages_direct_compact+0x68/0x194
[35381.071187] [<ffff000008210138>] __alloc_pages_nodemask+0xc20/0xf7c
[35381.077437] [<ffff0000082709e4>] alloc_pages_vma+0x1a4/0x1c0
[35381.083080] [<ffff000008285b68>]
do_huge_pmd_anonymous_page+0x128/0x324
[35381.089677] [<ffff000008248a24>] __handle_mm_fault+0x71c/0x7e8
[35381.095492] [<ffff000008248be8>] handle_mm_fault+0xf8/0x194
[35381.101049] [<ffff000008240dcc>] __get_user_pages+0x124/0x34c
[35381.106777] [<ffff000008241870>] populate_vma_page_range+0x90/0x9c
[35381.112941] [<ffff000008241940>] __mm_populate+0xc4/0x15c
[35381.118322] [<ffff00000824b294>] SyS_mlockall+0x100/0x164
[35381.123705] Exception stack(0xffff800dce5f3ec0 to 0xffff800dce5f4000)
[35381.130128] 3ec0: 0000000000000003 d6e6024cc9b87e00 0000aaaabe94f000
0000000000000000
[35381.137940] 3ee0: 0000000000000002 0000000000000000 0000000000000000
0000aaaacf6fc3c0
[35381.145753] 3f00: 00000000000000e6 0000aaaacf6fc490 0000ffffeeeab0f0
d6e6024cc9b87e00
[35381.153565] 3f20: 0000000000000000 0000aaaabe81b3c0 0000000000000020
00009e53eff806b5
[35381.161379] 3f40: 0000aaaabe94de48 0000ffffa7c269b0 0000000000000011
0000ffffeeeabf68
[35381.169190] 3f60: 0000aaaaceacfe60 0000aaaabe94f000 0000aaaabe9ba358
0000aaaabe7ffb80
[35381.177003] 3f80: 0000aaaabe9ba000 0000aaaabe959f64 0000000000000000
0000aaaabe94f000
[35381.184815] 3fa0: 0000000000000000 0000ffffeeeabdb0 0000aaaabe5f3bf8
0000ffffeeeabdb0
[35381.192628] 3fc0: 0000ffffa7c269b8 0000000060000000 0000000000000003
00000000000000e6
[35381.200440] 3fe0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[35381.208254] [<ffff00000808339c>] __sys_trace_return+0x0/0x4
[35381.213809] Disabling lock debugging due to kernel taint
--------------------------------end--------------------------------------

The root cause might be what I fixed at [1]. But from arm kvm points of
view, it would be better we caught the exception earlier and clearer.

If the size is not PAGE_SIZE aligned, unmap_stage2_range might unmap the
wrong(more or less) page range. Hence it caused the "BUG: Bad page
state"

[1] https://lkml.org/lkml/2018/5/3/1042

Signed-off-by: jia.he@hxt-semitech.com
---
 virt/kvm/arm/mmu.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index 7f6a944..8dac311 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -297,6 +297,8 @@ static void unmap_stage2_range(struct kvm *kvm, phys_addr_t start, u64 size)
 	phys_addr_t next;
 
 	assert_spin_locked(&kvm->mmu_lock);
+	WARN_ON(size & ~PAGE_MASK);
+
 	pgd = kvm->arch.pgd + stage2_pgd_index(addr);
 	do {
 		/*
-- 
1.8.3.1
