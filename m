Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 282686B00E4
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 12:12:54 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8886706pbb.27
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:12:53 -0700 (PDT)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id js8si7890983pbc.134.2013.10.22.09.12.52
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 09:12:53 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id hz11so1405345vcb.24
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 09:12:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <526696BF.6050909@gmx.de>
References: <526696BF.6050909@gmx.de>
Date: Tue, 22 Oct 2013 18:12:51 +0200
Message-ID: <CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs at in histfs
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On Tue, Oct 22, 2013 at 5:16 PM, Toralf F=F6rster <toralf.foerster@gmx.de> =
wrote:
>
> When I fuzz testing a 32 bit UML at a 32 bit host (guest 3.12.-rc6-x, hos=
t 3.11.6) with trinity
> and use hostfs for the victom files for trinity. then trintiy often hangs=
 while trying to finish.
>
> At the host I do have 1 process eating 100% CPU power of 1 core. A back t=
race of thet linux process at the hosts gives :
>
> tfoerste@n22 ~ $ sudo gdb /usr/local/bin/linux-v3.12-rc6-57-g69c88dc 1674=
9 -n -batch -ex bt
> radix_tree_next_chunk (root=3D0x21, iter=3D0x47647c60, flags=3D12) at lib=
/radix-tree.c:769
> 769                                     while (++offset < RADIX_TREE_MAP_=
SIZE) {
> #0  radix_tree_next_chunk (root=3D0x21, iter=3D0x47647c60, flags=3D12) at=
 lib/radix-tree.c:769
> #1  0x080cc13e in find_get_pages (mapping=3D0x483ed240, start=3D0, nr_pag=
es=3D14, pages=3D0xc) at mm/filemap.c:844
> #2  0x080d5caa in pagevec_lookup (pvec=3D0x47647cc4, mapping=3D0x21, star=
t=3D33, nr_pages=3D33) at mm/swap.c:914
> #3  0x080d609a in truncate_inode_pages_range (mapping=3D0x483ed240, lstar=
t=3D0, lend=3D-1) at mm/truncate.c:241
> #4  0x080d643f in truncate_inode_pages (mapping=3D0x21, lstart=3D51539607=
585) at mm/truncate.c:358
> #5  0x08260838 in hostfs_evict_inode (inode=3D0x483ed188) at fs/hostfs/ho=
stfs_kern.c:242
> #6  0x0811a8cf in evict (inode=3D0x483ed188) at fs/inode.c:549
> #7  0x0811b2ad in iput_final (inode=3D<optimized out>) at fs/inode.c:1391
> #8  iput (inode=3D0x483ed188) at fs/inode.c:1409
> #9  0x08117648 in dentry_iput (dentry=3D<optimized out>) at fs/dcache.c:3=
31
> #10 d_kill (dentry=3D0x47d6d580, parent=3D0x47d95d10) at fs/dcache.c:477
> #11 0x08118068 in dentry_kill (dentry=3D<optimized out>, unlock_on_failur=
e=3D<optimized out>) at fs/dcache.c:586
> #12 dput (dentry=3D0x47d6d580) at fs/dcache.c:641
> #13 0x08104903 in __fput (file=3D0x47471840) at fs/file_table.c:264
> #14 0x0810496b in ____fput (work=3D0x47471840) at fs/file_table.c:282
> #15 0x08094496 in task_work_run () at kernel/task_work.c:123
> #16 0x0807efd2 in exit_task_work (task=3D<optimized out>) at include/linu=
x/task_work.h:21
> #17 do_exit (code=3D1196535808) at kernel/exit.c:787
> #18 0x0807f5dd in do_group_exit (exit_code=3D0) at kernel/exit.c:920
> #19 0x0807f649 in SYSC_exit_group (error_code=3D<optimized out>) at kerne=
l/exit.c:931
> #20 SyS_exit_group (error_code=3D0) at kernel/exit.c:929
> #21 0x08062984 in handle_syscall (r=3D0x4763b1d4) at arch/um/kernel/skas/=
syscall.c:35
> #22 0x08074fb5 in handle_trap (local_using_sysemu=3D<optimized out>, regs=
=3D<optimized out>, pid=3D<optimized out>) at arch/um/os-Linux/skas/process=
.c:198
> #23 userspace (regs=3D0x4763b1d4) at arch/um/os-Linux/skas/process.c:431
> #24 0x0805f750 in fork_handler () at arch/um/kernel/process.c:160
> #25 0x00000000 in ?? ()
>

That trace is identical to the one you reported yesterday.
But this time no nfs is in the game, right?

> Last message of trinity's watchdog are :
>
> ...
> [watchdog] exit_reason=3D2, but 2 children still running.
> Bailing main loop. Exit reason: Reached maximum syscall count.
> [watchdog] Reached limit 10001. Telling children to exit.
> [watchdog] [1516] Watchdog exiting
>
>
> I'm unsure if this is only UML specific, interesting for the fs people or=
 mm or ... ?
>
>
> --
> MfG/Sincerely
> Toralf F=F6rster
> pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
>
> -------------------------------------------------------------------------=
-----
> October Webinars: Code for Performance
> Free Intel webinars can help you accelerate application performance.
> Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most =
from
> the latest Intel processors and coprocessors. See abstracts and register =
>
> http://pubads.g.doubleclick.net/gampad/clk?id=3D60135991&iu=3D/4140/ostg.=
clktrk
> _______________________________________________
> User-mode-linux-devel mailing list
> User-mode-linux-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel



--=20
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
