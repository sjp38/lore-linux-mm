Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0756B0262
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so11675776wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:44 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id r9si24827220wme.19.2016.04.26.05.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:36 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n3so4763413wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:36 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 06/18] mm: make vm_brk killable
Date: Tue, 26 Apr 2016 14:56:13 +0200
Message-Id: <1461675385-5934-7-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Now that all the callers handle vm_brk failure we can change it
wait for mmap_sem killable to help oom_reaper to not get blocked
just because vm_brk gets blocked behind mmap_sem readers.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 2 +-
 mm/mmap.c          | 9 +++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1085e025852a..7b52750caf9e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2003,7 +2003,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
 
 /* These take the mm semaphore themselves */
-extern unsigned long vm_brk(unsigned long, unsigned long);
+extern unsigned long __must_check vm_brk(unsigned long, unsigned long);
 extern int vm_munmap(unsigned long, size_t);
 extern unsigned long __must_check vm_mmap(struct file *, unsigned long,
         unsigned long, unsigned long,
diff --git a/mm/mmap.c b/mm/mmap.c
index 032605bda665..62cb02310494 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2712,12 +2712,9 @@ unsigned long vm_brk(unsigned long addr, unsigned long len)
 	unsigned long ret;
 	bool populate;
 
-	/*
-	 * XXX not all users are chcecking the return value, convert
-	 * to down_write_killable after they are able to cope with
-	 * error
-	 */
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	ret = do_brk(addr, len);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
 	up_write(&mm->mmap_sem);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
