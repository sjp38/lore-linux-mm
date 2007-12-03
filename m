Date: Mon, 3 Dec 2007 18:45:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][for -mm] memory controller enhancements for reclaiming take2
 [8/8] wake up waiters at unchage
Message-Id: <20071203184551.a78a23de.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Throttling direct reclaim reduces the sytem load. But waiters are only waken
up if someone finish try_to_free_mem_cgroup_pages().

In progress of reclaiming, there can be enough memory before try_to_free_xxx
is finished. Because we throttle the number of reclaimers, it's better to
wake up waiters if there is enough room, in moderate way.
This decreases the system idle time under memory pressure in cgroup.

Signed-off-by: KAMEZAWA  Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



 mm/memcontrol.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6.24-rc3-mm2/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/memcontrol.c
+++ linux-2.6.24-rc3-mm2/mm/memcontrol.c
@@ -816,6 +816,13 @@ void mem_cgroup_uncharge(struct page_cgr
 			__mem_cgroup_remove_list(pc);
 			spin_unlock_irqrestore(&mz->lru_lock, flags);
 			kfree(pc);
+			/*
+			 * If there is enough room but there are waiters,
+			 * wake up one. (wake up all is tend to be heavy)
+			 */
+			if (!res_counter_above_high_watermark(&mem->res) &&
+			     waitqueue_active(&mem->waitq))
+				wake_up(&mem->waitq);
 		}
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
