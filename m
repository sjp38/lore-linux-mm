Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B0E206B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:03:05 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4077167vbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 02:03:04 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split handle vma->vm_policy linkages"
Date: Wed, 30 May 2012 05:02:04 -0400
Message-Id: <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

commit 05f144a0d5 removed vma->vm_policy updates code and it is a purpose of
mbind_range(). Now, mbind_range() is virtually no-op. no-op function don't
makes any bugs, I agree. but maybe it is not right fix.

Cc: Dave Jones <davej@redhat.com>,
Cc: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   41 ++++++++++++++++++++++++-----------------
 1 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f15c1b2..0a60def 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -607,6 +607,27 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 	return first;
 }
 
+/* Apply policy to a single VMA */
+static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
+{
+	int err = 0;
+	struct mempolicy *old = vma->vm_policy;
+
+	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
+		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
+		 vma->vm_ops, vma->vm_file,
+		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
+
+	if (vma->vm_ops && vma->vm_ops->set_policy)
+		err = vma->vm_ops->set_policy(vma, new);
+	if (!err) {
+		mpol_get(new);
+		vma->vm_policy = new;
+		mpol_put(old);
+	}
+	return err;
+}
+
 /* Step 2: apply policy to a range and do splits. */
 static int mbind_range(struct mm_struct *mm, unsigned long start,
 		       unsigned long end, struct mempolicy *new_pol)
@@ -655,23 +676,9 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			if (err)
 				goto out;
 		}
-
-		/*
-		 * Apply policy to a single VMA. The reference counting of
-		 * policy for vma_policy linkages has already been handled by
-		 * vma_merge and split_vma as necessary. If this is a shared
-		 * policy then ->set_policy will increment the reference count
-		 * for an sp node.
-		 */
-		pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
-			vma->vm_start, vma->vm_end, vma->vm_pgoff,
-			vma->vm_ops, vma->vm_file,
-			vma->vm_ops ? vma->vm_ops->set_policy : NULL);
-		if (vma->vm_ops && vma->vm_ops->set_policy) {
-			err = vma->vm_ops->set_policy(vma, new_pol);
-			if (err)
-				goto out;
-		}
+		err = policy_vma(vma, new_pol);
+		if (err)
+			goto out;
 	}
 
  out:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
