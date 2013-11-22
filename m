Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 323376B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:35:42 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so706804eaj.7
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:35:41 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id j44si7498595eep.178.2013.11.22.12.35.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Nov 2013 12:35:41 -0800 (PST)
Received: from [192.168.178.21] ([92.224.129.130]) by mail.gmx.com (mrgmx003)
 with ESMTPSA (Nemesis) id 0LrNE4-1VXhUu1cku-0134Gm for <linux-mm@kvack.org>;
 Fri, 22 Nov 2013 21:35:40 +0100
Message-ID: <528FC01A.6000300@gmx.de>
Date: Fri, 22 Nov 2013 21:35:38 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs in
 radix_tree_next_chunk()
References: <526696BF.6050909@gmx.de>	<CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>	<5266A698.10400@gmx.de>	<5266B60A.1000005@nod.at>	<52715AD1.7000703@gmx.de> <CALYGNiPvJF1u8gXNcX1AZR5-VkGqJnaose84KBbdaoBAq8aoGQ@mail.gmail.com> <527AB23D.2060305@gmx.de> <527AB51B.1020005@nod.at>
In-Reply-To: <527AB51B.1020005@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On 11/06/2013 10:31 PM, Richard Weinberger wrote:
> Can you please ask gdb for the value of offset?

With this diff against latest Linus tree v3.12-11355-g57498f9 :

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7811ed3..54d9802 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -750,6 +750,7 @@ restart:
        /* Index outside of the tree */
        if (offset >= RADIX_TREE_MAP_SIZE)
                return NULL;
+       printk ("offset a: %lu \n", offset);

        node = rnode;
        while (1) {
@@ -770,6 +771,7 @@ restart:
                                        if (node->slots[offset])
                                                break;
                                }
+                       printk ("offset b: %lu \n", offset);
                        index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
                        index += offset << shift;
                        /* Overflow after ~0UL */
@@ -812,6 +814,7 @@ restart:
                }
        }

+       printk ("offset c: %lu \n", offset);
        return node->slots + offset;
 }
 EXPORT_SYMBOL(radix_tree_next_chunk);


I got today these syslog message when the trinity process hangs at a 32 bit Gentoo linux:


Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset c: 63
Nov 22 21:29:29 trinity kernel: offset a: 0
Nov 22 21:29:29 trinity kernel: offset b: 3
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset c: 63
Nov 22 21:29:29 trinity kernel: offset a: 0
Nov 22 21:29:29 trinity kernel: offset b: 3
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity sshd[1299]: pam_unix(sshd:session): session closed for user tfoerste
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset c: 63
Nov 22 21:29:29 trinity kernel: offset a: 0
Nov 22 21:29:29 trinity kernel: offset b: 3
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:29 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset c: 63
Nov 22 21:29:30 trinity kernel: offset a: 0
Nov 22 21:29:30 trinity kernel: offset b: 3
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset c: 63
Nov 22 21:29:30 trinity kernel: offset a: 0
Nov 22 21:29:30 trinity kernel: offset b: 3
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity sshd[1533]: pam_unix(sshd:session): session opened for user root by (uid=0)
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset b: 63
Nov 22 21:29:30 trinity kernel: offset c: 63
Nov 22 21:29:30 trinity kernel: offset a: 0
Nov 22 21:29:30 trinity kernel: offset b: 3
Nov 22 21:29:31 trinity kernel: offset b: 63
Nov 22 21:29:31 trinity kernel: offset b: 63
Nov 22 21:29:31 trinity kernel: offset b: 63
Nov 22 21:29:31 trinity kernel: offset b: 63
Nov 22 21:29:31 trinity kernel: offset b: 63
Nov 22 21:29:31 trinity kernel: offset c: 63
Nov 22 21:29:31 trinity shutdown[1536]: shutting down for system halt
Nov 22 21:29:31 trinity init: Switching to runlevel: 0


FWIW gdb's output :


tfoerste@n22 ~/devel/linux $ sudo gdb /home/tfoerste/devel/linux/linux 3612 -n -batch -ex bt
0x083d3c83 in memcpy ()
#0  0x083d3c83 in memcpy ()
#1  0x080a6257 in log_store (facility=0, level=4, flags=LOG_NEWLINE, ts_nsec=0, dict=0x86101e0 <__log_buf+25512> "\200=\355\265D", dict_len=0, text=0x86101e0 <__log_buf+25512> "\200=\355\265D", text_len=13) at kernel/printk/printk.c:344
#2  0x080a7158 in vprintk_emit (facility=0, level=4, dict=0x0, dictlen=0, fmt=0x63a8 <Address 0x63a8 out of bounds>, args=0x63a8 <Address 0x63a8 out of bounds>) at kernel/printk/printk.c:1610
#3  0x08423845 in printk (fmt=0x63a8 <Address 0x63a8 out of bounds>) at kernel/printk/printk.c:1690
#4  0x0829c39e in radix_tree_next_chunk (root=0x63a8, iter=0x3f, flags=0) at lib/radix-tree.c:774
#5  0x080cc78e in find_get_pages (mapping=0x48c21010, start=0, nr_pages=14, pages=0x86101e0 <__log_buf+25512>) at mm/filemap.c:844
#6  0x080d654a in pagevec_lookup (pvec=0x49bffcc8, mapping=0x63a8, start=25512, nr_pages=25512) at mm/swap.c:937
#7  0x080d694a in truncate_inode_pages_range (mapping=0x48c21010, lstart=0, lend=-1) at mm/truncate.c:241
#8  0x080d6cef in truncate_inode_pages (mapping=0x63a8, lstart=603765886628684712) at mm/truncate.c:358
#9  0x08260a48 in hostfs_evict_inode (inode=0x48c20f58) at fs/hostfs/hostfs_kern.c:233
#10 0x0811b46f in evict (inode=0x48c20f58) at fs/inode.c:549
#11 0x0811bf5d in iput_final (inode=<optimized out>) at fs/inode.c:1419
#12 iput (inode=0x48c20f58) at fs/inode.c:1437
#13 0x08118858 in dentry_iput (dentry=<optimized out>) at fs/dcache.c:300
#14 d_kill (parent=<optimized out>, dentry=<optimized out>) at fs/dcache.c:447
#15 dentry_kill (dentry=0x4957de70, unlock_on_failure=<optimized out>) at fs/dcache.c:549
#16 0x08118b5d in dput (dentry=0x4957de70) at fs/dcache.c:605
#17 0x08105353 in __fput (file=0x48a7cd80) at fs/file_table.c:261
#18 0x081053bb in ____fput (work=0x48a7cd80) at fs/file_table.c:279
#19 0x08094486 in task_work_run () at kernel/task_work.c:123
#20 0x0807efb2 in exit_task_work (task=<optimized out>) at include/linux/task_work.h:21
#21 do_exit (code=1217397248) at kernel/exit.c:787
#22 0x0807f5fd in do_group_exit (exit_code=0) at kernel/exit.c:920
#23 0x0807f669 in SYSC_exit_group (error_code=<optimized out>) at kernel/exit.c:931
#24 SyS_exit_group (error_code=0) at kernel/exit.c:929
#25 0x08062ab4 in handle_syscall (r=0x48a787cc) at arch/um/kernel/skas/syscall.c:35
#26 0x08075115 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#27 userspace (regs=0x48a787cc) at arch/um/os-Linux/skas/process.c:431
#28 0x0805f770 in fork_handler () at arch/um/kernel/process.c:149
#29 0x00000000 in ?? ()


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
