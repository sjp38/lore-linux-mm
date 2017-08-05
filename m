Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A57046B025F
	for <linux-mm@kvack.org>; Sat,  5 Aug 2017 11:52:43 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k82so3228421oih.1
        for <linux-mm@kvack.org>; Sat, 05 Aug 2017 08:52:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o82si1889764oib.359.2017.08.05.08.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Aug 2017 08:52:42 -0700 (PDT)
Date: Sat, 5 Aug 2017 08:52:41 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: kernel panic on null pointer on page->mem_cgroup
Message-ID: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux F2FS Dev Mailing List <linux-f2fs-devel@lists.sourceforge.net>, linux-mm@kvack.org

Hi Johannes,

Can I ask your help about the below panic which is annoying me recently.
I'm currently testing xfstests with 4.13-rc2, and have hit the below panic
very randomly.

[ 3722.366490] BUG: unable to handle kernel NULL pointer dereference at 00000000000003b0
[ 3722.378815] IP: test_clear_page_writeback+0x12e/0x2c0
[ 3722.384931] PGD 3fb77067 
[ 3722.384932] P4D 3fb77067 
[ 3722.389222] PUD 1302f067 
[ 3722.392676] PMD 0 
[ 3722.407447] 
[ 3722.416459] Oops: 0000 [#1] SMP
[ 3722.424191] Modules linked in: quota_v2 quota_tree dm_snapshot dm_bufio dm_flakey f2fs(O) ppdev joydev input_leds serio_raw snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd parport_pc soundcore mac_hid i2c_piix4 parport ib_iser rdma_cm iw_cm ib_cm ib_core configfs iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi autofs4 btrfs raid10 raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath linear hid_generic usbhid hid crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc aesni_intel aes_x86_64 crypto_simd glue_helper cryptd ahci psmouse libahci e1000 pata_acpi video [last unloaded: scsi_debug]
[ 3722.494822] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G           O    4.13.0-rc2+ #7
[ 3722.509659] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[ 3722.523018] task: ffff8e3abe32bc00 task.stack: ffffab1e801f0000
[ 3722.534108] RIP: 0010:test_clear_page_writeback+0x12e/0x2c0
[ 3722.547281] RSP: 0018:ffff8e3abfd03d78 EFLAGS: 00010046
[ 3722.561761] RAX: 0000000000000000 RBX: ffffdb59c03f8900 RCX: ffffffffffffffe8
[ 3722.595343] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffff8e3abffeb000
[ 3722.615108] RBP: ffff8e3abfd03da8 R08: 0000000000020059 R09: 00000000fffffffc
[ 3722.674717] R10: 0000000000000000 R11: 0000000000020048 R12: ffff8e3a8c39f668
[ 3722.691916] R13: 0000000000000001 R14: ffff8e3a8c39f680 R15: 0000000000000000
[ 3722.736393] FS:  0000000000000000(0000) GS:ffff8e3abfd00000(0000) knlGS:0000000000000000
[ 3722.797553] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3722.852623] CR2: 00000000000003b0 CR3: 000000002c5e1000 CR4: 00000000000406e0
[ 3722.896451] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3722.950847] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 3722.965578] Call Trace:
[ 3722.971710]  <IRQ>
[ 3722.976306]  end_page_writeback+0x47/0x70
[ 3722.983252]  f2fs_write_end_io+0x76/0x180 [f2fs]
[ 3723.012721]  bio_endio+0x9f/0x120
[ 3723.035764]  blk_update_request+0xa8/0x2f0
[ 3723.064621]  scsi_end_request+0x39/0x1d0
[ 3723.086994]  scsi_io_completion+0x211/0x690
[ 3723.116553]  scsi_finish_command+0xd9/0x120
[ 3723.143690]  scsi_softirq_done+0x127/0x150
[ 3723.170070]  __blk_mq_complete_request_remote+0x13/0x20
[ 3723.199780]  flush_smp_call_function_queue+0x56/0x110
[ 3723.233148]  generic_smp_call_function_single_interrupt+0x13/0x30
[ 3723.255267]  smp_call_function_single_interrupt+0x27/0x40
[ 3723.285327]  call_function_single_interrupt+0x89/0x90
[ 3723.309718] RIP: 0010:native_safe_halt+0x6/0x10


(gdb) l *(test_clear_page_writeback+0x12e)
0xffffffff811bae3e is in test_clear_page_writeback (./include/linux/memcontrol.h:619).
614		mod_node_page_state(page_pgdat(page), idx, val);
615		if (mem_cgroup_disabled() || !page->mem_cgroup)
616			return;
617		mod_memcg_state(page->mem_cgroup, idx, val);
618		pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
619		this_cpu_add(pn->lruvec_stat->count[idx], val);
620	}
621	
622	unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
623							gfp_t gfp_mask,

So first, without your below patch, I've confirmed that there is no problem.

   commit 00f3ca2c2d6635d ("mm: memcontrol: per-lruvec stats infrastructure")

Second, what I've figured out so far is page->mem_cgroup is already checked
above, but after that line, it just becomes NULL. Is it possible somebody can
take it away without locking the page?

Could you please shed a light on this?
Or, is there a patch to fix this already?

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
