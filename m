Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B590D8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:16 -0400 (EDT)
Received: by pxi10 with SMTP id 10so839081pxi.8
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:15 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 4/6] nommu: check the vma list when unmapping file-mapped vma
Date: Mon, 28 Mar 2011 22:56:45 +0900
Message-Id: <1301320607-7259-5-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now we have the sorted vma list, use it in do_munmap() to check that
we have an exact match.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 6c5a13b507b4..33f5d23c6d44 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1659,7 +1659,6 @@ static int shrink_vma(struct mm_struct *mm,
 int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
-	struct rb_node *rb;
 	unsigned long end = start + len;
 	int ret;
 
@@ -1692,9 +1691,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 			}
 			if (end == vma->vm_end)
 				goto erase_whole_vma;
-			rb = rb_next(&vma->vm_rb);
-			vma = rb_entry(rb, struct vm_area_struct, vm_rb);
-		} while (rb);
+			vma = vma->vm_next;
+		} while (vma);
 		kleave(" = -EINVAL [split file]");
 		return -EINVAL;
 	} else {
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
