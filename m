Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1228E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:08:11 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so7144930pga.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:08:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z188sor53812003pgb.42.2019.01.10.14.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:08:09 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH v2 2/5] kernel: cgroup: add poll file operation
Date: Thu, 10 Jan 2019 14:07:15 -0800
Message-Id: <20190110220718.261134-3-surenb@google.com>
In-Reply-To: <20190110220718.261134-1-surenb@google.com>
References: <20190110220718.261134-1-surenb@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>

From: Johannes Weiner <hannes@cmpxchg.org>

Cgroup has a standardized poll/notification mechanism for waking all
pollers on all fds when a filesystem node changes. To allow polling
for custom events, add a .poll callback that can override the default.

This is in preparation for pollable cgroup pressure files which have
per-fd trigger configurations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 include/linux/cgroup-defs.h |  4 ++++
 kernel/cgroup/cgroup.c      | 12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 5e1694fe035b..6f9ea8601421 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -32,6 +32,7 @@ struct kernfs_node;
 struct kernfs_ops;
 struct kernfs_open_file;
 struct seq_file;
+struct poll_table_struct;
 
 #define MAX_CGROUP_TYPE_NAMELEN 32
 #define MAX_CGROUP_ROOT_NAMELEN 64
@@ -573,6 +574,9 @@ struct cftype {
 	ssize_t (*write)(struct kernfs_open_file *of,
 			 char *buf, size_t nbytes, loff_t off);
 
+	__poll_t (*poll)(struct kernfs_open_file *of,
+			 struct poll_table_struct *pt);
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	struct lock_class_key	lockdep_key;
 #endif
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 7a8429f8e280..3f533f95acdc 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3499,6 +3499,16 @@ static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
 	return ret ?: nbytes;
 }
 
+static __poll_t cgroup_file_poll(struct kernfs_open_file *of, poll_table *pt)
+{
+	struct cftype *cft = of->kn->priv;
+
+	if (cft->poll)
+		return cft->poll(of, pt);
+
+	return kernfs_generic_poll(of, pt);
+}
+
 static void *cgroup_seqfile_start(struct seq_file *seq, loff_t *ppos)
 {
 	return seq_cft(seq)->seq_start(seq, ppos);
@@ -3537,6 +3547,7 @@ static struct kernfs_ops cgroup_kf_single_ops = {
 	.open			= cgroup_file_open,
 	.release		= cgroup_file_release,
 	.write			= cgroup_file_write,
+	.poll			= cgroup_file_poll,
 	.seq_show		= cgroup_seqfile_show,
 };
 
@@ -3545,6 +3556,7 @@ static struct kernfs_ops cgroup_kf_ops = {
 	.open			= cgroup_file_open,
 	.release		= cgroup_file_release,
 	.write			= cgroup_file_write,
+	.poll			= cgroup_file_poll,
 	.seq_start		= cgroup_seqfile_start,
 	.seq_next		= cgroup_seqfile_next,
 	.seq_stop		= cgroup_seqfile_stop,
-- 
2.20.1.97.g81188d93c3-goog
