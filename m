Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 84A996B025C
	for <linux-mm@kvack.org>; Sun, 10 Nov 2013 10:14:13 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so4155221pdj.34
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 07:14:13 -0800 (PST)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id ei3si12955579pbc.260.2013.11.10.07.14.10
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 07:14:12 -0800 (PST)
Received: from [192.168.178.21] ([78.54.142.24]) by mail.gmx.com (mrgmx001)
 with ESMTPSA (Nemesis) id 0LpbJm-1W8YXm2dja-00fVD5 for <linux-mm@kvack.org>;
 Sun, 10 Nov 2013 16:14:09 +0100
Message-ID: <527FA2BE.6090307@gmx.de>
Date: Sun, 10 Nov 2013 16:14:06 +0100
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
> Am 06.11.2013 22:18, schrieb Toralf FA?rster:
>> On 11/06/2013 05:06 PM, Konstantin Khlebnikov wrote:
>>> In this case it must stop after scanning whole tree in line:
>>> /* Overflow after ~0UL */
>>> if (!index)
>>>   return NULL;
>>>
>>
>> A fresh current example with latest git tree shows that lines 769 and 770 do alternate :
> 
> Can you please ask gdb for the value of offset?
> 
> Thanks,
> //richard
> 

With this change 

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 7811ed3..b2e9db5 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -767,6 +767,7 @@ restart:
                                                offset + 1);
                        else
                                while (++offset < RADIX_TREE_MAP_SIZE) {
+                                       printk ("node->slots[offset] %p offeset %lu\n", node->slots[offset], offset);
                                        if (node->slots[offset])
                                                break;
                                }

against v3.12-48-gbe408cd these are the last lines in the syslog of the UML
(command: ssh root@trinity "tail -f /var/log/messages")

...
Nov 10 13:26:32 trinity kernel: node->slots[offset]   (null) offeset 23
Nov 10 13:26:32 trinity kernel: node->slots[offset]   (null) offeset 24
Nov 10 13:26:32 trinity kernel: node->slots[offset]   (null) offeset 25
Nov 10 13:26:32 trinity kernel: node->slots[offset]   (null) offeset 26
Nov 10 13:26:32 trinity kernel: node->slots[offset]   (null) offeset 27
...
Nov 10 13:49:11 trinity sshd[3628]: pam_unix(sshd:session): session closed for user tfoerste
Nov 10 13:49:15 trinity sshd[3858]: pam_unix(sshd:session): session opened for user tfoerste by (uid=0)
Nov 10 13:49:15 trinity su[3862]: Successful su for root by root
Nov 10 13:49:15 trinity su[3862]: + ??? root:root
Nov 10 13:49:15 trinity su[3862]: pam_unix(su:session): session opened for user root by (uid=0)
Nov 10 13:49:15 trinity su[3862]: pam_unix(su:session): session closed for user root
Nov 10 13:49:15 trinity tfoerste: M=/mnt/hostfs


It is now at (I left the computer for a while) and I gdo et this output of 3 subsequent calls of the gdb back trace at the host system :


