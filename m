Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 862BE900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:44:11 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so98824915pab.9
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:44:11 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id zt10si3328998pbc.18.2015.02.03.09.43.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:57 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ7007W3IRS2G50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:53 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 18/19] module: fix types of device tables aliases
Date: Tue, 03 Feb 2015 20:43:11 +0300
Message-id: <1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>

MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
Normally alias should have the same type as aliased symbol.

Device tables are arrays, so they have 'struct type##_device_id[x]'
types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
	'struct type##_device_id'.

This inconsistency confuses compiler, it could make a wrong
assumption about variable's size which leads KASan to
produce a false positive report about out of bounds access.

For every global variable compiler calls __asan_register_globals()
passing information about global variable (address, size, size with
redzone, name ...) __asan_register_globals() poison symbols
redzone to detect possible out of bounds accesses.

When symbol has an alias __asan_register_globals() will be called
as for symbol so for alias. Compiler determines size of variable by
size of variable's type. Alias and symbol have the same address,
so if alias have the wrong size part of memory that actually belongs
to the symbol could be poisoned as redzone of alias symbol.

By fixing type of alias symbol we will fix size of it, so
__asan_register_globals() will not poison valid memory.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/module.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/module.h b/include/linux/module.h
index b653d7c..42999fe 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
 #ifdef MODULE
 /* Creates an alias so file2alias.c can find device table. */
 #define MODULE_DEVICE_TABLE(type, name)					\
-  extern const struct type##_device_id __mod_##type##__##name##_device_table \
+extern const typeof(name) __mod_##type##__##name##_device_table		\
   __attribute__ ((unused, alias(__stringify(name))))
 #else  /* !MODULE */
 #define MODULE_DEVICE_TABLE(type, name)
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
