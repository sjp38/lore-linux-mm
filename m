Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E35936B0075
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:10:44 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so91822876pac.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:10:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v12si33219720pbs.166.2015.05.14.10.10.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:10:39 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 07/11] mm: debug: VM_BUG()
Date: Thu, 14 May 2015 13:10:10 -0400
Message-Id: <1431623414-1905-8-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

VM_BUG() complements VM_BUG_ON() just like with WARN() and WARN_ON().

This lets us format custom strings to output when a VM_BUG() is hit.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 8b3f5a0..42f41e3 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -12,7 +12,14 @@ char *format_page(struct page *page, char *buf, char *end);
 #ifdef CONFIG_DEBUG_VM
 char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
 char *format_mm(const struct mm_struct *mm, char *buf, char *end);
-#define VM_BUG_ON(cond) BUG_ON(cond)
+#define VM_BUG(cond, fmt...)						\
+	do {								\
+		if (unlikely(cond)) {					\
+			pr_emerg(fmt);					\
+			BUG();						\
+		}							\
+	} while (0)
+#define VM_BUG_ON(cond) VM_BUG(cond, "%s\n", __stringify(cond))
 #define VM_BUG_ON_PAGE(cond, page)					\
 	do {								\
 		if (unlikely(cond)) {					\
@@ -46,6 +53,7 @@ static char *format_mm(const struct mm_struct *mm, char *buf, char *end)
 {
 	return buf;
 }
+#define VM_BUG(cond, fmt...) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
