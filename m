Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD5FE6B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 05:04:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 59B433EE0AE
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:04:41 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 443F845DF47
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:04:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E92345DF43
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:04:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D0F6E18001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:04:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD8701DB8037
	for <linux-mm@kvack.org>; Tue, 10 May 2011 18:04:40 +0900 (JST)
Date: Tue, 10 May 2011 17:57:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-05-06-16-39 uploaded
Message-Id: <20110510175746.0a1fbe40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201105070015.p470FlAR013200@imap1.linux-foundation.org>
References: <201105070015.p470FlAR013200@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 06 May 2011 16:39:31 -0700
akpm@linux-foundation.org wrote:


> memcg-reclaim-memory-from-nodes-in-round-robin-order.patch
> memcg-reclaim-memory-from-nodes-in-round-robin-fix.patch

I'm very sorry that this fix is required for this logic.
==

next_scan_node_update is the time when scan_nodes nodemask should be updated.
Then, time_after() is correct. Otherwise, next-scan_node_update is intialized
to be 0 and time_before() returns always true, scan_nodes never be updated.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1517,7 +1517,7 @@ static void mem_cgroup_may_update_nodema
 {
 	int nid;
 
-	if (time_before(mem->next_scan_node_update, jiffies))
+	if (time_after(mem->next_scan_node_update, jiffies))
 		return;
 
 	mem->next_scan_node_update = jiffies + 10*HZ;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