tfoerste@n22 ~/devel/linux $ sudo gdb /home/tfoerste/devel/linux/linux 8946 -n -batch -ex bt
string (buf=0x8609ef9 <textbuf.25662+25> "ll) offeset 4\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c0980 <null+3> "ll)", spec=...) at lib/vsprintf.c:524
524                             *buf = *s;
#0  string (buf=0x8609ef9 <textbuf.25662+25> "ll) offeset 4\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c0980 <null+3> "ll)", spec=...) at lib/vsprintf.c:524
#1  0x0829ac42 in pointer (fmt=0x75 <Address 0x75 out of bounds>, buf=0x8609ef4 <textbuf.25662+20> "  (null) offeset 4\n", end=0x5 <Address 0x5 out of bounds>, ptr=0x0, spec=...) at lib/vsprintf.c:1239
#2  0x0829a9dd in vsnprintf (buf=0x8609ee0 <textbuf.25662> "node->slots[offset]   (null) offeset 4\n", size=992, fmt=0x8609efc <textbuf.25662+28> " offeset 4\n", args=0x4370fc10 "") at lib/vsprintf.c:1667
#3  0x0829b0f7 in vscnprintf (buf=0x75 <Address 0x75 out of bounds>, size=992, fmt=0x75 <Address 0x75 out of bounds>, args=0x75 <Address 0x75 out of bounds>) at lib/vsprintf.c:1776
#4  0x080a6968 in vprintk_emit (facility=0, level=-1, dict=0x0, dictlen=0, fmt=0x75 <Address 0x75 out of bounds>, args=0x75 <Address 0x75 out of bounds>) at kernel/printk/printk.c:1548
#5  0x08419b05 in printk (fmt=0x75 <Address 0x75 out of bounds>) at kernel/printk/printk.c:1690
#6  0x08296a8d in radix_tree_next_chunk (root=0x75, iter=0x4370fc54, flags=0) at lib/radix-tree.c:770
#7  0x080cc1fe in find_get_pages (mapping=0x44bb707c, start=0, nr_pages=14, pages=0x5) at mm/filemap.c:844
#8  0x080d5d6a in pagevec_lookup (pvec=0x4370fcb8, mapping=0x75, start=117, nr_pages=117) at mm/swap.c:914
#9  0x080d615a in truncate_inode_pages_range (mapping=0x44bb707c, lstart=32809, lend=-1) at mm/truncate.c:241
#10 0x080d64ff in truncate_inode_pages (mapping=0x75, lstart=21474836597) at mm/truncate.c:358
#11 0x080d6a0d in truncate_pagecache (inode=0x75, newsize=32809) at mm/truncate.c:597
#12 0x081d9118 in nfs_vmtruncate (offset=<optimized out>, inode=<optimized out>) at fs/nfs/inode.c:554
#13 nfs_setattr_update_inode (inode=0x44bb6fc4, attr=0x8029) at fs/nfs/inode.c:585
#14 0x081e73ba in nfs_proc_setattr (dentry=0x75, fattr=0x0, sattr=0x4370fe1c) at fs/nfs/proc.c:142
#15 0x081da99c in nfs_setattr (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/nfs/inode.c:523
#16 0x0811c256 in notify_change (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/attr.c:248
#17 0x081011bb in do_truncate (dentry=0x47fb5b00, length=502511206441, time_attrs=5, filp=0x8609efc <textbuf.25662+28>) at fs/open.c:60
#18 0x081013f2 in do_sys_ftruncate (fd=117, length=32809, small=1) at fs/open.c:190
#19 0x081016da in SYSC_ftruncate (length=<optimized out>, fd=<optimized out>) at fs/open.c:200
#20 SyS_ftruncate (fd=129, length=32809) at fs/open.c:198
#21 0x08062974 in handle_syscall (r=0x473c9fd4) at arch/um/kernel/skas/syscall.c:35
#22 0x08074fa5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#23 userspace (regs=0x473c9fd4) at arch/um/os-Linux/skas/process.c:431
#24 0x0805f740 in fork_handler () at arch/um/kernel/process.c:160
#25 0x00000000 in ?? ()

tfoerste@n22 ~/devel/linux $ sudo gdb /home/tfoerste/devel/linux/linux 8946 -n -batch -ex bt
0x082995e7 in string (buf=0x8609ef8 <textbuf.25662+24> "ull) offeset 57\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c097f <null+2> "ull)", spec=...) at lib/vsprintf.c:524
524                             *buf = *s;
#0  0x082995e7 in string (buf=0x8609ef8 <textbuf.25662+24> "ull) offeset 57\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c097f <null+2> "ull)", spec=...) at lib/vsprintf.c:524
#1  0x0829ac42 in pointer (fmt=0x75 <Address 0x75 out of bounds>, buf=0x8609ef4 <textbuf.25662+20> "  (null) offeset 57\n", end=0x5 <Address 0x5 out of bounds>, ptr=0x0, spec=...) at lib/vsprintf.c:1239
#2  0x0829a9dd in vsnprintf (buf=0x8609ee0 <textbuf.25662> "node->slots[offset]   (null) offeset 57\n", size=992, fmt=0x8609efc <textbuf.25662+28> " offeset 57\n", args=0x4370fc10 "") at lib/vsprintf.c:1667
#3  0x0829b0f7 in vscnprintf (buf=0x75 <Address 0x75 out of bounds>, size=992, fmt=0x75 <Address 0x75 out of bounds>, args=0x75 <Address 0x75 out of bounds>) at lib/vsprintf.c:1776
#4  0x080a6968 in vprintk_emit (facility=0, level=-1, dict=0x0, dictlen=0, fmt=0x75 <Address 0x75 out of bounds>, args=0x75 <Address 0x75 out of bounds>) at kernel/printk/printk.c:1548
#5  0x08419b05 in printk (fmt=0x75 <Address 0x75 out of bounds>) at kernel/printk/printk.c:1690
#6  0x08296a8d in radix_tree_next_chunk (root=0x75, iter=0x4370fc54, flags=0) at lib/radix-tree.c:770
#7  0x080cc1fe in find_get_pages (mapping=0x44bb707c, start=0, nr_pages=14, pages=0x5) at mm/filemap.c:844
#8  0x080d5d6a in pagevec_lookup (pvec=0x4370fcb8, mapping=0x75, start=117, nr_pages=117) at mm/swap.c:914
#9  0x080d615a in truncate_inode_pages_range (mapping=0x44bb707c, lstart=32809, lend=-1) at mm/truncate.c:241
#10 0x080d64ff in truncate_inode_pages (mapping=0x75, lstart=21474836597) at mm/truncate.c:358
#11 0x080d6a0d in truncate_pagecache (inode=0x75, newsize=32809) at mm/truncate.c:597
#12 0x081d9118 in nfs_vmtruncate (offset=<optimized out>, inode=<optimized out>) at fs/nfs/inode.c:554
#13 nfs_setattr_update_inode (inode=0x44bb6fc4, attr=0x8029) at fs/nfs/inode.c:585
#14 0x081e73ba in nfs_proc_setattr (dentry=0x75, fattr=0x0, sattr=0x4370fe1c) at fs/nfs/proc.c:142
#15 0x081da99c in nfs_setattr (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/nfs/inode.c:523
#16 0x0811c256 in notify_change (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/attr.c:248
#17 0x081011bb in do_truncate (dentry=0x47fb5b00, length=502511206441, time_attrs=5, filp=0x8609efc <textbuf.25662+28>) at fs/open.c:60
#18 0x081013f2 in do_sys_ftruncate (fd=117, length=32809, small=1) at fs/open.c:190
#19 0x081016da in SYSC_ftruncate (length=<optimized out>, fd=<optimized out>) at fs/open.c:200
#20 SyS_ftruncate (fd=129, length=32809) at fs/open.c:198
#21 0x08062974 in handle_syscall (r=0x473c9fd4) at arch/um/kernel/skas/syscall.c:35
#22 0x08074fa5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#23 userspace (regs=0x473c9fd4) at arch/um/os-Linux/skas/process.c:431
#24 0x0805f740 in fork_handler () at arch/um/kernel/process.c:160
#25 0x00000000 in ?? ()


