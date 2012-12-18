Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8C9386B006C
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 01:49:50 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so296309pad.8
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 22:49:49 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v4 3/3] add PGVOLATILE vmstat count
Date: Tue, 18 Dec 2012 15:47:54 +0900
Message-Id: <1355813274-571-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1355813274-571-1-git-send-email-minchan@kernel.org>
References: <1355813274-571-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch add pgvolatile vmstat so admin can see how many of volatile
pages are discarded by VM until now. It could be a good indicator of
patch effect during test but still not sure we need it in real practice.
Will rethink it.

Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
CC: David Rientjes <rientjes@google.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vm_event_item.h |    2 +-
 mm/vmscan.c                   |    1 +
 mm/vmstat.c                   |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3d31145..f83c3d2 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -23,7 +23,7 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFREE, PGVOLATILE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cfe95d3..1ec7345 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -794,6 +794,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, ttu_flags)) {
 			case SWAP_DISCARD:
+				count_vm_event(PGVOLATILE);
 				goto discard_page;
 			case SWAP_FAIL:
 				goto activate_locked;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..9fd8ead 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -747,6 +747,7 @@ const char * const vmstat_text[] = {
 	TEXTS_FOR_ZONES("pgalloc")
 
 	"pgfree",
+	"pgvolatile",
 	"pgactivate",
 	"pgdeactivate",
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
