Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F97B8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:20 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id 32so783784pzk.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:19 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 5/6] nommu: fix a potential memory leak in do_mmap_private()
Date: Mon, 28 Mar 2011 22:56:46 +0900
Message-Id: <1301320607-7259-6-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If f_op->read() fails and sysctl_nr_trim_pages > 1, there could be a
memory leak between @region->vm_end and @region->vm_top.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 33f5d23c6d44..662fd46449a6 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1241,7 +1241,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	return 0;
 
 error_free:
-	free_page_series(region->vm_start, region->vm_end);
+	free_page_series(region->vm_start, region->vm_top);
 	region->vm_start = vma->vm_start = 0;
 	region->vm_end   = vma->vm_end = 0;
 	region->vm_top   = 0;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
