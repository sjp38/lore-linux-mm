Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 758E16B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 13:02:05 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 102so18723497ior.2
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 10:02:05 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x4si384188iti.124.2018.02.01.10.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 10:02:04 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v11 09/10] mm: Allow arch code to override copy_highpage()
Date: Thu,  1 Feb 2018 11:01:17 -0700
Message-Id: <3e5949f4cedfdd499bd745135bd99f36cbb13503.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1517497017.git.khalid.aziz@oracle.com>
References: <cover.1517497017.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, anthony.yznaga@oracle.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

Some architectures can support metadata for memory pages and when a
page is copied, its metadata must also be copied. Sparc processors
from M7 onwards support metadata for memory pages. This metadata
provides tag based protection for access to memory pages. To maintain
this protection, the tag data must be copied to the new page when a
page is migrated across NUMA nodes. This patch allows arch specific
code to override default copy_highpage() and copy metadata along
with page data upon migration.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
---
v9:
	- new patch

 include/linux/highmem.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 776f90f3a1cd..0690679832d4 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -237,6 +237,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
 
 #endif
 
+#ifndef __HAVE_ARCH_COPY_HIGHPAGE
+
 static inline void copy_highpage(struct page *to, struct page *from)
 {
 	char *vfrom, *vto;
@@ -248,4 +250,6 @@ static inline void copy_highpage(struct page *to, struct page *from)
 	kunmap_atomic(vfrom);
 }
 
+#endif
+
 #endif /* _LINUX_HIGHMEM_H */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
