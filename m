Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 28FE86B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:59:09 -0400 (EDT)
Message-ID: <5212E948.8000401@asianux.com>
Date: Tue, 20 Aug 2013 11:58:00 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] fs/proc/task_mmu.c: check the return value of mpol_to_str()
References: <5212E8DF.5020209@asianux.com> <5212E910.7030609@asianux.com>
In-Reply-To: <5212E910.7030609@asianux.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, Cyrill Gorcunov <gorcunov@openvz.org>, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>hughd@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

mpol_to_str() may fail, and not fill the buffer (e.g. -EINVAL), so need
check about it, or buffer may not be zero based, and next seq_printf()
will cause issue.

Also print related warning when the buffer space is not enough.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 fs/proc/task_mmu.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index a117207..1cb7445 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1359,7 +1359,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
 	struct mempolicy *pol;
-	int n;
+	int n, ret;
 	char buffer[50];
 
 	if (!mm)
@@ -1376,7 +1376,19 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	walk.mm = mm;
 
 	pol = get_vma_policy(task, vma, vma->vm_start);
-	mpol_to_str(buffer, sizeof(buffer), pol);
+	ret = mpol_to_str(buffer, sizeof(buffer), pol);
+	if (ret < 0)
+		switch (ret) {
+		case -ENOSPC:
+			pr_warn("in %s: string is truncated in mpol_to_str().\n",
+				__func__);
+			break;
+		default:
+			pr_err("in %s: call mpol_to_str() fail, errcode: %d. buffer: %p, size: %zu,  pol: %p\n",
+				__func__, ret, buffer, sizeof(buffer), pol);
+			return ret;
+		}
+
 	mpol_cond_put(pol);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
