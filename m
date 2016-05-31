Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB9446B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 06:08:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a136so41013986wme.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:08:51 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id a195si36072975wma.36.2016.05.31.03.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 03:08:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 01AB01C34EB
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:08:50 +0100 (IST)
Date: Tue, 31 May 2016 11:08:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, page_alloc: Reset zonelist iterator after resetting fair
 zone allocation policy
Message-ID: <20160531100848.GR2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

Geert Uytterhoeven reported the following problem that bisected to commit
c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a
zonelist twice") on m68k/ARAnyM

    BUG: scheduling while atomic: cron/668/0x10c9a0c0
    Modules linked in:
    CPU: 0 PID: 668 Comm: cron Not tainted 4.6.0-atari-05133-gc33d6c06f60f710f #364
    Stack from 10c9a074:
            10c9a074 003763ca 0003d7d0 00361a58 00bcf834 0000029c 10c9a0c0 10c9a0c0
            002f0f42 00bcf5e0 00000000 00000082 0048e018 00000000 00000000 002f0c30
            000410de 00000000 00000000 10c9a0e0 002f112c 00000000 7fffffff 10c9a180
            003b1490 00bcf60c 10c9a1f0 10c9a118 002f2d30 00000000 10c9a174 10c9a180
            0003ef56 003b1490 00bcf60c 003b1490 00bcf60c 0003eff6 003b1490 00bcf60c
            003b1490 10c9a128 002f118e 7fffffff 00000082 002f1612 002f1624 7fffffff
    Call Trace: [<0003d7d0>] __schedule_bug+0x40/0x54
     [<002f0f42>] __schedule+0x312/0x388
     [<002f0c30>] __schedule+0x0/0x388
     [<000410de>] prepare_to_wait+0x0/0x52
     [<002f112c>] schedule+0x64/0x82
     [<002f2d30>] schedule_timeout+0xda/0x104
     [<0003ef56>] set_next_entity+0x18/0x40
     [<0003eff6>] pick_next_task_fair+0x78/0xda
     [<002f118e>] io_schedule_timeout+0x36/0x4a
     [<002f1612>] bit_wait_io+0x0/0x40
     [<002f1624>] bit_wait_io+0x12/0x40
     [<002f12c4>] __wait_on_bit+0x46/0x76
     [<0006a06a>] wait_on_page_bit_killable+0x64/0x6c
     [<002f1612>] bit_wait_io+0x0/0x40
     [<000411fe>] wake_bit_function+0x0/0x4e
     [<0006a1b8>] __lock_page_or_retry+0xde/0x124
     [<00217000>] do_scan_async+0x114/0x17c
     [<00098856>] lookup_swap_cache+0x24/0x4e
     [<0008b7c8>] handle_mm_fault+0x626/0x7de
     [<0008ef46>] find_vma+0x0/0x66
     [<002f2612>] down_read+0x0/0xe
     [<0006a001>] wait_on_page_bit_killable_timeout+0x77/0x7c
     [<0008ef5c>] find_vma+0x16/0x66
     [<00006b44>] do_page_fault+0xe6/0x23a
     [<0000c350>] res_func+0xa3c/0x141a
     [<00005bb8>] buserr_c+0x190/0x6d4
     [<0000c350>] res_func+0xa3c/0x141a
     [<000028ec>] buserr+0x20/0x28
     [<0000c350>] res_func+0xa3c/0x141a
     [<000028ec>] buserr+0x20/0x28

The relationship is not obvious but it's due to a failure to rescan the full
zonelist after the fair zone allocation policy exhausts the batch count. While
this is a functional problem, it's also a performance issue. A page allocator
microbenchmark showed the following

                                 4.7.0-rc1                  4.7.0-rc1
                                   vanilla                 reset-v1r2
Min      alloc-odr0-1     327.00 (  0.00%)           326.00 (  0.31%)
Min      alloc-odr0-2     235.00 (  0.00%)           235.00 (  0.00%)
Min      alloc-odr0-4     198.00 (  0.00%)           198.00 (  0.00%)
Min      alloc-odr0-8     170.00 (  0.00%)           170.00 (  0.00%)
Min      alloc-odr0-16    156.00 (  0.00%)           156.00 (  0.00%)
Min      alloc-odr0-32    150.00 (  0.00%)           150.00 (  0.00%)
Min      alloc-odr0-64    146.00 (  0.00%)           146.00 (  0.00%)
Min      alloc-odr0-128   145.00 (  0.00%)           145.00 (  0.00%)
Min      alloc-odr0-256   155.00 (  0.00%)           155.00 (  0.00%)
Min      alloc-odr0-512   168.00 (  0.00%)           165.00 (  1.79%)
Min      alloc-odr0-1024  175.00 (  0.00%)           174.00 (  0.57%)
Min      alloc-odr0-2048  180.00 (  0.00%)           180.00 (  0.00%)
Min      alloc-odr0-4096  187.00 (  0.00%)           186.00 (  0.53%)
Min      alloc-odr0-8192  190.00 (  0.00%)           190.00 (  0.00%)
Min      alloc-odr0-16384 191.00 (  0.00%)           191.00 (  0.00%)
Min      alloc-odr1-1     736.00 (  0.00%)           445.00 ( 39.54%)
Min      alloc-odr1-2     343.00 (  0.00%)           335.00 (  2.33%)
Min      alloc-odr1-4     277.00 (  0.00%)           270.00 (  2.53%)
Min      alloc-odr1-8     238.00 (  0.00%)           233.00 (  2.10%)
Min      alloc-odr1-16    224.00 (  0.00%)           218.00 (  2.68%)
Min      alloc-odr1-32    210.00 (  0.00%)           208.00 (  0.95%)
Min      alloc-odr1-64    207.00 (  0.00%)           203.00 (  1.93%)
Min      alloc-odr1-128   276.00 (  0.00%)           202.00 ( 26.81%)
Min      alloc-odr1-256   206.00 (  0.00%)           202.00 (  1.94%)
Min      alloc-odr1-512   207.00 (  0.00%)           202.00 (  2.42%)
Min      alloc-odr1-1024  208.00 (  0.00%)           205.00 (  1.44%)
Min      alloc-odr1-2048  213.00 (  0.00%)           212.00 (  0.47%)
Min      alloc-odr1-4096  218.00 (  0.00%)           216.00 (  0.92%)
Min      alloc-odr1-8192  341.00 (  0.00%)           219.00 ( 35.78%)
.
Note that order-0 allocations are unaffected but higher orders get
a small boost from this patch and a large reduction in system CPU
usage overall as can be seen here

           4.7.0-rc1   4.7.0-rc1
             vanilla  reset-v1r2
User           85.32       86.31
System       2221.39     2053.36
Elapsed      2368.89     2202.47

Fixes: c33d6c06f60f ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
Reported-and-tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb320cde4d6d..557549c81083 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3024,6 +3024,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		apply_fair = false;
 		fair_skipped = false;
 		reset_alloc_batches(ac->preferred_zoneref->zone);
+		z = ac->preferred_zoneref;
 		goto zonelist_scan;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
