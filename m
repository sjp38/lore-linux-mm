Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D67FE6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:19:35 -0400 (EDT)
Date: Thu, 2 Jun 2011 16:19:27 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602141927.GA2011@thinkpad>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 02, 2011 at 03:09:53AM -0400, CAI Qian wrote:
> Hello,
> 
> ----- Original Message -----
> > I've just experienced this bug with ksmd:
> > 
> > [ 55.837551] BUG: unable to handle kernel NULL pointer dereference at
> > 00000000000000e8
> > [ 55.837598] IP: [<ffffffff810bb9b2>] __lock_acquire+0x62/0x1d70
> > [ 55.837630] PGD 0
> > [ 55.837643] Oops: 0000 [#1] SMP
> > [ 55.837663] CPU 2
> > [ 55.837674] Modules linked in: snd_hda_codec_hdmi
> > snd_hda_codec_conexant rtl8192ce rtl8192c_common rtlwifi mac80211
> > usbhid hid cfg80211 snd_hda_intel snd_hda_codec psmouse snd_pcm e1000e
> > thinkpad_acpi snd_timer snd_page_alloc snd soundcore nvram
> > [ 55.837816]
> > [ 55.837824] Pid: 33, comm: ksmd Not tainted 3.0.0-rc1+ #289 LENOVO
> > 4286CTO/4286CTO
> > [ 55.837850] RIP: 0010:[<ffffffff810bb9b2>] [<ffffffff810bb9b2>]
> > __lock_acquire+0x62/0x1d70
> > [ 55.837878] RSP: 0018:ffff88023d3abc50 EFLAGS: 00010046
> > [ 55.837894] RAX: 0000000000000046 RBX: 00000000000000e8 RCX:
> > 0000000000000001
> > [ 55.837915] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> > 00000000000000e8
> > [ 55.837936] RBP: ffff88023d3abd40 R08: 0000000000000002 R09:
> > 0000000000000000
> > [ 55.837957] R10: 0000000000000001 R11: 0000000000000000 R12:
> > ffff88023d3a3e00
> > [ 55.837978] R13: 0000000000000000 R14: 0000000000000002 R15:
> > 0000000000000000
> > [ 55.837999] FS: 0000000000000000(0000) GS:ffff88023e280000(0000)
> > knlGS:0000000000000000
> > [ 55.838022] CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 55.838039] CR2: 00000000000000e8 CR3: 00000000016f5000 CR4:
> > 00000000000406e0
> > [ 55.838060] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000
> > [ 55.838081] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > 0000000000000400
> > [ 55.838102] Process ksmd (pid: 33, threadinfo ffff88023d3aa000, task
> > ffff88023d3a3e00)
> > [ 55.838131] Stack:
> > [ 55.838140] ffff88023d3abce0 0000000000000000 ffffffff81d46810
> > 00000000000012c7
> > [ 55.838168] 000000000000037c ffff88023d3a3e00 0000000000000001
> > 0000000000000000
> > [ 55.838338] 0000000000000000 0000000000000000 00000000001ba37c
> > ffffffff81a22000
> > [ 55.838365] Call Trace:
> > [ 55.838375] [<ffffffff810be55f>] ? mark_held_locks+0x6f/0xa0
> > [ 55.838394] [<ffffffff814e3360>] ?
> > _raw_spin_unlock_irqrestore+0x40/0x70
> > [ 55.838416] [<ffffffff810bdc90>] lock_acquire+0x90/0x110
> > [ 55.838434] [<ffffffff8114c652>] ? ksm_scan_thread+0x132/0xe20
> > [ 55.838453] [<ffffffff8112df6c>] ? free_percpu+0x9c/0x130
> > [ 55.838470] [<ffffffff814e1cbc>] down_read+0x4c/0x70
> > [ 55.838486] [<ffffffff8114c652>] ? ksm_scan_thread+0x132/0xe20
> > [ 55.838505] [<ffffffff814e33bb>] ? _raw_spin_unlock+0x2b/0x40
> > [ 55.838523] [<ffffffff8114c652>] ksm_scan_thread+0x132/0xe20
> > [ 55.838541] [<ffffffff814df822>] ? schedule+0x3b2/0x960
> > [ 55.838559] [<ffffffff810a5690>] ? wake_up_bit+0x40/0x40
> > [ 55.838576] [<ffffffff8114c520>] ? run_store+0x310/0x310
> > [ 55.838593] [<ffffffff810a5186>] kthread+0x96/0xa0
> > [ 55.838609] [<ffffffff814e5014>] kernel_thread_helper+0x4/0x10
> > [ 55.838628] [<ffffffff814e3700>] ? retint_restore_args+0xe/0xe
> > [ 55.838647] [<ffffffff810a50f0>] ? __init_kthread_worker+0x70/0x70
> > [ 55.838666] [<ffffffff814e5010>] ? gs_change+0xb/0xb
> > [ 55.838681] Code: b7 00 00 48 89 fb 85 c0 41 89 f5 45 0f 45 f0 8b 05
> > 84 de 68 00 85 c0 0f 84 7b 09 00 00 8b 05 7a 49 7a 00 85 c0 0f 84 c6
> > 01 00 00
> > [ 55.838780] 8b 03 ba 01 00 00 00 48 3d e0 3c 8c 81 44 0f 44 f2 41 83
> > fd
> > [ 55.838830] RIP [<ffffffff810bb9b2>] __lock_acquire+0x62/0x1d70
> > [ 55.838850] RSP <ffff88023d3abc50>
> > [ 55.839567] CR2: 00000000000000e8
> > [ 55.895721] ---[ end trace eea0fa5dfa6846f1 ]---
> > 
> > The bug can be easily reproduced using the following testcase:
> > 
> > ========================
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <unistd.h>
> > #include <sys/mman.h>
> > 
> > #define BUFSIZE getpagesize()
> > 
> > int main(int argc, char **argv)
> > {
> > void *ptr;
> > 
> > if (posix_memalign(&ptr, getpagesize(), BUFSIZE) < 0) {
> > perror("posix_memalign");
> > exit(1);
> > }
> > if (madvise(ptr, BUFSIZE, MADV_MERGEABLE) < 0) {
> > perror("madvise");
> > exit(1);
> > }
> > *(char *)NULL = 0;
> Hmm, the reproducer gave something else here but no panic.
> $ strace ./test 
> execve("./test", ["./test"], [/* 26 vars */]) = 0
> brk(0)                                  = 0x220f000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd18ec0a000
> access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
> open("/etc/ld.so.cache", O_RDONLY)      = 3
> fstat(3, {st_mode=S_IFREG|0644, st_size=41227, ...}) = 0
> mmap(NULL, 41227, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fd18ebff000
> close(3)                                = 0
> open("/lib64/libc.so.6", O_RDONLY)      = 3
> read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\355\341n<\0\0\0"..., 832) = 832
> fstat(3, {st_mode=S_IFREG|0755, st_size=1912928, ...}) = 0
> mmap(0x3c6ee00000, 3737768, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x3c6ee00000
> mprotect(0x3c6ef87000, 2097152, PROT_NONE) = 0
> mmap(0x3c6f187000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x187000) = 0x3c6f187000
> mmap(0x3c6f18c000, 18600, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x3c6f18c000
> close(3)                                = 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd18ebfe000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd18ebfd000
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fd18ebfc000
> arch_prctl(ARCH_SET_FS, 0x7fd18ebfd700) = 0
> mprotect(0x3c6f187000, 16384, PROT_READ) = 0
> mprotect(0x3c6e81f000, 4096, PROT_READ) = 0
> munmap(0x7fd18ebff000, 41227)           = 0
> brk(0)                                  = 0x220f000
> brk(0x2232000)                          = 0x2232000
> madvise(0x2210000, 4096, 0xc /* MADV_??? */) = 0
> --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> +++ killed by SIGSEGV (core dumped) +++
> Segmentation fault (core dumped)
> 
> Did I miss anything?

mmh.. I can reproduce the bug also with the standard ubuntu (11.04)
kernel. Could you post your .config?

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
