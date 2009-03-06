Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5EB136B0119
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 05:39:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n26Adfv6023173
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Mar 2009 19:39:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B810245DD7A
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:39:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 947DB45DD78
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:39:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EB9F1DB803C
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:39:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 199B91DB803E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 19:39:41 +0900 (JST)
Date: Fri, 6 Mar 2009 19:38:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/3] memcg documenation soft limit (Yet Another One)
Message-Id: <20090306193821.ca2fb628.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>
	<20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
	<20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Documentation for softlimit (3/3)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

Index: mmotm-2.6.29-Mar3/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.29-Mar3.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.29-Mar3/Documentation/cgroups/memory.txt
@@ -322,6 +322,25 @@ will be charged as a new owner of it.
   - a cgroup which uses hierarchy and it has child cgroup.
   - a cgroup which uses hierarchy and not the root of hierarchy.
 
+5.4 softlimit
+  Memory cgroup supports softlimit and has 2 params for control.
+    - memory.softlimit_in_bytes
+	- softlimit to this cgroup.
+    - memory.softlimit_priority.
+	- priority of this cgroup at softlimit reclaim.
+	  Allowed priority level is 3-0 and 3 is the lowest.
+	  If 0, this cgroup will not be target of softlimit.
+
+  At memory shortage of the system (or local node/zone), softlimit helps
+  kswapd(), a global memory recalim kernel thread, and inform victim cgroup
+  to be shrinked to kswapd.
+
+  Victim selection logic:
+  The kernel searches from the lowest priroty(3) up to the highest(1).
+  If it find a cgroup witch has memory larger than softlimit, steal memory
+  from it.
+  If multiple cgroups are on the same priority, each cgroup wil be a
+  victim in turn.
 
 6. Hierarchy support
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
