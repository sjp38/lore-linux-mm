Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0112803BE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:54:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u191so13608336pgc.13
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 13:54:55 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id g65si1531352pgc.150.2017.08.23.13.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 13:54:53 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id m7so740755pga.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 13:54:53 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] mm/madvise: fix freeing of locked page with MADV_FREE
Date: Wed, 23 Aug 2017 13:52:35 -0700
Message-Id: <20170823205235.132061-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, David Rientjes <rientjes@google.com>, Eric Biggers <ebiggers@google.com>

From: Eric Biggers <ebiggers@google.com>

If madvise(..., MADV_FREE) split a transparent hugepage, it called
put_page() before unlock_page().  This was wrong because put_page() can
free the page, e.g. if a concurrent madvise(..., MADV_DONTNEED) has
removed it from the memory mapping.  put_page() then rightfully
complained about freeing a locked page.

Fix this by moving the unlock_page() before put_page().

This bug was found by syzkaller, which encountered the following splat:

    BUG: Bad page state in process syzkaller412798  pfn:1bd800
    page:ffffea0006f60000 count:0 mapcount:0 mapping:          (null) index:0x20a00
    flags: 0x200000000040019(locked|uptodate|dirty|swapbacked)
    raw: 0200000000040019 0000000000000000 0000000000020a00 00000000ffffffff
    raw: ffffea0006f60020 ffffea0006f60020 0000000000000000 0000000000000000
    page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
    bad because of flags: 0x1(locked)
    Modules linked in:
    CPU: 1 PID: 3037 Comm: syzkaller412798 Not tainted 4.13.0-rc5+ #35
    Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
    Call Trace:
     __dump_stack lib/dump_stack.c:16 [inline]
     dump_stack+0x194/0x257 lib/dump_stack.c:52
     bad_page+0x230/0x2b0 mm/page_alloc.c:565
     free_pages_check_bad+0x1f0/0x2e0 mm/page_alloc.c:943
     free_pages_check mm/page_alloc.c:952 [inline]
     free_pages_prepare mm/page_alloc.c:1043 [inline]
     free_pcp_prepare mm/page_alloc.c:1068 [inline]
     free_hot_cold_page+0x8cf/0x12b0 mm/page_alloc.c:2584
     __put_single_page mm/swap.c:79 [inline]
     __put_page+0xfb/0x160 mm/swap.c:113
     put_page include/linux/mm.h:814 [inline]
     madvise_free_pte_range+0x137a/0x1ec0 mm/madvise.c:371
     walk_pmd_range mm/pagewalk.c:50 [inline]
     walk_pud_range mm/pagewalk.c:108 [inline]
     walk_p4d_range mm/pagewalk.c:134 [inline]
     walk_pgd_range mm/pagewalk.c:160 [inline]
     __walk_page_range+0xc3a/0x1450 mm/pagewalk.c:249
     walk_page_range+0x200/0x470 mm/pagewalk.c:326
     madvise_free_page_range.isra.9+0x17d/0x230 mm/madvise.c:444
     madvise_free_single_vma+0x353/0x580 mm/madvise.c:471
     madvise_dontneed_free mm/madvise.c:555 [inline]
     madvise_vma mm/madvise.c:664 [inline]
     SYSC_madvise mm/madvise.c:832 [inline]
     SyS_madvise+0x7d3/0x13c0 mm/madvise.c:760
     entry_SYSCALL_64_fastpath+0x1f/0xbe

Here is a C reproducer:

    #define _GNU_SOURCE
    #include <pthread.h>
    #include <sys/mman.h>
    #include <unistd.h>

    #define MADV_FREE	8
    #define PAGE_SIZE	4096

    static void *mapping;
    static const size_t mapping_size = 0x1000000;

    static void *madvise_thrproc(void *arg)
    {
        madvise(mapping, mapping_size, (long)arg);
    }

    int main(void)
    {
        pthread_t t[2];

        for (;;) {
            mapping = mmap(NULL, mapping_size, PROT_WRITE,
                           MAP_POPULATE|MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);

            munmap(mapping + mapping_size / 2, PAGE_SIZE);

            pthread_create(&t[0], 0, madvise_thrproc, (void*)MADV_DONTNEED);
            pthread_create(&t[1], 0, madvise_thrproc, (void*)MADV_FREE);
            pthread_join(t[0], NULL);
            pthread_join(t[1], NULL);
            munmap(mapping, mapping_size);
        }
    }

Note: to see the splat, CONFIG_TRANSPARENT_HUGEPAGE=y and
CONFIG_DEBUG_VM=y are needed.

Fixes: 854e9ed09ded ("mm: support madvise(MADV_FREE)")
Google-Bug-Id: 64696096
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org # v4.5+
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 47d8d8a25eae..23ed525bc2bc 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -368,8 +368,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				pte_offset_map_lock(mm, pmd, addr, &ptl);
 				goto out;
 			}
-			put_page(page);
 			unlock_page(page);
+			put_page(page);
 			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 			pte--;
 			addr -= PAGE_SIZE;
-- 
2.14.1.342.g6490525c54-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
