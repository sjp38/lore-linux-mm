Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id CD7246B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 08:41:08 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so3743940igb.6
        for <linux-mm@kvack.org>; Mon, 12 May 2014 05:41:08 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nx5si9149388icb.26.2014.05.12.05.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 05:41:08 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: remap_file_pages: initialize populate before usage
Date: Mon, 12 May 2014 08:40:54 -0400
Message-Id: <1399898454-14915-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

'populate' wasn't initialized before being used in error paths,
causing panics when mm_populate() would get called with invalid
values.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 84dcfc7..2a0e0a8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2591,7 +2591,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long populate;
+	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. "
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
