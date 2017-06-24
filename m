Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 853BA6B02C3
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 11:08:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e187so70420327pgc.7
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 08:08:32 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id p26si116167pfj.496.2017.06.24.08.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 08:08:31 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id f127so9710068pgc.2
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 08:08:31 -0700 (PDT)
Date: Sat, 24 Jun 2017 08:08:26 -0700
From: Andrei Vagin <avagin@gmail.com>
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save
 pfn:1499f4
Message-ID: <20170624150824.GA19708@gmail.com>
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
 <20170624001738.GB7946@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20170624001738.GB7946@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 23, 2017 at 05:17:44PM -0700, Andrei Vagin wrote:
> On Thu, Jun 22, 2017 at 11:21:03PM -0700, Andrei Vagin wrote:
> > Hello,
> > 
> > We run CRIU tests for linux-next and today they triggered a kernel
> > bug. I want to mention that this kernel is built with kasan. This bug
> > was triggered in travis-ci. I can't reproduce it on my host. Without
> > kasan, kernel crashed but it is impossible to get a kernel log for
> > this case.
> 
> We use this tree
> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/
> 
> This issue isn't reproduced on the akpm-base branch and
> it is reproduced each time on the akpm branch. I didn't
> have time today to bisect it, will do on Monday.

c3aab7b2d4e8434d53bc81770442c14ccf0794a8 is the first bad commit

commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
Merge: 849c34f 93a7379
Author: Stephen Rothwell
Date:   Fri Jun 23 16:40:07 2017 +1000

    Merge branch 'akpm-current/current'


