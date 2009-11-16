Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A27B86B004D
	for <linux-mm@kvack.org>; Sun, 15 Nov 2009 21:06:33 -0500 (EST)
Received: by pxi5 with SMTP id 5so871758pxi.12
        for <linux-mm@kvack.org>; Sun, 15 Nov 2009 18:06:32 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 16 Nov 2009 08:06:32 +0600
Message-ID: <b9df5fa10911151806y24cce0b9pe1162fb07a0d7e9@mail.gmail.com>
Subject: [PATCH] mm: Fix section mismatch in memory_hotplug.c
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 __free_pages_bootmem() is a __meminit function - which has been called
from put_pages_bootmem thus causes a section mismatch warning.

 We were warned by the following warning:

  LD      mm/built-in.o
WARNING: mm/built-in.o(.text+0x26b22): Section mismatch in reference
from the function put_page_bootmem() to the function
.meminit.text:__free_pages_bootmem()
The function put_page_bootmem() references
the function __meminit __free_pages_bootmem().
This is often because put_page_bootmem lacks a __meminit
annotation or the annotation of __free_pages_bootmem is wrong.

Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

--- linus/mm/memory_hotplug.c	2009-11-13 13:17:06.000000000 +0600
+++ rakib/mm/memory_hotplug.c	2009-11-15 08:30:31.000000000 +0600
@@ -70,7 +70,9 @@ static void get_page_bootmem(unsigned lo
 	atomic_inc(&page->_count);
 }

-void put_page_bootmem(struct page *page)
+/* reference to __meminit __free_pages_bootmem is valid
+ * so use __ref to tell modpost not to generate a warning */
+void __ref put_page_bootmem(struct page *page)
 {
 	int type;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
