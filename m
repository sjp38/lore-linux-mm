Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4B64B6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:17 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so6679149pab.32
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:16 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yt9si16577925pab.91.2014.02.10.12.41.15
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/8] mm, hwpoison: release page on PageHWPoison() in __do_fault()
Date: Mon, 10 Feb 2014 22:40:59 +0200
Message-Id: <1392064866-11840-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It seems we forget to release page after detecting HW error.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index be6a0c0d4ae0..5f2001a7ab31 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3348,6 +3348,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
 		ret = VM_FAULT_HWPOISON;
+		page_cache_release(vmf.page);
 		goto uncharge_out;
 	}
 
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
