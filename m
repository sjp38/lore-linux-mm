Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 051566B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 09:52:47 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 19so139566189vko.0
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:52:47 -0800 (PST)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id 68si9233597uau.239.2016.11.08.06.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 06:52:44 -0800 (PST)
Received: by mail-vk0-x22b.google.com with SMTP id x186so150532811vkd.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:52:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1478614869.2443.18.camel@redhat.com>
References: <1478614869.2443.18.camel@redhat.com>
From: Ilya Dryomov <idryomov@gmail.com>
Date: Tue, 8 Nov 2016 15:52:43 +0100
Message-ID: <CAOi1vP8yR3ic39jT0S30K7pEhWe=TsKbn3K3yL+yJkqpv44D=g@mail.gmail.com>
Subject: Re: crash in invalidate_mapping_pages codepath during fadvise
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Sage Weil <sage@redhat.com>, "Yan, Zheng" <zyan@redhat.com>

On Tue, Nov 8, 2016 at 3:21 PM, Jeff Layton <jlayton@redhat.com> wrote:
> We hit the following panic while running some (userland) ceph testing:
>
> [ 3643.590247] ------------[ cut here ]------------
> [ 3643.594883] kernel BUG at /srv/autobuild-ceph/gitbuilder.git/build/inc=
lude/linux/swap.h:276!
> [ 3643.603346] invalid opcode: 0000 [#1] SMP
> [ 3643.607369] Modules linked in: xfs libcrc32c kvm_intel ib_iser rdma_cm=
 ib_cm iw_cm ib_core configfs iscsi_tcp libiscsi_tcp libiscsi gpio_ich inte=
l_powerclamp coretemp kvm joydev irqbypass serio_raw lpc_ich i7core_edac sh=
pchp edac_core tpm_infineon nfsd nfs_acl auth_rpcgss nfs fscache lockd sunr=
pc scsi_transport_iscsi grace lp parport btrfs xor raid6_pq hid_generic usb=
hid hid e1000e ahci ptp psmouse libahci pps_core arcmsr [last unloaded: kvm=
_intel]
> [ 3643.648733] CPU: 0 PID: 27907 Comm: wb_throttle Not tainted 4.8.0-ceph=
-00048-g4c60319 #1
> [ 3643.656901] Hardware name: Supermicro X8SIL/X8SIL, BIOS 1.1 05/27/2010
> [ 3643.663493] task: ffff8c786a550000 task.stack: ffff8c786a558000
> [ 3643.669558] RIP: 0010:[<ffffffffbd1caecc>]  [<ffffffffbd1caecc>] clear=
_exceptional_entry+0x8c/0xf0
> [ 3643.678631] RSP: 0018:ffff8c786a55bd58  EFLAGS: 00010046
> [ 3643.684018] RAX: ffff8c75a2134920 RBX: ffff8c770633e8a8 RCX: 000000000=
0000000
> [ 3643.691227] RDX: 0000000000000001 RSI: 0000000000000002 RDI: ffff8c75a=
2134920
> [ 3643.698453] RBP: ffff8c786a55bd98 R08: ffff8c75a2134948 R09: 000000000=
0000001
> [ 3643.705673] R10: 0000000000000000 R11: 00000000005b7493 R12: 0000349b7=
d000102
> [ 3643.712900] R13: ffff8c770633e8c0 R14: ffff8c770633e8b0 R15: 000000000=
0000000
> [ 3643.720127] FS:  00007f002a5c2700(0000) GS:ffff8c787fc00000(0000) knlG=
S:0000000000000000
> [ 3643.728323] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3643.734155] CR2: 00007f8354663ff0 CR3: 0000000429eac000 CR4: 000000000=
00006f0
> [ 3643.741325] Stack:
> [ 3643.743364]  ffff8c75a2134920 ffff8c75a2134948 0000000000000000 000000=
0000000000
> [ 3643.750896]  ffffffffffffffff ffff8c770633e8a8 0000000000000000 000000=
0000000000
> [ 3643.758429]  ffff8c786a55bee8 ffffffffbd1cbfe2 ffff8c786a55be68 ffff8c=
770633e6a8
> [ 3643.765962] Call Trace:
> [ 3643.768448]  [<ffffffffbd1cbfe2>] invalidate_mapping_pages+0x72/0x2b0
> [ 3643.774929]  [<ffffffffbd206711>] SyS_fadvise64_64+0x1f1/0x270
> [ 3643.780793]  [<ffffffffbd20679e>] SyS_fadvise64+0xe/0x10
> [ 3643.786131]  [<ffffffffbd826340>] entry_SYSCALL_64_fastpath+0x23/0xc1
> [ 3643.792629] Code: 45 c8 4c 39 20 75 62 48 c7 00 00 00 00 00 48 8b 45 c=
0 48 83 ab e8 00 00 00 01 48 85 c0 74 4a 8b 50 04 89 d1 c1 e9 07 85 c9 75 0=
2 <0f> 0b 83 c2 80 89 50 04 48 8b 75 c0 8b 46 04 c1 e8 07 85 c0 75
> [ 3643.813243] RIP  [<ffffffffbd1caecc>] clear_exceptional_entry+0x8c/0xf=
0
> [ 3643.820030]  RSP <ffff8c786a55bd58>
> [ 3643.823777] ---[ end trace 0c3854ea0ec46fa7 ]---
>
> The kernel here is basically a v4.8.0 kernel with a pile of ceph patches
> on top. None of the ceph modules are plugged in, so I don't think any of
> those patches are a factor here.
>
> The VM_BUG_ON is here:
>
> static inline void workingset_node_shadows_dec(struct radix_tree_node *no=
de)
> {
>         VM_BUG_ON(!workingset_node_shadows(node));
>         node->count -=3D 1U << RADIX_TREE_COUNT_SHIFT;
> }
>
> Here is the full console output, if it's helpful. There's a another bug
> after the first one about sleeping in invalid context, but that could
> be fallout from the earlier BUG?
>
>     http://qa-proxy.ceph.com/teuthology/jlayton-2016-11-07_19:48:50-fs-wi=
p-jlayton-fsync---basic-mira/531006/console_logs/mira107.log

It's been fixed by d3798ae8c6f3 ("mm: filemap: don't plant shadow entries
without radix tree node") in 4.9-rc.

Thanks,

                Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
