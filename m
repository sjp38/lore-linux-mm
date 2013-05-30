Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 89D416B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 18:50:05 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v2] swap: avoid read_swap_cache_async() race to deadlock while waiting on discard I/O completion
Date: Thu, 30 May 2013 19:49:34 -0300
Message-Id: <c217bcf6114e2af059488dc93d06b472077c5d74.1369953156.git.aquini@redhat.com>
In-Reply-To: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
References: <2434dea05a7fda7e7ccf48f70124bd65f2556b2d.1369935749.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, riel@redhat.com, lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com

read_swap_cache_async() can race against get_swap_page(), and stumble across
a SWAP_HAS_CACHE entry in the swap map whose page wasn't brought into the
swapcache yet. This transient swap_map state is expected to be transitory,
but the actual placement of discard at scan_swap_map() inserts a wait for
I/O completion thus making the thread at read_swap_cache_async() to loop
around its -EEXIST case, while the other end at get_swap_page()
is scheduled away at scan_swap_map(). This can leave the system deadlocked
if the I/O completion happens to be waiting on the CPU waitqueue where
read_swap_cache_async() is busy looping and !CONFIG_PREEMPT.

This patch introduces a cond_resched() call to make the aforementioned
read_swap_cache_async() busy loop condition to bail out when necessary,
thus avoiding the subtle race window.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---
Changelog:
* fixed typos in commit message;			(hannes)
* enhanced the commentary on the deadlock scenario;	(hannes)
* include the received ACKs and Cc: stable

 mm/swap_state.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index b3d40dc..f24ab0d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -336,8 +336,24 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * Swap entry may have been freed since our caller observed it.
 		 */
 		err = swapcache_prepare(entry);
-		if (err == -EEXIST) {	/* seems racy */
+		if (err == -EEXIST) {
 			radix_tree_preload_end();
+			/*
+			 * We might race against get_swap_page() and stumble
+			 * across a SWAP_HAS_CACHE swap_map entry whose page
+			 * has not been brought into the swapcache yet, while
+			 * the other end is scheduled away waiting on discard
+			 * I/O completion at scan_swap_map().
+			 *
+			 * In order to avoid turning this transitory state
+			 * into a permanent loop around this -EEXIST case
+			 * if !CONFIG_PREEMPT and the I/O completion happens
+			 * to be waiting on the CPU waitqueue where we are now
+			 * busy looping, we just conditionally invoke the
+			 * scheduler here, if there are some more important
+			 * tasks to run.
+			 */
+			cond_resched();
 			continue;
 		}
 		if (err) {		/* swp entry is obsolete ? */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
