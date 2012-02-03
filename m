Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 6F0166B13F2
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 20:37:16 -0500 (EST)
Received: by eekb57 with SMTP id b57so92751eek.2
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 17:37:14 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: fix up documentation on global LRU.
Date: Thu,  2 Feb 2012 17:37:13 -0800
Message-Id: <1328233033-14246-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

In v3.3-rc1, the global LRU has been removed with commit
"mm: make per-memcg LRU lists exclusive". The patch fixes up the memcg docs.

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 4c95c00..847a2a4 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -34,8 +34,7 @@ Current Status: linux-2.6.34-mmotm(development version of 2010/April)
 
 Features:
  - accounting anonymous pages, file caches, swap caches usage and limiting them.
- - private LRU and reclaim routine. (system's global LRU and private LRU
-   work independently from each other)
+ - pages are linked to per-memcg LRU exclusively, and there is no global LRU.
  - optionally, memory+swap usage can be accounted and limited.
  - hierarchical accounting
  - soft limit
@@ -154,7 +153,7 @@ updated. page_cgroup has its own LRU on cgroup.
 2.2.1 Accounting details
 
 All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
-Some pages which are never reclaimable and will not be on the global LRU
+Some pages which are never reclaimable and will not be on the LRU
 are not accounted. We just account pages under usual VM management.
 
 RSS pages are accounted at page_fault unless they've already been accounted
@@ -209,19 +208,19 @@ In this case, setting memsw.limit_in_bytes=3G will prevent bad use of swap.
 By using memsw limit, you can avoid system OOM which can be caused by swap
 shortage.
 
-* why 'memory+swap' rather than swap.
-The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
-to move account from memory to swap...there is no change in usage of
-memory+swap. In other words, when we want to limit the usage of swap without
-affecting global LRU, memory+swap limit is better than just limiting swap from
-OS point of view.
-
 * What happens when a cgroup hits memory.memsw.limit_in_bytes
 When a cgroup hits memory.memsw.limit_in_bytes, it's useless to do swap-out
 in this cgroup. Then, swap-out will not be done by cgroup routine and file
-caches are dropped. But as mentioned above, global LRU can do swapout memory
-from it for sanity of the system's memory management state. You can't forbid
-it by cgroup.
+caches are dropped.
+
+TODO:
+* use 'memory+swap' rather than swap was due to existence of global LRU. It can
+swap out arbitrary pages. Swap-out means to move account from memory to swap...
+there is no change in usage of memory+swap. In other words, when we want to
+limit the usage of swap without affecting global LRU, memory+swap limit is
+better than just limiting swap from OS point of view. However, the global LRU
+has been removed now and all pages are linked in private LRU. We might want to
+revisit this in the future.
 
 2.5 Reclaim
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
