Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2D9D8E00A2
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:40:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so3114657edb.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 08:40:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8-v6si1445005ejm.81.2019.01.09.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 08:40:37 -0800 (PST)
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [RFC PATCH 01/15] mm/vmalloc: add new 'alignment' field for vm_struct structure
Date: Wed,  9 Jan 2019 17:40:11 +0100
Message-Id: <20190109164025.24554-2-rpenyaev@suse.de>
In-Reply-To: <20190109164025.24554-1-rpenyaev@suse.de>
References: <20190109164025.24554-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I need a new alignment field for vm area in order to reallocate
previously allocated area with the same alignment.

Patch for a new vrealloc() call will follow and this new call
I want to keep as simple as possible, thus not to provide dozens
of variants, like vrealloc_user(), which cares about alignment.

Current changes are just preparations.

Worth to mention, that on archs were unsigned long is 64 bit
this new field does not bloat vm_struct, because originally
there was a padding between nr_pages and phys_addr.

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            | 10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..78210aa0bb43 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -38,6 +38,7 @@ struct vm_struct {
 	unsigned long		flags;
 	struct page		**pages;
 	unsigned int		nr_pages;
+	unsigned int		alignment;
 	phys_addr_t		phys_addr;
 	const void		*caller;
 };
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e83961767dc1..4851b4a67f55 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1347,12 +1347,14 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 EXPORT_SYMBOL_GPL(map_vm_area);
 
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
-			      unsigned long flags, const void *caller)
+			     unsigned int align, unsigned long flags,
+			     const void *caller)
 {
 	spin_lock(&vmap_area_lock);
 	vm->flags = flags;
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
+	vm->alignment = align;
 	vm->caller = caller;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
@@ -1399,7 +1401,7 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 	}
 
-	setup_vmalloc_vm(area, va, flags, caller);
+	setup_vmalloc_vm(area, va, align, flags, caller);
 
 	return area;
 }
@@ -2601,8 +2603,8 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 
 	/* insert all vm's */
 	for (area = 0; area < nr_vms; area++)
-		setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
-				 pcpu_get_vm_areas);
+		setup_vmalloc_vm(vms[area], vas[area], align,
+				 VM_ALLOC, pcpu_get_vm_areas);
 
 	kfree(vas);
 	return vms;
-- 
2.19.1
