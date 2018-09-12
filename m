Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDCC8E0008
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:06 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id m9-v6so3135630ybm.20
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:06 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 191-v6si528277ybt.587.2018.09.12.13.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:04 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 5/6] File /proc/<pid>/numa_vamaps access needs PTRACE_MODE_READ_REALCREDS check
Date: Wed, 12 Sep 2018 13:24:03 -0700
Message-Id: <1536783844-4145-6-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

Permission to access /proc/<pid>/numa_vamaps file should be governed by
PTRACE_READ_REALCREADS check to restrict getting specific VA range to numa
node mapping information.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 fs/proc/base.c     | 4 +++-
 fs/proc/task_mmu.c | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1af99ae..3c19a55 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -745,7 +745,9 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 	struct mm_struct *mm = ERR_PTR(-ESRCH);
 
 	if (task) {
-		mm = mm_access(task, mode | PTRACE_MODE_FSCREDS);
+		if (!(mode & PTRACE_MODE_REALCREDS))
+			mode |= PTRACE_MODE_FSCREDS;
+		mm = mm_access(task, mode);
 		put_task_struct(task);
 
 		if (!IS_ERR_OR_NULL(mm)) {
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 93dce46..30b29d2 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -2043,7 +2043,7 @@ static int numa_vamaps_open(struct inode *inode, struct file *file)
 	if (!nvm)
 		return -ENOMEM;
 
-	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	mm = proc_mem_open(inode, PTRACE_MODE_READ | PTRACE_MODE_REALCREDS);
 	if (IS_ERR(mm)) {
 		kfree(nvm);
 		return PTR_ERR(mm);
-- 
2.7.4
