Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B147F6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:56:58 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x6so6357566oif.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:56:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d137si7515539itc.64.2016.06.14.14.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 14:56:57 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: BUG allocating pages
Message-ID: <57607DA5.3060003@oracle.com>
Date: Tue, 14 Jun 2016 17:56:53 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[  708.545446] page:ffffea0000790400 count:0 mapcount:0 mapping:          (null) index:0x1

[  708.547672] flags: 0x1fffff80000000()

[  708.548363] page dumped because: VM_BUG_ON_PAGE(!PageBuddy(page))

[  708.549505] ------------[ cut here ]------------

[  708.550264] kernel BUG at include/linux/page-flags.h:646!

[  708.551168] invalid opcode: 0000 [#1] PREEMPT SMP KASAN

[  708.552044] Modules linked in:

[  708.552640] CPU: 5 PID: 2952 Comm: trinity-c128 Tainted: G    B   W       4.7.0-rc3-next-20160614-sasha-00032-g8e3c1a2-dirty #3105

[  708.554605] task: ffff8803d2648000 ti: ffff8800c6770000 task.ti: ffff8800c6770000

[  708.555782] RIP: __rmqueue (include/linux/page-flags.h:646 mm/page_alloc.c:705 mm/page_alloc.c:1797 mm/page_alloc.c:2166)
[  708.557174] RSP: 0000:ffff8800c6776e98  EFLAGS: 00010086

[  708.557762] RAX: 0000000000000000 RBX: 0000000000000003 RCX: 0000000000000000

[  708.558500] RDX: 1ffffd40000f2087 RSI: 0000000000000086 RDI: ffffea0000790438

[  708.559241] RBP: ffff8800c6776fb8 R08: 6d75642065676170 R09: 6163656220646570

[  708.559944] R10: 0000000000000000 R11: ffff880428d6d57f R12: ffff88009dfd4138

[  708.560661] R13: ffffea0000790418 R14: 0000000000000003 R15: 0000000000000010

[  708.561376] FS:  00007f5ad8e11700(0000) GS:ffff8803d7400000(0000) knlGS:0000000000000000

[  708.562224] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

[  708.562827] CR2: 0000000000696fa0 CR3: 00000000cad6e000 CR4: 00000000000006a0

[  708.563573] Stack:

[  708.563798]  ffff8800c6776f18 ffffffff9f793633 ffffea0000790400 1ffff10018ceedde

[  708.564601]  0000000000000001 ffffea0000790420 00000000000000a0 ffffea0000790400

[  708.565550]  ffff88009dfd3000 ffffea0000000000 0000000000000001 0000000041b58ab3

[  708.566395] Call Trace:

[  708.570602] get_page_from_freelist (mm/page_alloc.c:2193 mm/page_alloc.c:2585 mm/page_alloc.c:2982)
[  708.572396] __alloc_pages_slowpath (mm/page_alloc.c:3600)
[  708.582146] __alloc_pages_nodemask (mm/page_alloc.c:3841)
[  708.587986] alloc_pages_vma (mm/mempolicy.c:2027)
[  708.589193] shmem_alloc_page (mm/shmem.c:1343 mm/shmem.c:1397)
[  708.592284] shmem_alloc_and_acct_page (mm/shmem.c:1426)
[  708.592950] shmem_getpage_gfp (mm/shmem.c:1702)
[  708.595464] shmem_write_begin (mm/shmem.c:123 mm/shmem.c:2163)
[  708.596055] generic_perform_write (mm/filemap.c:2712)
[  708.598479] __generic_file_write_iter (mm/filemap.c:2838)
[  708.599135] generic_file_write_iter (include/linux/fs.h:746 mm/filemap.c:2866)
[  708.599763] do_iter_readv_writev (fs/read_write.c:700)
[  708.602848] do_readv_writev (fs/read_write.c:847)
[  708.608499] vfs_writev (fs/read_write.c:886)
[  708.609018] do_writev (fs/read_write.c:920)
[  708.611922] SyS_writev (fs/read_write.c:989)
[  708.612430] do_syscall_64 (arch/x86/entry/common.c:350)
[  708.613040] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 708.613660] Code: 08 4c 89 ef e8 82 91 12 00 48 8b 85 08 ff ff ff 8b 40 f8 83 f8 80 74 21 48 8b bd 18 ff ff ff 48 c7 c6 80 b3 70 a9 e8 10 b2 07 00 <0f> 0b 48 c7 c7 80 25 8a ad e8 3f a2 ab 01 4c 89 e9 c7 45 98 ff

All code
========
   0:	08 4c 89 ef          	or     %cl,-0x11(%rcx,%rcx,4)
   4:	e8 82 91 12 00       	callq  0x12918b
   9:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  10:	8b 40 f8             	mov    -0x8(%rax),%eax
  13:	83 f8 80             	cmp    $0xffffff80,%eax
  16:	74 21                	je     0x39
  18:	48 8b bd 18 ff ff ff 	mov    -0xe8(%rbp),%rdi
  1f:	48 c7 c6 80 b3 70 a9 	mov    $0xffffffffa970b380,%rsi
  26:	e8 10 b2 07 00       	callq  0x7b23b
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	48 c7 c7 80 25 8a ad 	mov    $0xffffffffad8a2580,%rdi
  34:	e8 3f a2 ab 01       	callq  0x1aba278
  39:	4c 89 e9             	mov    %r13,%rcx
  3c:	c7                   	.byte 0xc7
  3d:	45 98                	rex.RB cwtl
  3f:	ff 00                	incl   (%rax)

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	48 c7 c7 80 25 8a ad 	mov    $0xffffffffad8a2580,%rdi
   9:	e8 3f a2 ab 01       	callq  0x1aba24d
   e:	4c 89 e9             	mov    %r13,%rcx
  11:	c7                   	.byte 0xc7
  12:	45 98                	rex.RB cwtl
  14:	ff 00                	incl   (%rax)
[  708.616605] RIP __rmqueue (include/linux/page-flags.h:646 mm/page_alloc.c:705 mm/page_alloc.c:1797 mm/page_alloc.c:2166)
[  708.617184]  RSP <ffff8800c6776e98>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
