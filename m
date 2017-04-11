Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17C6E6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 22:56:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x125so134402464pgb.5
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:56:19 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 1si14979551plw.137.2017.04.10.19.56.17
        for <linux-mm@kvack.org>;
        Mon, 10 Apr 2017 19:56:18 -0700 (PDT)
Date: Tue, 11 Apr 2017 11:56:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 04/10] mm: make the try_to_munlock void function
Message-ID: <20170411025615.GA6545@bbox>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-5-git-send-email-minchan@kernel.org>
 <20170408031833.iwhbyliu2lp3wazi@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20170408031833.iwhbyliu2lp3wazi@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.levin@verizon.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

Hi Sasha,

On Sat, Apr 08, 2017 at 03:18:35AM +0000, alexander.levin@verizon.com wrote:
> On Wed, Mar 15, 2017 at 02:24:47PM +0900, Minchan Kim wrote:
> > try_to_munlock returns SWAP_MLOCK if the one of VMAs mapped
> > the page has VM_LOCKED flag. In that time, VM set PG_mlocked to
> > the page if the page is not pte-mapped THP which cannot be
> > mlocked, either.
> >=20
> > With that, __munlock_isolated_page can use PageMlocked to check
> > whether try_to_munlock is successful or not without relying on
> > try_to_munlock's retval. It helps to make try_to_unmap/try_to_unmap_one
> > simple with upcoming patches.
> >=20
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>=20
> Hey Minchan,
>=20
> I seem to be hitting one of those newly added BUG_ONs with trinity:
>=20
> [   21.017404] page:ffffea000307a300 count:10 mapcount:7 mapping:ffff8801=
0083f3a8 index:0x131
> [   21.019974] flags: 0x1fffc00001c001d(locked|referenced|uptodate|dirty|=
swapbacked|unevictable|mlocked)                                            =
          [   21.022806] raw: 01fffc00001c001d ffff88010083f3a8 00000000000=
00131 0000000a00000006                                                     =
                  [   21.023974] raw: dead000000000100 dead000000000200 000=
0000000000000 ffff880109838008
> [   21.026098] page dumped because: VM_BUG_ON_PAGE(PageMlocked(page))
> [   21.026903] page->mem_cgroup:ffff880109838008                         =
                                                                           =
          [   21.027505] page allocated via order 0, migratetype Movable, g=
fp_mask 0x14200ca(GFP_HIGHUSER_MOVABLE)
> [   21.028783] save_stack_trace (arch/x86/kernel/stacktrace.c:60)=20
> [   21.029362] save_stack (./arch/x86/include/asm/current.h:14 mm/kasan/k=
asan.c:50)                                                                 =
          [   21.029859] __set_page_owner (mm/page_owner.c:178)            =
                                                                           =
                  [   21.030414] get_page_from_freelist (./include/linux/pa=
ge_owner.h:30 mm/page_alloc.c:1742 mm/page_alloc.c:1750 mm/page_alloc.c:309=
7)                        [   21.031071] __alloc_pages_nodemask (mm/page_al=
loc.c:4011)                                                                =
                                  [   21.031716] alloc_pages_vma (./include=
/linux/mempolicy.h:77 ./include/linux/mempolicy.h:82 mm/mempolicy.c:2024)  =
                                          [   21.032307] shmem_alloc_page (=
mm/shmem.c:1389 mm/shmem.c:1444)                                           =
                                                  [   21.032881] shmem_getp=
age_gfp (mm/shmem.c:1474 mm/shmem.c:1753)                                  =
                                                          [   21.033488] sh=
