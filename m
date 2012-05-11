Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id EC4A36B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:07:38 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3388193dak.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:07:37 -0700 (PDT)
Date: Fri, 11 May 2012 10:08:21 +0800
From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] slub: missing test for partial pages flush work in flush_all
Message-ID: <201205111008157652383@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: slub-maintainer <cl@linux.com>, gilad <gilad@benyossef.com>
Cc: linux-mm <linux-mm@kvack.org>

Subject: [PATCH] slub: missing test for partial pages flush work in flush_all

Find some kernel message like:
SLUB raid5-md127: kmem_cache_destroy called for cache that still has objects.
Pid: 6143, comm: mdadm Tainted: G           O 3.4.0-rc6+        #75
Call Trace:
[<ffffffff811227f8>] kmem_cache_destroy+0x328/0x400
[<ffffffffa005ff1d>] free_conf+0x2d/0xf0 [raid456]
[<ffffffffa0060791>] stop+0x41/0x60 [raid456]
[<ffffffffa000276a>] md_stop+0x1a/0x60 [md_mod]
[<ffffffffa000c974>] do_md_stop+0x74/0x470 [md_mod]
[<ffffffffa000d0ff>] md_ioctl+0xff/0x11f0 [md_mod]
[<ffffffff8127c958>] blkdev_ioctl+0xd8/0x7a0
[<ffffffff8115ef6b>] block_ioctl+0x3b/0x40
[<ffffffff8113b9c6>] do_vfs_ioctl+0x96/0x560
[<ffffffff8113bf21>] sys_ioctl+0x91/0xa0
[<ffffffff816e9d22>] system_call_fastpath+0x16/0x1b

Then using kmemleak can found those messages:
unreferenced object 0xffff8800b6db7380 (size 112):
  comm "mdadm", pid 5783, jiffies 4294810749 (age 90.589s)
  hex dump (first 32 bytes):
    01 01 db b6 ad 4e ad de ff ff ff ff ff ff ff ff  .....N..........
    ff ff ff ff ff ff ff ff 98 40 4a 82 ff ff ff ff  .........@J.....
  backtrace:
    [<ffffffff816b52c1>] kmemleak_alloc+0x21/0x50
    [<ffffffff8111a11b>] kmem_cache_alloc+0xeb/0x1b0
    [<ffffffff8111c431>] kmem_cache_open+0x2f1/0x430
    [<ffffffff8111c6c8>] kmem_cache_create+0x158/0x320
    [<ffffffffa008f979>] setup_conf+0x649/0x770 [raid456]
    [<ffffffffa009044b>] run+0x68b/0x840 [raid456]
    [<ffffffffa000bde9>] md_run+0x529/0x940 [md_mod]
    [<ffffffffa000c218>] do_md_run+0x18/0xc0 [md_mod]
    [<ffffffffa000dba8>] md_ioctl+0xba8/0x11f0 [md_mod]
    [<ffffffff81272b28>] blkdev_ioctl+0xd8/0x7a0
    [<ffffffff81155bfb>] block_ioctl+0x3b/0x40
    [<ffffffff811326d6>] do_vfs_ioctl+0x96/0x560
    [<ffffffff81132c31>] sys_ioctl+0x91/0xa0
    [<ffffffff816dd3a2>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff

This bug introduced by Commit a8364d5555b2030d093cde0f0795.The
commit did not include checks for per cpu partial pages being present on a
cpu.

Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 mm/slub.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..6fce08f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return !!(c->page);
+	return c->page || c->partial;
 }
 
 static void flush_all(struct kmem_cache *s)
-- 
1.7.5.4



Thanks all. 
majianpeng
2012-05-09

 				
--------------
majianpeng
2012-05-11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
