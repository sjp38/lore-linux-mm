Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B5A326B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 21:53:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o981mRLW007104
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 8 Oct 2010 10:48:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9523545DE51
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 10:48:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72C8D45DE50
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 10:48:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53596E38005
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 10:48:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 051C2E38002
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 10:48:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
Message-Id: <20101008104852.803E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  8 Oct 2010 10:48:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Recently, Robert Mueller reported zone_reclaim_mode doesn't work
properly on his new NUMA server (Dual Xeon E5520 + Intel S5520UR MB).
He is using Cyrus IMAPd and it's built on a very traditional
single-process model.

  * a master process which reads config files and manages the other
    process
  * multiple imapd processes, one per connection
  * multiple pop3d processes, one per connection
  * multiple lmtpd processes, one per connection
  * periodical "cleanup" processes.

Then, there are thousands of independent processes. The problem is,
recent Intel motherboard turn on zone_reclaim_mode by default and
traditional prefork model software don't work fine on it.
Unfortunatelly, Such model is still typical one even though 21th
century. We can't ignore them.

This patch raise zone_reclaim_mode threshold to 30. 30 don't have
specific meaning. but 20 mean one-hop QPI/Hypertransport and such
relatively cheap 2-4 socket machine are often used for tradiotional
server as above. The intention is, their machine don't use
zone_reclaim_mode.

Note: ia64 and Power have arch specific RECLAIM_DISTANCE definition.
then this patch doesn't change such high-end NUMA machine behavior.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Bron Gondwana <brong@fastmail.fm>
Cc: Robert Mueller <robm@fastmail.fm>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/topology.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/topology.h b/include/linux/topology.h
index 64e084f..bfbec49 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -60,7 +60,7 @@ int arch_update_cpu_topology(void);
  * (in whatever arch specific measurement units returned by node_distance())
  * then switch on zone reclaim on boot.
  */
-#define RECLAIM_DISTANCE 20
+#define RECLAIM_DISTANCE 30
 #endif
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS	(1)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
