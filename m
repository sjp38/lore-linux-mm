Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 111576B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 14:10:09 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so1081012eek.9
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 11:10:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si3040932eeh.218.2013.12.13.11.10.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 11:10:08 -0800 (PST)
Date: Fri, 13 Dec 2013 20:10:05 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [uml-devel] why does index in truncate_inode_pages_range() grows
 so much ?
Message-ID: <20131213191005.GA23630@quack.suse.cz>
References: <529217CD.1000204@gmx.de>
 <20131203140214.GB31128@quack.suse.cz>
 <529E3450.9000700@gmx.de>
 <20131203230058.GA24037@quack.suse.cz>
 <20131204130639.GA31973@quack.suse.cz>
 <52A36389.7010103@gmx.de>
 <20131211202639.GE1163@quack.suse.cz>
 <52AAD8D4.2060807@gmx.de>
 <CAFLxGvy16wv0m4D+ydmqbksUu9CaEaDtGdtnk1YHa56jAU+SEA@mail.gmail.com>
 <52AB052E.9000404@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <52AB052E.9000404@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

On Fri 13-12-13 14:01:34, Toralf Forster wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA256
> 
> On 12/13/2013 11:51 AM, Richard Weinberger wrote:
> > On Fri, Dec 13, 2013 at 10:52 AM, Toralf Forster <toralf.foerster@gmx.de> wrote:
> >> -----BEGIN PGP SIGNED MESSAGE-----
> >> Hash: SHA256
> >>
> >> On 12/11/2013 09:26 PM, Jan Kara wrote:
> >>> Thanks! So this works more or less as expected - trinity issued a
> >>> read at absurdly high offset so we created pagecache page a that
> >>> offset and tried to read data into it. That failed. We left the
> >>> page in the pagecache where it was for reclaim to reclaim it when
> >>> free pages are needed. Everything works as designed except we could
> >>> possibly argue that it's not the most efficient way to use
> >>> pages...
> >>>
> >>> Patch 'vfs: fix a bug when we do some dio reads with append dio
> >>> writes' (http://www.spinics.net/lists/linux-fsdevel/msg70899.html)
> >>> should actually change the situation and we won't unnecessarily
> >>> cache these pages.
> >>>
> >> confirmed - applied to latest git tree of Linus I helps.
> > 
> > Good to know! :-)
> > 
> 
> OTOH - there's seems to be more places for an improvement - now trinity
> often runs hours w/o problem (before it runs within a rather short time
> into such issues).
> 
> But today I got another case (I did not patched the source files except
> the mentioned patch by Jan Kara) where the trinity call cycles since 2
> hours w/o any progress. But fortunately the system is still responsive,
> ssh works and I can shutdown that virtual machine smoothly, furthermore
> all local and remote file systems can be unounted cleanly - so that patch
> is a big improvement).
  OK, that is indeed strange. Can you step through find_get_pages() in gdb
to see where exactly are we looping? From the traces below the argument
values look somewhat unreliable so it's not clear to me what is exactly
happening.

								Honza

