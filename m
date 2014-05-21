Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 75DDE6B0039
	for <linux-mm@kvack.org>; Tue, 20 May 2014 22:27:24 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so6901749wiw.2
        for <linux-mm@kvack.org>; Tue, 20 May 2014 19:27:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id wc2si14811370wjc.78.2014.05.20.19.27.22
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 19:27:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/4] Documentation: update Documentation/vm/pagemap.txt
Date: Tue, 20 May 2014 22:26:34 -0400
Message-Id: <1400639194-3743-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>

This patch adds a chapter about kpagecache interface.

ChangeLog:
- add len column in example output

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 Documentation/vm/pagemap.txt | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git v3.15-rc5.orig/Documentation/vm/pagemap.txt v3.15-rc5/Documentation/vm/pagemap.txt
index 5948e455c4d2..12a871efd372 100644
--- v3.15-rc5.orig/Documentation/vm/pagemap.txt
+++ v3.15-rc5/Documentation/vm/pagemap.txt
@@ -150,3 +150,32 @@ once.
 Reading from any of the files will return -EINVAL if you are not starting
 the read on an 8-byte boundary (e.g., if you sought an odd number of bytes
 into the file), or if the size of the read is not a multiple of 8 bytes.
+
+
+kpagecache, from file perspective
+---------------------------------
+
+Similarly to pagemap, we have a interface /proc/kpagecache to let userspace
+know about pagecache profile for a given file. Unlike pagemap interface,
+we don't have to mmap() and fault in the target file, so the impact on other
+workloads (maybe the target of your analysis) is minimum.
+
+To use this interface, firstly we open it and write the name of the target
+file to it for setup. And then we can read the pagecache info of the file.
+The file contains the array of 64-bit entries for each page offset. Data
+format is like below:
+
+    * Bits  0-49  page frame number (PFN) if present
+    * Bits 50-59  zero (reserved)
+    * Bits 60-63  pagecache tags
+
+Good example is tools/vm/page-types.c, where we can get the list of pages
+belonging to the file like below:
+
+  $ dd if=/dev/urandom of=file bs=4096 count=2
+  $ date >> file
+  $ tools/vm/page-types -f file -Nl
+  voffset offset  len     tag     flags
+  0       640c7   1       0       __RU_l______________________________
+  1       640d7   1       0       __RU_l______________________________
+  2       640f4   1       1       ___UDlA_____________________________
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
