Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCA236B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:04:40 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id c41so2906820otc.18
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:04:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si1210777otf.146.2017.11.29.22.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 22:04:39 -0800 (PST)
Date: Thu, 30 Nov 2017 14:04:31 +0800
From: Dave Young <dyoung@redhat.com>
Subject: [PATCH] mm: check pfn_valid first in zero_resv_unavail
Message-ID: <20171130060431.GA2290@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: pasha.tatashin@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org

With latest kernel I get below bug while testing kdump:

[    0.000000] BUG: unable to handle kernel paging request at ffffea00034b1040
[    0.000000] IP: zero_resv_unavail+0xbd/0x126
[    0.000000] PGD 37b98067 P4D 37b98067 PUD 37b97067 PMD 0 
[    0.000000] Oops: 0002 [#1] SMP
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.15.0-rc1+ #316
[    0.000000] Hardware name: LENOVO 20ARS1BJ02/20ARS1BJ02, BIOS GJET92WW (2.42 ) 03/03/2017
[    0.000000] task: ffffffff81a0e4c0 task.stack: ffffffff81a00000
[    0.000000] RIP: 0010:zero_resv_unavail+0xbd/0x126
[    0.000000] RSP: 0000:ffffffff81a03d88 EFLAGS: 00010006
[    0.000000] RAX: 0000000000000000 RBX: ffffea00034b1040 RCX: 0000000000000010
[    0.000000] RDX: 0000000000000000 RSI: 0000000000000092 RDI: ffffea00034b1040
[    0.000000] RBP: 00000000000d2c41 R08: 00000000000000c0 R09: 0000000000000a0d
[    0.000000] R10: 0000000000000002 R11: 0000000000007f01 R12: ffffffff81a03d90
[    0.000000] R13: ffffea0000000000 R14: 0000000000000063 R15: 0000000000000062
[    0.000000] FS:  0000000000000000(0000) GS:ffffffff81c73000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffffea00034b1040 CR3: 0000000037609000 CR4: 00000000000606b0
[    0.000000] Call Trace:
[    0.000000]  ? free_area_init_nodes+0x640/0x664
[    0.000000]  ? zone_sizes_init+0x58/0x72
[    0.000000]  ? setup_arch+0xb50/0xc6c
[    0.000000]  ? start_kernel+0x64/0x43d
[    0.000000]  ? secondary_startup_64+0xa5/0xb0
[    0.000000] Code: c1 e8 0c 48 39 d8 76 27 48 89 de 48 c1 e3 06 48 c7 c7 7a 87 79 81 e8 b0 c0 3e ff 4c 01 eb b9 10 00 00 00 31 c0 48 89 df 49 ff c6 <f3> ab eb bc 6a 00 49 
c7 c0 f0 93 d1 81 31 d2 83 ce ff 41 54 49 
[    0.000000] RIP: zero_resv_unavail+0xbd/0x126 RSP: ffffffff81a03d88
[    0.000000] CR2: ffffea00034b1040
[    0.000000] ---[ end trace f5ba9e8f73c7ee26 ]---

This is introduced with below commit:
commit a4a3ede2132ae0863e2d43e06f9b5697c51a7a3b
Author: Pavel Tatashin <pasha.tatashin@oracle.com>
Date:   Wed Nov 15 17:36:31 2017 -0800

    mm: zero reserved and unavailable struct pages

The reason is some efi reserved boot ranges is not reported in E820 ram.
In my case it is a bgrt buffer:
efi: mem00: [Boot Data          |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x00000000d2c41000-0x00000000d2c85fff] (0MB)

Use "add_efi_memmap" can workaround the problem with another fix:
https://lkml.org/lkml/2017/11/30/5

In zero_resv_unavail it would be better to check pfn_valid first before zero
the page struct. This fixes the problem and potential other similar problems.

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -6253,6 +6253,8 @@ void __paginginit zero_resv_unavail(void
 	pgcnt = 0;
 	for_each_resv_unavail_range(i, &start, &end) {
 		for (pfn = PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
+			if (!pfn_valid(pfn))
+				continue;
 			mm_zero_struct_page(pfn_to_page(pfn));
 			pgcnt++;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
