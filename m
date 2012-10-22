Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 01D5B6B0069
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:04:42 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r1so486356ghr.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 05:04:42 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 2/2] mm/slob: Use free_page instead of put_page for page-size kmalloc allocations
Date: Mon, 22 Oct 2012 09:04:31 -0300
Message-Id: <1350907471-2236-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Tim Bird <tim.bird@am.sony.com>, Ezequiel Garcia <elezegarcia@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>

When freeing objects, the slob allocator currently free empty pages
calling __free_pages(). However, page-size kmallocs are disposed
using put_page() instead.

It makes no sense to call put_page() for kernel pages that are provided
by the object allocator, so we shouldn't be doing this ourselves.

This is based on:
commit d9b7f22623b5fa9cc189581dcdfb2ac605933bf4
Author: Glauber Costa <glommer@parallels.com>
slub: use free_page instead of put_page for freeing kmalloc allocation

Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Glauber Costa <glommer@parallels.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index a65e802..362632d 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -506,7 +506,7 @@ void kfree(const void *block)
 		unsigned int *m = (unsigned int *)(block - align);
 		slob_free(m, *m + align);
 	} else
-		put_page(sp);
+		__free_pages(sp, compound_order(sp));
 }
 EXPORT_SYMBOL(kfree);
 
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
