Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B5C2390013B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 09:23:55 -0400 (EDT)
From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Subject: [PATCH] avoid null pointer access in vm_struct
Date: Wed, 17 Aug 2011 22:28:48 +0900
Message-ID: <20110817132848.2352.80544.stgit@ltc219.sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yrl.pp-manager.tt@hitachi.com, Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Namhyung Kim <namhyung@gmail.com>, David Rientjes <rientjes@google.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

The /proc/vmallocinfo shows information about vmalloc allocations in vmlist
that is a linklist of vm_struct. It, however, may access pages field of
vm_struct where a page was not allocated, which results in a null pointer
access and leads to a kernel panic.

Why this happen:
For example, in __vmalloc_area_node, the nr_pages field of vm_struct are
set to the expected number of pages to be allocated, before the actual
pages allocations. At the same time, when the /proc/vmallocinfo is read, it
accesses the pages field of vm_struct according to the nr_pages field at
show_numa_info(). Thus, a null pointer access happens.

Patch:
This patch avoids accessing the pages field with unallocated page when
show_numa_info() is called. So, it can solve this problem.

Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Namhyung Kim <namhyung@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---

 mm/vmalloc.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ef0903..e2ec5b0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2472,13 +2472,16 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 	if (NUMA_BUILD) {
 		unsigned int nr, *counters = m->private;
 
-		if (!counters)
+		if (!counters || !v->nr_pages || !v->pages)
 			return;
 
 		memset(counters, 0, nr_node_ids * sizeof(unsigned int));
 
-		for (nr = 0; nr < v->nr_pages; nr++)
+		for (nr = 0; nr < v->nr_pages; nr++) {
+			if (!v->pages[nr])
+				break;
 			counters[page_to_nid(v->pages[nr])]++;
+		}
 
 		for_each_node_state(nr, N_HIGH_MEMORY)
 			if (counters[nr])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
