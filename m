Received: from freak.mileniumnet.com.br (IDENT:maluco@freak.mileniumnet.com.br [200.199.222.9])
	by strauss.mileniumnet.com.br (8.9.3/8.9.3) with ESMTP id OAA07664
	for <linux-mm@kvack.org>; Fri, 18 May 2001 14:31:01 -0300
Date: Fri, 18 May 2001 13:20:47 -0400 (AMT)
From: Thiago Rondon <maluco@mileniumnet.com.br>
Subject: [PATCH?] mm/vmalloc.c
Message-ID: <Pine.LNX.4.21.0105181320180.8753-100000@freak.mileniumnet.com.br>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a stupid patch, just to "clean" the code.

--- vmalloc.c.orig	Thu May 17 13:42:43 2001
+++ vmalloc.c	Thu May 17 13:43:38 2001
@@ -180,19 +180,13 @@
 	addr = VMALLOC_START;
 	write_lock(&vmlist_lock);
 	for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
-		if ((size + addr) < addr) {
-			write_unlock(&vmlist_lock);
-			kfree(area);
-			return NULL;
-		}
+		if ((size + addr) < addr)
+			goto out;
 		if (size + addr < (unsigned long) tmp->addr)
 			break;
 		addr = tmp->size + (unsigned long) tmp->addr;
-		if (addr > VMALLOC_END-size) {
-			write_unlock(&vmlist_lock);
-			kfree(area);
-			return NULL;
-		}
+		if (addr > VMALLOC_END-size)
+			goto out;
 	}
 	area->flags = flags;
 	area->addr = (void *)addr;
@@ -201,6 +195,11 @@
 	*p = area;
 	write_unlock(&vmlist_lock);
 	return area;
+
+out:
+	write_unlock(&vmlist_lock);
+	kfree(area);
+	return NULL;
 }
 
 void vfree(void * addr)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
