Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6A15B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 05:11:12 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rd18so5714301iec.10
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 02:11:12 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id v13si30118277ico.86.2014.06.03.02.11.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 02:11:08 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so5673662iec.37
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 02:11:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140603042121.GA27177@redhat.com>
References: <20140603042121.GA27177@redhat.com>
Date: Tue, 3 Jun 2014 13:11:08 +0400
Message-ID: <CALYGNiNV951SnBKdr0PEkgLbLCxy+YB6HJpafRr6CynO+a1sdQ@mail.gmail.com>
Subject: Re: 3.15-rc8 mm/filemap.c:202 BUG
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, Jun 3, 2014 at 8:21 AM, Dave Jones <davej@redhat.com> wrote:
> I'm still seeing this one from time to time, though it takes me quite a while to hit it,
> despite my attempts at trying to narrow down the set of syscalls that cause it.
>
> kernel BUG at mm/filemap.c:202!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> CPU: 3 PID: 3013 Comm: trinity-c361 Not tainted 3.15.0-rc8+ #225
> task: ffff88006c610000 ti: ffff880055960000 task.ti: ffff880055960000
> RIP: 0010:[<ffffffffac158e28>]  [<ffffffffac158e28>] __delete_from_page_cache+0x318/0x360
> RSP: 0018:ffff880055963b90  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: 0000000000000003 RCX: ffff880146f68388
> RDX: 000000000000022a RSI: ffffffffaca8db38 RDI: ffffffffaca62b17
> RBP: ffff880055963be0 R08: 0000000000000002 R09: ffff88000613d530
> R10: ffff880055963ba8 R11: ffff880007f49a40 R12: ffffea0006795880
> R13: ffff880143232ad0 R14: 0000000000000000 R15: ffff880143232ad8
> FS:  00007f1e40673700(0000) GS:ffff88024d180000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f1e404e6000 CR3: 00000000603eb000 CR4: 00000000001407e0
> DR0: 0000000001bb1000 DR1: 0000000002537000 DR2: 00000000016a5000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Stack:
>  ffff880143232ae8 0000000000000000 ffff88000613d530 ffff88000613d568
>  0000000008828259 ffffea0006795880 ffff880143232ae8 0000000000000000
>  0000000000000002 0000000000000002 ffff880055963c08 ffffffffac158eae
> Call Trace:
>  [<ffffffffac158eae>] delete_from_page_cache+0x3e/0x70
>  [<ffffffffac16921b>] truncate_inode_page+0x5b/0x90
>  [<ffffffffac174493>] shmem_undo_range+0x363/0x790
>  [<ffffffffac1748d4>] shmem_truncate_range+0x14/0x30
>  [<ffffffffac174bcf>] shmem_fallocate+0x9f/0x340
>  [<ffffffffac324d40>] ? timerqueue_add+0x60/0xb0
>  [<ffffffffac1c5ff6>] do_fallocate+0x116/0x1a0
>  [<ffffffffac182260>] SyS_madvise+0x3c0/0x870
>  [<ffffffffac346b33>] ? __this_cpu_preempt_check+0x13/0x20
>  [<ffffffffac74c41f>] tracesys+0xdd/0xe2
> Code: ff ff 01 41 f6 c6 01 48 8b 45 c8 75 16 4c 89 30 e9 70 fe ff ff 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 0f 0b 66 0f 1f 44 00 00 <0f> 0b 66 0f 1f 44 00 00  41 54 9d e8 78 9e fd ff e9 8c fe ff ff
> RIP  [<ffffffffac158e28>] __delete_from_page_cache+0x318/0x360
>
> There was also another variant of the same BUG with a slighty different stack trace.
>
> kernel BUG at mm/filemap.c:202!
> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> CPU: 2 PID: 6928 Comm: trinity-c45 Not tainted 3.15.0-rc5+ #208
> task: ffff88023669d0a0 ti: ffff880186146000 task.ti: ffff880186146000
> RIP: 0010:[<ffffffff8415ba05>]  [<ffffffff8415ba05>] __delete_from_page_cache+0x315/0x320
> RSP: 0018:ffff880186147b18  EFLAGS: 00010046
> RAX: 0000000000000000 RBX: 0000000000000003 RCX: 0000000000000002
> RDX: 000000000000012a RSI: ffffffff84a9a83c RDI: ffffffff84a6e0c0
> RBP: ffff880186147b68 R08: 0000000000000002 R09: ffff88002669e668
> R10: ffff880186147b30 R11: 0000000000000000 R12: ffffea0008b067c0
> R13: ffff880025355670 R14: 0000000000000000 R15: ffff880025355678
> FS:  00007fc10026f740(0000) GS:ffff880244400000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00002ab350f5c004 CR3: 000000018566c000 CR4: 00000000001407e0
> DR0: 0000000001989000 DR1: 0000000000944000 DR2: 0000000002494000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Stack:
>  ffff880025355688 ffff8800253556a0 ffff88002669e668 ffff88002669e6a0
>  000000008ea099ef ffffea0008b067c0 ffff880025355688 0000000000000000
>  0000000000000000 0000000000000002 ffff880186147b90 ffffffff8415ba4d
> Call Trace:
>  [<ffffffff8415ba4d>] delete_from_page_cache+0x3d/0x70
>  [<ffffffff8416b0ab>] truncate_inode_page+0x5b/0x90
>  [<ffffffff84175f0b>] shmem_undo_range+0x30b/0x780
>  [<ffffffff84176394>] shmem_truncate_range+0x14/0x30
>  [<ffffffff8417647d>] shmem_evict_inode+0xcd/0x150
>  [<ffffffff841e4b17>] evict+0xa7/0x170
>  [<ffffffff841e5435>] iput+0xf5/0x180
>  [<ffffffff841df8a0>] dentry_kill+0x260/0x2d0
>  [<ffffffff841df97c>] dput+0x6c/0x110
>  [<ffffffff841c92a9>] __fput+0x189/0x200
>  [<ffffffff841c936e>] ____fput+0xe/0x10
>  [<ffffffff84090484>] task_work_run+0xb4/0xe0
>  [<ffffffff8406ee42>] do_exit+0x302/0xb80
>  [<ffffffff84349e13>] ? __this_cpu_preempt_check+0x13/0x20
>  [<ffffffff8407073c>] do_group_exit+0x4c/0xc0
>  [<ffffffff840707c4>] SyS_exit_group+0x14/0x20
>  [<ffffffff8475bf64>] tracesys+0xdd/0xe2
> Code: 4c 89 30 e9 80 fe ff ff 48 8b 75 c0 4c 89 ff e8 82 8f 1c 00 84 c0 0f 85 6c fe ff ff e9 4f fe ff ff 0f 1f 44 00 00 e8 ae 95 5e 00 <0f> 0b e8 04 1c f1 ff 0f 0b 66 90 0f 1f 44 00 00 55 48 89 e5 41
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

