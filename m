From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH RESEND v10 09/10] mm: Allow arch code to override copy_highpage()
Date: Thu, 16 Nov 2017 07:38:32 -0700
Message-ID: <6bf7a449fb35d9235b539bb452df23c453b23401.1510768775.git.khalid.aziz__15945.0070154437$1510843150$gmane$org@oracle.com>
References: <cover.1510768775.git.khalid.aziz@oracle.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by blaine.gmane.org with esmtp (Exim 4.84_2)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1eFLJf-0006qQ-Ll
	for glkm-linux-mm-2@m.gmane.org; Thu, 16 Nov 2017 15:38:55 +0100
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16BE8280277
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 09:39:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y139so127370wmc.9
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 06:39:02 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 6si1324235edy.402.2017.11.16.06.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 06:39:00 -0800 (PST)
In-Reply-To: <cover.1510768775.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1510768775.git.khalid.aziz@oracle.com>
References: <cover.1510768775.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Cc: Khalid Aziz <khalid.aziz@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

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
