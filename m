Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0016B007D
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 11:01:44 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so5231266pab.2
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 08:01:44 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ol9si12180736pdb.124.2014.11.27.08.01.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 27 Nov 2014 08:01:41 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFP004YTGN9PJ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Nov 2014 16:04:22 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v8 10/12] kmemleak: disable kasan instrumentation for kmemleak
Date: Thu, 27 Nov 2014 19:00:54 +0300
Message-id: <1417104057-20335-11-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>

kmalloc internally round up allocation size, and kmemleak
uses rounded up size as object's size. This makes kasan
to complain while kmemleak scans memory or calculates of object's
checksum. The simplest solution here is to disable kasan.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/kmemleak.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 3cda50c..9bda1b3 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -98,6 +98,7 @@
 #include <asm/processor.h>
 #include <linux/atomic.h>
 
+#include <linux/kasan.h>
 #include <linux/kmemcheck.h>
 #include <linux/kmemleak.h>
 #include <linux/memory_hotplug.h>
@@ -1113,7 +1114,10 @@ static bool update_checksum(struct kmemleak_object *object)
 	if (!kmemcheck_is_obj_initialized(object->pointer, object->size))
 		return false;
 
+	kasan_disable_local();
 	object->checksum = crc32(0, (void *)object->pointer, object->size);
+	kasan_enable_local();
+
 	return object->checksum != old_csum;
 }
 
@@ -1164,7 +1168,9 @@ static void scan_block(void *_start, void *_end,
 						  BYTES_PER_POINTER))
 			continue;
 
+		kasan_disable_local();
 		pointer = *ptr;
+		kasan_enable_local();
 
 		object = find_and_get_object(pointer, 1);
 		if (!object)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
