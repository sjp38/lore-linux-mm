Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8764F6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 23:34:15 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so49053906obb.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 20:34:14 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id kg2si5646949oeb.87.2015.09.23.20.33.50
        for <linux-mm@kvack.org>;
        Wed, 23 Sep 2015 20:34:14 -0700 (PDT)
From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: [PATCH RESEND] CMA: fix CONFIG_CMA_SIZE_MBYTES overflow in 64bit
Date: Thu, 24 Sep 2015 11:27:47 +0800
Message-ID: <1443065267-97873-1-git-send-email-tanxiaojun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, kyungmin.park@samsung.com, iamjoonsoo.kim@lge.com, grant.likely@linaro.org, arnd@arndb.de, joshc@codeaurora.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Tan Xiaojun <tanxiaojun@huawei.com>

In 64bit system, if you set CONFIG_CMA_SIZE_MBYTES>=2048, it will
overflow and size_bytes will be a big wrong number.

Set CONFIG_CMA_SIZE_MBYTES=2048 and you will get an info below
during system boot:

*********
cma: Failed to reserve 17592186042368 MiB
*********

Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
---
 drivers/base/dma-contiguous.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 950fff9..426ba27 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -46,7 +46,7 @@ struct cma *dma_contiguous_default_area;
  * Users, who want to set the size of global CMA area for their system
  * should use cma= kernel parameter.
  */
-static const phys_addr_t size_bytes = CMA_SIZE_MBYTES * SZ_1M;
+static const phys_addr_t size_bytes = (phys_addr_t)CMA_SIZE_MBYTES * SZ_1M;
 static phys_addr_t size_cmdline = -1;
 static phys_addr_t base_cmdline;
 static phys_addr_t limit_cmdline;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
