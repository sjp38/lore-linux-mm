Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02F7F6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:47:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6-v6so17169218pge.5
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:47:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d5-v6sor4764384pgj.70.2018.10.16.06.47.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 06:47:22 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH] mm: add a vma to vmacache when addr overlaps the vma range
Date: Tue, 16 Oct 2018 21:47:12 +0800
Message-Id: <20181016134712.18123-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

vmacache will cache the latest visited vma to improve the performance of
find_vma(). While current implementation would cache a vma even its range
doesn't overlap with addr.

This entry in vmacache will be a dummy entry, since the vmacache_find()
only returns a vma when its range overlap with addr.

This patch avoid to add a vma to vmacache when the range doesn't
overlap.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---

Based on my understanding, this change would put more accurate vma entry in the
cache, which means reduce unnecessary vmacache update and vmacache find.

But the test result is not as expected. From the original changelog, I don't
see the explanation to add this non-overlap entry into the vmacache, so
curious about why this performs a little better than putting an overlapped
entry.

Below is the test result for building kernel in two cases:

         make -j4                   make -j8
base-line:

real    6m15.947s          real    5m11.684s
user    21m14.481s         user    27m23.471s
sys     2m34.407s          sys     3m13.233s

real    6m16.089s          real    5m11.445s
user    21m18.295s         user    27m24.045s
sys     2m35.551s          sys     3m13.443s

real    6m16.239s          real    5m11.218s
user    21m17.590s         user    27m19.133s
sys     2m35.252s          sys     3m12.684s

patched:

real    6m15.416s          real    5m10.810s
user    21m21.800s         user    27m25.223s
sys     2m33.398s          sys     3m14.784s

real    6m15.114s          real    5m12.285s
user    21m19.986s         user    27m32.055s
sys     2m34.718s          sys     3m13.107s


real    6m16.206s          real    5m11.509s
user    21m22.557s         user    27m28.265s
sys     2m35.637s          sys     3m12.747s


---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2e0daf666f42..dda495d84862 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2214,7 +2214,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 			rb_node = rb_node->rb_right;
 	}
 
-	if (vma)
+	if (vma && vma->vm_start <= addr)
 		vmacache_update(addr, vma);
 	return vma;
 }
-- 
2.15.1