tfoerste@n22 ~/devel/linux $ sudo gdb /home/tfoerste/devel/linux/linux 8946 -n -batch -ex bt
string (buf=0x8609efb <textbuf.25662+27> ") offeset 20\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c0982 <null+5> ")", spec=...) at lib/vsprintf.c:524
524                             *buf = *s;
#0  string (buf=0x8609efb <textbuf.25662+27> ") offeset 20\n", end=0x860a2c0 <cont> "4721fffc:  [<00000000>] 0x0k_handler+0x60/0x700360d/0x4e00ffff 00000000 4721fc0c:  [<0805f8cc>] __switch_to+0x5c/0xf0", s=0x84c0982 <null+5> ")", spec=...) at lib/vsprintf.c:524
#1  0x0829ac42 in pointer (fmt=0x6c <Address 0x6c out of bounds>, buf=0x8609ef4 <textbuf.25662+20> "  (null) offeset 20\n", end=0x5 <Address 0x5 out of bounds>, ptr=0x0, spec=...) at lib/vsprintf.c:1239
#2  0x0829a9dd in vsnprintf (buf=0x8609ee0 <textbuf.25662> "node->slots[offset]   (null) offeset 20\n", size=992, fmt=0x8609efc <textbuf.25662+28> " offeset 20\n", args=0x4370fc10 "") at lib/vsprintf.c:1667
#3  0x0829b0f7 in vscnprintf (buf=0x6c <Address 0x6c out of bounds>, size=992, fmt=0x6c <Address 0x6c out of bounds>, args=0x6c <Address 0x6c out of bounds>) at lib/vsprintf.c:1776
#4  0x080a6968 in vprintk_emit (facility=0, level=-1, dict=0x0, dictlen=0, fmt=0x6c <Address 0x6c out of bounds>, args=0x6c <Address 0x6c out of bounds>) at kernel/printk/printk.c:1548
#5  0x08419b05 in printk (fmt=0x6c <Address 0x6c out of bounds>) at kernel/printk/printk.c:1690
#6  0x08296a8d in radix_tree_next_chunk (root=0x6c, iter=0x4370fc54, flags=0) at lib/radix-tree.c:770
#7  0x080cc1fe in find_get_pages (mapping=0x44bb707c, start=0, nr_pages=14, pages=0x5) at mm/filemap.c:844
#8  0x080d5d6a in pagevec_lookup (pvec=0x4370fcb8, mapping=0x6c, start=108, nr_pages=108) at mm/swap.c:914
#9  0x080d615a in truncate_inode_pages_range (mapping=0x44bb707c, lstart=32809, lend=-1) at mm/truncate.c:241
#10 0x080d64ff in truncate_inode_pages (mapping=0x6c, lstart=21474836588) at mm/truncate.c:358
#11 0x080d6a0d in truncate_pagecache (inode=0x6c, newsize=32809) at mm/truncate.c:597
#12 0x081d9118 in nfs_vmtruncate (offset=<optimized out>, inode=<optimized out>) at fs/nfs/inode.c:554
#13 nfs_setattr_update_inode (inode=0x44bb6fc4, attr=0x8029) at fs/nfs/inode.c:585
#14 0x081e73ba in nfs_proc_setattr (dentry=0x6c, fattr=0x0, sattr=0x4370fe1c) at fs/nfs/proc.c:142
#15 0x081da99c in nfs_setattr (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/nfs/inode.c:523
#16 0x0811c256 in notify_change (dentry=0x47fb5b00, attr=0x4370fe1c) at fs/attr.c:248
#17 0x081011bb in do_truncate (dentry=0x47fb5b00, length=463856500777, time_attrs=5, filp=0x8609efc <textbuf.25662+28>) at fs/open.c:60
#18 0x081013f2 in do_sys_ftruncate (fd=108, length=32809, small=1) at fs/open.c:190
#19 0x081016da in SYSC_ftruncate (length=<optimized out>, fd=<optimized out>) at fs/open.c:200
#20 SyS_ftruncate (fd=129, length=32809) at fs/open.c:198
#21 0x08062974 in handle_syscall (r=0x473c9fd4) at arch/um/kernel/skas/syscall.c:35
#22 0x08074fa5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#23 userspace (regs=0x473c9fd4) at arch/um/os-Linux/skas/process.c:431
#24 0x0805f740 in fork_handler () at arch/um/kernel/process.c:160
#25 0x00000000 in ?? ()



