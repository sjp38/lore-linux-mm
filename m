Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF9C98E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 10:35:47 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id p20so12497225ywe.5
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 07:35:47 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z4si32920054ybz.42.2019.01.04.07.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 07:35:46 -0800 (PST)
From: Ashish Mhetre <amhetre@nvidia.com>
Subject: [PATCH] mm: Expose lazy vfree pages to control via sysctl
Date: Fri, 4 Jan 2019 21:05:41 +0530
Message-ID: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdumpa@nvidia.com, mcgrof@kernel.org, keescook@chromium.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, Snikam@nvidia.com, Ashish Mhetre <amhetre@nvidia.com>

From: Hiroshi Doyu <hdoyu@nvidia.com>

The purpose of lazy_max_pages is to gather virtual address space till it
reaches the lazy_max_pages limit and then purge with a TLB flush and hence
reduce the number of global TLB flushes.
The default value of lazy_max_pages with one CPU is 32MB and with 4 CPUs it
is 96MB i.e. for 4 cores, 96MB of vmalloc space will be gathered before it
is purged with a TLB flush.
This feature has shown random latency issues. For example, we have seen
that the kernel thread for some camera application spent 30ms in
__purge_vmap_area_lazy() with 4 CPUs.
So, create "/proc/sys/lazy_vfree_pages" file to control lazy vfree pages.
With this sysctl, the behaviour of lazy_vfree_pages can be controlled and
the systems which can't tolerate latency issues can also disable it.
This is one of the way through which lazy_vfree_pages can be controlled as
proposed in this patch. The other possible solution would be to configure
lazy_vfree_pages through kernel cmdline.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
Signed-off-by: Ashish Mhetre <amhetre@nvidia.com>
---
 kernel/sysctl.c | 8 ++++++++
 mm/vmalloc.c    | 5 ++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3ae223f..49523efc 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -111,6 +111,7 @@ extern int pid_max;
 extern int pid_max_min, pid_max_max;
 extern int percpu_pagelist_fraction;
 extern int latencytop_enabled;
+extern int sysctl_lazy_vfree_pages;
 extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
 #ifndef CONFIG_MMU
 extern int sysctl_nr_trim_pages;
@@ -1251,6 +1252,13 @@ static struct ctl_table kern_table[] = {
 
 static struct ctl_table vm_table[] = {
 	{
+		.procname	= "lazy_vfree_pages",
+		.data		= &sysctl_lazy_vfree_pages,
+		.maxlen		= sizeof(sysctl_lazy_vfree_pages),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "overcommit_memory",
 		.data		= &sysctl_overcommit_memory,
 		.maxlen		= sizeof(sysctl_overcommit_memory),
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 97d4b25..fa07966 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -619,13 +619,16 @@ static void unmap_vmap_area(struct vmap_area *va)
  * code, and it will be simple to change the scale factor if we find that it
  * becomes a problem on bigger systems.
  */
+
+int sysctl_lazy_vfree_pages = 32UL * 1024 * 1024 / PAGE_SIZE;
+
 static unsigned long lazy_max_pages(void)
 {
 	unsigned int log;
 
 	log = fls(num_online_cpus());
 
-	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
+	return log * sysctl_lazy_vfree_pages;
 }
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
-- 
2.7.4
