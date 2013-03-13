Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 5A3CA6B003A
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:33:12 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 4/8] mm, vmalloc: iterate vmap_area_list, instead of vmlist in vread/vwrite()
Date: Wed, 13 Mar 2013 15:32:56 +0900
Message-Id: <1363156381-2881-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Bob Liu <lliubbo@gmail.com>, Pekka Enberg <penberg@kernel.org>, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <js1304@gmail.com>

Now, when we hold a vmap_area_lock, va->vm can't be discarded. So we can
safely access to va->vm when iterating a vmap_area_list with holding a
vmap_area_lock. With this property, change iterating vmlist codes in
vread/vwrite() to iterating vmap_area_list.

There is a little difference relate to lock, because vmlist_lock is mutex,
but, vmap_area_lock is spin_lock. It may introduce a spinning overhead
during vread/vwrite() is executing. But, these are debug-oriented
functions, so this overhead is not real problem for common case.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1bf94ad..59aa328 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2012,7 +2012,8 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
 
 long vread(char *buf, char *addr, unsigned long count)
 {
-	struct vm_struct *tmp;
+	struct vmap_area *va;
+	struct vm_struct *vm;
 	char *vaddr, *buf_start = buf;
 	unsigned long buflen = count;
 	unsigned long n;
@@ -2021,10 +2022,17 @@ long vread(char *buf, char *addr, unsigned long count)
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
-	read_lock(&vmlist_lock);
-	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
-		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+	spin_lock(&vmap_area_lock);
+	list_for_each_entry(va, &vmap_area_list, list) {
+		if (!count)
+			break;
+
+		if (!(va->flags & VM_VM_AREA))
+			continue;
+
+		vm = va->vm;
+		vaddr = (char *) vm->addr;
+		if (addr >= vaddr + vm->size - PAGE_SIZE)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -2034,10 +2042,10 @@ long vread(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + vm->size - PAGE_SIZE - addr;
 		if (n > count)
 			n = count;
-		if (!(tmp->flags & VM_IOREMAP))
+		if (!(vm->flags & VM_IOREMAP))
 			aligned_vread(buf, addr, n);
 		else /* IOREMAP area is treated as memory hole */
 			memset(buf, 0, n);
@@ -2046,7 +2054,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	read_unlock(&vmlist_lock);
+	spin_unlock(&vmap_area_lock);
 
 	if (buf == buf_start)
 		return 0;
@@ -2085,7 +2093,8 @@ finished:
 
 long vwrite(char *buf, char *addr, unsigned long count)
 {
-	struct vm_struct *tmp;
+	struct vmap_area *va;
+	struct vm_struct *vm;
 	char *vaddr;
 	unsigned long n, buflen;
 	int copied = 0;
@@ -2095,10 +2104,17 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count = -(unsigned long) addr;
 	buflen = count;
 
-	read_lock(&vmlist_lock);
-	for (tmp = vmlist; count && tmp; tmp = tmp->next) {
-		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+	spin_lock(&vmap_area_lock);
+	list_for_each_entry(va, &vmap_area_list, list) {
+		if (!count)
+			break;
+
+		if (!(va->flags & VM_VM_AREA))
+			continue;
+
+		vm = va->vm;
+		vaddr = (char *) vm->addr;
+		if (addr >= vaddr + vm->size - PAGE_SIZE)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -2107,10 +2123,10 @@ long vwrite(char *buf, char *addr, unsigned long count)
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + vm->size - PAGE_SIZE - addr;
 		if (n > count)
 			n = count;
-		if (!(tmp->flags & VM_IOREMAP)) {
+		if (!(vm->flags & VM_IOREMAP)) {
 			aligned_vwrite(buf, addr, n);
 			copied++;
 		}
@@ -2119,7 +2135,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	read_unlock(&vmlist_lock);
+	spin_unlock(&vmap_area_lock);
 	if (!copied)
 		return 0;
 	return buflen;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
