Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id BB60F6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:40:26 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so60997186obd.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:40:26 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id rw3si13773371obb.49.2015.07.27.07.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 07:40:26 -0700 (PDT)
From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next] mm: Fix build for nommu systems
Date: Mon, 27 Jul 2015 07:40:17 -0700
Message-Id: <1438008017-14692-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>

Commit 31705a3a633b ("mm, mpx: add vm_flags_t vm_flags arg to
do_mmap_pgoff()") added vm_flags as parameter to do_mmap_pgoff().
The resulting code for nommu systems no longer compiles.

The fix matches the mmu code changes.

Fixes: 31705a3a633b ("mm, mpx: add vm_flags_t vm_flags arg to
	do_mmap_pgoff()")
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 mm/nommu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 530eea5af989..af2196e35013 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1245,7 +1245,7 @@ unsigned long do_mmap(struct file *file,
 	struct vm_area_struct *vma;
 	struct vm_region *region;
 	struct rb_node *rb;
-	unsigned long capabilities, vm_flags, result;
+	unsigned long capabilities, result;
 	int ret;
 
 	*populate = 0;
@@ -1263,7 +1263,7 @@ unsigned long do_mmap(struct file *file,
 
 	/* we've determined that we can make the mapping, now translate what we
 	 * now know into VMA flags */
-	vm_flags = determine_vm_flags(file, prot, flags, capabilities);
+	vm_flags |= determine_vm_flags(file, prot, flags, capabilities);
 
 	/* we're going to need to record the mapping */
 	region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
