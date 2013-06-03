Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 996C86B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:31:48 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so5836270pbb.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 08:31:47 -0700 (PDT)
Message-ID: <51ACB6DB.6040809@gmail.com>
Date: Mon, 03 Jun 2013 23:31:39 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm, vmalloc: Only call setup_vmalloc_vm only in __get_vm_area_node
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Now for insert_vmalloc_vm, it only calls the two functions:
- setup_vmalloc_vm: fill vm_struct and vmap_area instances
- clear_vm_unlist: clear VM_UNLIST bit in vm_struct->flags

So in function __get_vm_area_node, if VM_UNLIST bit unset
in flags, that is the else branch here, we don't need to
clear VM_UNLIST bit for vm->flags since this bit is obviously
not set. That is to say, we could only call setup_vmalloc_vm
instead of insert_vmalloc_vm here. And then we could even
remove the if test here.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d365724..6580c76 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1367,16 +1367,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 	}
 
-	/*
-	 * When this function is called from __vmalloc_node_range,
-	 * we add VM_UNLIST flag to avoid accessing uninitialized
-	 * members of vm_struct such as pages and nr_pages fields.
-	 * They will be set later.
-	 */
-	if (flags & VM_UNLIST)
-		setup_vmalloc_vm(area, va, flags, caller);
-	else
-		insert_vmalloc_vm(area, va, flags, caller);
+	setup_vmalloc_vm(area, va, flags, caller);
 
 	return area;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
