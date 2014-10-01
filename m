Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id E40A46B006C
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 04:57:17 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id s7so200383qap.32
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 01:57:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g2si528382qcz.19.2014.10.01.01.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 01:57:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/4] mm: gup: use get_user_pages_unlocked within get_user_pages_fast
Date: Wed,  1 Oct 2014 10:56:37 +0200
Message-Id: <1412153797-6667-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/mips/mm/gup.c       | 8 +++-----
 arch/powerpc/mm/gup.c    | 6 ++----
 arch/s390/kvm/kvm-s390.c | 4 +---
 arch/s390/mm/gup.c       | 6 ++----
 arch/sh/mm/gup.c         | 6 ++----
 arch/sparc/mm/gup.c      | 6 ++----
 arch/x86/mm/gup.c        | 7 +++----
 7 files changed, 15 insertions(+), 28 deletions(-)

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
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index 81b0e11..37ca29a 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -1092,9 +1092,7 @@ long kvm_arch_fault_in_page(struct kvm_vcpu *vcpu, gpa_t gpa, int writable)
 	hva = gmap_fault(gpa, vcpu->arch.gmap);
 	if (IS_ERR_VALUE(hva))
 		return (long)hva;
-	down_read(&mm->mmap_sem);
-	rc = get_user_pages(current, mm, hva, 1, writable, 0, NULL, NULL);
-	up_read(&mm->mmap_sem);
+	rc = get_user_pages_unlocked(current, mm, hva, 1, writable, 0, NULL);
 
 	return rc < 0 ? rc : 0;
 }
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
index 1aed043..fa7de7d 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -219,10 +219,8 @@ slow:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
