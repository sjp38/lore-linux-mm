Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB2B6B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:37:23 -0500 (EST)
Received: by vkbs1 with SMTP id s1so13949310vkb.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:37:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 132si3217122vki.116.2015.11.12.08.37.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 08:37:22 -0800 (PST)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH V2] mm: vmalloc: don't remove inexistent guard hole in remove_vm_area()
Date: Thu, 12 Nov 2015 17:37:18 +0100
Message-Id: <1447346238-29153-1-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
References: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
allocation") missed a spot. Currently remove_vm_area() decreases
vm->size to "remove" the guard hole page, even when it isn't present.
All but one users just free the vm_struct rigth away and never access
vm->size anyway.
Don't touch the size in remove_vm_area() and have __vunmap() use the
proper get_vm_area_size() helper.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/vmalloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d045634..8e3c9c5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1443,7 +1443,6 @@ struct vm_struct *remove_vm_area(const void *addr)
 		vmap_debug_free_range(va->va_start, va->va_end);
 		kasan_free_shadow(vm);
 		free_unmap_vmap_area(va);
-		vm->size -= PAGE_SIZE;
 
 		return vm;
 	}
@@ -1468,8 +1467,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
 		return;
 	}
 
-	debug_check_no_locks_freed(addr, area->size);
-	debug_check_no_obj_freed(addr, area->size);
+	debug_check_no_locks_freed(addr, get_vm_area_size(area));
+	debug_check_no_obj_freed(addr, get_vm_area_size(area));
 
 	if (deallocate_pages) {
 		int i;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