The fuzzer trinity is still running and tries to kill one of it childs 
(the output comes from a ssh command, which started trinity in the UML):

...
w[atchdog] sending SIGKILL to pid 4345. [diff:261]
[watchdog] sending SIGKILL to pid 4346. [diff:263]
[watchdog] sending SIGKILL to pid 4344. [diff:263]
[watchdog] sending SIGKILL to pid 4345. [diff:266]
[watchdog] sending SIGKILL to pid 4346. [diff:267]
[watchdog] sending SIGKILL to pid 4344. [diff:267]
[watchdog] sending SIGKILL to pid 4345. [diff:270]
[watchdog] sending SIGKILL to pid 4346. [diff:271]
[watchdog] sending SIGKILL to pid 4344. [diff:271]
...


but I cannot connect to the UML via ssh.


>>
>> tfoerste@n22 ~/devel/linux $ sudo gdb /usr/local/bin/linux-v3.12-48-gbe408cd 16619 -n -batch -ex bt
>> 0x08296a8c in radix_tree_next_chunk (root=0x25, iter=0x462e7c64, flags=12) at lib/radix-tree.c:770
>> 770                                             if (node->slots[offset])
>> #0  0x08296a8c in radix_tree_next_chunk (root=0x25, iter=0x462e7c64, flags=12) at lib/radix-tree.c:770
>> #1  0x080cc1fe in find_get_pages (mapping=0x462ad470, start=0, nr_pages=14, pages=0xc) at mm/filemap.c:844
>> #2  0x080d5d6a in pagevec_lookup (pvec=0x462e7cc8, mapping=0x25, start=37, nr_pages=37) at mm/swap.c:914
>> #3  0x080d615a in truncate_inode_pages_range (mapping=0x462ad470, lstart=0, lend=-1) at mm/truncate.c:241
>> #4  0x080d64ff in truncate_inode_pages (mapping=0x25, lstart=51539607589) at mm/truncate.c:358
>>
>>
>>
>>
>> tfoerste@n22 ~/devel/linux $ sudo gdb /usr/local/bin/linux-v3.12-48-gbe408cd 16619 -n -batch -ex bt
>> radix_tree_next_chunk (root=0x28, iter=0x462e7c64, flags=18) at lib/radix-tree.c:769
>> 769                                     while (++offset < RADIX_TREE_MAP_SIZE) {
>> #0  radix_tree_next_chunk (root=0x28, iter=0x462e7c64, flags=18) at lib/radix-tree.c:769
>> #1  0x080cc1fe in find_get_pages (mapping=0x462ad470, start=0, nr_pages=14, pages=0x12) at mm/filemap.c:844
>> #2  0x080d5d6a in pagevec_lookup (pvec=0x462e7cc8, mapping=0x28, start=40, nr_pages=40) at mm/swap.c:914
>> #3  0x080d615a in truncate_inode_pages_range (mapping=0x462ad470, lstart=0, lend=-1) at mm/truncate.c:241
>> #4  0x080d64ff in truncate_inode_pages (mapping=0x28, lstart=77309411368) at mm/truncate.c:358
>> #5  0x0825e388 in hostfs_evict_inode (inode=0x462ad3b8) at fs/hostfs/hostfs_kern.c:242
>> #6  0x0811a8df in evict (inode=0x462ad3b8) at fs/inode.c:549
>>
>>
> 
> 


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
