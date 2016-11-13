Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDAAE6B0038
	for <linux-mm@kvack.org>; Sat, 12 Nov 2016 22:33:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so11673941wmu.1
        for <linux-mm@kvack.org>; Sat, 12 Nov 2016 19:33:53 -0800 (PST)
Received: from vps202351.ovh.net (blatinox.fr. [51.254.120.209])
        by mx.google.com with ESMTP id i21si17749790wmf.35.2016.11.12.19.33.52
        for <linux-mm@kvack.org>;
        Sat, 12 Nov 2016 19:33:52 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?= <jeremy.lefaure@lse.epita.fr>
Subject: [PATCH] thb: propagate conditional compilation to code depending on sysfs in khugepaged.c
Date: Sat, 12 Nov 2016 22:33:28 -0500
Message-Id: <20161113033328.9250-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, =?UTF-8?q?J=C3=A9r=C3=A9my=20Lefaure?= <jeremy.lefaure@lse.epita.fr>

Commit b46e756f5e47 ("thp: extract khugepaged from mm/huge_memory.c")
moved code from huge_memory.c to khugepaged.c. Some of this code should
be compiled only when CONFIG_SYSFS is enabled but the condition around
this code was not moved into khugepaged.c. The result is a compilation
error when CONFIG_SYSFS is disabled:

mm/built-in.o: In function `khugepaged_defrag_store':
khugepaged.c:(.text+0x2d095): undefined reference to
`single_hugepage_flag_store'
mm/built-in.o: In function `khugepaged_defrag_show':
khugepaged.c:(.text+0x2d0ab): undefined reference to
`single_hugepage_flag_show'

This commit adds the #ifdef CONFIG_SYSFS around the code related to
sysfs.

Signed-off-by: JA(C)rA(C)my Lefaure <jeremy.lefaure@lse.epita.fr>
---
 mm/khugepaged.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 728d779..87e1a7ca 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -103,6 +103,7 @@ static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
 
+#ifdef CONFIG_SYSFS
 static ssize_t scan_sleep_millisecs_show(struct kobject *kobj,
 					 struct kobj_attribute *attr,
 					 char *buf)
@@ -295,6 +296,7 @@ struct attribute_group khugepaged_attr_group = {
 	.attrs = khugepaged_attr,
 	.name = "khugepaged",
 };
+#endif /* CONFIG_SYSFS */
 
 #define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB)
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
