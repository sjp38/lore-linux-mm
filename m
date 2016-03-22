Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8096B0253
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 18:45:35 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so328994218pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:45:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uw2si13392154pac.4.2016.03.22.15.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 15:45:34 -0700 (PDT)
Date: Tue, 22 Mar 2016 15:45:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/9] mm, oom: introduce oom reaper
Message-Id: <20160322154533.c269d76a65b81bb1b8f72545@linux-foundation.org>
In-Reply-To: <1458644426-22973-3-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
	<1458644426-22973-3-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

On Tue, 22 Mar 2016 12:00:19 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.

What happened to oom-reaper-handle-mlocked-pages.patch?  I have it in
-mm but I don't see it in this v6.


From: Michal Hocko <mhocko@suse.com>
Subject: oom reaper: handle mlocked pages

__oom_reap_vmas current skips over all mlocked vmas because they need a
special treatment before they are unmapped.  This is primarily done for
simplicity.  There is no reason to skip over them and reduce the amount of
reclaimed memory.  This is safe from the semantic point of view because
try_to_unmap_one during rmap walk would keep tell the reclaim to cull the
page back and mlock it again.

munlock_vma_pages_all is also safe to be called from the oom reaper
context because it doesn't sit on any locks but mmap_sem (for read).

Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: Andrea Argangeli <andrea@kernel.org>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/oom_kill.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff -puN mm/oom_kill.c~oom-reaper-handle-mlocked-pages mm/oom_kill.c
--- a/mm/oom_kill.c~oom-reaper-handle-mlocked-pages
+++ a/mm/oom_kill.c
@@ -442,13 +442,6 @@ static bool __oom_reap_vmas(struct mm_st
 			continue;
 
 		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
-		 */
-		if (vma->vm_flags & VM_LOCKED)
-			continue;
-
-		/*
 		 * Only anonymous pages have a good chance to be dropped
 		 * without additional steps which we cannot afford as we
 		 * are OOM already.
@@ -458,9 +451,12 @@ static bool __oom_reap_vmas(struct mm_st
 		 * we do not want to block exit_mmap by keeping mm ref
 		 * count elevated without a good reason.
 		 */
-		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
+		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
+			if (vma->vm_flags & VM_LOCKED)
+				munlock_vma_pages_all(vma);
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
 					 &details);
+		}
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	up_read(&mm->mmap_sem);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
