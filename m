Date: Mon, 25 Feb 2008 23:37:05 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 03/15] memcg: page_cache_release not __free_page
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252336270.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's nothing wrong with mem_cgroup_charge failure in do_wp_page and
do_anonymous page using __free_page, but it does look odd when nearby
code uses page_cache_release: use that instead (while turning a blind
eye to ancient inconsistencies of page_cache_release versus put_page).

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- memcg02/mm/memory.c	2008-02-15 23:43:20.000000000 +0000
+++ memcg03/mm/memory.c	2008-02-25 14:05:43.000000000 +0000
@@ -1711,7 +1711,7 @@ unlock:
 	}
 	return ret;
 oom_free_new:
-	__free_page(new_page);
+	page_cache_release(new_page);
 oom:
 	if (old_page)
 		page_cache_release(old_page);
@@ -2163,7 +2163,7 @@ release:
 	page_cache_release(page);
 	goto unlock;
 oom_free_page:
-	__free_page(page);
+	page_cache_release(page);
 oom:
 	return VM_FAULT_OOM;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
