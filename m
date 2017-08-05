Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 768C46B05BE
	for <linux-mm@kvack.org>; Sat,  5 Aug 2017 10:05:47 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u11so20835310qtu.10
        for <linux-mm@kvack.org>; Sat, 05 Aug 2017 07:05:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n89si3448133qtd.449.2017.08.05.07.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Aug 2017 07:05:45 -0700 (PDT)
Message-ID: <1501941942.6577.7.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Sat, 05 Aug 2017 10:05:42 -0400
In-Reply-To: <54eba2da-94ff-bd8a-3405-47577437550a@oracle.com>
References: <20170804190730.17858-1-riel@redhat.com>
	 <20170804190730.17858-3-riel@redhat.com>
	 <54eba2da-94ff-bd8a-3405-47577437550a@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

On Fri, 2017-08-04 at 16:09 -0700, Mike Kravetz wrote:
> On 08/04/2017 12:07 PM, riel@redhat.com wrote:
> > From: Rik van Riel <riel@redhat.com>
> > 
> > Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> > empty in the child process after fork. This differs from
> > MADV_DONTFORK
> > in one important way.
> > 
> > If a child process accesses memory that was MADV_WIPEONFORK, it
> > will get zeroes. The address ranges are still valid, they are just
> > empty.
> > 
> This didn't seem 'quite right' to me for shared mappings and/or file
> backed mappings.A A I wasn't exactly sure what it 'should' do in such
> cases.A A So, I tried it with a mapping created as follows:
> 
> addr = mmap(ADDR, page_size,
> A A A A A A A A A A A A A A A A A A A A A A A A PROT_READ | PROT_WRITE,
> A A A A A A A A A A A A A A A A A A A A A A A A MAP_ANONYMOUS|MAP_SHARED, -1, 0);

Your test program is pretty much the same I used, except I
used MAP_PRIVATE instead of MAP_SHARED.

Let me see how the code paths differ for both cases...


