Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 67EB88D0006
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:57:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C31DB3EE0AE
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:57:52 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC2E745DE4E
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:57:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9535945DE4D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:57:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 869321DB803C
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:57:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 35CB61DB8038
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:57:52 +0900 (JST)
Message-ID: <4FB0F356.70101@jp.fujitsu.com>
Date: Mon, 14 May 2012 20:58:14 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 1/4] x86: get pg_data_t's memory from other node
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com>
In-Reply-To: <4FB0F174.1000400@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

If system can create movable node which all memory of the
node is allocated as ZONE_MOVABLE, setup_node_data() cannot
allocate memory for the node's pg_data_t.
So when memblock_alloc_nid() fails, setup_node_data() retries
memblock_alloc().

---
  arch/x86/mm/numa.c |    8 ++++++--
  1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-3.4-rc6/arch/x86/mm/numa.c
===================================================================
--- linux-3.4-rc6.orig/arch/x86/mm/numa.c	2012-05-15 06:43:38.887962970 +0900
+++ linux-3.4-rc6/arch/x86/mm/numa.c	2012-05-15 06:43:42.422918776 +0900
@@ -223,9 +223,13 @@ static void __init setup_node_data(int n
  		remapped = true;
  	} else {
  		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
-		if (!nd_pa) {
-			pr_err("Cannot find %zu bytes in node %d\n",
+		if (!nd_pa)
+			printk(KERN_WARNING "Cannot find %zu bytes in node %d\n",
  			       nd_size, nid);
+		nd_pa = memblock_alloc(nd_size, SMP_CACHE_BYTES);
+		if (!nd_pa) {
+			pr_err("Cannot find %zu bytes in other node\n",
+			       nd_size);
  			return;
  		}
  		nd = __va(nd_pa);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
