Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 895B56B016C
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 07:07:06 -0400 (EDT)
Subject: [PATCH 2/2] vmscan: activate executable pages after first usage
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 8 Aug 2011 15:07:00 +0400
Message-ID: <20110808110659.31053.92935.stgit@localhost6>
In-Reply-To: <20110808110658.31053.55013.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Logic added in commit v2.6.30-5507-g8cab475
(vmscan: make mapped executable pages the first class citizen)
was noticeably weakened in commit v2.6.33-5448-g6457474
(vmscan: detect mapped file pages used only once)

Currently these pages can become "first class citizens" only after second usage.

After this patch page_check_references() will activate they after first usage,
and executable code gets yet better chance to stay in memory.

TODO:
run some cool tests like in v2.6.30-5507-g8cab475 =)

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3cd766d..29b3612 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -727,6 +727,12 @@ static enum page_references page_check_references(struct page *page,
 		if (referenced_page || referenced_ptes > 1)
 			return PAGEREF_ACTIVATE;
 
+		/*
+		 * Activate file-backed executable pages after first usage.
+		 */
+		if (vm_flags & VM_EXEC)
+			return PAGEREF_ACTIVATE;
+
 		return PAGEREF_KEEP;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
