Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5AB6B025F
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so11673898wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:38 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 6si29889862wjf.49.2016.04.26.05.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:34 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e201so4192915wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:33 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 03/18] mm: make vm_munmap killable
Date: Tue, 26 Apr 2016 14:56:10 +0200
Message-Id: <1461675385-5934-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>

From: Michal Hocko <mhocko@suse.com>

Almost all current users of vm_munmap are ignoring the return value
and so they do not handle potential error. This means that some VMAs
might stay behind. This patch doesn't try to solve those potential
problems. Quite contrary it adds a new failure mode by using
down_write_killable in vm_munmap. This should be safer than other
failure modes, though, because the process is guaranteed to die
as soon as it leaves the kernel and exit_mmap will clean the whole
address space.

This will help in the OOM conditions when the oom victim might be stuck
waiting for the mmap_sem for write which in turn can block oom_reaper
which relies on the mmap_sem for read to make a forward progress and
reclaim the address space of the victim.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mmap.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 1d229487dab1..032605bda665 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2494,11 +2494,9 @@ int vm_munmap(unsigned long start, size_t len)
 	int ret;
 	struct mm_struct *mm = current->mm;
 
-	/*
-	 * XXX convert to down_write_killable as soon as all users are able
-	 * to handle the error.
-	 */
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	ret = do_munmap(mm, start, len);
 	up_write(&mm->mmap_sem);
 	return ret;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
