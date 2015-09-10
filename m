Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DA0956B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 10:18:46 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so44383581pad.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 07:18:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z11si8396132pas.89.2015.09.10.07.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 07:18:46 -0700 (PDT)
Subject: [PATCH] mm/page_alloc: Favor kthread and dying threads over normal threads
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp>
Date: Thu, 10 Sep 2015 23:18:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

>From fb48bec5d08068bc68023f4684098d0ce9ab6439 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 10 Sep 2015 20:13:38 +0900
Subject: [PATCH] mm/page_alloc: Favor kthread and dying threads over normal
 threads

shrink_inactive_list() and throttle_direct_reclaim() are expecting that
dying threads should not be throttled so that they can leave memory
allocator functions and die and release their memory shortly.
Also, throttle_direct_reclaim() is expecting that kernel threads should
not be throttled as they may be indirectly responsible for cleaning pages
necessary for reclaim to make forward progress.

Currently __GFP_WAIT && order <= PAGE_ALLOC_COSTLY_ORDER && !__GFP_NORETRY
&& !__GFP_NOFAIL allocation requests implicitly retry forever unless
TIF_MEMDIE is set by the OOM killer. But we unlikely can change such
requests not to retry in the near future because most of allocation failure
paths are not tested well. If we change it now and add __GFP_NOFAIL to
callers, we increase possibility of waiting for unkillable OOM victim
threads.

Also, currently the OOM killer sets TIF_MEMDIE to only one thread even if
there are 1000 threads sharing the mm struct. All threads get SIGKILL and
are treated as dying thread, but there is a problem. While OOM victim
threads with TIF_MEMDIE are favored at several locations in memory
allocator functions, OOM victim threads without TIF_MEMDIE are not favored
(except abovementioned shrink_inactive_list()) unless they are doing
__GFP_FS allocations.

Therefore, __GFP_WAIT && order <= PAGE_ALLOC_COSTLY_ORDER && !__GFP_NORETRY
allocation requests by dying threads and kernel threads are throttled by
abovementioned implicit retry loop because they are using watermark for
normal threads' normal allocation requests.

For example, kernel threads and OOM victim threads without TIF_MEMDIE can
fall into OOM livelock condition using a reproducer shown below (which
mutually blocks other threads using unkillable mutex lock).

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
	const int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
	sleep(2);
	while (write(fd, "", 1) == 1);
	return 0;
}

static int memory_consumer(void *unused)
{
	const int fd = open("/dev/zero", O_RDONLY);
	unsigned long size;
	char *buf = NULL;
	sleep(3);
	unlink("/tmp/file");
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	read(fd, buf, size); /* Will cause OOM due to overcommit */
	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	for (i = 0; i < 1000; i++)
		clone(file_writer, malloc(4 * 1024) + 4 * 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
	clone(memory_consumer, malloc(4 * 1024) + 4 * 1024, CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, NULL);
	pause();
	return 0;
}
----------

The OOM killer randomly chooses only one thread (and let
__alloc_pages_slowpath() favor only that thread) when each threads are
mutually blocked. This is prone to cause OOM livelock.

But favoring only dying threads still causes OOM livelock because
sometimes dying threads depend on memory allocations issued by kernel
threads.

Kernel threads and dying threads (especially OOM victim threads) want
higher priority than normal threads. This patch favors them by
implicitly applying ALLOC_HIGH watermark.

Presumably we don't need to apply ALLOC_NO_WATERMARKS priority for
TIF_MEMDIE threads if we evenly favor all OOM victim threads. But it is
outside of this patch's scope because we after all need to handle cases
where killing other threads are necessary for OOM victim threads to make
forward progress (e.g. multiple instances of the reproducer shown above
are running concurrently).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dcfe935..777c331 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2990,6 +2990,13 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				((current->flags & PF_MEMALLOC) ||
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
+		/*
+		 * Favor kernel threads and dying threads like
+		 * shrink_inactive_list() and throttle_direct_reclaim().
+		 */
+		else if (!atomic && ((current->flags & PF_KTHREAD) ||
+				     fatal_signal_pending(current)))
+			alloc_flags |= ALLOC_HIGH;
 	}
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