> tfoerste@n22 ~/devel/github/bingo $ date; sudo gdb /home/tfoerste/devel/linux/linux 9776 -n -batch -ex 'bt'
> Fri Dec 13 13:54:33 CET 2013
> find_get_pages (mapping=0x45182810, start=0, nr_pages=14, pages=0x0) at mm/filemap.c:885
> 885     }
> #0  find_get_pages (mapping=0x45182810, start=0, nr_pages=14, pages=0x0) at mm/filemap.c:885
> #1  0x080d669a in pagevec_lookup (pvec=0x40607d40, mapping=0x0, start=0, nr_pages=0) at mm/swap.c:937
> #2  0x080d6a9a in truncate_inode_pages_range (mapping=0x45182810, lstart=0, lend=-1) at mm/truncate.c:241
> #3  0x080d6e3f in truncate_inode_pages (mapping=0x0, lstart=0) at mm/truncate.c:358
> #4  0x0818c2d2 in ext4_evict_inode (inode=0x45182758) at fs/ext4/inode.c:228
> #5  0x0811b5ff in evict (inode=0x45182758) at fs/inode.c:549
> #6  0x0811c0ed in iput_final (inode=<optimized out>) at fs/inode.c:1419
> #7  iput (inode=0x45182758) at fs/inode.c:1437
> #8  0x08112056 in do_unlinkat (dfd=5, pathname=0x8065d84 <register_lines+276> "") at fs/namei.c:3718
> #9  0x081121c5 in SYSC_unlinkat (flag=<optimized out>, pathname=<optimized out>, dfd=<optimized out>) at fs/namei.c:3754
> #10 SyS_unlinkat (dfd=5, pathname=134634884, flag=0) at fs/namei.c:3746
> #11 0x08062a94 in handle_syscall (r=0x473b59cc) at arch/um/kernel/skas/syscall.c:35
> #12 0x080750f5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
> #13 userspace (regs=0x473b59cc) at arch/um/os-Linux/skas/process.c:431
> #14 0x0805f750 in fork_handler () at arch/um/kernel/process.c:149
> #15 0x5a5a5a5a in ?? ()
> 
> 
> tfoerste@n22 ~/devel/github/bingo $ date; sudo gdb /home/tfoerste/devel/linux/linux 9776 -n -batch -ex 'bt'
> Fri Dec 13 13:54:47 CET 2013
> radix_tree_next_chunk (root=0x3f, iter=0x40607cdc, flags=6) at lib/radix-tree.c:773
> 773                             index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
> #0  radix_tree_next_chunk (root=0x3f, iter=0x40607cdc, flags=6) at lib/radix-tree.c:773
> #1  0x080cc88e in find_get_pages (mapping=0x45182810, start=0, nr_pages=14, pages=0x6) at mm/filemap.c:844
> #2  0x080d669a in pagevec_lookup (pvec=0x40607d40, mapping=0x3f, start=63, nr_pages=63) at mm/swap.c:937
> #3  0x080d6a9a in truncate_inode_pages_range (mapping=0x45182810, lstart=0, lend=-1) at mm/truncate.c:241
> #4  0x080d6e3f in truncate_inode_pages (mapping=0x3f, lstart=25769803839) at mm/truncate.c:358
> #5  0x0818c2d2 in ext4_evict_inode (inode=0x45182758) at fs/ext4/inode.c:228
> #6  0x0811b5ff in evict (inode=0x45182758) at fs/inode.c:549
> #7  0x0811c0ed in iput_final (inode=<optimized out>) at fs/inode.c:1419
> #8  iput (inode=0x45182758) at fs/inode.c:1437
> #9  0x08112056 in do_unlinkat (dfd=5, pathname=0x8065d84 <register_lines+276> "") at fs/namei.c:3718
> #10 0x081121c5 in SYSC_unlinkat (flag=<optimized out>, pathname=<optimized out>, dfd=<optimized out>) at fs/namei.c:3754
> #11 SyS_unlinkat (dfd=5, pathname=134634884, flag=0) at fs/namei.c:3746
> #12 0x08062a94 in handle_syscall (r=0x473b59cc) at arch/um/kernel/skas/syscall.c:35
> #13 0x080750f5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
> #14 userspace (regs=0x473b59cc) at arch/um/os-Linux/skas/process.c:431
> #15 0x0805f750 in fork_handler () at arch/um/kernel/process.c:149
> #16 0x5a5a5a5a in ?? ()
> 
> 
> tfoerste@n22 ~/devel/github/bingo $ date; sudo gdb /home/tfoerste/devel/linux/linux 9776 -n -batch -ex 'bt'
> Fri Dec 13 13:57:16 CET 2013
> radix_tree_next_chunk (root=0x10, iter=0x40607cdc, flags=6) at lib/radix-tree.c:769
> 769                                     while (++offset < RADIX_TREE_MAP_SIZE) {
> #0  radix_tree_next_chunk (root=0x10, iter=0x40607cdc, flags=6) at lib/radix-tree.c:769
> #1  0x080cc88e in find_get_pages (mapping=0x45182810, start=0, nr_pages=14, pages=0x6) at mm/filemap.c:844
> #2  0x080d669a in pagevec_lookup (pvec=0x40607d40, mapping=0x10, start=16, nr_pages=16) at mm/swap.c:937
> #3  0x080d6a9a in truncate_inode_pages_range (mapping=0x45182810, lstart=0, lend=-1) at mm/truncate.c:241
> #4  0x080d6e3f in truncate_inode_pages (mapping=0x10, lstart=25769803792) at mm/truncate.c:358
> #5  0x0818c2d2 in ext4_evict_inode (inode=0x45182758) at fs/ext4/inode.c:228
> #6  0x0811b5ff in evict (inode=0x45182758) at fs/inode.c:549
> #7  0x0811c0ed in iput_final (inode=<optimized out>) at fs/inode.c:1419
> #8  iput (inode=0x45182758) at fs/inode.c:1437
> #9  0x08112056 in do_unlinkat (dfd=5, pathname=0x8065d84 <register_lines+276> "") at fs/namei.c:3718
> #10 0x081121c5 in SYSC_unlinkat (flag=<optimized out>, pathname=<optimized out>, dfd=<optimized out>) at fs/namei.c:3754
> #11 SyS_unlinkat (dfd=5, pathname=134634884, flag=0) at fs/namei.c:3746
> #12 0x08062a94 in handle_syscall (r=0x473b59cc) at arch/um/kernel/skas/syscall.c:35
> #13 0x080750f5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
> #14 userspace (regs=0x473b59cc) at arch/um/os-Linux/skas/process.c:431
> #15 0x0805f750 in fork_handler () at arch/um/kernel/process.c:149
> #16 0x5a5a5a5a in ?? ()
> 
> - -- 
> MfG/Sincerely
> Toralf Forster
> pgp finger print:1A37 6F99 4A9D 026F 13E2 4DCF C4EA CDDE 0076 E94E
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2.0.22 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
> 
> iF4EAREIAAYFAlKrBS0ACgkQxOrN3gB26U4bRgD/U/5sIELFBZUTeEgfM9eJBnxh
> PhdMMBTTJHoB3v9z70YA/iEZzD9L30vVSWqYrybOWNPYwDR1i67F41nUemmPczqu
> =u/iT
> -----END PGP SIGNATURE-----
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
