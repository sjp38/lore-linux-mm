Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 08 of 13] stop useless vm trashing while we wait the
	TIF_MEMDIE task to exit
Message-Id: <be951f4c07326327719a.1199778639@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:39 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID be951f4c07326327719ad105f14be41296fcf753
# Parent  ee9691f08d054949b7718cff94c4f132d97626de
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
