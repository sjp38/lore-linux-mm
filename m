Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE9A280251
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:20:35 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id f134so15049120lfg.6
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:35 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id r14si6430262lfi.358.2016.10.12.17.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 17:20:33 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id x79so9727632lff.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:33 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 04/10] mm: replace get_user_pages_locked() write/force parameters with gup_flags
Date: Thu, 13 Oct 2016 01:20:14 +0100
Message-Id: <20161013002020.3062-5-lstoakes@gmail.com>
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
References: <20161013002020.3062-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch removes the write and force parameters from get_user_pages_locked()
and replaces them with a gup_flags parameter to make the use of FOLL_FORCE
explicit in callers as use of this flag can result in surprising behaviour (and
hence bugs) within the mm subsystem.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 include/linux/mm.h |  2 +-
 mm/frame_vector.c  |  8 +++++++-
 mm/gup.c           | 12 +++---------
 mm/nommu.c         |  5 ++++-
 4 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6adc4bc..27ab538 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1282,7 +1282,7 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    int write, int force, struct page **pages,
 			    struct vm_area_struct **vmas);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages, int *locked);
+		    unsigned int gup_flags, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       struct page **pages, unsigned int gup_flags);
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 381bb07..81b6749 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -41,10 +41,16 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	int ret = 0;
 	int err;
 	int locked;
+	unsigned int gup_flags = 0;
 
 	if (nr_frames == 0)
 		return 0;
 
+	if (write)
+		gup_flags |= FOLL_WRITE;
+	if (force)
+		gup_flags |= FOLL_FORCE;
+
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
@@ -59,7 +65,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 		vec->got_ref = true;
 		vec->is_pfns = false;
 		ret = get_user_pages_locked(start, nr_frames,
-			write, force, (struct page **)(vec->ptrs), &locked);
+			gup_flags, (struct page **)(vec->ptrs), &locked);
 		goto out;
 	}
 
diff --git a/mm/gup.c b/mm/gup.c
index cfcb014..7a0d033 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -838,18 +838,12 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  *          up_read(&mm->mmap_sem);
  */
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			   int write, int force, struct page **pages,
+			   unsigned int gup_flags, struct page **pages,
 			   int *locked)
 {
-	unsigned int flags = FOLL_TOUCH;
-
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
-
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, NULL, locked, true, flags);
+				       pages, NULL, locked, true,
+				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 7e27add..842cfdd 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -176,9 +176,12 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 EXPORT_SYMBOL(get_user_pages);
 
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
-			    int write, int force, struct page **pages,
+			    unsigned int gup_flags, struct page **pages,
 			    int *locked)
 {
+	int write = gup_flags & FOLL_WRITE;
+	int force = gup_flags & FOLL_FORCE;
+
 	return get_user_pages(start, nr_pages, write, force, pages, NULL);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
