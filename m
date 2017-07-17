Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 482FD6B03A1
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:28:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o8so1723372qtc.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:28:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p35si384829qtd.279.2017.07.17.15.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 15:28:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/3] mm:hugetlb:  Define system call hugetlb size encodings in single file
Date: Mon, 17 Jul 2017 15:27:59 -0700
Message-Id: <1500330481-28476-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>

If hugetlb pages are requested in mmap or shmget system calls,  a huge
page size other than default can be requested.  This is accomplished by
encoding the log2 of the huge page size in the upper bits of the flag
argument.  asm-generic and arch specific headers all define the same
values for these encodings.

Put common definitions in a single header file.  arch specific code can
still override if desired.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/uapi/asm-generic/hugetlb_encode.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)
 create mode 100644 include/uapi/asm-generic/hugetlb_encode.h

diff --git a/include/uapi/asm-generic/hugetlb_encode.h b/include/uapi/asm-generic/hugetlb_encode.h
new file mode 100644
index 0000000..aa09fc0
--- /dev/null
+++ b/include/uapi/asm-generic/hugetlb_encode.h
@@ -0,0 +1,30 @@
+#ifndef _ASM_GENERIC_HUGETLB_ENCODE_H_
+#define _ASM_GENERIC_HUGETLB_ENCODE_H_
+
+/*
+ * Several system calls take a flag to request "hugetlb" huge pages.
+ * Without further specification, these system calls will use the
+ * system's default huge page size.  If a system supports multiple
+ * huge page sizes, the desired huge page size can be specified in
+ * bits [26:31] of the flag arguments.  The value in these 6 bits
+ * will encode the log2 of the huge page size.
+ *
+ * The following definitions are associated with this huge page size
+ * encoding in flag arguments.  System call specific header files
+ * that use this encoding should include this file.  They can then
+ * provide definitions based on these with their own specific prefix.
+ * for example #define MAP_HUGE_SHIFT HUGETLB_FLAG_ENCODE_SHIFT.
+ */
+
+#define HUGETLB_FLAG_ENCODE_SHIFT	26
+#define HUGETLB_FLAG_ENCODE_MASK	0x3f
+
+#define HUGETLB_FLAG_ENCODE_512KB	(19 << MAP_HUGE_SHIFT
+#define HUGETLB_FLAG_ENCODE_1MB		(20 << MAP_HUGE_SHIFT)
+#define HUGETLB_FLAG_ENCODE_2MB		(21 << MAP_HUGE_SHIFT)
+#define HUGETLB_FLAG_ENCODE_8MB		(23 << MAP_HUGE_SHIFT)
+#define HUGETLB_FLAG_ENCODE_16MB	(24 << MAP_HUGE_SHIFT)
+#define HUGETLB_FLAG_ENCODE_1GB		(30 << MAP_HUGE_SHIFT)
+#define HUGETLB_FLAG_ENCODE__16GB	(34 << MAP_HUGE_SHIFT)
+
+#endif /* _ASM_GENERIC_HUGETLB_ENCODE_H_ */
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