mem_fault (mm/shmem.c:1987)                                                =
                                                                  [   21.03=
4055] __do_fault (mm/memory.c:3012)                                        =
                                                                          [=
   21.034568] __handle_mm_fault (mm/memory.c:3449 mm/memory.c:3497 mm/memor=
y.c:3723 mm/memory.c:3841)                                                 =
       [   21.035192] handle_mm_fault (mm/memory.c:3878)                   =
                                                                           =
               [   21.035772] __do_page_fault (arch/x86/mm/fault.c:1446)   =
                                                                           =
                       [   21.037148] do_page_fault (arch/x86/mm/fault.c:15=
08 ./include/linux/context_tracking_state.h:30 ./include/linux/context_trac=
king.h:63 arch/x86/mm/fault.c:1509)=20
> [   21.037657] do_async_page_fault (./arch/x86/include/asm/traps.h:82 arc=
h/x86/kernel/kvm.c:264)=20
> [   21.038266] async_page_fault (arch/x86/entry/entry_64.S:1011)=20
> [   21.038901] ------------[ cut here ]------------
> [   21.039546] kernel BUG at mm/rmap.c:1560!
> [   21.040126] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> [   21.040910] Modules linked in:
> [   21.041345] CPU: 6 PID: 1317 Comm: trinity-c62 Tainted: G        W    =
   4.11.0-rc5-next-20170407 #7
> [   21.042761] task: ffff8801067d3e40 task.stack: ffff8800c06d0000
> [   21.043572] RIP: 0010:try_to_munlock (??:?)=20
> [   21.044639] RSP: 0018:ffff8800c06d71a0 EFLAGS: 00010296
> [   21.045330] RAX: 0000000000000000 RBX: 1ffff100180dae36 RCX: 000000000=
0000000
> [   21.046289] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffffed001=
80dae28
> [   21.047225] RBP: ffff8800c06d7358 R08: 0000000000001639 R09: 6c7561665=
f656761
> [   21.048982] R10: ffffea000307a31c R11: 303378302f383278 R12: ffff8800c=
06d7330
> [   21.049823] R13: ffffea000307a300 R14: ffff8800c06d72d0 R15: ffffea000=
307a300
> [   21.050647] FS:  00007f4ab05a7700(0000) GS:ffff880109d80000(0000) knlG=
S:0000000000000000
> [   21.051574] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   21.052246] CR2: 00007f4aafdebfc0 CR3: 00000000c069f000 CR4: 000000000=
00406a0
> [   21.053072] Call Trace:
> [   21.061057] __munlock_isolated_page (mm/mlock.c:131)=20
> [   21.065328] __munlock_pagevec (mm/mlock.c:339)=20
> [   21.079191] munlock_vma_pages_range (mm/mlock.c:494)=20
> [   21.085665] mlock_fixup (mm/mlock.c:569)=20
> [   21.086205] apply_vma_lock_flags (mm/mlock.c:608)=20
> [   21.089035] SyS_munlock (./arch/x86/include/asm/current.h:14 mm/mlock.=
c:739 mm/mlock.c:729)=20
> [   21.089502] do_syscall_64 (arch/x86/entry/common.c:284)
>=20

Thanks for the report.

When I look at the code, that VM_BUG_ON check should be removed because
__munlock_pagevec doesn't hold any PG_lock so a page can have PG_mlocked
again before passing the page into try_to_munlock.

=46rom 4369227f190264291961bb4024e14d34e6656b54 Mon Sep 17 00:00:00 2001
=46rom: Minchan Kim <minchan@kernel.org>
Date: Tue, 11 Apr 2017 11:41:54 +0900
Subject: [PATCH] mm: remove PG_Mlocked VM_BUG_ON check

Caller of try_to_munlock doesn't guarantee he pass the page
with clearing PG_mlocked.
Look at __munlock_pagevec which doesn't hold any PG_lock
so anybody can set PG_mlocked under us.
Remove bogus PageMlocked check in try_to_munlock.

Reported-by: Sasha Levin <alexander.levin@verizon.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Andrew,

This patch can be foled into mm-make-the-try_to_munlock-void-function.patch.
Thanks.

 mm/rmap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index a69a2a70d057..0773118214cc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1557,7 +1557,6 @@ void try_to_munlock(struct page *page)
 	};
=20
 	VM_BUG_ON_PAGE(!PageLocked(page) || PageLRU(page), page);
-	VM_BUG_ON_PAGE(PageMlocked(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page) && PageDoubleMap(page), page);
=20
 	rmap_walk(page, &rwc);
--=20
2.7.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
