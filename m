Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1634C6B0087
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 11:52:56 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so2362037pad.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 08:52:55 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id lb5si8815824pbc.163.2015.01.21.08.52.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 08:52:36 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIJ00GS1DQ8VXA0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 16:56:32 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v9 16/17] module: fix types of device tables aliases
Date: Wed, 21 Jan 2015 19:51:44 +0300
Message-id: <1421859105-25253-17-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
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

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/module.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/module.h b/include/linux/module.h
index ebfb0e1..54e75a7 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
 #ifdef MODULE
 /* Creates an alias so file2alias.c can find device table. */
 #define MODULE_DEVICE_TABLE(type, name)					\
-  extern const struct type##_device_id __mod_##type##__##name##_device_table \
+extern typeof(name) __mod_##type##__##name##_device_table \
   __attribute__ ((unused, alias(__stringify(name))))
 #else  /* !MODULE */
 #define MODULE_DEVICE_TABLE(type, name)
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
