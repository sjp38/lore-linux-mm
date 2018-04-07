Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61E096B0006
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 06:38:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so2046447pfz.19
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 03:38:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q6si8230803pgt.130.2018.04.07.03.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 03:38:40 -0700 (PDT)
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522322870-4335-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
In-Reply-To: <20180329143003.c52ada618be599c5358e8ca2@linux-foundation.org>
Message-Id: <201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp>
Date: Sat, 7 Apr 2018 19:38:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com

>From 31c863e57a4ab7dfb491b2860fe3653e1e8f593b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 7 Apr 2018 19:29:30 +0900
Subject: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.

As a theoretical problem, an mm_struct with 60000+ vmas can loop with
potentially allocating memory, with mm->mmap_sem held for write by current
thread. This is bad if current thread was selected as an OOM victim, for
current thread will continue allocations using memory reserves while OOM
reaper is unable to reclaim memory.

As an actually observable problem, it is not difficult to make OOM reaper
unable to reclaim memory if the OOM victim is blocked at
i_mmap_lock_write() in this loop. Unfortunately, since nobody can explain
whether it is safe to use killable wait there, let's check for SIGKILL
before trying to allocate memory. Even without an OOM event, there is no
point with continuing the loop from the beginning if current thread is
killed.

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
index 242c8c9..8831bae 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -441,6 +441,10 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
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
