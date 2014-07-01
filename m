Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8147F6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 03:30:09 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id o6so10101625oag.2
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 00:30:09 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ik8si29015328obc.39.2014.07.01.00.30.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 00:30:08 -0700 (PDT)
Message-ID: <53B26364.1040606@huawei.com>
Date: Tue, 1 Jul 2014 15:29:40 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: How to boot up an ARM board enabled CONFIG_SPARSEMEM
References: <53B26229.5030504@huawei.com>
In-Reply-To: <53B26229.5030504@huawei.com>
Content-Type: multipart/mixed;
	boundary="------------040206030606030302060306"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: wangnan0@huawei.com, yinghai@kernel.org

--------------040206030606030302060306
Content-Type: text/plain; charset="gb18030"
Content-Transfer-Encoding: 7bit

Hi,

Recently We are testing stable kernel 3.10 on an ARM board.
It failed to boot if we enabled CONFIG_SPARSEMEM config.

Through the analysis, we found that mem_init() assumes the pages of different
sections are continuous.

But the truth is the pages of different sections are not continuous when
CONFIG_SPARSEMEM is enabled.

So now we have two ways to boot up when we enabled CONFIG_SPARSEMEM on an arm board.

1. In mem_init() and show_mem() compare pfn instead of page just like the patch in attachement.
2. Enable CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER when enabled CONFIG_SPARSEMEM.

QUESTION:

I want to know why CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER depends on x86_64 ?

Whether we can enable it on an ARM board ?

Or any other better solution ?


Best regards!




--------------040206030606030302060306
Content-Type: text/plain; charset="gb18030";
	name="0001-sparse-mem-compare-pfn-instead-of-page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-sparse-mem-compare-pfn-instead-of-page.patch"

>From c142b3157d4e0f9909076a24b6fe58c60afde0f3 Mon Sep 17 00:00:00 2001
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
Date: Tue, 1 Jul 2014 14:59:19 +0800
Subject: [PATCH] sparse mem: compare pfn instead of page

If CONFIG_SPARSEMEM is enabled, here the pages of different
sections are not continuous.
So we compare pfn instead of page.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 arch/arm/mm/init.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 0ecc43f..a36caac 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -115,6 +115,9 @@ void show_mem(unsigned int filter)
 
 		do {
 			total++;
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_MACH_HI1380)
+			page = pfn_to_page(pfn1);
+#endif
 			if (PageReserved(page))
 				reserved++;
 			else if (PageSwapCache(page))
@@ -125,8 +128,13 @@ void show_mem(unsigned int filter)
 				free++;
 			else
 				shared += page_count(page) - 1;
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_MACH_HI1380)
+			pfn1++;
+		} while (pfn1 < pfn2);
+#else
 			page++;
 		} while (page < end);
+#endif
 	}
 
 	printk("%d pages of RAM\n", total);
@@ -619,12 +627,21 @@ void __init mem_init(void)
 		end  = pfn_to_page(pfn2 - 1) + 1;
 
 		do {
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_MACH_HI1380)
+			page = pfn_to_page(pfn1);
+#endif
 			if (PageReserved(page))
 				reserved_pages++;
 			else if (!page_count(page))
 				free_pages++;
+
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_MACH_HI1380)
+			pfn1++;
+		} while (pfn1 < pfn2);
+#else
 			page++;
 		} while (page < end);
+#endif
 	}
 
 	/*
-- 
1.8.1.2



--------------040206030606030302060306--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