> 
> The problem is reproduced on the kernel without kasan too: https://goo.gl/Dxsv4R
> 
> [  337.289845] BUG: Bad page state in process criu  pfn:19c601
> [  337.295726] page:ffffdf4cc6718040 count:0 mapcount:1 mapping:dead000000000000 index:0x2ab1a9801 compound_mapcount: 1
> [  337.306595] flags: 0x17fff8000000000()
> [  337.312251] raw: 017fff8000000000 dead000000000000 0000000000000000 00000000ffffffff
> [  337.321756] raw: ffffdf4cc6718001 0000000900000003 0000000000000000 0000000000000000
> [  337.335768] page dumped because: nonzero compound_mapcount
> [  337.342082] Modules linked in:
> [  337.342089] CPU: 1 PID: 22242 Comm: criu Not tainted 4.12.0-rc6-next-20170623 #1
> [  337.342091] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> [  337.342094] Call Trace:
> [  337.342106]  dump_stack+0x85/0xc7
> [  337.342113]  bad_page+0xc1/0x120
> [  337.342119]  __free_pages_ok+0x3ab/0x570
> [  337.342127]  free_compound_page+0x1b/0x20
> [  337.342132]  free_transhuge_page+0xa4/0xb0
> [  337.342138]  __put_compound_page+0x30/0x50
> [  337.342143]  __put_page+0x2c/0x150
> [  337.342148]  page_cache_pipe_buf_release+0x3a/0x60
> [  337.342151]  iter_file_splice_write+0x2fc/0x3d0
> [  337.342169]  SyS_splice+0x331/0x810
> [  337.342174]  ? trace_hardirqs_on_caller+0x11f/0x190
> [  337.342186]  entry_SYSCALL_64_fastpath+0x23/0xc2
> [  337.342190] RIP: 0033:0x2b94bad9d9a3
> [  337.342192] RSP: 002b:00007ffdfac31d98 EFLAGS: 00000246 ORIG_RAX: 0000000000000113
> [  337.342196] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b94bad9d9a3
> [  337.342198] RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000015
> [  337.342200] RBP: 00007ffdfac31970 R08: 0000000000200000 R09: 0000000000000001
> [  337.342202] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> [  337.342204] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
> [  337.342241] Disabling lock debugging due to kernel taint
> [  337.342253] page:ffffdf4cc671ff40 count:0 mapcount:0 mapping:          (null) index:0x0
> [  337.352360] flags: 0x17fff8000000000()
> [  337.357600] raw: 017fff8000000000 0000000000000000 0000000000000000 00000000ffffffff
> [  337.366628] raw: 0000000000000000 ffffdf4cc671ff60 0000000000000000 0000000000000000
> [  337.375506] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> [  337.390656] ------------[ cut here ]------------
> [  337.390658] kernel BUG at ./include/linux/mm.h:466!
> [  337.406508] invalid opcode: 0000 [#1] SMP
> [  337.410958] Modules linked in:
> [  337.414135] CPU: 1 PID: 22242 Comm: criu Tainted: G    B           4.12.0-rc6-next-20170623 #1
> [  337.424254] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> [  337.433596] task: ffff88f233f230c0 task.stack: ffffaf8f01d30000
> [  337.441023] RIP: 0010:page_cache_pipe_buf_release+0x50/0x60
> [  337.446712] RSP: 0018:ffffaf8f01d33de8 EFLAGS: 00010246
> [  337.453440] RAX: 000000000000003e RBX: 0000000000000000 RCX: 0000000000000000
> [  337.460716] RDX: ffff88f29fd152c0 RSI: 0000000000000000 RDI: ffff88f29fd0cfd8
> [  337.469356] RBP: ffffaf8f01d33df0 R08: 0000000000000001 R09: 0000000000000000
> [  337.476613] R10: 0000000000000000 R11: ffffffff8e11138a R12: ffff88f2286fcfd8
> [  337.485277] R13: ffff88f29183c448 R14: 0000000000001000 R15: 00000000000fe000
> [  337.492540] FS:  00002b94ba04f040(0000) GS:ffff88f29fd00000(0000) knlGS:0000000000000000
> [  337.502144] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  337.508019] CR2: 00007f9e8e153024 CR3: 00000001c7e8f000 CR4: 00000000001406e0
> [  337.516665] Call Trace:
> [  337.519243]  iter_file_splice_write+0x2fc/0x3d0
> [  337.525306]  SyS_splice+0x331/0x810
> [  337.530303]  ? trace_hardirqs_on_caller+0x11f/0x190
> [  337.535307]  entry_SYSCALL_64_fastpath+0x23/0xc2
> [  337.541424] RIP: 0033:0x2b94bad9d9a3
> [  337.545128] RSP: 002b:00007ffdfac31d98 EFLAGS: 00000246 ORIG_RAX: 0000000000000113
> [  337.554205] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b94bad9d9a3
> [  337.561471] RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000015
> [  337.568727] RBP: 00007ffdfac31970 R08: 0000000000200000 R09: 0000000000000001
> [  337.577366] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> [  337.584618] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
> [  337.593262] Code: f0 ff 4f 1c 74 06 83 66 18 fe c9 c3 48 89 75 f8 e8 f6 dc f2 ff 48 8b 75 f8 83 66 18 fe c9 c3 48 c7 c6 f0 c1 e8 8e e8 70 5d f5 ff <0f> 0b 0f 1f 40 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 
> [  337.613641] RIP: page_cache_pipe_buf_release+0x50/0x60 RSP: ffffaf8f01d33de8
> [  337.620879] ---[ end trace 3db25f07d52a5dbf ]---
> 
> 
> > 
> > [  699.207570] BUG: Bad page state in process ip6tables-save  pfn:1499f4
> > [  699.214542] page:ffffea0005267d00 count:-1 mapcount:0 mapping:
> >     (null) index:0x1
> > [  699.222758] flags: 0x17fff8000000000()
> > [  699.226632] raw: 017fff8000000000 0000000000000000 0000000000000001
> > ffffffffffffffff
> > [  699.234495] raw: dead000000000100 dead000000000200 0000000000000000
> > 0000000000000000
> > [  699.242359] page dumped because: nonzero _count
> > [  699.247006] Modules linked in:
> > [  699.247022] CPU: 0 PID: 19609 Comm: ip6tables-save Not tainted
> > 4.12.0-rc6-next-20170622 #1
> > [  699.247029] Hardware name: Google Google Compute Engine/Google
> > Compute Engine, BIOS Google 01/01/2011
> > [  699.247035] Call Trace:
> > [  699.247054]  dump_stack+0x85/0xc2
> > [  699.247070]  bad_page+0xea/0x160
> > [  699.247086]  check_new_page_bad+0xc2/0xe0
> > [  699.247103]  get_page_from_freelist+0xfec/0x1270
> > [  699.247161]  __alloc_pages_nodemask+0x1cf/0x4b0
> > [  699.247188]  ? __alloc_pages_slowpath+0x1610/0x1610
> > [  699.247214]  ? mark_lock+0x6d/0x860
> > [  699.247223]  ? alloc_set_pte+0x7db/0x8f0
> > [  699.247247]  alloc_pages_vma+0x85/0x250
> > [  699.247270]  wp_page_copy+0x13c/0xad0
> > [  699.247285]  ? do_wp_page+0x292/0x9a0
> > [  699.247309]  ? lock_downgrade+0x2c0/0x2c0
> > [  699.247320]  ? __do_fault+0x140/0x140
> > [  699.247341]  ? do_raw_spin_unlock+0x88/0x130
> > [  699.247361]  do_wp_page+0x29a/0x9a0
> > [  699.247386]  ? finish_mkwrite_fault+0x250/0x250
> > [  699.247403]  ? do_raw_spin_lock+0x93/0x120
> > [  699.247427]  __handle_mm_fault+0xb94/0x1790
> > [  699.247450]  ? __pmd_alloc+0x270/0x270
> > [  699.247466]  ? find_held_lock+0x119/0x150
> > [  699.247528]  handle_mm_fault+0x235/0x490
> > [  699.247553]  __do_page_fault+0x332/0x680
> > [  699.247586]  do_page_fault+0x22/0x30
> > [  699.247601]  page_fault+0x28/0x30
> > [  699.247609] RIP: 0033:0x2aaea0abef2b
> > [  699.247616] RSP: 002b:00007ffe1deecd20 EFLAGS: 00010206
> > [  699.247628] RAX: 00002aaea12f6e60 RBX: 000000037ffff1a0 RCX: 0000000000000028
> > [  699.247635] RDX: 00002aaea12f6f10 RSI: 00002aaea0af0040 RDI: 00002aaea10ec000
> > [  699.247642] RBP: 00007ffe1deece70 R08: 000000006fffffff R09: 0000000070000021
> > [  699.247649] R10: 0000000000000031 R11: 000000006ffffdff R12: 00002aaea0af0000
> > [  699.247655] R13: 00007ffe1deecf40 R14: 0000000000000003 R15: 000000006ffffeff
> > [  699.247697] Disabling lock debugging due to kernel taint
> > 
> > Here is a whole log: https://goo.gl/5xekS3
> > 
> > Thanks,
> > Andrei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
