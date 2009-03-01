Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6F66B0092
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 01:30:10 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n216U14f028652
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 12:00:01 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n216U8KM3227866
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 12:00:09 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n216U0Dn007034
	for <linux-mm@kvack.org>; Sun, 1 Mar 2009 17:30:00 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 01 Mar 2009 11:59:59 +0530
Message-Id: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
Subject: [PATCH 0/4] Memory controller soft limit patches (v3)
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

Changelog v3...v2
1. Implemented several review comments from Kosaki-San and Kamezawa-San
   Please see individual changelogs for changes

Changelog v2...v1
1. Soft limits now support hierarchies
2. Use spinlocks instead of mutexes for synchronization of the RB tree

Here is v3 of the new soft limit implementation. Soft limits is a new feature
for the memory resource controller, something similar has existed in the
group scheduler in the form of shares. The CPU controllers interpretation
of shares is very different though. 

Soft limits are the most useful feature to have for environments where
the administrator wants to overcommit the system, such that only on memory
contention do the limits become active. The current soft limits implementation
provides a soft_limit_in_bytes interface for the memory controller and not
for memory+swap controller. The implementation maintains an RB-Tree of groups
that exceed their soft limit and starts reclaiming from the group that
exceeds this limit by the maximum amount.

If there are no major objections to the patches, I would like to get them
included in -mm.

TODOs

1. The current implementation maintains the delta from the soft limit
   and pushes back groups to their soft limits, a ratio of delta/soft_limit
   might be more useful
2. It would be nice to have more targetted reclaim (in terms of pages to
   recalim) interface. So that groups are pushed back, close to their soft
   limits.

Tests
-----

I've run two memory intensive workloads with differing soft limits and
seen that they are pushed back to their soft limit on contention. Their usage
was their soft limit plus additional memory that they were able to grab
on the system. Soft limit can take a while before we see the expected
results.

Please review, comment.

Series
------

memcg-soft-limit-documentation.patch
memcg-add-soft-limit-interface.patch
memcg-organize-over-soft-limit-groups.patch
memcg-soft-limit-reclaim-on-contention.patch



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
