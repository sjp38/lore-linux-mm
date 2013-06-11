Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7F2846B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 15:58:50 -0400 (EDT)
Date: Tue, 11 Jun 2013 14:29:21 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: [PATCH, RFC] mm: Implement RLIMIT_RSS
Message-ID: <20130611182921.GB25941@logfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

I've seen a couple of instances where people try to impose a vsize
limit simply because there is no rss limit in Linux.  The vsize limit
is a horrible approximation and even this patch seems to be an
improvement.

Would there be strong opposition to actually supporting RLIMIT_RSS?

JA?rn

--
It's not whether you win or lose, it's how you place the blame.
-- unknown


Not quite perfect, but close enough for many purposes.  This checks rss
limit inside may_expand_vm() and will fail if we are already over the
limit.

Signed-off-by: Joern Engel <joern@logfs.org>
---
 mm/mmap.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ab652fa..ea90c73 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2446,12 +2446,19 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 {
 	unsigned long cur = mm->total_vm;	/* pages */
-	unsigned long lim;
+	unsigned long lim, rlim;
 
 	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
+	rlim = rlimit(RLIMIT_RSS) >> PAGE_SHIFT;
 
 	if (cur + npages > lim)
 		return 0;
+	if (cur + npages > rlim) {
+		/* Yes, the rss limit is somewhat imprecise. */
+		if (get_mm_rss(mm) > rlim) {
+			return 0;
+		}
+	}
 	return 1;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
