Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D9D196B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:49:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 34so103562671pgx.6
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:49:51 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id t126si10093977pgb.42.2017.04.17.22.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 22:49:50 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 63so18321029pgh.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 22:49:50 -0700 (PDT)
From: Hoeun Ryu <hoeun.ryu@gmail.com>
Subject: [PATCH v2] mm: add VM_STATIC flag to vmalloc and prevent from removing the areas
Date: Tue, 18 Apr 2017 14:48:39 +0900
Message-Id: <1492494570-21068-1-git-send-email-hoeun.ryu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org, khandual@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Roman Pen <r.peniaev@gmail.com>, Michal Hocko <mhocko@suse.com>, Andreas Dilger <adilger@dilger.ca>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-arch@vger.kernel.org, Hoeun Ryu <hoeun.ryu@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

 vm_area_add_early/vm_area_register_early() are used to reserve vmalloc area
during boot process and those virtually mapped areas are never unmapped.
So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
existing vmlist entries and prevent those areas from being removed from the
rbtree by accident. This flags can be also used by other vmalloc APIs to
specify that the area will never go away.
 This makes remove_vm_area() more robust against other kind of errors (eg.
programming errors).

Signed-off-by: Hoeun Ryu <hoeun.ryu@gmail.com>
---
v2:
 - update changelog
 - add description to VM_STATIC
 - check VM_STATIC first before VM_VM_AREA in remove_vm_area()

 include/linux/vmalloc.h | 7 +++++++
 mm/vmalloc.c            | 9 ++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 46991ad..a42c210 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -19,6 +19,13 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+/*
+ * static area, vmap_area will never go away.
+ * This flag is OR-ed automatically in vmalloc_init() if the area is inserted
+ * by vm_area_add_early()/vm_area_register_early() during early boot process
+ * or you can give this flag manually using other vmalloc APIs.
+ */
+#define VM_STATIC		0x00000200
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8ef8ea1..6bc6c39 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1262,7 +1262,7 @@ void __init vmalloc_init(void)
 	/* Import existing vmlist entries. */
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
-		va->flags = VM_VM_AREA;
+		va->flags = VM_VM_AREA | VM_STATIC;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
@@ -1480,7 +1480,7 @@ struct vm_struct *remove_vm_area(const void *addr)
 	might_sleep();
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
+	if (va && likely(!(va->flags & VM_STATIC)) && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
 
 		spin_lock(&vmap_area_lock);
@@ -1510,7 +1510,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 
 	area = remove_vm_area(addr);
 	if (unlikely(!area)) {
-		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
+		WARN(1, KERN_ERR "Trying to vfree() nonexistent or static vm area (%p)\n",
 				addr);
 		return;
 	}
@@ -2708,6 +2708,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->phys_addr)
 		seq_printf(m, " phys=%pa", &v->phys_addr);
 
+	if (v->flags & VM_STATIC)
+		seq_puts(m, " static");
+
 	if (v->flags & VM_IOREMAP)
 		seq_puts(m, " ioremap");
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
