Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 4D0076B00EC
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 05:18:26 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so5779428bkw.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 02:18:24 -0700 (PDT)
Subject: [PATCH] mm: forbid lumpy-reclaim in shrink_active_list()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 19 Mar 2012 13:18:21 +0400
Message-ID: <20120319091821.17716.54031.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch reset reclaim mode in shrink_active_list() to RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC.
(sync/async sign is used only in shrink_page_list and does not affect shrink_active_list)

Currenly shrink_active_list() sometimes works in lumpy-reclaim mode,
if RECLAIM_MODE_LUMPYRECLAIM left over from earlier shrink_inactive_list().
Meanwhile, in age_active_anon() sc->reclaim_mode is totally zero.
So, current behavior is too complex and confusing, all this looks like bug.

In general, shrink_active_list() populate inactive list for next shrink_inactive_list().
Lumpy shring_inactive_list() isolate pages around choosen one from both active and
inactive lists. So, there no reasons for lumpy-isolation in shrink_active_list()

Proposed-by: Hugh Dickins <hughd@google.com>
Link: https://lkml.org/lkml/2012/3/15/583
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 57d8ef6..ae83ca3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1690,6 +1690,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	lru_add_drain();
 
+	reset_reclaim_mode(sc);
+
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
