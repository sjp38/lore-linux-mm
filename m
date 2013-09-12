Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3C0F56B0033
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 06:03:31 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH v2 3/9] x86, dma: Support allocate memory from bottom upwards in dma_contiguous_reserve().
Date: Thu, 12 Sep 2013 17:52:11 +0800
Message-Id: <1378979537-21196-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

During early boot, if the bottom up mode is set, just
try allocating bottom up from the end of kernel image,
and if that fails, do normal top down allocation.

So in function dma_contiguous_reserve(), we add the
above logic.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 drivers/base/dma-contiguous.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 99802d6..aada945 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -228,17 +228,28 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 			goto err;
 		}
 	} else {
+		phys_addr_t addr;
+
+		if (memblock_direction_bottom_up()) {
+			addr = memblock_alloc_bottom_up(
+						MEMBLOCK_ALLOC_ACCESSIBLE,
+						limit, size, alignment);
+			if (addr)
+				goto success;
+		}
+
 		/*
 		 * Use __memblock_alloc_base() since
 		 * memblock_alloc_base() panic()s.
 		 */
-		phys_addr_t addr = __memblock_alloc_base(size, alignment, limit);
+		addr = __memblock_alloc_base(size, alignment, limit);
 		if (!addr) {
 			ret = -ENOMEM;
 			goto err;
-		} else {
-			base = addr;
 		}
+
+success:
+		base = addr;
 	}
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
