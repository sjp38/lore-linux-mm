Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id F000B6B0062
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 01:39:30 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH 4/4] memory-hotplug: auto offline page_cgroup when onlining memory block failed
Date: Thu, 27 Sep 2012 13:45:05 +0800
Message-Id: <1348724705-23779-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

When a memory block is onlined, we will try allocate memory on that node
to store page_cgroup. If onlining the memory block failed, we don't
offline the page cgroup, and we have no chance to offline this page cgroup
unless the memory block is onlined successfully again. It will cause
that we can't hot-remove the memory device on that node, because some
memory is used to store page cgroup. If onlining the memory block
is failed, there is no need to stort page cgroup for this memory. So
auto offline page_cgroup when onlining memory block failed.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/page_cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5ddad0c..44db00e 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -251,6 +251,9 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
 				mn->nr_pages, mn->status_change_nid);
 		break;
 	case MEM_CANCEL_ONLINE:
+		offline_page_cgroup(mn->start_pfn,
+				mn->nr_pages, mn->status_change_nid);
+		break;
 	case MEM_GOING_OFFLINE:
 		break;
 	case MEM_ONLINE:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
