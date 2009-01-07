Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C94326B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 13:41:15 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n07If9Tp029398
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 00:11:09 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n07IfD7v4362360
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 00:11:13 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n07If8bl023185
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 05:41:08 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 08 Jan 2009 00:11:10 +0530
Message-Id: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 0/4] Memory controller soft limit patches
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Here is v1 of the new soft limit implementation. Soft limits is a new feature
for the memory resource controller, something similar has existed in the
group scheduler in the form of shares. We'll compare shares and soft limits
below. I've had soft limit implementations earlier, but I've discarded those
approaches in favour of this one.

Soft limits are the most useful feature to have for environments where
the administrator wants to overcommit the system, such that only on memory
contention do the limits become active. The current soft limits implementation
provides a soft_limit_in_bytes interface for the memory controller and not
for memory+swap controller. The implementation maintains an RB-Tree of groups
that exceed their soft limit and starts reclaiming from the group that
exceeds this limit by the maximum amount.

This is an RFC implementation and is not meant for inclusion

TODOs

1. The shares interface is not yet implemented, the current soft limit
   implementation is not yet hierarchy aware. The end goal is to add
   a shares interface on top of soft limits and to maintain shares in
   a manner similar to the group scheduler
2. The current implementation maintains the delta from the soft limit
   and pushes back groups to their soft limits, a ratio of delta/soft_limit
   is more useful
3. It would be nice to have more targetted reclaim (in terms of pages to
   recalim) interface. So that groups are pushed back, close to their soft
   limits.

Tests
-----

I've run two memory intensive workloads with differing soft limits and
seen that they are pushed back to their soft limit on contention. Their usage
was their soft limit plus additional memory that they were able to grab
on the system.

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
