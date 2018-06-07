Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 731036B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:05:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p16-v6so1081808pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 15:05:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k22-v6si20819689pll.416.2018.06.07.15.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 15:05:48 -0700 (PDT)
Date: Thu, 7 Jun 2018 15:05:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Check for SIGKILL inside dup_mmap() loop.
Message-Id: <20180607150546.1c7db21f70221008e14b8bb8@linux-foundation.org>
In-Reply-To: <20180418193254.2db529eeca5d0dc5b82f6b3e@linux-foundation.org>
References: <201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp>
	<20180418144401.7c9311079914803c9076d209@linux-foundation.org>
	<201804190154.w3J1sieH011800@www262.sakura.ne.jp>
	<20180418193254.2db529eeca5d0dc5b82f6b3e@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, penguin-kernel@I-love.SAKURA.ne.jp, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, mhocko@suse.com, riel@redhat.com, Matthew Wilcox <willy@infradead.org>

Despite all the discussion, we're short on formal review/ack tags on
this one.

Here's what I have:


From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: mm: check for SIGKILL inside dup_mmap() loop

As a theoretical problem, dup_mmap() of an mm_struct with 60000+ vmas can
loop while potentially allocating memory, with mm->mmap_sem held for write
by current thread.  This is bad if current thread was selected as an OOM
victim, for current thread will continue allocations using memory reserves
while OOM reaper is unable to reclaim memory.

As an actually observable problem, it is not difficult to make OOM reaper
unable to reclaim memory if the OOM victim is blocked at
i_mmap_lock_write() in this loop.  Unfortunately, since nobody can explain
whether it is safe to use killable wait there, let's check for SIGKILL
before trying to allocate memory.  Even without an OOM event, there is no
point with continuing the loop from the beginning if current thread is
killed.

I tested with debug printk().  This patch should be safe because we
already fail if security_vm_enough_memory_mm() or
kmem_cache_alloc(GFP_KERNEL) fails and exit_mmap() handles it.

[  417.030691] ***** Aborting dup_mmap() due to SIGKILL *****
[  417.036129] ***** Aborting dup_mmap() due to SIGKILL *****
[  417.044544] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.116445] ***** Aborting dup_mmap() due to SIGKILL *****
[  419.118401] ***** Aborting exit_mmap() due to NULL mmap *****

[akpm@linux-foundation.org: add comment]
Link: http://lkml.kernel.org/r/201804071938.CDE04681.SOFVQJFtMHOOLF@I-love.SAKURA.ne.jp
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/fork.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN kernel/fork.c~mm-check-for-sigkill-inside-dup_mmap-loop kernel/fork.c
--- a/kernel/fork.c~mm-check-for-sigkill-inside-dup_mmap-loop
+++ a/kernel/fork.c
@@ -440,6 +440,14 @@ static __latent_entropy int dup_mmap(str
 			continue;
 		}
 		charge = 0;
+		/*
+		 * Don't duplicate many vmas if we've been oom-killed (for
+		 * example)
+		 */
+		if (fatal_signal_pending(current)) {
+			retval = -EINTR;
+			goto out;
+		}
 		if (mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned long len = vma_pages(mpnt);
 
_
