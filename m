Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 94AD56B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:36:58 -0400 (EDT)
Received: by werf3 with SMTP id f3so6018wer.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:36:56 -0700 (PDT)
From: Avery Pennarun <apenwarr@gmail.com>
Subject: [PATCH 1/5] mm: bootmem: BUG() if you try to allocate bootmem too late.
Date: Tue, 13 Mar 2012 01:36:37 -0400
Message-Id: <1331617001-20906-2-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Avery Pennarun <apenwarr@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If you try to allocate or reserve bootmem after the bootmem subsystem has
already been shut down and replaced with the real VM system, it would
succeed, but then your memory would silently get freed and could be
reallocated by the normal VM.

Add a few lines of code to catch this condition immediately rather than
manifesting as memory corruption.

Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
---
 mm/bootmem.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 668e94d..7a9f505 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -39,6 +39,7 @@ bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
 static struct list_head bdata_list __initdata = LIST_HEAD_INIT(bdata_list);
 
 static int bootmem_debug;
+static int bootmem_stopped;
 
 static int __init bootmem_debug_setup(char *buf)
 {
@@ -182,6 +183,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 
 	bdebug("nid=%td start=%lx end=%lx\n",
 		bdata - bootmem_node_data, start, end);
+	bootmem_stopped = 1;
 
 	while (start < end) {
 		unsigned long *map, idx, vec;
@@ -279,6 +281,7 @@ static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 	unsigned long idx;
 	int exclusive = flags & BOOTMEM_EXCLUSIVE;
 
+	BUG_ON(bootmem_stopped);
 	bdebug("nid=%td start=%lx end=%lx flags=%x\n",
 		bdata - bootmem_node_data,
 		sidx + bdata->node_min_pfn,
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
