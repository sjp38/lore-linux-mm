Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id F0AED6B0093
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:12:02 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4804276pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:12:02 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RFC PATCH 3/8] mm, vmalloc: protect va->vm by vmap_area_lock
Date: Fri,  7 Dec 2012 01:09:30 +0900
Message-Id: <1354810175-4338-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1354810175-4338-1-git-send-email-js1304@gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

Inserting and removing an entry to vmlist is linear time complexity, so
it is inefficient. Following patches will try to remove vmlist entirely.
This patch is preparing step for it.

For removing vmlist, iterating vmlist codes should be changed to iterating
a vmap_area_list. Before implementing that, we should make sure that
when we iterate a vmap_area_list, accessing to va->vm doesn't cause a race
condition. This patch ensure that when iterating a vmap_area_list,
there is no race condition for accessing to vm_struct.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 16147bc..a0b85a6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1290,12 +1290,14 @@ struct vm_struct *vmlist;
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
+	spin_lock(&vmap_area_lock);
 	vm->flags = flags;
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
+	spin_unlock(&vmap_area_lock);
 }
 
 static void insert_vmalloc_vmlist(struct vm_struct *vm)
@@ -1446,6 +1448,11 @@ struct vm_struct *remove_vm_area(const void *addr)
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
 
+		spin_lock(&vmap_area_lock);
+		va->vm = NULL;
+		va->flags &= ~VM_VM_AREA;
+		spin_unlock(&vmap_area_lock);
+
 		if (!(vm->flags & VM_UNLIST)) {
 			struct vm_struct *tmp, **p;
 			/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
