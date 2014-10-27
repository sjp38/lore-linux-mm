Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 868EC90001A
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:47:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so1621604pdj.26
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 09:47:55 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ff1si10845542pbc.179.2014.10.27.09.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 09:47:53 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE400LCZ44M9OA0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 16:50:46 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v5 10/12] fs: dcache: manually unpoison dname after allocation
 to shut up kasan's reports
Date: Mon, 27 Oct 2014 19:46:57 +0300
Message-id: <1414428419-17860-11-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>

We need to manually unpoison rounded up allocation size for dname
to avoid kasan's reports in dentry_string_cmp().
When CONFIG_DCACHE_WORD_ACCESS=y dentry_string_cmp may access
few bytes beyound requested in kmalloc() size.

dentry_string_cmp() relates on that fact that dentry allocated
using kmalloc and kmalloc internally round up allocation size.
So this is not a bug, but this makes kasan to complain about
such accesses.
To avoid such reports we mark rounded up allocation size in
shadow as accessible.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 fs/dcache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index d5a23fd..d58ffcc6 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -38,6 +38,8 @@
 #include <linux/prefetch.h>
 #include <linux/ratelimit.h>
 #include <linux/list_lru.h>
+#include <linux/kasan.h>
+
 #include "internal.h"
 #include "mount.h"
 
@@ -1429,6 +1431,10 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 		}
 		atomic_set(&p->u.count, 1);
 		dname = p->name;
+#ifdef CONFIG_DCACHE_WORD_ACCESS
+		kasan_unpoison_shadow(dname,
+				round_up(name->len + 1,	sizeof(unsigned long)));
+#endif
 	} else  {
 		dname = dentry->d_iname;
 	}	
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
