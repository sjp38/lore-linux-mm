Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2E0B6B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 05:29:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j37so115070448ioo.2
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 02:29:35 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id z65si10546664ioi.251.2016.10.14.02.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 02:29:35 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id j37so115077710ioo.3
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 02:29:35 -0700 (PDT)
MIME-Version: 1.0
From: yoma sophian <sophian.yoma@gmail.com>
Date: Fri, 14 Oct 2016 17:29:34 +0800
Message-ID: <CADUS3okBoQNW_mzgZnfr6evK2Qrx2TDtPygqnodn0CwtSyrA8w@mail.gmail.com>
Subject: some question about order0 page allocation
Content-Type: multipart/mixed; boundary=001a113dface423f4a053ecfdd2a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a113dface423f4a053ecfdd2a
Content-Type: text/plain; charset=UTF-8

hi all:
I got oom log like at the end of mail from my embedded system.
But the log makes me curious are
a. the free memory size is ok.
        (Normal free:50080kB)
    the pcp hot page is also enough.
        (Normal per-cpu:
        CPU    0: hi:  186, btch:  31 usd:  18
        CPU    1: hi:  186, btch:  31 usd:  22)

b. the water mark should be ok as well.
    in __alloc_pages_may_oom, we use ALLOC_WMARK_HIGH|ALLOC_CPUSET for
watermake checking.
   so in this case:
   free-free_cma = 3192KB > (highmark -= highmark/2 = 2130KB)

But why the oom-killer sill be activated?
appreciate your kind help in advance.

(the kernel version is 3.10)
[ 5515.127555] dialog invoked oom-killer: gfp_mask=0x80d0, order=0,
oom_score_adj=0
[ 5515.136841] CPU: 0 PID: 1535 Comm: com.nvt.dialser Tainted: G
    O 3.10.0+ #28
