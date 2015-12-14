Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B61F6B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:04:16 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so102150613pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:04:15 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id p7si2019072pfi.26.2015.12.14.03.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 03:04:15 -0800 (PST)
Received: by pfnn128 with SMTP id n128so104043600pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:04:15 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [RFC] mm: change find_vma() function
Date: Mon, 14 Dec 2015 19:02:25 +0800
Message-Id: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: yalin wang <yalin.wang2010@gmail.com>

change find_vma() to break ealier when found the adderss
is not in any vma, don't need loop to search all vma.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 mm/mmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index b513f20..8294c9b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 			vma = tmp;
 			if (tmp->vm_start <= addr)
 				break;
+			if (!tmp->vm_prev || tmp->vm_prev->vm_end <= addr)
+				break;
+
 			rb_node = rb_node->rb_left;
 		} else
 			rb_node = rb_node->rb_right;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
