Date: Tue, 08 Oct 2002 16:59:38 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.41] New version of shared page tables
Message-ID: <223810000.1034114378@baldur.austin.ibm.com>
In-Reply-To: <181170000.1034109448@baldur.austin.ibm.com>
References: <181170000.1034109448@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1070740887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==========1070740887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Ok, Bill Irwin found another bug.  Here's the 2 lines of change.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1070740887==========
Content-Type: text/plain; charset=us-ascii; name="shpte-tweak.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="shpte-tweak.diff"; size=541

--- a/fs/exec.c	8 Oct 2002 17:32:52 -0000	1.2
+++ b/fs/exec.c	8 Oct 2002 21:46:04 -0000
@@ -46,6 +46,7 @@
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <asm/mmu_context.h>
+#include <asm/rmap.h>
 
 #ifdef CONFIG_KMOD
 #include <linux/kmod.h>
@@ -308,7 +309,7 @@
 	flush_page_to_ram(page);
 	set_pte(pte, pte_mkdirty(pte_mkwrite(mk_pte(page, PAGE_COPY))));
 	page_add_rmap(page, pte);
-	increment_rss(virt_to_page(pte));
+	increment_rss(kmap_atomic_to_page(pte));
 	pte_unmap(pte);
 	spin_unlock(&tsk->mm->page_table_lock);
 

--==========1070740887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
