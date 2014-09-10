Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3E66B003D
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:38:39 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so11256262pde.33
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:38:39 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id qb9si27778122pbb.256.2014.09.10.07.38.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 10 Sep 2014 07:38:38 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBO000PEWT15C90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 10 Sep 2014 15:41:25 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH v2 06/10] mm: slub: introduce
 metadata_access_enable()/metadata_access_disable()
Date: Wed, 10 Sep 2014 18:31:23 +0400
Message-id: <1410359487-31938-7-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Wrap access to object's metadata in external functions with
metadata_access_enable()/metadata_access_disable() function calls.

This hooks separates payload accesses from metadata accesses
which might be useful for different checkers (e.g. KASan).

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slub.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index c4158b2..f3603d2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -477,13 +477,23 @@ static int slub_debug;
 static char *slub_debug_slabs;
 static int disable_higher_order_debug;
 
+static inline void metadata_access_enable(void)
+{
+}
+
+static inline void metadata_access_disable(void)
+{
+}
+
 /*
  * Object debugging
  */
 static void print_section(char *text, u8 *addr, unsigned int length)
 {
+	metadata_access_enable();
 	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
 			length, 1);
+	metadata_access_disable();
 }
 
 static struct track *get_track(struct kmem_cache *s, void *object,
@@ -513,7 +523,9 @@ static void set_track(struct kmem_cache *s, void *object,
 		trace.max_entries = TRACK_ADDRS_COUNT;
 		trace.entries = p->addrs;
 		trace.skip = 3;
+		metadata_access_enable();
 		save_stack_trace(&trace);
+		metadata_access_disable();
 
 		/* See rant in lockdep.c */
 		if (trace.nr_entries != 0 &&
@@ -687,7 +699,9 @@ static int check_bytes_and_report(struct kmem_cache *s, struct page *page,
 	u8 *fault;
 	u8 *end;
 
+	metadata_access_enable();
 	fault = memchr_inv(start, value, bytes);
+	metadata_access_disable();
 	if (!fault)
 		return 1;
 
@@ -780,7 +794,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 	if (!remainder)
 		return 1;
 
+	metadata_access_enable();
 	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
+	metadata_access_disable();
 	if (!fault)
 		return 1;
 	while (end > fault && end[-1] == POISON_INUSE)
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
