Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A82BB6B00EE
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 22:56:30 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so11340266pdj.14
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:56:30 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id um2si9533771pac.33.2014.11.11.19.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 19:56:29 -0800 (PST)
Message-ID: <5462DA52.7040100@huawei.com>
Date: Wed, 12 Nov 2014 11:56:02 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2] memory-hotplug: remove redundant call of page_to_pfn
References: <1415764673-32152-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1415764673-32152-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: wangnan0@huawei.com, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave
 Hansen <dave.hansen@intel.com>

This is just a small optimization. The start_pfn can be
obtained directly by phys_index << PFN_SECTION_SHIFT.
So the call of page_to_pfn() is redundant and remove it.

v2:
	added the purpose of the patch to the description.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
Acked-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7c5d871..85be040 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -228,8 +228,8 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 	struct page *first_page;
 	int ret;

-	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
-	start_pfn = page_to_pfn(first_page);
+	start_pfn = phys_index << PFN_SECTION_SHIFT;
+	first_page = pfn_to_page(start_pfn);

 	switch (action) {
 		case MEM_ONLINE:
-- 
1.8.1.4


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
