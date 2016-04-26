Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0A8D6B0268
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:57 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so11523212lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 12/18] aio: make aio_setup_ring killable
Date: Tue, 26 Apr 2016 14:56:19 +0200
Message-Id: <1461675385-5934-13-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Benamin LaHaise <bcrl@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

aio_setup_ring waits for mmap_sem in writable mode. If the waiting
task gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely
OOM resolving. Wait for the lock in the killable mode and return with
EINTR if the task got killed while waiting. This will also expedite
the return to the userspace and do_exit.

Cc: Benamin LaHaise <bcrl@kvack.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Acked-by: Jeff Moyer <jmoyer@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/aio.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/aio.c b/fs/aio.c
index 155f84253f33..be771046d77c 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -496,7 +496,12 @@ static int aio_setup_ring(struct kioctx *ctx)
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem)) {
+		ctx->mmap_size = 0;
+		aio_free_ring(ctx);
+		return -EINTR;
+	}
+
 	ctx->mmap_base = do_mmap_pgoff(ctx->aio_ring_file, 0, ctx->mmap_size,
 				       PROT_READ | PROT_WRITE,
 				       MAP_SHARED, 0, &unused);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
