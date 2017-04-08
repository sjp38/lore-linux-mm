Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16A816B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 23:19:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id x8so3078368itb.11
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 20:19:07 -0700 (PDT)
Received: from omzsmtpe02.verizonbusiness.com (omzsmtpe02.verizonbusiness.com. [199.249.25.209])
        by mx.google.com with ESMTPS id e42si4700327ioj.166.2017.04.07.20.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 20:19:06 -0700 (PDT)
From: alexander.levin@verizon.com
Subject: Re: [PATCH v2 04/10] mm: make the try_to_munlock void function
Date: Sat, 8 Apr 2017 03:18:35 +0000
Message-ID: <20170408031833.iwhbyliu2lp3wazi@sasha-lappy>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-5-git-send-email-minchan@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <80920216F207954A9D8DB3E2943E2492@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Mar 15, 2017 at 02:24:47PM +0900, Minchan Kim wrote:
> try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> the page if the page is not pte-mapped THP which cannot be
> mlocked, either.
>=20
> With that, __munlock_isolated_page can use PageMlocked to check
> whether try_to_munlock is successful or not without relying on
> try_to_munlock's retval. It helps to make try_to_unmap/try_to_unmap_one
> simple with upcoming patches.
>=20
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Hey Minchan,

I seem to be hitting one of those newly added BUG_ONs with trinity:

[   21.017404] page:ffffea000307a300 count:10 mapcount:7 mapping:ffff880100=
83f3a8 index:0x131
[   21.019974] flags: 0x1fffc00001c001d(locked|referenced|uptodate|dirty|sw=
apbacked|unevictable|mlocked)                                              =
        [   21.022806] raw: 01fffc00001c001d ffff88010083f3a8 0000000000000=
131 0000000a00000006                                                       =
                [   21.023974] raw: dead000000000100 dead000000000200 00000=
00000000000 ffff880109838008
[   21.026098] page dumped because: VM_BUG_ON_PAGE(PageMlocked(page))
[   21.026903] page->mem_cgroup:ffff880109838008                           =
                                                                           =
        [   21.027505] page allocated via order 0, migratetype Movable, gfp=
_mask 0x14200ca(GFP_HIGHUSER_MOVABLE)
[   21.028783] save_stack_trace (arch/x86/kernel/stacktrace.c:60)=20
[   21.029362] save_stack (./arch/x86/include/asm/current.h:14 mm/kasan/kas=
an.c:50)                                                                   =
        [   21.029859] __set_page_owner (mm/page_owner.c:178)              =
                                                                           =
                [   21.030414] get_page_from_freelist (./include/linux/page=
_owner.h:30 mm/page_alloc.c:1742 mm/page_alloc.c:1750 mm/page_alloc.c:3097)=
                        [   21.031071] __alloc_pages_nodemask (mm/page_allo=
c.c:4011)                                                                  =
                                [   21.031716] alloc_pages_vma (./include/l=
inux/mempolicy.h:77 ./include/linux/mempolicy.h:82 mm/mempolicy.c:2024)    =
                                        [   21.032307] shmem_alloc_page (mm=
/shmem.c:1389 mm/shmem.c:1444)                                             =
                                                [   21.032881] shmem_getpag=
e_gfp (mm/shmem.c:1474 mm/shmem.c:1753)                                    =
                                                        [   21.033488] shme=
m_fault (mm/shmem.c:1987)                                                  =
                                                                [   21.0340=
55] __do_fault (mm/memory.c:3012)                                          =
                                                                        [  =
 21.034568] __handle_mm_fault (mm/memory.c:3449 mm/memory.c:3497 mm/memory.=
c:3723 mm/memory.c:3841)                                                   =
     [   21.035192] handle_mm_fault (mm/memory.c:3878)                     =
                                                                           =
             [   21.035772] __do_page_fault (arch/x86/mm/fault.c:1446)     =
                                                                           =
                     [   21.037148] do_page_fault (arch/x86/mm/fault.c:1508=
 ./include/linux/context_tracking_state.h:30 ./include/linux/context_tracki=
ng.h:63 arch/x86/mm/fault.c:1509)=20
[   21.037657] do_async_page_fault (./arch/x86/include/asm/traps.h:82 arch/=
x86/kernel/kvm.c:264)=20
[   21.038266] async_page_fault (arch/x86/entry/entry_64.S:1011)=20
[   21.038901] ------------[ cut here ]------------
[   21.039546] kernel BUG at mm/rmap.c:1560!
[   21.040126] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
[   21.040910] Modules linked in:
[   21.041345] CPU: 6 PID: 1317 Comm: trinity-c62 Tainted: G        W      =
 4.11.0-rc5-next-20170407 #7
[   21.042761] task: ffff8801067d3e40 task.stack: ffff8800c06d0000
[   21.043572] RIP: 0010:try_to_munlock (??:?)=20
[   21.044639] RSP: 0018:ffff8800c06d71a0 EFLAGS: 00010296
[   21.045330] RAX: 0000000000000000 RBX: 1ffff100180dae36 RCX: 00000000000=
00000
[   21.046289] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffffed00180=
dae28
[   21.047225] RBP: ffff8800c06d7358 R08: 0000000000001639 R09: 6c7561665f6=
56761
[   21.048982] R10: ffffea000307a31c R11: 303378302f383278 R12: ffff8800c06=
d7330
[   21.049823] R13: ffffea000307a300 R14: ffff8800c06d72d0 R15: ffffea00030=
7a300
[   21.050647] FS:  00007f4ab05a7700(0000) GS:ffff880109d80000(0000) knlGS:=
0000000000000000
[   21.051574] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   21.052246] CR2: 00007f4aafdebfc0 CR3: 00000000c069f000 CR4: 00000000000=
406a0
[   21.053072] Call Trace:
[   21.061057] __munlock_isolated_page (mm/mlock.c:131)=20
[   21.065328] __munlock_pagevec (mm/mlock.c:339)=20
[   21.079191] munlock_vma_pages_range (mm/mlock.c:494)=20
[   21.085665] mlock_fixup (mm/mlock.c:569)=20
[   21.086205] apply_vma_lock_flags (mm/mlock.c:608)=20
[   21.089035] SyS_munlock (./arch/x86/include/asm/current.h:14 mm/mlock.c:=
739 mm/mlock.c:729)=20
[   21.089502] do_syscall_64 (arch/x86/entry/common.c:284)

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
