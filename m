Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B2FEF900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 12:36:14 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so2029609wiv.0
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 09:36:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cr6si6762863wjb.60.2014.10.29.09.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Oct 2014 09:36:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/5] mm: gup: use get_user_pages_unlocked within get_user_pages_fast
Date: Wed, 29 Oct 2014 17:35:18 +0100
Message-Id: <1414600520-7664-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

This allows the get_user_pages_fast slow path to release the mmap_sem
before blocking.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/mips/mm/gup.c    |  8 +++-----
 arch/powerpc/mm/gup.c |  6 ++----
 arch/s390/mm/gup.c    |  6 ++----
 arch/sh/mm/gup.c      |  6 ++----
 arch/sparc/mm/gup.c   |  6 ++----
 arch/x86/mm/gup.c     |  7 +++----
 mm/gup.c              |  6 ++----
 mm/util.c             | 10 ++--------
 8 files changed, 18 insertions(+), 37 deletions(-)

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 06ce17c..20884f5 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -301,11 +301,9 @@ slow_irqon:
 	start += nr << PAGE_SHIFT;
 	pages += nr;
 
-	down_read(&mm->mmap_sem);
-	ret = get_user_pages(current, mm, start,
-				(end - start) >> PAGE_SHIFT,
-				write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
+	ret = get_user_pages_unlocked(current, mm, start,
+				      (end - start) >> PAGE_SHIFT,
+				      write, 0, pages);
 
 	/* Have to be a bit careful with return values */
 	if (nr > 0) {
diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index d874668..b70c34a 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -215,10 +215,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-				     nr_pages - nr, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		ret = get_user_pages_unlocked(current, mm, start,
+					      nr_pages - nr, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 639fce46..5c586c7 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -235,10 +235,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	/* Try to get the remaining pages with get_user_pages */
 	start += nr << PAGE_SHIFT;
 	pages += nr;
-	down_read(&mm->mmap_sem);
-	ret = get_user_pages(current, mm, start,
-			     nr_pages - nr, write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
+	ret = get_user_pages_unlocked(current, mm, start,
+			     nr_pages - nr, write, 0, pages);
 	/* Have to be a bit careful with return values */
 	if (nr > 0)
 		ret = (ret < 0) ? nr : ret + nr;
diff --git a/arch/sh/mm/gup.c b/arch/sh/mm/gup.c
index 37458f3..e15f52a 100644
--- a/arch/sh/mm/gup.c
+++ b/arch/sh/mm/gup.c
@@ -257,10 +257,8 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		ret = get_user_pages_unlocked(current, mm, start,
+			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index ae6ce38..2e5c4fc 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -249,10 +249,8 @@ slow:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		ret = get_user_pages_unlocked(current, mm, start,
+			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 207d9aef..2ab183b 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -388,10 +388,9 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		ret = get_user_pages_unlocked(current, mm, start,
+					      (end - start) >> PAGE_SHIFT,
+					      write, 0, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/mm/gup.c b/mm/gup.c
index 01534ff..a349ae3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1187,10 +1187,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-				     nr_pages - nr, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		ret = get_user_pages_unlocked(current, mm, start,
+					      nr_pages - nr, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff --git a/mm/util.c b/mm/util.c
index fec39d4..f3ef639 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -240,14 +240,8 @@ int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
-	int ret;
-
-	down_read(&mm->mmap_sem);
-	ret = get_user_pages(current, mm, start, nr_pages,
-					write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
-
-	return ret;
+	return get_user_pages_unlocked(current, mm, start, nr_pages,
+				       write, 0, pages);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
