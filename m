Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9FCF26B00CB
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:44:26 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297iOlh030760
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:44:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E051E45DE4F
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:44:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7F2645DE4E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:44:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 867901DB803C
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:44:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 270BF1DB8040
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:44:23 +0900 (JST)
Date: Mon, 9 Mar 2009 16:43:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] memcg: softlimit documenation
Message-Id: <20090309164304.7725fcc9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Documentation for softlimit

Changelog: (v1)->(v2)
 - fixed typos.
 - added more precise text.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

Index: develop/Documentation/cgroups/memory.txt
===================================================================
--- develop.orig/Documentation/cgroups/memory.txt
+++ develop/Documentation/cgroups/memory.txt
@@ -322,6 +322,35 @@ will be charged as a new owner of it.
   - a cgroup which uses hierarchy and it has child cgroup.
   - a cgroup which uses hierarchy and not the root of hierarchy.
 
+5.4 softlimit
+  Memory cgroup supports softlimit and has 2 parameters for control.
+
+    - memory.softlimit_in_bytes
+	softlimit for this cgroup
+
+    - memory.softlimit_priority
+	priority of this cgroup at softlimit reclaim
+	Allowed priority level is 0-8 and 0 is the lowest, 8 is the highest.
+        If 8 is specified, this will not be target of softlimit.
+
+  At memory shortage of the system (or local node/zone), softlimit helps
+  kswapd(), a global memory reclaim kernel thread, and informs victim cgroup
+  to be shrinked to kswapd.
+
+  Victim selection logic:
+  *Now*, static priority round-robin queue is used.
+
+  The kernel searches from the lowest priroty(0) up to the highest(7).
+  (priority (8) will never be scanned.)
+  If it finds a cgroup which has memory larger than softlimit, steal memory
+  from it. If multiple cgroups are on the same priority, each cgroup will be a
+  victim in turn.
+
+  Note: the kernel splits memory into zones and the system's memory shortage
+  is usually shorgage of zone's memory. So, even if a memcg'spriority is low,
+  it may not be selected because target zone's memory is not included in it.
+
+  Todo: some kind of dynamic-priority scheduler is fine.
 
 6. Hierarchy support
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
