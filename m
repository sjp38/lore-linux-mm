Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8D60B6B00A2
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:35 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id um1so495466pbc.30
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:35 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ha5si919197pbc.210.2014.03.04.19.59.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:34 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so506662pab.22
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:34 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 08/11] mm, memcg: add memcg oom reserve documentation
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041956250.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

Add documentation on memcg oom reserves to
Documentation/cgroups/memory.txt and give an example of its usage and
recommended best practices.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/cgroups/memory.txt | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -71,6 +71,7 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.oom_reserve_in_bytes	 # set/show limit of oom memory reserves
  memory.numa_stat		 # show the number of memory usage per numa node
 
  memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
@@ -772,6 +773,31 @@ At reading, current status of OOM is shown.
 	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
 				 be stopped.)
 
+Processes that handle oom conditions in their own memcgs or their child
+memcgs may need to allocate memory themselves to do anything useful,
+including pagefaulting its text or allocating kernel memory to read the
+memcg "tasks" file.  For this reason, memory.oom_reserve_in_bytes is
+provided that specifies how much memory that processes waiting on
+memory.oom_control can allocate above the memcg limit.
+
+The memcg that the oom handler is attached to is charged for the memory
+that it allocates against its own memory.oom_reserve_in_bytes.  This
+memory is therefore only available to processes that are waiting for
+a notification.
+
+For example, if you do
+
+	# echo 2m > memory.oom_reserve_in_bytes
+
+then any process attached to this memcg that is waiting on memcg oom
+notifications anywhere on the system can allocate an additional 2MB
+above memory.limit_in_bytes.
+
+You may still consider doing mlockall(MCL_FUTURE) for processes that
+are waiting on oom notifications to keep this vaue as minimal as
+possible, or allow it to be large enough so that its text can still
+be pagefaulted in under oom conditions when the value is known.
+
 11. Memory Pressure
 
 The pressure level notifications can be used to monitor the memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
