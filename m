Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE348E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:36:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so5885696edm.20
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:36:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor8087632edd.12.2018.12.11.06.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:36:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
Date: Tue, 11 Dec 2018 15:36:41 +0100
Message-Id: <20181211143641.3503-4-mhocko@kernel.org>
In-Reply-To: <20181211143641.3503-1-mhocko@kernel.org>
References: <20181211143641.3503-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

David Rientjes has reported that 1860033237d4 ("mm: make
PR_SET_THP_DISABLE immediately active") has changed the way how
we report THPable VMAs to the userspace. Their monitoring tool is
triggering false alarms on PR_SET_THP_DISABLE tasks because it considers
an insufficient THP usage as a memory fragmentation resp. memory
pressure issue.

Before the said commit each newly created VMA inherited VM_NOHUGEPAGE
flag and that got exposed to the userspace via /proc/<pid>/smaps file.
This implementation had its downsides as explained in the commit message
but it is true that the userspace doesn't have any means to query for
the process wide THP enabled/disabled status.

PR_SET_THP_DISABLE is a process wide flag so it makes a lot of sense
to export in the process wide context rather than per-vma. Introduce
a new field to /proc/<pid>/status which export this status.  If
PR_SET_THP_DISABLE is used then it reports false same as when the THP is
not compiled in. It doesn't consider the global THP status because we
already export that information via sysfs

Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/filesystems/proc.txt |  3 +++
 fs/proc/array.c                    | 10 ++++++++++
 2 files changed, 13 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index cd465304bec4..b24fd9bccc99 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -182,6 +182,7 @@ For example, to get the status information of a process, all you have to do is
   VmSwap:        0 kB
   HugetlbPages:          0 kB
   CoreDumping:    0
+  THP_enabled:	  1
   Threads:        1
   SigQ:   0/28578
   SigPnd: 0000000000000000
@@ -256,6 +257,8 @@ Table 1-2: Contents of the status files (as of 4.8)
  HugetlbPages                size of hugetlb memory portions
  CoreDumping                 process's memory is currently being dumped
                              (killing the process may lead to a corrupted core)
+ THP_enabled		     process is allowed to use THP (returns 0 when
+			     PR_SET_THP_DISABLE is set on the process
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
  SigPnd                      bitmap of pending signals for the thread
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 0ceb3b6b37e7..9d428d5a0ac8 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -392,6 +392,15 @@ static inline void task_core_dumping(struct seq_file *m, struct mm_struct *mm)
 	seq_putc(m, '\n');
 }
 
+static inline void task_thp_status(struct seq_file *m, struct mm_struct *mm)
+{
+	bool thp_enabled = IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE);
+
+	if (thp_enabled)
+		thp_enabled = !test_bit(MMF_DISABLE_THP, &mm->flags);
+	seq_printf(m, "THP_enabled:\t%d\n", thp_enabled);
+}
+
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
@@ -406,6 +415,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 	if (mm) {
 		task_mem(m, mm);
 		task_core_dumping(m, mm);
+		task_thp_status(m, mm);
 		mmput(mm);
 	}
 	task_sig(m, task);
-- 
2.19.2
