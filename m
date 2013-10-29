Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 82E066B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 13:39:15 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so166695pdj.21
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 10:39:15 -0700 (PDT)
Received: from psmtp.com ([74.125.245.142])
        by mx.google.com with SMTP id gu5si16446782pac.130.2013.10.29.10.39.13
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 10:39:14 -0700 (PDT)
Received: from [85.177.119.89] ([85.177.119.89]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0LjuR3-1W7o7K1oeP-00bslz for <linux-mm@kvack.org>;
 Tue, 29 Oct 2013 18:39:11 +0100
Message-ID: <526FF2BD.8030808@gmx.de>
Date: Tue, 29 Oct 2013 18:39:09 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs at
 in hostfs
References: <526696BF.6050909@gmx.de> <CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com> <5266A698.10400@gmx.de> <5266B60A.1000005@nod.at>
In-Reply-To: <5266B60A.1000005@nod.at>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On 10/22/2013 07:29 PM, Richard Weinberger wrote:
> Am 22.10.2013 18:23, schrieb Toralf FA?rster:
>> On 10/22/2013 06:12 PM, Richard Weinberger wrote:
>>> On Tue, Oct 22, 2013 at 5:16 PM, Toralf FA?rster <toralf.foerster@gmx.de> wrote:
>>>>
>>>> When I fuzz testing a 32 bit UML at a 32 bit host (guest 3.12.-rc6-x, host 3.11.6) with trinity
>>>> and use hostfs for the victom files for trinity. then trintiy often hangs while trying to finish.
>>>>
>>>> At the host I do have 1 process eating 100% CPU power of 1 core. A back trace of thet linux process at the hosts gives :
>>>>
>>>> tfoerste@n22 ~ $ sudo gdb /usr/local/bin/linux-v3.12-rc6-57-g69c88dc 16749 -n -batch -ex bt
>>>> radix_tree_next_chunk (root=0x21, iter=0x47647c60, flags=12) at lib/radix-tree.c:769
>>>> 769                                     while (++offset < RADIX_TREE_MAP_SIZE) {
>>>> #0  radix_tree_next_chunk (root=0x21, iter=0x47647c60, flags=12) at lib/radix-tree.c:769
>>>> #1  0x080cc13e in find_get_pages (mapping=0x483ed240, start=0, nr_pages=14, pages=0xc) at mm/filemap.c:844
>>>> #2  0x080d5caa in pagevec_lookup (pvec=0x47647cc4, mapping=0x21, start=33, nr_pages=33) at mm/swap.c:914
>>>> #3  0x080d609a in truncate_inode_pages_range (mapping=0x483ed240, lstart=0, lend=-1) at mm/truncate.c:241
>>>> #4  0x080d643f in truncate_inode_pages (mapping=0x21, lstart=51539607585) at mm/truncate.c:358
>>>> #5  0x08260838 in hostfs_evict_inode (inode=0x483ed188) at fs/hostfs/hostfs_kern.c:242
>>>> #6  0x0811a8cf in evict (inode=0x483ed188) at fs/inode.c:549
>>>> #7  0x0811b2ad in iput_final (inode=<optimized out>) at fs/inode.c:1391
>>>> #8  iput (inode=0x483ed188) at fs/inode.c:1409
>>>> #9  0x08117648 in dentry_iput (dentry=<optimized out>) at fs/dcache.c:331
>>>> #10 d_kill (dentry=0x47d6d580, parent=0x47d95d10) at fs/dcache.c:477
>>>> #11 0x08118068 in dentry_kill (dentry=<optimized out>, unlock_on_failure=<optimized out>) at fs/dcache.c:586
>>>> #12 dput (dentry=0x47d6d580) at fs/dcache.c:641
>>>> #13 0x08104903 in __fput (file=0x47471840) at fs/file_table.c:264
>>>> #14 0x0810496b in ____fput (work=0x47471840) at fs/file_table.c:282
>>>> #15 0x08094496 in task_work_run () at kernel/task_work.c:123
>>>> #16 0x0807efd2 in exit_task_work (task=<optimized out>) at include/linux/task_work.h:21
>>>> #17 do_exit (code=1196535808) at kernel/exit.c:787
>>>> #18 0x0807f5dd in do_group_exit (exit_code=0) at kernel/exit.c:920
>>>> #19 0x0807f649 in SYSC_exit_group (error_code=<optimized out>) at kernel/exit.c:931
>>>> #20 SyS_exit_group (error_code=0) at kernel/exit.c:929
>>>> #21 0x08062984 in handle_syscall (r=0x4763b1d4) at arch/um/kernel/skas/syscall.c:35
>>>> #22 0x08074fb5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
>>>> #23 userspace (regs=0x4763b1d4) at arch/um/os-Linux/skas/process.c:431
>>>> #24 0x0805f750 in fork_handler () at arch/um/kernel/process.c:160
>>>> #25 0x00000000 in ?? ()
>>>>
>>>
>>> That trace is identical to the one you reported yesterday.
>>> But this time no nfs is in the game, right?
>>>
>>
>> Right - I could narrow down it in the meanwhile to hostfs only. First I
>> argued if NFS sometimes might force the issue to happen later but in the
>> mean while I don't think so.
> 
> It looks like we never find a way out of the while(1) in
> radix_tree_next_chunk().
> 
> Thanks,
> //richard
> 

But today I found a proof that it is not only fs/hostfs specific :


tfoerste@n22 ~ $ sudo gdb /home/tfoerste/devel/linux/linux 22692 -n -batch -ex bt
0x08298fcc in radix_tree_next_chunk (root=0x25, iter=0x3ba6fc4c, flags=6) at lib/radix-tree.c:770
770                                             if (node->slots[offset])
#0  0x08298fcc in radix_tree_next_chunk (root=0x25, iter=0x3ba6fc4c, flags=6) at lib/radix-tree.c:770
#1  0x080cc20e in find_get_pages (mapping=0x3b0d61dc, start=0, nr_pages=14, pages=0x6) at mm/filemap.c:844
#2  0x080d5d7a in pagevec_lookup (pvec=0x3ba6fcb0, mapping=0x25, start=37, nr_pages=37) at mm/swap.c:914
#3  0x080d616a in truncate_inode_pages_range (mapping=0x3b0d61dc, lstart=0, lend=-1) at mm/truncate.c:241
#4  0x080d650f in truncate_inode_pages (mapping=0x25, lstart=25769803813) at mm/truncate.c:358
#5  0x08205b08 in nfs4_evict_inode (inode=0x3b0d6124) at fs/nfs/nfs4super.c:101
#6  0x0811a99f in evict (inode=0x3b0d6124) at fs/inode.c:549
#7  0x0811b37d in iput_final (inode=<optimized out>) at fs/inode.c:1391
#8  iput (inode=0x3b0d6124) at fs/inode.c:1409
#9  0x081d6014 in nfs_dentry_iput (dentry=0x6, inode=0x3b0d6124) at fs/nfs/dir.c:1255
#10 0x08117705 in dentry_iput (dentry=<optimized out>) at fs/dcache.c:329
#11 d_kill (dentry=0x4508a000, parent=0x47adf790) at fs/dcache.c:477
#12 0x08118138 in dentry_kill (dentry=<optimized out>, unlock_on_failure=<optimized out>) at fs/dcache.c:586
#13 dput (dentry=0x4508a000) at fs/dcache.c:641
#14 0x081049d3 in __fput (file=0x3baf3000) at fs/file_table.c:264
#15 0x08104a3b in ____fput (work=0x3baf3000) at fs/file_table.c:282
#16 0x08094496 in task_work_run () at kernel/task_work.c:123
#17 0x0807efd2 in exit_task_work (task=<optimized out>) at include/linux/task_work.h:21
#18 do_exit (code=1167823872) at kernel/exit.c:787
#19 0x0807f5dd in do_group_exit (exit_code=0) at kernel/exit.c:920
#20 0x0807f649 in SYSC_exit_group (error_code=<optimized out>) at kernel/exit.c:931
#21 SyS_exit_group (error_code=0) at kernel/exit.c:929
#22 0x08062984 in handle_syscall (r=0x459741d4) at arch/um/kernel/skas/syscall.c:35
#23 0x08074fb5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
#24 userspace (regs=0x459741d4) at arch/um/os-Linux/skas/process.c:431
#25 0x0805f750 in fork_handler () at arch/um/kernel/process.c:160
#26 0x00000000 in ?? ()


But it happened rarely and I did not found a scenario to easily reproduce it till now.

-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
