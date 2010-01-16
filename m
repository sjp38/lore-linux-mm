Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A82926B0047
	for <linux-mm@kvack.org>; Sat, 16 Jan 2010 11:23:37 -0500 (EST)
Received: by ywh5 with SMTP id 5so3664790ywh.11
        for <linux-mm@kvack.org>; Sat, 16 Jan 2010 08:23:35 -0800 (PST)
Subject: [PATCH -mmotm-2010-01-15-15-34] Fix wrong offset for vma merge in
 mbind
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 17 Jan 2010 01:15:28 +0900
Message-ID: <1263658528.2162.6.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mm-fix-mbind-vma-merge-problem.patch added vma_merge in mbind
to merge mergeable vmas.
But it passed wrong offset of vm_file.

This patch fixes it.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---
 mm/mempolicy.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9751f3f..7e529d0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -570,6 +570,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	struct vm_area_struct *prev;
 	struct vm_area_struct *vma;
 	int err = 0;
+	pgoff_t pgoff;
 	unsigned long vmstart;
 	unsigned long vmend;
 
@@ -582,9 +583,9 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		vmstart = max(start, vma->vm_start);
 		vmend   = min(end, vma->vm_end);
 
+		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
-				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
-				  new_pol);
+				  vma->anon_vma, vma->vm_file, pgoff, new_pol);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
-- 
1.6.3.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
