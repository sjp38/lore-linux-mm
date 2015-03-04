Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C87736B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 07:52:38 -0500 (EST)
Received: by pdjy10 with SMTP id y10so57262063pdj.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 04:52:38 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 5si4885668pdw.163.2015.03.04.04.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 04:52:37 -0800 (PST)
Received: by pabrd3 with SMTP id rd3so9350560pab.5
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 04:52:37 -0800 (PST)
From: Leon Yu <chianglungyu@gmail.com>
Subject: [PATCH v2] mm: fix anon_vma->degree underflow in anon_vma endless growing prevention
Date: Wed,  4 Mar 2015 20:52:21 +0800
Message-Id: <1425473541-4924-1-git-send-email-chianglungyu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: Leon Yu <chianglungyu@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>, Chih-Wei Huang <cwhuang@android-x86.org>, stable@vger.kernel.org

I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after
upgrading to 3.19 and had no luck with 4.0-rc1 neither.

So, after looking into new logic introduced by 7a3ef208e662 ("mm: prevent
endless growth of anon_vma hierarchy"), I found chances are that
unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
anon_vma_clone() due to allocation failure.  If dst->anon_vma is not NULL
in error path, its degree will be incorrectly decremented in
unlink_anon_vmas() and eventually underflow when exiting as a result of
another call to unlink_anon_vmas().  That's how "kernel BUG at
mm/rmap.c:399!" is triggered for me.

This patch fixes the underflow by dropping dst->anon_vma when allocation
fails.  It's safe to do so regardless of original value of dst->anon_vma
because dst->anon_vma doesn't have valid meaning if anon_vma_clone()
fails.  Besides, callers don't care dst->anon_vma in such case neither.

Also suggested by Michal Hocko, we can clean up vma_adjust() a bit as
anon_vma_clone() now does the work.

Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
Signed-off-by: Leon Yu <chianglungyu@gmail.com>
Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Cc: <stable@vger.kernel.org>
---
Changes in v2:
 - clean up vma_adjust() per Michal Hocko's suggestion
 - comment tweaked by Andrew Morton

 mm/mmap.c | 4 +---
 mm/rmap.c | 7 +++++++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index da9990a..9ec50a3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -774,10 +774,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 			importer->anon_vma = exporter->anon_vma;
 			error = anon_vma_clone(importer, exporter);
-			if (error) {
-				importer->anon_vma = NULL;
+			if (error)
 				return error;
-			}
 		}
 	}
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 5e3e090..bed3cf2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -287,6 +287,13 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 	return 0;
 
  enomem_failure:
+	/*
+	 * dst->anon_vma is dropped here otherwise its degree can be incorrectly
+	 * decremented in unlink_anon_vmas().
+	 * We can safely do this because callers of anon_vma_clone() don't care
+	 * about dst->anon_vma if anon_vma_clone() failed.
+	 */
+	dst->anon_vma = NULL;
 	unlink_anon_vmas(dst);
 	return -ENOMEM;
 }
-- 
2.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
