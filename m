Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 13 of 13] congestion wait
Message-Id: <352591adebd643c51fe6.1199778644@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:44 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User andrea@cpushare.com
# Date 1199701210 -3600
# Node ID 352591adebd643c51fe629c5ee343342f60b24f0
# Parent  74af3b1477511c7bd6a526b47195ddf95a5424dc
congestion wait

Don't block in congestion_wait if memdie is set.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -83,6 +83,9 @@ long congestion_wait(int rw, long timeou
 	DEFINE_WAIT(wait);
 	wait_queue_head_t *wqh = &congestion_wqh[rw];
 
+	if (unlikely(test_thread_flag(TIF_MEMDIE)))
+		return timeout;
+
 	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
 	ret = io_schedule_timeout(timeout);
 	finish_wait(wqh, &wait);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
