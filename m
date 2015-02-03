Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 78FA0900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:44 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so99002001pad.7
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:44 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id wi2si3328155pbc.7.2015.02.03.09.43.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:39 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700JQNIRFOR50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:39 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 07/19] mm: slub: share object_err function
Date: Tue, 03 Feb 2015 20:43:00 +0300
Message-id: <1422985392-28652-8-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Remove static and add function declarations to
linux/slub_def.h so it could be used by kernel
address sanitizer.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/slub_def.h | 3 +++
 mm/slub.c                | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index db7d5de..3388511 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -126,4 +126,7 @@ static inline void *virt_to_obj(struct kmem_cache *s,
 	return (void *)x - ((x - slab_page) % s->size);
 }
 
+void object_err(struct kmem_cache *s, struct page *page,
+		u8 *object, char *reason);
+
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/mm/slub.c b/mm/slub.c
index 1562955..3eb73f5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -629,7 +629,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	dump_stack();
 }
 
-static void object_err(struct kmem_cache *s, struct page *page,
+void object_err(struct kmem_cache *s, struct page *page,
 			u8 *object, char *reason)
 {
 	slab_bug(s, "%s", reason);
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
