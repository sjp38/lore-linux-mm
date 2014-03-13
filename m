Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 40C436B0037
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:29 -0400 (EDT)
Received: by mail-ea0-f178.google.com with SMTP id a15so744310eae.23
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y6si7117315eep.17.2014.03.13.14.40.26
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:27 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 6/6] Documentation: update Documentation/vm/pagemap.txt
Date: Thu, 13 Mar 2014 17:39:46 -0400
Message-Id: <1394746786-6397-7-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

This patch adds a chapter about kpagecache interface.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 Documentation/vm/pagemap.txt | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git v3.14-rc6.orig/Documentation/vm/pagemap.txt v3.14-rc6/Documentation/vm/pagemap.txt
index 5948e455c4d2..c8039263fc45 100644
--- v3.14-rc6.orig/Documentation/vm/pagemap.txt
+++ v3.14-rc6/Documentation/vm/pagemap.txt
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
+workloads (maybe profile targets) is minimum.
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
+  pgoff	pfn	tags	flags
+  0	3305f	0	__RU_l______________________________
+  1	374bb	0	__RU_l______________________________
+  2	6c5ac	1	___UDlA_____________________________
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
