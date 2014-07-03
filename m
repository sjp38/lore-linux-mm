Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD206B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:49:09 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so122958lan.30
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:49:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id u3si7116234laj.24.2014.07.03.05.49.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:49:08 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 1/5] vm_cgroup: basic infrastructure
Date: Thu, 3 Jul 2014 16:48:17 +0400
Message-ID: <5169989c3d82823f9675f00152c8bf28f91ab890.1404383187.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

This patch introduces the vm cgroup to control address space expansion
of tasks that belong to a cgroup. The idea is to provide a mechanism to
limit memory overcommit not only for the whole system, but also on per
cgroup basis.

This patch only adds some basic cgroup methods, like alloc/free and
write/read, while the real accounting/limiting is done in the following
patches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/cgroup_subsys.h |    4 ++
 include/linux/vm_cgroup.h     |   18 ++++++
 init/Kconfig                  |    4 ++
 mm/Makefile                   |    1 +
 mm/vm_cgroup.c                |  131 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 158 insertions(+)
 create mode 100644 include/linux/vm_cgroup.h
 create mode 100644 mm/vm_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 98c4f9b12b03..8eb7db12f6ea 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -47,6 +47,10 @@ SUBSYS(net_prio)
 SUBSYS(hugetlb)
 #endif
 
+#if IS_ENABLED(CONFIG_CGROUP_VM)
+SUBSYS(vm)
+#endif
+
 /*
  * The following subsystems are not supported on the default hierarchy.
  */
diff --git a/include/linux/vm_cgroup.h b/include/linux/vm_cgroup.h
new file mode 100644
index 000000000000..b629c9affa4b
--- /dev/null
+++ b/include/linux/vm_cgroup.h
@@ -0,0 +1,18 @@
+#ifndef _LINUX_VM_CGROUP_H
+#define _LINUX_VM_CGROUP_H
+
+#ifdef CONFIG_CGROUP_VM
+static inline bool vm_cgroup_disabled(void)
+{
+	if (vm_cgrp_subsys.disabled)
+		return true;
+	return false;
+}
+#else /* !CONFIG_CGROUP_VM */
+static inline bool vm_cgroup_disabled(void)
+{
+	return true;
+}
+#endif /* CONFIG_CGROUP_VM */
+
+#endif /* _LINUX_VM_CGROUP_H */
diff --git a/init/Kconfig b/init/Kconfig
index 9d76b99af1b9..4419835bea7c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1008,6 +1008,10 @@ config MEMCG_KMEM
 	  unusable in real life so DO NOT SELECT IT unless for development
 	  purposes.
 
+config CGROUP_VM
+	bool "Virtual Memory Resource Controller for Control Groups"
+	default n
+
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
diff --git a/mm/Makefile b/mm/Makefile
index 4064f3ec145e..914520d2669f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -52,6 +52,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
+obj-$(CONFIG_CGROUP_VM) += vm_cgroup.o
 obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
diff --git a/mm/vm_cgroup.c b/mm/vm_cgroup.c
new file mode 100644
index 000000000000..7f5b81482748
--- /dev/null
+++ b/mm/vm_cgroup.c
@@ -0,0 +1,131 @@
+#include <linux/cgroup.h>
+#include <linux/res_counter.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/vm_cgroup.h>
+
+struct vm_cgroup {
+	struct cgroup_subsys_state css;
+
+	/*
+	 * The counter to account for vm usage.
+	 */
+	struct res_counter res;
+};
+
+static struct vm_cgroup *root_vm_cgroup __read_mostly;
+
+static inline bool vm_cgroup_is_root(struct vm_cgroup *vmcg)
+{
+	return vmcg == root_vm_cgroup;
+}
+
+static struct vm_cgroup *vm_cgroup_from_css(struct cgroup_subsys_state *s)
+{
+	return s ? container_of(s, struct vm_cgroup, css) : NULL;
+}
+
+static struct cgroup_subsys_state *
+vm_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
+{
+	struct vm_cgroup *parent = vm_cgroup_from_css(parent_css);
+	struct vm_cgroup *vmcg;
+
+	vmcg = kzalloc(sizeof(*vmcg), GFP_KERNEL);
+	if (!vmcg)
+		return ERR_PTR(-ENOMEM);
+
+	res_counter_init(&vmcg->res, parent ? &parent->res : NULL);
+
+	if (!parent)
+		root_vm_cgroup = vmcg;
+
+	return &vmcg->css;
+}
+
+static void vm_cgroup_css_free(struct cgroup_subsys_state *css)
+{
+	struct vm_cgroup *vmcg = vm_cgroup_from_css(css);
+
+	kfree(vmcg);
+}
+
+static u64 vm_cgroup_read_u64(struct cgroup_subsys_state *css,
+			      struct cftype *cft)
+{
+	struct vm_cgroup *vmcg = vm_cgroup_from_css(css);
+	int memb = cft->private;
+
+	return res_counter_read_u64(&vmcg->res, memb);
+}
+
+static ssize_t vm_cgroup_write(struct kernfs_open_file *of,
+			       char *buf, size_t nbytes, loff_t off)
+{
+	struct vm_cgroup *vmcg = vm_cgroup_from_css(of_css(of));
+	unsigned long long val;
+	int ret;
+
+	if (vm_cgroup_is_root(vmcg))
+		return -EINVAL;
+
+	buf = strstrip(buf);
+	ret = res_counter_memparse_write_strategy(buf, &val);
+	if (ret)
+		return ret;
+
+	ret = res_counter_set_limit(&vmcg->res, val);
+	return ret ?: nbytes;
+}
+
+static ssize_t vm_cgroup_reset(struct kernfs_open_file *of, char *buf,
+			       size_t nbytes, loff_t off)
+{
+	struct vm_cgroup *vmcg= vm_cgroup_from_css(of_css(of));
+	int memb = of_cft(of)->private;
+
+	switch (memb) {
+	case RES_MAX_USAGE:
+		res_counter_reset_max(&vmcg->res);
+		break;
+	case RES_FAILCNT:
+		res_counter_reset_failcnt(&vmcg->res);
+		break;
+	default:
+		BUG();
+	}
+	return nbytes;
+}
+
+static struct cftype vm_cgroup_files[] = {
+	{
+		.name = "usage_in_bytes",
+		.private = RES_USAGE,
+		.read_u64 = vm_cgroup_read_u64,
+	},
+	{
+		.name = "max_usage_in_bytes",
+		.private = RES_MAX_USAGE,
+		.write = vm_cgroup_reset,
+		.read_u64 = vm_cgroup_read_u64,
+	},
+	{
+		.name = "limit_in_bytes",
+		.private = RES_LIMIT,
+		.write = vm_cgroup_write,
+		.read_u64 = vm_cgroup_read_u64,
+	},
+	{
+		.name = "failcnt",
+		.private = RES_FAILCNT,
+		.write = vm_cgroup_reset,
+		.read_u64 = vm_cgroup_read_u64,
+	},
+	{ },	/* terminate */
+};
+
+struct cgroup_subsys vm_cgrp_subsys = {
+	.css_alloc = vm_cgroup_css_alloc,
+	.css_free = vm_cgroup_css_free,
+	.base_cftypes = vm_cgroup_files,
+};
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