This might shine some light, CONFIG_DEBUG_VM should be =y.

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -199,7 +199,7 @@ void __delete_from_page_cache(struct page *page,
void *shadow)
        __dec_zone_page_state(page, NR_FILE_PAGES);
        if (PageSwapBacked(page))
                __dec_zone_page_state(page, NR_SHMEM);
-       BUG_ON(page_mapped(page));
+       VM_BUG_ON_PAGE(page_mapped(page), page);

        /*
         * Some filesystems seem to re-dirty the page even after



Hugh, As I see shmem truncate/punch hole might race with
shmem_getpage_gfp() (when it converts
swap-entries into normal pages) and leave pages in truncated area. Am I right?
Currently I don't see how exactly this could lead to this problem, but
this looks suspicious.
I don't like the way in which truncate silently skips page entries
when they are changing under it.
Completely untested patch follows.

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -495,8 +495,9 @@ static void shmem_undo_range(struct inode *inode,
loff_t lstart, loff_t lend,
                        if (radix_tree_exceptional_entry(page)) {
                                if (unfalloc)
                                        continue;
-                               nr_swaps_freed += !shmem_free_swap(mapping,
-                                                               index, page);
+                               if (shmem_free_swap(mapping, index, page))
+                                       goto retry;
+                               nr_swaps_freed++;
                                continue;
                        }

@@ -509,10 +510,11 @@ static void shmem_undo_range(struct inode
*inode, loff_t lstart, loff_t lend,
                        }
                        unlock_page(page);
                }
+               index++;
+retry:
                pagevec_remove_exceptionals(&pvec);
                pagevec_release(&pvec);
                mem_cgroup_uncharge_end();
-               index++;
        }

        spin_lock(&info->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
