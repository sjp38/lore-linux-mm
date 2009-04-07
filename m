Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 35E9B5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 06:55:19 -0400 (EDT)
Message-ID: <49DB306A.8070407@cn.fujitsu.com>
Date: Tue, 07 Apr 2009 18:52:26 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] cpuset,mm: fix memory spread bug
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

The kernel still allocated the page caches on old node after modifying its
cpuset's mems when 'memory_spread_page' was set, or it didn't spread the page
cache evenly over all the nodes that faulting task is allowed to usr after
memory_spread_page was set. it is caused by the old mem_allowed and flags
of the task, the current kernel doesn't updates them unless some function
invokes cpuset_update_task_memory_state(), it is too late sometimes.We must
update the mem_allowed and the flags of the tasks in time.

Slab has the same problem.

The following patches fix this bug by updating tasks' mem_allowed and spread
flag after its cpuset's mems or spread flag is changed.

patch 1: restructure the function cpuset_update_task_memory_state()
patch 2: update tasks' page/slab spread flags in time
patch 3: update tasks' mems_allowed in time


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
