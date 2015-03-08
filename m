Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 819766B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 19:12:15 -0400 (EDT)
Received: by iecrl12 with SMTP id rl12so15782362iec.8
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 16:12:15 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id h96si7290118iod.13.2015.03.08.16.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 16:12:14 -0700 (PDT)
Received: by iecrp18 with SMTP id rp18so30568809iec.7
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 16:12:14 -0700 (PDT)
Date: Sun, 8 Mar 2015 16:12:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hugetlb: abort __get_user_pages if current has been oom
 killed
Message-ID: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If __get_user_pages() is faulting a significant number of hugetlb pages,
usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
very large amount of memory.

If the process has been oom killed, this will cause a lot of memory to
be overcharged to its memcg since it has access to memory reserves or
could potentially deplete all system memory reserves.

In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
memory, based on the premise of commit 462e00cc7151 ("oom: stop
allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
terminate when the process has been oom killed.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/gup.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -457,6 +457,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			if (!vma || check_vma_flags(vma, gup_flags))
 				return i ? : -EFAULT;
 			if (is_vm_hugetlb_page(vma)) {
+				if (unlikely(fatal_signal_pending(current)))
+					return i ? : -ERESTARTSYS;
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
 						gup_flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
