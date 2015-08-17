Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 92416280244
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 23:16:03 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so98425261pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 20:16:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dn2si22343750pdb.103.2015.08.16.20.16.02
        for <linux-mm@kvack.org>;
        Sun, 16 Aug 2015 20:16:02 -0700 (PDT)
From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch V3 2/9] kernel/profile.c: Replace cpu_to_mem() with cpu_to_node()
Date: Mon, 17 Aug 2015 11:18:59 +0800
Message-Id: <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

Function profile_cpu_callback() allocates memory without specifying
__GFP_THISNODE flag, so replace cpu_to_mem() with cpu_to_node()
because cpu_to_mem() may cause suboptimal memory allocation if
there's no free memory on the node returned by cpu_to_mem().

It's safe to use cpu_to_mem() because build_all_zonelists() also
builds suitable fallback zonelist for memoryless node.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 kernel/profile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index a7bcd28d6e9f..d14805bdcc4c 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -336,7 +336,7 @@ static int profile_cpu_callback(struct notifier_block *info,
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		node = cpu_to_mem(cpu);
+		node = cpu_to_node(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
 			page = alloc_pages_exact_node(node,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
