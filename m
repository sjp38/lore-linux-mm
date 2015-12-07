Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 408B36B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 06:40:51 -0500 (EST)
Received: by qgeb1 with SMTP id b1so142063968qge.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 03:40:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z204si26977217qka.99.2015.12.07.03.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 03:40:50 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: kernel BUG at mm/filemap.c:238! (4.4.0-rc4)
Message-ID: <5665703F.4090302@redhat.com>
Date: Mon, 7 Dec 2015 12:40:47 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jstancek@redhat.com

Hi,

"ADSP018" test from LTP[1] is triggering BUG_ON below reliably for me on 4.4.0-rc4.
I'll start a bisect - if someone already sees a suspect/culprit that could narrow
it down, please let me know.

# ./aiodio_sparse -i 4 -a 8k -w 16384k -s 65536k -n 2
aiodio_sparse    0  TINFO  :  Dirtying free blocks
aiodio_sparse    0  TINFO  :  Starting I/O tests
aiodio_sparse    0  TINFO  :  Killing childrens(s)

[  637.250251] ------------[ cut here ]------------
[  637.255404] kernel BUG at mm/filemap.c:238!
[  637.260069] invalid opcode: 0000 [#1] SMP
[  637.264655] Modules linked in: loop x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul iTCO_wdt iTCO_vendor_support ipmi_devintf ppdev aesni_intel lrw gf128mul glue_helper ablk_helper cryptd ipmi_ssif lpc_ich sg pcspkr shpchp i2c_i801 mfd_core ipmi_si winbond_cir parport_pc rc_core parport ipmi_msghandler video nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sr_mod sd_mod cdrom mgag200 drm_kms_helper igb syscopyarea sysfillrect sysimgblt ptp fb_sys_fops pps_core ttm dca i2c_algo_bit drm ahci libahci crc32c_intel libata i2c_core dm_mirror dm_region_hash dm_log dm_mod
[  637.328054] CPU: 6 PID: 22523 Comm: aiodio_sparse Not tainted 4.4.0-rc4 #1
[  637.335723] Hardware name: Intel Corporation S1200RP/S1200RP, BIOS S1200RP.86B.03.01.0002.041520151123 04/15/2015
[  637.347173] task: ffff880437fab200 ti: ffff8804379f4000 task.ti: ffff8804379f4000
[  637.355522] RIP: 0010:[<ffffffff811cd141>]  [<ffffffff811cd141>] delete_from_page_cache+0x81/0x90
[  637.365433] RSP: 0018:ffff8804379f7978  EFLAGS: 00010246
[  637.371358] RAX: 002fffff80020028 RBX: ffffea000fe71c40 RCX: 0000000000000000
[  637.379319] RDX: ffff88043e410220 RSI: 0000000000000000 RDI: ffffea000fe71c40
[  637.387280] RBP: ffff8804379f79a0 R08: 0000000000000000 R09: 0000000000000001
[  637.395241] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880430b543b8
[  637.403202] R13: ffff8804379f79f0 R14: 0000000000000964 R15: 0000000000000000
[  637.411161] FS:  00007fd344bab740(0000) GS:ffff88043e400000(0000) knlGS:0000000000000000
[  637.420188] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  637.426598] CR2: 00007ffc755f8aef CR3: 0000000001ad6000 CR4: 00000000003406e0
[  637.434560] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  637.442518] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  637.450479] Stack:
[  637.452718]  ffffea000fe71c40 ffff880430b543b8 ffff8804379f79f0 0000000000000964
[  637.461009]  0000000000000000 ffff8804379f79c0 ffffffff811dee66 ffffffffffffffff
[  637.469299]  ffff8804379f7a60 ffff8804379f7b10 ffffffff811df2cb 0000000000000000
[  637.477590] Call Trace:
[  637.480316]  [<ffffffff811dee66>] truncate_inode_page+0x56/0x90
[  637.486922]  [<ffffffff811df2cb>] truncate_inode_pages_range+0x3eb/0x760
[  637.494399]  [<ffffffff811df6ac>] truncate_inode_pages_final+0x4c/0x60
[  637.501695]  [<ffffffffa02b2537>] xfs_fs_evict_inode+0x77/0x1b0 [xfs]
[  637.508881]  [<ffffffff8127c22f>] evict+0xaf/0x180
[  637.514223]  [<ffffffff8127cc6f>] iput+0x1af/0x290
[  637.519566]  [<ffffffff812763fc>] __dentry_kill+0x17c/0x1e0
[  637.525782]  [<ffffffff812776ad>] dput+0x25d/0x310
[  637.531126]  [<ffffffff81277470>] ? dput+0x20/0x310
[  637.536566]  [<ffffffff8125f904>] __fput+0x1a4/0x240
[  637.542102]  [<ffffffff8125f9de>] ____fput+0xe/0x10
[  637.547542]  [<ffffffff810b91a7>] task_work_run+0x77/0xa0
[  637.553565]  [<ffffffff81098fdf>] do_exit+0x33f/0xc60
[  637.559199]  [<ffffffff8109998c>] do_group_exit+0x4c/0xc0
[  637.565221]  [<ffffffff810a7a11>] get_signal+0x331/0x8f0
[  637.571147]  [<ffffffff8101d3c7>] do_signal+0x37/0x680
[  637.576878]  [<ffffffff81113ab3>] ? rcu_read_lock_sched_held+0x93/0xa0
[  637.584160]  [<ffffffff8123303e>] ? kfree+0x1ae/0x270
[  637.589794]  [<ffffffff8108f2e4>] ? exit_to_usermode_loop+0x33/0xac
[  637.596785]  [<ffffffff8108f30f>] exit_to_usermode_loop+0x5e/0xac
[  637.603584]  [<ffffffff81003d0b>] syscall_return_slowpath+0xbb/0x130
[  637.610673]  [<ffffffff81761ada>] int_ret_from_sys_call+0x25/0x9f
[  637.617469] Code: e8 65 3d 59 00 4c 89 ef e8 1d 72 07 00 4d 85 f6 74 06 48 89 df 41 ff d6 48 89 df e8 1a fb 00 00 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> 0b 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55
[  637.639172] RIP  [<ffffffff811cd141>] delete_from_page_cache+0x81/0x90
[  637.646464]  RSP <ffff8804379f7978>

Regards,
Jan

[1] https://github.com/linux-test-project/ltp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