[ 5515.145711] Backtrace:
[ 5515.149716] [<c00129f8>] (dump_backtrace+0x0/0x114) from
[<c0012c68>] (show_stack+0x20/0x24)
[ 5515.160163]  r6:000080d0 r5:00000000 r4:de3c2000 r3:271ae71c
[ 5515.167278] [<c0012c48>] (show_stack+0x0/0x24) from [<c0550f6c>]
(dump_stack+0x24/0x28)
[ 5515.177129] [<c0550f48>] (dump_stack+0x0/0x28) from [<c010de20>]
(dump_header.isra.13+0x78/0x18c)
[ 5515.188266] [<c010dda8>] (dump_header.isra.13+0x0/0x18c) from
[<c010e384>] (oom_kill_process+0x268/0x3a8)
[ 5515.199405]  r9:00000000 r8:00000000 r7:000080d0 r6:00022d82 r5:000080d0
r4:df679f80
[ 5515.208930] [<c010e11c>] (oom_kill_process+0x0/0x3a8) from
[<c010e884>] (out_of_memory+0x20c/0x2d8)
[ 5515.219014] [<c010e678>] (out_of_memory+0x0/0x2d8) from
[<c011319c>] (__alloc_pages_nodemask+0x928/0x940)
[ 5515.229835] [<c0112874>] (__alloc_pages_nodemask+0x0/0x940) from
[<c01131d4>] (__get_free_pages+0x20/0x3c)
[ 5515.240825] [<c01131b4>] (__get_free_pages+0x0/0x3c) from
[<c0113210>] (get_zeroed_page+0x20/0x24)
[ 5515.250145] [<c01131f0>] (get_zeroed_page+0x0/0x24) from
[<c01adaa8>] (sysfs_follow_link+0x24/0x1a0)
[ 5515.260366] [<c01ada84>] (sysfs_follow_link+0x0/0x1a0) from
[<c015a8fc>] (path_lookupat+0x388/0x800)
[ 5515.270740] [<c015a574>] (path_lookupat+0x0/0x800) from
[<c015ada4>] (filename_lookup+0x30/0xcc)
[ 5515.281052] [<c015ad74>] (filename_lookup+0x0/0xcc) from
[<c015d520>] (user_path_at_empty+0x68/0x90)
[ 5515.291374]  r8:ffffff9c r7:de3c3f60 r6:de3c3eb8 r5:00000001 r4:d3a853c0
r3:de3c3eb8
[ 5515.300401] [<c015d4b8>] (user_path_at_empty+0x0/0x90) from
[<c015d56c>] (user_path_at+0x24/0x2c)
[ 5515.310516]  r8:00000010 r7:be29cd9c r6:ffffff9c r5:00000000 r4:00000001
[ 5515.318228] [<c015d548>] (user_path_at+0x0/0x2c) from [<c014ca9c>]
(SyS_faccessat+0xa4/0x1f4)
[ 5515.327702] [<c014c9f8>] (SyS_faccessat+0x0/0x1f4) from
[<c014cc10>] (SyS_access+0x24/0x28)
[ 5515.336850] [<c014cbec>] (SyS_access+0x0/0x28) from [<c000e380>]
(ret_fast_syscall+0x0/0x48)
[ 5515.346494] Mem-info:
[ 5515.348849] Normal per-cpu:
[ 5515.352345] CPU    0: hi:  186, btch:  31 usd:  18
[ 5515.357785] CPU    1: hi:  186, btch:  31 usd:  22
[ 5515.362814] active_anon:109178 inactive_anon:2272 isolated_anon:0
[ 5515.362814]  active_file:260 inactive_file:961 isolated_file:0
[ 5515.362814]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 5515.362814]  free:12118 slab_reclaimable:1271 slab_unreclaimable:5113
[ 5515.362814]  mapped:2653 shmem:2298 pagetables:979 bounce:0
[ 5515.362814]  free_cma:11605
[ 5515.396900] Normal free:50080kB min:2840kB low:3548kB high:4260kB
active_anon:436712kB inactive_anon:9088kB active_file:1316kB
inactive_file:1636kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:585728kB managed:504960kB mlocked:0kB
dirty:0kB writeback:0kB mapped:9624kB shmem:9192kB
slab_reclaimable:5084kB slab_unreclaimable:20452kB kernel_stack:2432kB
pagetables:3916kB unstable:0kB bounce:0kB free_cma:46888kB
writeback_tmp:0kB pages_scanned:24 all_unreclaimable? no
[ 5515.441095] lowmem_reserve[]: 0 0 0
[ 5515.444859] Normal: 4314*4kB (UEMC) 3586*8kB (UMC) 131*16kB (MC)
21*32kB (C) 6*64kB (C) 1*128kB (C) 0*256kB 0*512kB 0*1024kB 0*2048kB
0*4096kB = 49224kB
[ 5515.460587] 3477 total pagecache pages
[ 5515.464648] 0 pages in swap cache
[ 5515.468005] Swap cache stats: add 0, delete 0, find 0/0
[ 5515.473512] Free swap  = 0kB
[ 5515.476665] Total swap = 0kB
[ 5515.497647] 146432 pages of RAM
[ 5515.501295] 13056 free pages
[ 5515.504278] 3712 reserved pages
[ 5515.507864] 4891 slab pages
[ 5515.510899] 396881 pages shared
[ 5515.514303] 0 pages swap cached
[ 5515.668990] Out of memory: Kill process 1260 (app) score 563 or
sacrifice child
[ 5515.678006] Killed process 1277 (idlog) total-vm:511668kB,
anon-rss:61016kB, file-rss:680kB
(*) [Fusion Dispatch  5515.978,466] ( 1260: 1518) SaWMan/Watcher:
Process [0x224b4f00 pid:1277 fusion_id:2 flags:] has exited
ABNORMALLY!

--001a113dface423f4a053ecfdd2a
Content-Type: application/x-bzip2; name="oom.log.tar.bz2"
Content-Disposition: attachment; filename="oom.log.tar.bz2"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iu9koj9h0

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
KV5ttlAoth4kkf/F3JFOFCQYSHAfQA==
--001a113dface423f4a053ecfdd2a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
