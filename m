Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 710ED6B0263
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:20:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so36636611lfn.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:29 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id h78si6461496lji.63.2016.10.12.17.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 17:20:28 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l131so6885640lfl.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:27 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 01/10] mm: remove write/force parameters from __get_user_pages_locked()
Date: Thu, 13 Oct 2016 01:20:11 +0100
Message-Id: <20161013002020.3062-2-lstoakes@gmail.com>
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
References: <20161013002020.3062-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch removes the write and force parameters from __get_user_pages_locked()
to make the use of FOLL_FORCE explicit in callers as use of this flag can result
in surprising behaviour (and hence bugs) within the mm subsystem.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 mm/gup.c | 47 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 33 insertions(+), 14 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 96b2b2f..ba83942 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -729,7 +729,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct mm_struct *mm,
 						unsigned long start,
 						unsigned long nr_pages,
-						int write, int force,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked, bool notify_drop,
@@ -747,10 +746,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 
 	if (pages)
 		flags |= FOLL_GET;
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
 
 	pages_done = 0;
 	lock_dropped = false;
@@ -846,9 +841,15 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   int write, int force, struct page **pages,
 			   int *locked)
 {
+	unsigned int flags = FOLL_TOUCH;
+
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       write, force, pages, NULL, locked, true,
-				       FOLL_TOUCH);
+				       pages, NULL, locked, true, flags);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -869,9 +870,15 @@ __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct m
 {
 	long ret;
 	int locked = 1;
+
+	if (write)
+		gup_flags |= FOLL_WRITE;
+	if (force)
+		gup_flags |= FOLL_FORCE;
+
 	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				      pages, NULL, &locked, false, gup_flags);
+	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
+				      &locked, false, gup_flags);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -963,9 +970,15 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 		int write, int force, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false,
-				       FOLL_TOUCH | FOLL_REMOTE);
+	unsigned int flags = FOLL_TOUCH | FOLL_REMOTE;
+
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
+				       NULL, false, flags);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
@@ -979,9 +992,15 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 		int write, int force, struct page **pages,
 		struct vm_area_struct **vmas)
 {
+	unsigned int flags = FOLL_TOUCH;
+
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       write, force, pages, vmas, NULL, false,
-				       FOLL_TOUCH);
+				       pages, vmas, NULL, false, flags);
 }
 EXPORT_SYMBOL(get_user_pages);
 
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
