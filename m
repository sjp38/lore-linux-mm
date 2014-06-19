Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id E28356B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 17:56:56 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so2832277wgh.0
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:56:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z15si8781678wjy.104.2014.06.19.14.56.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 14:56:55 -0700 (PDT)
Date: Thu, 19 Jun 2014 17:56:41 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
Message-ID: <20140619215641.GA9792@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi,

I triggered the following bug on v3.16-rc1 when I did mbind() testing
where multiple processes repeat calling mbind() for a shared mapped file
(causing pingpong of page migration.)

In my investigation, it seems that some vma accidentally has vma->vm_start
= 0, which makes new_vma_page() choose a wrong vma and results in breaking
the assumption that the address passed to alloc_pages_vma() should be
inside a given vma.
I'm suspecting that mbind_range() do something wrong around vma handling,
but I don't have enough luck yet. Anyone has an idea?

Thanks,
Naoya Horiguchi

[  339.133960] ------------[ cut here ]------------
[  339.134893] kernel BUG at /src/linux-dev/mm/mempolicy.c:1738!
[  339.134893] invalid opcode: 0000 [#1] SMP
[  339.134893] Modules linked in: stap_2acbad8c3ba47062dbdc6f227d00f8f4__1958(O) bnep bluetooth cfg80211 rfkill ip6t_rpfilter ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev microcode i2c_piix4 pcspkr i2c_core virtio_balloon parport_pc parport serio_raw nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc virtio_blk virtio_net floppy ata_generic pata_acpi
[  339.134893] CPU: 2 PID: 2840 Comm: mbind_fuzz Tainted: G           O  3.16.0-rc1-140619-1205-00003-g80aa6b64a44e #157
[  339.134893] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  339.134893] task: ffff88007c133b60 ti: ffff88007dd28000 task.ti: ffff88007dd28000
[  339.134893] RIP: 0010:[<ffffffff811ebfe0>]  [<ffffffff811ebfe0>] policy_zonelist+0x50/0xb0
[  339.134893] RSP: 0000:ffff88007dd2bcf8  EFLAGS: 00010293
[  339.134893] RAX: 0000000000000000 RBX: ffff88007c133b60 RCX: 0000000000000000
[  339.134893] RDX: 0000000000000002 RSI: ffff88011bd3fad0 RDI: 00000000000200da
[  339.134893] RBP: ffff88007dd2bd00 R08: 0000000000000002 R09: 0000000000000002
[  339.134893] R10: ffff88007d8f3958 R11: 0000000000000001 R12: 00000000000200da
[  339.134893] R13: 0000000000000000 R14: ffff88011bd3fad0 R15: 0000000000000000
[  339.134893] FS:  00007f457cf90740(0000) GS:ffff8800bec00000(0000) knlGS:0000000000000000
[  339.134893] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  339.134893] CR2: 0000700000184000 CR3: 000000007959b000 CR4: 00000000000006e0
[  339.134893] Stack:
[  339.134893]  ffff88007c133b60 ffff88007dd2bd68 ffffffff811eeac8 ffff88007c133b60
[  339.134893]  ffff88007c133b60 0000000000000000 000000020000000c 0000000000000000
[  339.134893]  ffff88007c387e60 ffff88007c387e60 ffffea0000e19340 ffff88007d8f3958
[  339.134893] Call Trace:
[  339.134893]  [<ffffffff811eeac8>] alloc_pages_vma+0x88/0x1a0
[  339.134893]  [<ffffffff811eec7b>] new_vma_page+0x9b/0xb0
[  339.134893]  [<ffffffff811fee4d>] unmap_and_move+0x3d/0x200
[  339.134893]  [<ffffffff811ff235>] migrate_pages+0xe5/0x1e0
[  339.134893]  [<ffffffff811eebe0>] ? alloc_pages_vma+0x1a0/0x1a0
[  339.134893]  [<ffffffff811ef3c2>] do_mbind+0x1f2/0x3a0
[  339.134893]  [<ffffffff811ef60b>] SyS_mbind+0x9b/0xb0
[  339.134893]  [<ffffffff8174798b>] tracesys+0xdd/0xe2
[  339.134893] Code: 63 d2 31 c0 85 db 48 8b 14 d5 00 2d d6 81 0f 95 c0 48 69 c0 20 22 01 00 5b 5d 48 8d 84 02 00 1d 00 00 c3 0f 1f 84 00 00 00 00 00 <0f> 0b 66 0f 1f 44 00 00 f6 46 06 02 75 12 89 fb 48 0f bf 56 08
[  339.134893] RIP  [<ffffffff811ebfe0>] policy_zonelist+0x50/0xb0
[  339.134893]  RSP <ffff88007dd2bcf8>
[  339.178924] ---[ end trace 37c12438b6936769 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
