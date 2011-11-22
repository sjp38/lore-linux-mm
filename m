Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72F366B006E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 04:38:57 -0500 (EST)
Received: by ggnq1 with SMTP id q1so7331981ggn.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 01:38:54 -0800 (PST)
Message-ID: <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 10:38:49 +0100
In-Reply-To: <20111122084513.GA1688@x4.trippels.de>
References: <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	 <alpine.DEB.2.00.1111212105330.19606@router.home>
	 <20111122084513.GA1688@x4.trippels.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Christoph Lameter <cl@linux.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Le mardi 22 novembre 2011 A  09:45 +0100, Markus Trippelsdorf a A(C)crit :

> I sometimes see the following pattern. Is this a false positive?
> 
> 
> =============================================================================
> BUG anon_vma: Redzone overwritten
> -----------------------------------------------------------------------------
> 
> INFO: 0xffff88020f347c80-0xffff88020f347c87. First byte 0xbb instead of 0xcc
> INFO: Allocated in anon_vma_fork+0x51/0x140 age=1 cpu=2 pid=1826
> 	__slab_alloc.constprop.70+0x1ac/0x1e8
> 	kmem_cache_alloc+0x12e/0x160
> 	anon_vma_fork+0x51/0x140
> 	dup_mm+0x1f2/0x4a0
> 	copy_process+0xd10/0xf70
> 	do_fork+0x100/0x2b0
> 	sys_clone+0x23/0x30
> 	stub_clone+0x13/0x20
> INFO: Freed in __put_anon_vma+0x54/0xa0 age=0 cpu=1 pid=1827
> 	__slab_free+0x33/0x2d0
> 	kmem_cache_free+0x10e/0x120
> 	__put_anon_vma+0x54/0xa0
> 	unlink_anon_vmas+0x12f/0x1c0
> 	free_pgtables+0x83/0xe0
> 	exit_mmap+0xee/0x140
> 	mmput+0x43/0xf0
> 	flush_old_exec+0x33f/0x630
> 	load_elf_binary+0x340/0x1960
> 	search_binary_handler+0x8f/0x180
> 	do_execve+0x2d3/0x370
> 	sys_execve+0x42/0x70
> 	stub_execve+0x6c/0xc0
> INFO: Slab 0xffffea00083cd1c0 objects=10 used=9 fp=0xffff88020f347ab8 flags=0x4000000000000081
> INFO: Object 0xffff88020f347c40 @offset=3136 fp=0xffff88020f347ab8
> 
> Bytes b4 ffff88020f347c30: 39 b6 fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  9.......ZZZZZZZZ
> Object ffff88020f347c40: 30 c9 9b 0d 02 88 ff ff 01 00 00 00 00 00 5a 5a  0.............ZZ
> Object ffff88020f347c50: 50 7c 34 0f 02 88 ff ff 50 7c 34 0f 02 88 ff ff  P|4.....P|4.....
> Object ffff88020f347c60: 00 00 00 00 00 00 00 00 00 00 00 00 5a 5a 5a 5a  ............ZZZZ
> Object ffff88020f347c70: 70 7c 34 0f 02 88 ff ff 70 7c 34 0f 02 88 ff ff  p|4.....p|4.....
> Redzone ffff88020f347c80: bb bb bb bb bb bb bb bb                          ........
> Padding ffff88020f347dc0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> Pid: 1820, comm: slabinfo Not tainted 3.2.0-rc2-00369-gbbbc479-dirty #83
> Call Trace:
>  [<ffffffff81105df8>] ? print_section+0x38/0x40
>  [<ffffffff811062f3>] print_trailer+0xe3/0x150
>  [<ffffffff811064f0>] check_bytes_and_report+0xe0/0x100
>  [<ffffffff81107313>] check_object+0x183/0x240
>  [<ffffffff81107eb0>] validate_slab_slab+0x1c0/0x230
>  [<ffffffff8110a4a6>] validate_store+0xa6/0x190
>  [<ffffffff8110573c>] slab_attr_store+0x1c/0x30
>  [<ffffffff81168838>] sysfs_write_file+0xc8/0x140
>  [<ffffffff811124a3>] vfs_write+0xa3/0x160
>  [<ffffffff81112635>] sys_write+0x45/0x90
>  [<ffffffff814d3ffb>] system_call_fastpath+0x16/0x1b
> FIX anon_vma: Restoring 0xffff88020f347c80-0xffff88020f347c87=0xcc


Wait a minute

You trigger this using slabinfo looping or something ?

Bug is in slabinfo then, dont use it, and see if bug triggers.

Given slub is now lockless, validate_slab_slab() is probably very wrong
these days.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
