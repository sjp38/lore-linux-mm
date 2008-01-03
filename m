Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 08 of 11] stop useless vm trashing while we wait the
	TIF_MEMDIE task to exit
Message-Id: <59c2caaf27ab2eba9aaa.1199326154@v2.random>
In-Reply-To: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:14 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199325610 -3600
# Node ID 59c2caaf27ab2eba9aaaab7f9a06089bf164f22f
# Parent  686a1129469a1bad96745705ffe1567146bae222
stop useless vm trashing while we wait the TIF_MEMDIE task to exit

There's no point in trying to free memory if we're oom.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1129,6 +1129,13 @@ static unsigned long shrink_zone(int pri
 		nr_inactive = 0;
 
 	while (nr_active || nr_inactive) {
+		if (unlikely(zone_is_oom_locked(zone))) {
+			if (!test_thread_flag(TIF_MEMDIE))
+				/* get out of the way */
+				schedule_timeout_interruptible(1);
+			else
+				break;
+		}
 		if (nr_active) {
 			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
