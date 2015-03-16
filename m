Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 630126B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:36:45 -0400 (EDT)
Received: by wixw10 with SMTP id w10so36569158wix.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 01:36:44 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id bu8si16483835wib.29.2015.03.16.01.36.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 01:36:44 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 16 Mar 2015 08:36:42 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4538817D8059
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 08:37:03 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2G8ad386750620
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 08:36:39 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2G8acmF009233
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 04:36:39 -0400
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH] mm: trigger panic on bad page or PTE states if panic_on_oops
Date: Mon, 16 Mar 2015 09:37:01 +0100
Message-Id: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>

while debugging a memory management problem it helped a lot to
get a system dump as early as possible for bad page states.

Lets assume that if panic_on_oops is set then the system should
not continue with broken mm data structures.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 mm/memory.c     | 2 ++
 mm/page_alloc.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 2c3536c..bdbf9cc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -696,6 +696,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		printk(KERN_ALERT "vma->vm_file->f_op->mmap: %pSR\n",
 		       vma->vm_file->f_op->mmap);
 	dump_stack();
+	if (panic_on_oops)
+		panic("Fatal exception");
 	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8e20f9c..8c19db3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -337,6 +337,8 @@ static void bad_page(struct page *page, const char *reason,
 
 	print_modules();
 	dump_stack();
+	if (panic_on_oops)
+		panic("Fatal exception");
 out:
 	/* Leave bad fields for debug, except PageBuddy could make trouble */
 	page_mapcount_reset(page); /* remove PageBuddy */
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
