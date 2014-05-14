Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 194926B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:05:40 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so2274155qge.8
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:05:39 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0147.outbound.protection.outlook.com. [157.56.110.147])
        by mx.google.com with ESMTPS id e88si518127qgf.47.2014.05.14.02.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 May 2014 02:05:39 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [PATCHv2 2/2] ARM: ioremap: Add IO mapping space reused support.
Date: Wed, 14 May 2014 16:18:52 +0800
Message-ID: <1400055532-13134-3-git-send-email-superlibj8301@gmail.com>
In-Reply-To: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
References: <1400055532-13134-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, arnd@arndb.de, robherring2@gmail.com
Cc: lauraa@codeaurora.org, akpm@linux-foundation.org, d.hatayama@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, liwanp@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj8301@gmail.com>

For the IO mapping, the same physical address space maybe
mapped more than one time, for example, in some SoCs:
  - 0x20001000 ~ 0x20001400 --> 1KB for Dev1
  - 0x20001400 ~ 0x20001800 --> 1KB for Dev2
  and the page size is 4KB.

Then both Dev1 and Dev2 will do ioremap operations, and the IO
vmalloc area's virtual address will be aligned down to 4KB, and
the size will be aligned up to 4KB. That's to say, only one
4KB size's vmalloc area could contain Dev1 and Dev2 IO mapping area
at the same time.

For this case, we can ioremap only one time, and the later ioremap
operation will just return the exist vmalloc area.

This patch add IO mapping space reused support.

Signed-off-by: Richard Lee <superlibj8301@gmail.com>
---
 arch/arm/mm/ioremap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index f9c32ba..be69333 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -301,6 +301,12 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 	if (WARN_ON(pfn_valid(pfn)))
 		return NULL;
 
+	area = find_vm_area_paddr(paddr, size, &offset, VM_IOREMAP);
+	if (area) {
+		addr = (unsigned long)area->addr;
+		return (void __iomem *)(offset + addr);
+	}
+
 	area = get_vm_area_caller(size, VM_IOREMAP, caller);
  	if (!area)
  		return NULL;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
