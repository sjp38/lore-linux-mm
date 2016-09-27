Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4495728027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 08:50:10 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu14so23518527pad.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 05:50:10 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id g2si2688887pav.59.2016.09.27.05.50.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 05:50:09 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RESEND RFC PATCH 1/1] linux/mm.h: canonicalize macro PAGE_ALIGNED()
 definition
Message-ID: <57EA6AE7.7090807@zoho.com>
Date: Tue, 27 Sep 2016 20:49:43 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, npiggin@gmail.com, mhocko@kernel.org

From: zijun_hu <zijun_hu@htc.com>

macro PAGE_ALIGNED() is prone to cause error because it doesn't follow
convention to parenthesize parameter @addr within macro body, for example
unsigned long *ptr = kmalloc(...); PAGE_ALIGNED(ptr + 16);
for the left parameter of macro IS_ALIGNED(), (unsigned long)(ptr + 16)
is desired but the actual one is (unsigned long)ptr + 16

it is fixed by simply canonicalizing macro PAGE_ALIGNED() definition

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9cd426..ec6818631635 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -126,7 +126,7 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
 
 /* test whether an address (unsigned long or pointer) is aligned to PAGE_SIZE */
-#define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)addr, PAGE_SIZE)
+#define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)(addr), PAGE_SIZE)
 
 /*
  * Linux kernel virtual memory manager primitives.
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
