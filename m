Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 900056B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:17:04 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n11so2203098ioc.15
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 09:17:04 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i12si1843947ita.106.2018.02.21.09.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 09:17:03 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v12 09/11] mm: Allow arch code to override copy_highpage()
Date: Wed, 21 Feb 2018 10:15:51 -0700
Message-Id: <ecbafa2bfcc05f22183be2e7784ed11943b1d5b2.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, tglx@linutronix.de, anthony.yznaga@oracle.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

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
