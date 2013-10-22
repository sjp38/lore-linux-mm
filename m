Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f78.google.com (mail-vb0-f78.google.com [209.85.212.78])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6D26B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 09:44:25 -0400 (EDT)
Received: by mail-vb0-f78.google.com with SMTP id f12so8418vbg.9
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 06:44:25 -0700 (PDT)
Received: from psmtp.com ([74.125.245.191])
        by mx.google.com with SMTP id e5si10089415pbj.98.2013.10.22.08.16.18
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 08:16:19 -0700 (PDT)
Received: from [92.224.90.110] ([92.224.90.110]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0MKIEQ-1VWz021YEY-001hxc for <linux-mm@kvack.org>;
 Tue, 22 Oct 2013 17:16:16 +0200
Message-ID: <526696BF.6050909@gmx.de>
Date: Tue, 22 Oct 2013 17:16:15 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: fuzz tested 32 bit user mode linux image hangs at in histfs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org


When I fuzz testing a 32 bit UML at a 32 bit host (guest 3.12.-rc6-x, host 3.11.6) with trinity
and use hostfs for the victom files for trinity. then trintiy often hangs while trying to finish.

At the host I do have 1 process eating 100% CPU power of 1 core. A back trace of thet linux process at the hosts gives :

tfoerste@n22 ~ $ sudo gdb /usr/local/bin/linux-v3.12-rc6-57-g69c88dc 16749 -n -batch -ex bt
radix_tree_next_chunk (root=0x21, iter=0x47647c60, flags=12) at lib/radix-tree.c:769
769                                     while (++offset < RADIX_TREE_MAP_SIZE) {
#0  radix_tree_next_chunk (root=0x21, iter=0x47647c60, flags=12) at lib/radix-tree.c:769
#1  0x080cc13e in find_get_pages (mapping=0x483ed240, start=0, nr_pages=14, pages=0xc) at mm/filemap.c:844
#2  0x080d5caa in pagevec_lookup (pvec=0x47647cc4, mapping=0x21, start=33, nr_pages=33) at mm/swap.c:914
#3  0x080d609a in truncate_inode_pages_range (mapping=0x483ed240, lstart=0, lend=-1) at mm/truncate.c:241
#4  0x080d643f in truncate_inode_pages (mapping=0x21, lstart=51539607585) at mm/truncate.c:358
#5  0x08260838 in hostfs_evict_inode (inode=0x483ed188) at fs/hostfs/hostfs_kern.c:242
#6  0x0811a8cf in evict (inode=0x483ed188) at fs/inode.c:549
#7  0x0811b2ad in iput_final (inode=<optimized out>) at fs/inode.c:1391
#8  iput (inode=0x483ed188) at fs/inode.c:1409
#9  0x08117648 in dentry_iput (dentry=<optimized out>) at fs/dcache.c:331
#10 d_kill (dentry=0x47d6d580, parent=0x47d95d10) at fs/dcache.c:477
#11 0x08118068 in dentry_kill (dentry=<optimized out>, unlock_on_failure=<optimized out>) at fs/dcache.c:586
#12 dput (dentry=0x47d6d580) at fs/dcache.c:641
#13 0x08104903 in __fput (file=0x47471840) at fs/file_table.c:264
#14 0x0810496b in ____fput (work=0x47471840) at fs/file_table.c:282
#15 0x08094496 in task_work_run () at kernel/task_work.c:123
#16 0x0807efd2 in exit_task_work (task=<optimized out>) at include/linux/task_work.h:21
#17 do_exit (code=1196535808) at kernel/exit.c:787
#18 0x0807f5dd in do_group_exit (exit_code=0) at kernel/exit.c:920
#19 0x0807f649 in SYSC_exit_group (error_code=<optimized out>) at kernel/exit.c:931
#20 SyS_exit_group (error_code=0) at kernel/exit.c:929
#21 0x08062984 in handle_syscall (r=0x4763b1d4) at arch/um/kernel/skas/syscall.c:35
#22 0x08074fb5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#23 userspace (regs=0x4763b1d4) at arch/um/os-Linux/skas/process.c:431
#24 0x0805f750 in fork_handler () at arch/um/kernel/process.c:160
#25 0x00000000 in ?? ()


Last message of trinity's watchdog are :

...
[watchdog] exit_reason=2, but 2 children still running.
Bailing main loop. Exit reason: Reached maximum syscall count.
[watchdog] Reached limit 10001. Telling children to exit.
[watchdog] [1516] Watchdog exiting


I'm unsure if this is only UML specific, interesting for the fs people or mm or ... ?


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
