Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE376B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 00:26:16 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so7810031pde.0
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 21:26:16 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id wm3si23081759pab.194.2014.02.03.21.26.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 21:26:15 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 03 Feb 2014 21:26:06 -0800
Message-ID: <87r47jsb2p.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org


Recently due to a spike in connections per second memcached on 3
separate boxes triggered the OOM killer from accept.  At the time the
OOM killer was triggered there was 4GB out of 36GB free in zone 1. The
problem was that alloc_fdtable was allocating an order 3 page (32KiB) to
hold a bitmap, and there was sufficient fragmentation that the largest
page available was 8KiB.

I find the logic that PAGE_ALLOC_COSTLY_ORDER can't fail pretty dubious
but I do agree that order 3 allocations are very likely to succeed.

There are always pathologies where order > 0 allocations can fail when
there are copious amounts of free memory available.  Using the pigeon
hole principle it is easy to show that it requires 1 page more than 50%
of the pages being free to guarantee an order 1 (8KiB) allocation will
succeed, 1 page more than 75% of the pages being free to guarantee an
order 2 (16KiB) allocation will succeed and 1 page more than 87.5% of
the pages being free to guarantee an order 3 allocate will succeed.

A server churning memory with a lot of small requests and replies like
memcached is a common case that if anything can will skew the odds
against large pages being available.

Therefore let's not give external applications a practical way to kill
linux server applications, and specify __GFP_NORETRY to the kmalloc in
alloc_fdmem.  Unless I am misreading the code and by the time the code
reaches should_alloc_retry in __alloc_pages_slowpath (where
__GFP_NORETRY becomes signification).  We have already tried everything
reasonable to allocate a page and the only thing left to do is wait.  So
not waiting and falling back to vmalloc immediately seems like the
reasonable thing to do even if there wasn't a chance of triggering the
OOM killer.

Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 fs/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/file.c b/fs/file.c
index 771578b33fb6..db25c2bdfe46 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -34,7 +34,7 @@ static void *alloc_fdmem(size_t size)
 	 * vmalloc() if the allocation size will be considered "large" by the VM.
 	 */
 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
+		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
 		if (data != NULL)
 			return data;
 	}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
