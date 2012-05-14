Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0907D8D000C
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9E3F33EE0B6
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 857D445DE50
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE4245DE4D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F3251DB8038
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:36 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 168D91DB803E
	for <linux-mm@kvack.org>; Mon, 14 May 2012 20:58:36 +0900 (JST)
Message-ID: <4FB0F38A.5020909@jp.fujitsu.com>
Date: Mon, 14 May 2012 20:59:06 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 4/4] memblock: compare current_limit with end variable at
 memblock_find_in_range_node()
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com>
In-Reply-To: <4FB0F174.1000400@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

memblock_find_in_range_node() does not compare memblock.current_limit
with end variable. Thus even if memblock.current_limit is smaller than
end variable, the function allocates memory address that is bigger than
memblock.current_limit.

The patch adds the check to "memblock_find_in_range_node()"

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
  mm/memblock.c |    5 +++--
  1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-3.4-rc6/mm/memblock.c
===================================================================
--- linux-3.4-rc6.orig/mm/memblock.c	2012-05-15 03:51:25.104153055 +0900
+++ linux-3.4-rc6/mm/memblock.c	2012-05-15 04:16:49.468094485 +0900
@@ -97,11 +97,12 @@ phys_addr_t __init_memblock memblock_fin
  					phys_addr_t align, int nid)
  {
  	phys_addr_t this_start, this_end, cand;
+	phys_addr_t current_limit = memblock.current_limit;
  	u64 i;

  	/* pump up @end */
-	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
-		end = memblock.current_limit;
+	if ((end == MEMBLOCK_ALLOC_ACCESSIBLE) || (end > current_limit))
+		end = current_limit;

  	/* avoid allocating the first page */
  	start = max_t(phys_addr_t, start, PAGE_SIZE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
