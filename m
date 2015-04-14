Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA566B0074
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:55 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so85751895igb.1
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g6si11511349igc.13.2015.04.14.13.56.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 13:56:44 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 07/11] mm: debug: VM_BUG()
Date: Tue, 14 Apr 2015 16:56:29 -0400
Message-Id: <1429044993-1677-8-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

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
