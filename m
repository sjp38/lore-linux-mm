Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 707BA6B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:10:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 33so111224440pgx.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:10:47 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id f2si9864646pgc.108.2017.06.20.02.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 02:10:46 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id c73so6320458pfk.2
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:10:46 -0700 (PDT)
Date: Tue, 20 Jun 2017 02:10:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix new crash in unmapped_area_topdown()
Message-ID: <alpine.LSU.2.11.1706200206210.10925@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@codemonkey.org.uk>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Trinity gets kernel BUG at mm/mmap.c:1963! in about 3 minutes of
mmap testing.  That's the VM_BUG_ON(gap_end < gap_start) at the
end of unmapped_area_topdown().  Linus points out how MAP_FIXED
(which does not have to respect our stack guard gap intentions)
could result in gap_end below gap_start there.  Fix that, and
the similar case in its alternative, unmapped_area().

Cc: stable@vger.kernel.org
Fixes: 1be7107fbe18 ("mm: larger stack guard gap, between vmas")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Debugged-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/mmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- 4.12-rc6/mm/mmap.c	2017-06-19 09:06:10.035407505 -0700
+++ linux/mm/mmap.c	2017-06-19 21:09:28.616707311 -0700
@@ -1817,7 +1817,8 @@ unsigned long unmapped_area(struct vm_un
 		/* Check if current node has a suitable gap */
 		if (gap_start > high_limit)
 			return -ENOMEM;
-		if (gap_end >= low_limit && gap_end - gap_start >= length)
+		if (gap_end >= low_limit &&
+		    gap_end > gap_start && gap_end - gap_start >= length)
 			goto found;
 
 		/* Visit right subtree if it looks promising */
@@ -1920,7 +1921,8 @@ unsigned long unmapped_area_topdown(stru
 		gap_end = vm_start_gap(vma);
 		if (gap_end < low_limit)
 			return -ENOMEM;
-		if (gap_start <= high_limit && gap_end - gap_start >= length)
+		if (gap_start <= high_limit &&
+		    gap_end > gap_start && gap_end - gap_start >= length)
 			goto found;
 
 		/* Visit left subtree if it looks promising */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
