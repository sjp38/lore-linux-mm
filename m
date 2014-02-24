Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id AD5546B011C
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 18:28:10 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id z12so5305069wgg.5
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 15:28:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hu4si16594360wjb.92.2014.02.24.15.28.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 15:28:09 -0800 (PST)
From: Alexander Graf <agraf@suse.de>
Subject: [PATCH] ksm: Expose configuration via sysctl
Date: Tue, 25 Feb 2014 00:28:04 +0100
Message-Id: <1393284484-27637-1-git-send-email-agraf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

Configuration of tunables and Linux virtual memory settings has traditionally
happened via sysctl. Thanks to that there are well established ways to make
sysctl configuration bits persistent (sysctl.conf).

KSM introduced a sysfs based configuration path which is not covered by user
space persistent configuration frameworks.

In order to make life easy for sysadmins, this patch adds all access to all
KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
giving us a streamlined way to make KSM configuration persistent.

Reported-by: Sasche Peilicke <speilicke@suse.com>
Signed-off-by: Alexander Graf <agraf@suse.de>
---
 kernel/sysctl.c |   10 +++++++
 mm/ksm.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 332cefc..2169a00 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -217,6 +217,9 @@ extern struct ctl_table random_table[];
 #ifdef CONFIG_EPOLL
 extern struct ctl_table epoll_table[];
 #endif
+#ifdef CONFIG_KSM
+extern struct ctl_table ksm_table[];
+#endif
 
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
 int sysctl_legacy_va_layout;
@@ -1279,6 +1282,13 @@ static struct ctl_table vm_table[] = {
 	},
 
 #endif /* CONFIG_COMPACTION */
+#ifdef CONFIG_KSM
+	{
+		.procname	= "ksm",
+		.mode		= 0555,
+		.child		= ksm_table,
+	},
+#endif
 	{
 		.procname	= "min_free_kbytes",
 		.data		= &min_free_kbytes,
diff --git a/mm/ksm.c b/mm/ksm.c
index 3df141e..df93989 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2306,6 +2306,84 @@ static struct attribute_group ksm_attr_group = {
 };
 #endif /* CONFIG_SYSFS */
 
+#ifdef CONFIG_SYSCTL
+static int fill_from_user(char *buf, char __user *ubuf, size_t len)
+{
+	if (len > 15)
+		return -EINVAL;
+
+	if (copy_from_user(buf, ubuf, len))
+		return -EFAULT;
+
+	buf[len] = 0;
+	return 0;
+}
+
+static int sysctl_ksm(struct ctl_table *ctl, int write, void __user *buffer,
+		      size_t *lenp, loff_t *fpos)
+{
+	int r;
+	char buf[16];
+
+	if (!write)
+		return proc_dointvec(ctl, write, buffer, lenp, fpos);
+
+	r = fill_from_user(buf, buffer, *lenp);
+	if (r)
+		return r;
+
+	if (ctl->data == &ksm_run)
+		r = run_store(NULL, NULL, buf, *lenp);
+	else if (ctl->data == &ksm_thread_sleep_millisecs)
+		r = sleep_millisecs_store(NULL, NULL, buf, *lenp);
+	else if (ctl->data == &ksm_thread_pages_to_scan)
+		r = pages_to_scan_store(NULL, NULL, buf, *lenp);
+#ifdef CONFIG_NUMA
+	else if (ctl->data == &ksm_merge_across_nodes)
+		r = merge_across_nodes_store(NULL, NULL, buf, *lenp);
+#endif
+	else
+		r = -EINVAL;
+
+	return r;
+}
+
+struct ctl_table ksm_table[] =
+{
+	{
+		.procname	= "run",
+		.data		= &ksm_run,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_ksm,
+	},
+	{
+		.procname	= "sleep_millisecs",
+		.data		= &ksm_thread_sleep_millisecs,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_ksm,
+	},
+	{
+		.procname	= "pages_to_scan",
+		.data		= &ksm_thread_pages_to_scan,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_ksm,
+	},
+#ifdef CONFIG_NUMA
+	{
+		.procname	= "merge_across_nodes",
+		.data		= &ksm_merge_across_nodes,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= sysctl_ksm,
+	},
+#endif /* CONFIG_NUMA */
+	{ }
+};
+#endif /* CONFIG_SYSCTL */
+
 static int __init ksm_init(void)
 {
 	struct task_struct *ksm_thread;
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
