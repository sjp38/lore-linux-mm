Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA10726
	for <linux-mm@kvack.org>; Sun, 29 Dec 2002 02:18:44 -0800 (PST)
Message-ID: <3E0ECC02.6CEBD613@digeo.com>
Date: Sun, 29 Dec 2002 02:18:42 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: shpte scheduling-inside-spinlock bug
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is nasty.  vtruncate takes i_shared_lock:

Breakpoint 1, schedule () at kernel/sched.c:984
984                             printk(KERN_ERR "bad: scheduling while atomic!\n");
(gdb) bt
#0  schedule () at kernel/sched.c:984
#1  0xc05e1c3c in ?? ()
#2  0xc0124996 in schedule_timeout (timeout=-1069755296) at kernel/timer.c:1013
#3  0xc011a6e8 in io_schedule_timeout (timeout=25) at kernel/sched.c:1771
#4  0xc02087f7 in blk_congestion_wait (rw=1, timeout=25) at drivers/block/ll_rw_blk.c:1572
#5  0xc013941a in try_to_free_pages (classzone=0xc033cc80, gfp_mask=466, order=0) at mm/vmscan.c:838
#6  0xc01332f8 in __alloc_pages (gfp_mask=466, order=0, zonelist=0xc033d6a0) at mm/page_alloc.c:544
#7  0xc01170ff in pte_alloc_one (mm=0xc7ae11c0, address=1266679808) at include/linux/gfp.h:69
#8  0xc0148225 in pte_unshare (mm=0xc7ae11c0, pmd=0xc04cc2e0, address=1266679808) at mm/ptshare.c:144
#9  0xc01490ca in zap_shared_range (tlb=0xc05e1e90, pmd=0xc04cc2e0, address=1266679808, end=1267122176)
    at mm/ptshare.c:647
#10 0xc013b074 in zap_pmd_range (tlb=0xc05e1e90, dir=0xc7ae0f08, address=1265049600, size=2072576) at mm/memory.c:490
#11 0xc013b125 in unmap_page_range (tlb=0xc05e1e90, vma=0xc617cc20, address=1265049600, end=1267122176)
    at mm/memory.c:516
#12 0xc013b252 in zap_page_range (vma=0xc617cc20, address=1265049600, size=56000512) at mm/memory.c:571
#13 0xc013c188 in vmtruncate_list (head=0xc0f65f84, pgoff=36726) at mm/memory.c:1134
#14 0xc013c254 in vmtruncate (inode=0xc0f65eb0, offset=150429014) at mm/memory.c:1163
#15 0xc0162a37 in inode_setattr (inode=0xc0f65eb0, attr=0xc05e1f60) at fs/attr.c:76
#16 0xc019553e in ext2_setattr (dentry=0xc6f6c2a0, iattr=0xc05e1f60) at fs/ext2/inode.c:1242
#17 0xc0162cf9 in notify_change (dentry=0xc6f6c2a0, attr=0xc05e1f60) at fs/attr.c:169
#18 0xc01497c7 in do_truncate (dentry=0xc6f6c2a0, length=150429014) at fs/open.c:90
#19 0xc0149d23 in sys_ftruncate64 (fd=3, length=150429014) at fs/open.c:197
#20 0xc010aa13 in syscall_call () at include/linux/kallsyms.h:39
Cannot access memory at address 0xbffff968

We would like to not hold i_shared_lock across the zap_pte_range() call
anyway, for scheduling latency reasons.

But I suspect that i_shared_lock is the only thing which prevents the
vma from disappearing while truncate is playing with it.

umm...  I think we can just turn i_shared_lock into a semaphore.  Nests
inside mmap_sem.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
