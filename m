Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDA96B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:56:48 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id n69HCpVA011028
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:12:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69HEiMu1331336
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:14:44 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69HEioZ026947
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 03:14:44 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 09 Jul 2009 22:44:41 +0530
Message-Id: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
Subject: [RFC][PATCH 0/5] Memory controller soft limit patches (v8)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: Balbir Singh <balbir@linux.vnet.ibm.com>

New Feature: Soft limits for memory resource controller.

Here is v8 of the new soft limit implementation. Soft limits is a new feature
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

v8 has come out after a long duration, we were held back by bug fixes
(most notably swap cache leak fix) and Kamezawa-San has his series of
patches for soft limits. Kamezawa-San asked me to refactor these patches
to make the data structure per-node-per-zone.

TODOs

1. The current implementation maintains the delta from the soft limit
   and pushes back groups to their soft limits, a ratio of delta/soft_limit
   might be more useful
2. Small optimizations that I intend to push in v9, if the v8 design looks
   good and acceptable.

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

memcg-soft-limits-documentation.patch
memcg-soft-limits-interface.patch
memcg-soft-limits-organize.patch
memcg-soft-limits-refactor-reclaim-bits
memcg-soft-limits-reclaim-on-contention.patch


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
