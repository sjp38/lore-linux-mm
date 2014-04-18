Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 66AFA6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 02:36:57 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id s7so1293798qap.11
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 23:36:57 -0700 (PDT)
Received: from co9outboundpool.messaging.microsoft.com (co9ehsobe005.messaging.microsoft.com. [207.46.163.28])
        by mx.google.com with ESMTPS id s3si5739817qas.250.2014.04.17.23.36.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Apr 2014 23:36:56 -0700 (PDT)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH] mm: mmap: remove the first mapping check
Date: Fri, 18 Apr 2014 13:40:50 +0800
Message-ID: <1397799650-28977-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <b32955@freescale.com>

Remove the first mapping check for vma_link.
move the mutex_lock into the braces when vma->vm_file is true.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/mmap.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf..e77526a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -640,11 +640,10 @@ static void vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct address_space *mapping = NULL;
 
-	if (vma->vm_file)
+	if (vma->vm_file) {
 		mapping = vma->vm_file->f_mapping;
-
-	if (mapping)
 		mutex_lock(&mapping->i_mmap_mutex);
+	}
 
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	__vma_link_file(vma);
-- 
1.7.2.rc3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
