Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B92CE6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 09:21:12 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id x26so89172260qtb.6
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:21:12 -0800 (PST)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id n185si19937988qke.282.2016.11.08.06.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 06:21:11 -0800 (PST)
Received: by mail-qk0-f172.google.com with SMTP id n204so207654070qke.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:21:11 -0800 (PST)
Message-ID: <1478614869.2443.18.camel@redhat.com>
Subject: crash in invalidate_mapping_pages codepath during fadvise
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 08 Nov 2016 09:21:09 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: Sage Weil <sage@redhat.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>

We hit the following panic while running some (userland) ceph testing:

[ 3643.590247] ------------[ cut here ]------------
[ 3643.594883] kernel BUG at /srv/autobuild-ceph/gitbuilder.git/build/include/linux/swap.h:276!
[ 3643.603346] invalid opcode: 0000 [#1] SMP
[ 3643.607369] Modules linked in: xfs libcrc32c kvm_intel ib_iser rdma_cm ib_cm iw_cm ib_core configfs iscsi_tcp libiscsi_tcp libiscsi gpio_ich intel_powerclamp coretemp kvm joydev irqbypass serio_raw lpc_ich i7core_edac shpchp edac_core tpm_infineon nfsd nfs_acl auth_rpcgss nfs fscache lockd sunrpc scsi_transport_iscsi grace lp parport btrfs xor raid6_pq hid_generic usbhid hid e1000e ahci ptp psmouse libahci pps_core arcmsr [last unloaded: kvm_intel]
[ 3643.648733] CPU: 0 PID: 27907 Comm: wb_throttle Not tainted 4.8.0-ceph-00048-g4c60319 #1
[ 3643.656901] Hardware name: Supermicro X8SIL/X8SIL, BIOS 1.1 05/27/2010
[ 3643.663493] task: ffff8c786a550000 task.stack: ffff8c786a558000
[ 3643.669558] RIP: 0010:[<ffffffffbd1caecc>]  [<ffffffffbd1caecc>] clear_exceptional_entry+0x8c/0xf0
[ 3643.678631] RSP: 0018:ffff8c786a55bd58  EFLAGS: 00010046
[ 3643.684018] RAX: ffff8c75a2134920 RBX: ffff8c770633e8a8 RCX: 0000000000000000
[ 3643.691227] RDX: 0000000000000001 RSI: 0000000000000002 RDI: ffff8c75a2134920
[ 3643.698453] RBP: ffff8c786a55bd98 R08: ffff8c75a2134948 R09: 0000000000000001
[ 3643.705673] R10: 0000000000000000 R11: 00000000005b7493 R12: 0000349b7d000102
[ 3643.712900] R13: ffff8c770633e8c0 R14: ffff8c770633e8b0 R15: 0000000000000000
[ 3643.720127] FS:  00007f002a5c2700(0000) GS:ffff8c787fc00000(0000) knlGS:0000000000000000
[ 3643.728323] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3643.734155] CR2: 00007f8354663ff0 CR3: 0000000429eac000 CR4: 00000000000006f0
[ 3643.741325] Stack:
[ 3643.743364]  ffff8c75a2134920 ffff8c75a2134948 0000000000000000 0000000000000000
[ 3643.750896]  ffffffffffffffff ffff8c770633e8a8 0000000000000000 0000000000000000
[ 3643.758429]  ffff8c786a55bee8 ffffffffbd1cbfe2 ffff8c786a55be68 ffff8c770633e6a8
[ 3643.765962] Call Trace:
[ 3643.768448]  [<ffffffffbd1cbfe2>] invalidate_mapping_pages+0x72/0x2b0
[ 3643.774929]  [<ffffffffbd206711>] SyS_fadvise64_64+0x1f1/0x270
[ 3643.780793]  [<ffffffffbd20679e>] SyS_fadvise64+0xe/0x10
[ 3643.786131]  [<ffffffffbd826340>] entry_SYSCALL_64_fastpath+0x23/0xc1
[ 3643.792629] Code: 45 c8 4c 39 20 75 62 48 c7 00 00 00 00 00 48 8b 45 c0 48 83 ab e8 00 00 00 01 48 85 c0 74 4a 8b 50 04 89 d1 c1 e9 07 85 c9 75 02 <0f> 0b 83 c2 80 89 50 04 48 8b 75 c0 8b 46 04 c1 e8 07 85 c0 75 
[ 3643.813243] RIP  [<ffffffffbd1caecc>] clear_exceptional_entry+0x8c/0xf0
[ 3643.820030]  RSP <ffff8c786a55bd58>
[ 3643.823777] ---[ end trace 0c3854ea0ec46fa7 ]---

The kernel here is basically a v4.8.0 kernel with a pile of ceph patches
on top. None of the ceph modules are plugged in, so I don't think any of
those patches are a factor here.

The VM_BUG_ON is here:

static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
{
        VM_BUG_ON(!workingset_node_shadows(node));
        node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
}

Here is the full console output, if it's helpful. There's a another bug
after the first one about sleeping in invalid context, but that could
be fallout from the earlier BUG?

    http://qa-proxy.ceph.com/teuthology/jlayton-2016-11-07_19:48:50-fs-wip-jlayton-fsync---basic-mira/531006/console_logs/mira107.log

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
