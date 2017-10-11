Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8900C6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:53:44 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 10so3564874qty.5
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:53:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k88si1733098qtd.521.2017.10.11.01.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 01:53:43 -0700 (PDT)
From: shuwang@redhat.com
Subject: [PATCH] mm: kmemleak: start address align for scan_large_block
Date: Wed, 11 Oct 2017 16:53:34 +0800
Message-Id: <20171011085334.7391-1-shuwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, chuhu@redhat.com, yizhan@redhat.com, Shu Wang <shuwang@redhat.com>

From: Shu Wang <shuwang@redhat.com>

If the start address is not ptr bytes aligned, it may cause false
positives when a pointer is split by MAX_SCAN_SIZE.

For example:
tcp_metrics_nl_family is in __ro_after_init area. On my PC, the
__start_ro_after_init is not ptr aligned, and
tcp_metrics_nl_family->attrbuf was break by MAX_SCAN_SIZE.

 # cat /proc/kallsyms | grep __start_ro_after_init
 ffffffff81afac8b R __start_ro_after_init

 (gdb) p &tcp_metrics_nl_family->attrbuf
   (struct nlattr ***) 0xffffffff81b12c88 <tcp_metrics_nl_family+72>

 (gdb) p tcp_metrics_nl_family->attrbuf
   (struct nlattr **) 0xffff88007b9d9400

 scan_block(_start=0xffffffff81b11c8b, _end=0xffffffff81b12c8b, 0)
 scan_block(_start=0xffffffff81b12c8b, _end=0xffffffff81b13c8b, 0)

unreferenced object 0xffff88007b9d9400 (size 128):
  backtrace:
    kmemleak_alloc+0x4a/0xa0
    __kmalloc+0xec/0x220
    genl_register_family.part.8+0x11c/0x5c0
    genl_register_family+0x6f/0x90
    tcp_metrics_init+0x33/0x47
    tcp_init+0x27a/0x293
    inet_init+0x176/0x28a
    do_one_initcall+0x51/0x1b0

Signed-off-by: Shu Wang <shuwang@redhat.com>
---
 mm/kmemleak.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 7780cd83a495..388b73e01fa4 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1376,6 +1376,7 @@ static void scan_block(void *_start, void *_end,
 static void scan_large_block(void *start, void *end)
 {
 	void *next;
+	start = PTR_ALIGN(start, BYTES_PER_POINTER);
 
 	while (start < end) {
 		next = min(start + MAX_SCAN_SIZE, end);
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