> When setting MADV_WIPEONFORK on the vma/mapping, I got the following
> at task exit time:
> 
> [A A 694.558290] ------------[ cut here ]------------
> [A A 694.558978] kernel BUG at mm/filemap.c:212!
> [A A 694.559476] invalid opcode: 0000 [#1] SMP
> [A A 694.560023] Modules linked in: ip6t_REJECT nf_reject_ipv6
> ip6t_rpfilter xt_conntrack ebtable_broute bridge stp llc ebtable_nat
> ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
> ip6table_raw ip6table_mangle ip6table_security iptable_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
> iptable_raw iptable_mangle 9p iptable_security ebtable_filter
> ebtables ip6table_filter ip6_tables snd_hda_codec_generic
> snd_hda_intel snd_hda_codec snd_hwdep snd_hda_core snd_seq ppdev
> snd_seq_device joydev crct10dif_pclmul crc32_pclmul crc32c_intel
> snd_pcm ghash_clmulni_intel 9pnet_virtio virtio_balloon snd_timer
> 9pnet parport_pc snd parport i2c_piix4 soundcore nfsd auth_rpcgss
> nfs_acl lockd grace sunrpc virtio_net virtio_blk virtio_console
> 8139too qxl drm_kms_helper ttm drm serio_raw 8139cp
> [A A 694.571554]A A mii virtio_pci ata_generic virtio_ring virtio
> pata_acpi
> [A A 694.572608] CPU: 3 PID: 1200 Comm: test_wipe2 Not tainted 4.13.0-
> rc3+ #8
> [A A 694.573778] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.9.1-1.fc24 04/01/2014
> [A A 694.574917] task: ffff880137178040 task.stack: ffffc900019d4000
> [A A 694.575650] RIP: 0010:__delete_from_page_cache+0x344/0x410
> [A A 694.576409] RSP: 0018:ffffc900019d7a88 EFLAGS: 00010082
> [A A 694.577238] RAX: 0000000000000021 RBX: ffffea00047d0e00 RCX:
> 0000000000000006
> [A A 694.578537] RDX: 0000000000000000 RSI: 0000000000000096 RDI:
> ffff88023fd0db90
> [A A 694.579774] RBP: ffffc900019d7ad8 R08: 00000000000882b6 R09:
> 000000000000028a
> [A A 694.580754] R10: ffffc900019d7da8 R11: ffffffff8211184d R12:
> ffffea00047d0e00
> [A A 694.582040] R13: 0000000000000000 R14: 0000000000000202 R15:
> ffff8801384439e8
> [A A 694.583236] FS:A A 0000000000000000(0000) GS:ffff88023fd00000(0000)
> knlGS:0000000000000000
> [A A 694.584607] CS:A A 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [A A 694.585409] CR2: 00007ff77a8da618 CR3: 0000000001e09000 CR4:
> 00000000001406e0
> [A A 694.586547] Call Trace:
> [A A 694.586996]A A delete_from_page_cache+0x54/0x110
> [A A 694.587481]A A truncate_inode_page+0xab/0x120
> [A A 694.588110]A A shmem_undo_range+0x498/0xa50
> [A A 694.588813]A A ? save_stack_trace+0x1b/0x20
> [A A 694.589529]A A ? set_track+0x70/0x140
> [A A 694.590150]A A ? init_object+0x69/0xa0
> [A A 694.590722]A A ? __inode_wait_for_writeback+0x73/0xe0
> [A A 694.591525]A A shmem_truncate_range+0x16/0x40
> [A A 694.592268]A A shmem_evict_inode+0xb1/0x190
> [A A 694.592735]A A evict+0xbb/0x1c0
> [A A 694.593147]A A iput+0x1c0/0x210
> [A A 694.593497]A A dentry_unlink_inode+0xb4/0x150
> [A A 694.593982]A A __dentry_kill+0xc1/0x150
> [A A 694.594400]A A dput+0x1c8/0x1e0
> [A A 694.594745]A A __fput+0x172/0x1e0
> [A A 694.595103]A A ____fput+0xe/0x10
> [A A 694.595463]A A task_work_run+0x80/0xa0
> [A A 694.595886]A A do_exit+0x2d6/0xb50
> [A A 694.596323]A A ? __do_page_fault+0x288/0x4a0
> [A A 694.596818]A A do_group_exit+0x47/0xb0
> [A A 694.597249]A A SyS_exit_group+0x14/0x20
> [A A 694.597682]A A entry_SYSCALL_64_fastpath+0x1a/0xa5
> [A A 694.598198] RIP: 0033:0x7ff77a5e78c8
> [A A 694.598612] RSP: 002b:00007ffc5aece318 EFLAGS: 00000246 ORIG_RAX:
> 00000000000000e7
> [A A 694.599804] RAX: ffffffffffffffda RBX: 0000000000000000 RCX:
> 00007ff77a5e78c8
> [A A 694.600609] RDX: 0000000000000000 RSI: 000000000000003c RDI:
> 0000000000000000
> [A A 694.601424] RBP: 00007ff77a8da618 R08: 00000000000000e7 R09:
> ffffffffffffff98
> [A A 694.602224] R10: 0000000000000003 R11: 0000000000000246 R12:
> 0000000000000001
> [A A 694.603151] R13: 00007ff77a8dbc60 R14: 0000000000000000 R15:
> 0000000000000000
> [A A 694.603984] Code: 60 f3 c5 81 e8 2e 7e 03 00 0f 0b 48 c7 c6 60 f3
> c5 81 4c 89 e7 e8 1d 7e 03 00 0f 0b 48 c7 c6 00 f4 c5 81 4c 89 e7 e8
> 0c 7e 03 00 <0f> 0b 48 c7 c6 38 f3 c5 81 4c 89 e7 e8 fb 7d 03 00 0f
> 0b 48 c7A 
> [A A 694.606500] RIP: __delete_from_page_cache+0x344/0x410 RSP:
> ffffc900019d7a88
> [A A 694.607426] ---[ end trace 55e6b04ae95d8ce3 ]---
> 
> BTW, this was on 4.13.0-rc3 + your patches.A A Simple test program is
> below.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
