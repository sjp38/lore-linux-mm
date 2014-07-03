Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA926B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:49:50 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id c11so123995lbj.17
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:49:49 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kw5si26017924lbc.58.2014.07.03.05.49.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:49:49 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 5/5] vm_cgroup: do not charge tasks in root cgroup
Date: Thu, 3 Jul 2014 16:48:21 +0400
Message-ID: <e97d260eecc1a5f01a900996ae12cc265b6023c7.1404383187.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

For the root cgroup (the whole system), we already have overcommit
accounting and control, so we can skip charging tasks in the root cgroup
to avoid overhead.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/vm_cgroup.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/vm_cgroup.c b/mm/vm_cgroup.c
index 6642f934540a..c871fecaab4c 100644
--- a/mm/vm_cgroup.c
+++ b/mm/vm_cgroup.c
@@ -1,6 +1,7 @@
 #include <linux/cgroup.h>
 #include <linux/res_counter.h>
 #include <linux/mm.h>
+#include <linux/mman.h>
 #include <linux/slab.h>
 #include <linux/rcupdate.h>
 #include <linux/shmem_fs.h>
@@ -65,6 +66,9 @@ static int vm_cgroup_do_charge(struct vm_cgroup *vmcg,
 	unsigned long val = nr_pages << PAGE_SHIFT;
 	struct res_counter *fail_res;
 
+	if (vm_cgroup_is_root(vmcg))
+		return 0;
+
 	return res_counter_charge(&vmcg->res, val, &fail_res);
 }
 
@@ -73,6 +77,9 @@ static void vm_cgroup_do_uncharge(struct vm_cgroup *vmcg,
 {
 	unsigned long val = nr_pages << PAGE_SHIFT;
 
+	if (vm_cgroup_is_root(vmcg))
+		return;
+
 	res_counter_uncharge(&vmcg->res, val);
 }
 
@@ -159,6 +166,9 @@ static u64 vm_cgroup_read_u64(struct cgroup_subsys_state *css,
 	struct vm_cgroup *vmcg = vm_cgroup_from_css(css);
 	int memb = cft->private;
 
+	if (vm_cgroup_is_root(vmcg))
+		return vm_memory_committed() << PAGE_SHIFT;
+
 	return res_counter_read_u64(&vmcg->res, memb);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
