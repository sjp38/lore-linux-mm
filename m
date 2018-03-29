Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE8046B0026
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:28:36 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 140-v6so5158226itg.4
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:28:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c41si4097228ioj.308.2018.03.29.04.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:28:35 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Date: Thu, 29 Mar 2018 20:27:50 +0900
Message-Id: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

Theoretically it is possible that an mm_struct with 60000+ vmas loops
with potentially allocating memory, with mm->mmap_sem held for write by
the current thread. Unless I overlooked that fatal_signal_pending() is
somewhere in the loop, this is bad if current thread was selected as an
OOM victim, for the current thread will continue allocations using memory
reserves while the OOM reaper is unable to reclaim memory.

But there is no point with continuing the loop from the beginning if
current thread is killed. If there were __GFP_KILLABLE (or something
like memalloc_nofs_save()/memalloc_nofs_restore()), we could apply it
to all allocations inside the loop. But since we don't have such flag,
this patch uses fatal_signal_pending() check inside the loop.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 kernel/fork.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index 1e8c9a7..38d5baa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -440,6 +440,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 			continue;
 		}
 		charge = 0;
+		if (fatal_signal_pending(current)) {
+			retval = -EINTR;
+			goto out;
+		}
 		if (mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned long len = vma_pages(mpnt);
 
-- 
1.8.3.1
