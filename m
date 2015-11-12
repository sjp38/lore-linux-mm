Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id F1B906B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:17:08 -0500 (EST)
Received: by vkgy188 with SMTP id y188so12118156vkg.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:17:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 186si2868041vki.141.2015.11.12.07.17.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 07:17:08 -0800 (PST)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH] mm: vmalloc: don't remove inexistent guard hole in remove_vm_area()
Date: Thu, 12 Nov 2015 16:17:04 +0100
Message-Id: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: linux-kernel@vger.kernel.org

Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
allocation") missed a spot. Currently remove_vm_area() decreases
vm->size to remove the guard hole page, even when it isn't present.
This patch only decreases vm->size when VM_NO_GUARD isn't set.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/vmalloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d045634..1388c3d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1443,7 +1443,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 		vmap_debug_free_range(va->va_start, va->va_end);
 		kasan_free_shadow(vm);
 		free_unmap_vmap_area(va);
-		vm->size -= PAGE_SIZE;
+		if (!(vm->flags & VM_NO_GUARD))
+			vm->size -= PAGE_SIZE;
 
 		return vm;
 	}
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
