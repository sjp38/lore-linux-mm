Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1966B0253
	for <linux-mm@kvack.org>; Sun, 22 Nov 2015 07:13:33 -0500 (EST)
Received: by iofh3 with SMTP id h3so164285871iof.3
        for <linux-mm@kvack.org>; Sun, 22 Nov 2015 04:13:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l1si6180029igx.27.2015.11.22.04.13.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Nov 2015 04:13:32 -0800 (PST)
Subject: linux-4.4-rc1: TIF_MEMDIE without SIGKILL pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
Date: Sun, 22 Nov 2015 21:13:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, oleg@redhat.com
Cc: linux-mm@kvack.org

I was updating kmallocwd in preparation for testing "[RFC 0/3] OOM detection
rework v2" patchset. I noticed an unexpected result with linux.git as of
3ad5d7e06a96 .

The problem is that an OOM victim arrives at do_exit() with TIF_MEMDIE flag
set but without pending SIGKILL. Is this correct behavior?

----------
diff --git a/kernel/exit.c b/kernel/exit.c
index 07110c6..ea5bcd0 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -656,6 +656,7 @@ void do_exit(long code)
 	int group_dead;
 	TASKS_RCU(int tasks_rcu_i);
 
+	BUG_ON(test_thread_flag(TIF_MEMDIE) && !fatal_signal_pending(current));
 	profile_task_exit(tsk);
 
 	WARN_ON(blk_needs_flush_plug(tsk));
----------

[  103.796002] ------------[ cut here ]------------
[  103.797700] kernel BUG at kernel/exit.c:659!
[  103.799314] invalid opcode: 0000 [#1] SMP
[  103.800932] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc e\
btable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel aesni_intel glue_h\
elper lrw gf128mul ablk_helper ppdev cryptd vmw_balloon serio_raw pcspkr parport_pc vmw_vmci parport shpchp i2c_piix4 sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci ata_piix\
 mptspi scsi_transport_spi mptscsih libahci libata mptbase e1000 i2c_core
[  103.820275] CPU: 1 PID: 11036 Comm: oom-tester4 Not tainted 4.4.0-rc1+ #9
[  103.822514] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  103.825459] task: ffff880078f0c200 ti: ffff880078db8000 task.ti: ffff880078db8000
[  103.827850] RIP: 0010:[<ffffffff810726ef>]  [<ffffffff810726ef>] do_exit+0xa3f/0xb40
[  103.830535] RSP: 0018:ffff880078dbbcd0  EFLAGS: 00010246
[  103.832606] RAX: 0000000000100084 RBX: 0000000000000002 RCX: 0000000000000000
[  103.834935] RDX: 00000000418004fc RSI: 0000000000000001 RDI: 0000000000000002
[  103.837314] RBP: ffff880078dbbd30 R08: 0000000000000000 R09: 0000000000000000
[  103.839595] R10: 0000000000000001 R11: ffff880078f0c930 R12: 0000000000000002
[  103.841894] R13: ffff880078f0c200 R14: ffff880078f0c200 R15: 0000000000000008
[  103.844305] FS:  00007fbf5610a740(0000) GS:ffff88007fc40000(0000) knlGS:0000000000000000
[  103.846845] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  103.849002] CR2: 000055a5c65d17d0 CR3: 0000000078dfd000 CR4: 00000000001406e0
[  103.851433] Stack:
[  103.852787]  0000000000000001 ffff880078f0c200 0000000000000046 ffff880078dbbe18
[  103.855263]  ffff880078dbbe38 ffff880078f0c200 000000005c6d8319 ffff880035dc2f40
[  103.857717]  0000000000000002 ffff880078f0c200 ffff880078dbbe38 0000000000000008
[  103.860138] Call Trace:
[  103.861603]  [<ffffffff81072877>] do_group_exit+0x47/0xc0
  include/linux/sched.h:807
  kernel/exit.c:862
[  103.863513]  [<ffffffff8107e0b2>] get_signal+0x222/0x7e0
  kernel/signal.c:2307
[  103.865395]  [<ffffffff8100f362>] do_signal+0x32/0x670
  arch/x86/kernel/signal.c:709
[  103.867219]  [<ffffffff8106a517>] ? syscall_slow_exit_work+0x4b/0x10d
  arch/x86/entry/common.c:306
[  103.869264]  [<ffffffff8106a46a>] ? exit_to_usermode_loop+0x2e/0x90
  arch/x86/include/asm/paravirt.h:816
  arch/x86/entry/common.c:237
[  103.871249]  [<ffffffff8106a488>] exit_to_usermode_loop+0x4c/0x90
  arch/x86/entry/common.c:249
[  103.873324]  [<ffffffff8100355b>] syscall_return_slowpath+0xbb/0x130
  arch/x86/entry/common.c:282
  arch/x86/entry/common.c:344
[  103.875322]  [<ffffffff816e85da>] int_ret_from_sys_call+0x25/0x9f
  arch/x86/entry/entry_64.S:282
[  103.877228] Code: ba 9f 81 31 c0 e8 ed 6c 0c 00 48 8b b8 90 00 00 00 e8 e6 6b 02 00 e9 31 fb ff ff 49 8b 46 08 48 8b 40 08 a8 04 0f 85 bd 00 00 00 <0f> 0b 4c 89 f7 e8 77 80 0a 00 e9 fb f6 ff ff 49 8b 96 c0 05 00
[  103.884329] RIP  [<ffffffff810726ef>] do_exit+0xa3f/0xb40
  kernel/exit.c:659
[  103.886121]  RSP <ffff880078dbbcd0>
[  103.887537] ---[ end trace a5e757a180b4cf32 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
