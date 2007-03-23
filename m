Date: Thu, 22 Mar 2007 22:35:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] sprint_symbol should return length of string like sprintf
Message-ID: <Pine.LNX.4.64.0703222234320.7918@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[PATCH] sprint_symbol should return length of string like sprintf

Make sprint_symbol return the length of the symbol

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc4-mm1/include/linux/kallsyms.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/linux/kallsyms.h	2007-03-22 11:35:28.000000000 -0700
+++ linux-2.6.21-rc4-mm1/include/linux/kallsyms.h	2007-03-22 11:37:19.000000000 -0700
@@ -25,7 +25,7 @@ const char *kallsyms_lookup(unsigned lon
 			    char **modname, char *namebuf);
 
 /* Look up a kernel symbol and return it in a text buffer. */
-extern void sprint_symbol(char *buffer, unsigned long address);
+extern int sprint_symbol(char *buffer, unsigned long address);
 
 /* Look up a kernel symbol and print it to the kernel messages. */
 extern void __print_symbol(const char *fmt, unsigned long address);
Index: linux-2.6.21-rc4-mm1/kernel/kallsyms.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/kernel/kallsyms.c	2007-03-22 11:35:28.000000000 -0700
+++ linux-2.6.21-rc4-mm1/kernel/kallsyms.c	2007-03-22 11:37:19.000000000 -0700
@@ -268,7 +268,7 @@ const char *kallsyms_lookup(unsigned lon
 }
 
 /* Look up a kernel symbol and return it in a text buffer. */
-void sprint_symbol(char *buffer, unsigned long address)
+int sprint_symbol(char *buffer, unsigned long address)
 {
 	char *modname;
 	const char *name;
@@ -277,13 +277,13 @@ void sprint_symbol(char *buffer, unsigne
 
 	name = kallsyms_lookup(address, &size, &offset, &modname, namebuf);
 	if (!name)
-		sprintf(buffer, "0x%lx", address);
+		return sprintf(buffer, "0x%lx", address);
 	else {
 		if (modname)
-			sprintf(buffer, "%s+%#lx/%#lx [%s]", name, offset,
+			return sprintf(buffer, "%s+%#lx/%#lx [%s]", name, offset,
 				size, modname);
 		else
-			sprintf(buffer, "%s+%#lx/%#lx", name, offset, size);
+			return sprintf(buffer, "%s+%#lx/%#lx", name, offset, size);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
