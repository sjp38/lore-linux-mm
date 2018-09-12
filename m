Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70BBC8E0005
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:05 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e62-v6so5429744itb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:05 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b62-v6si1616292iti.112.2018.09.12.13.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:04 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 4/6] Add support to lseek /proc/<pid>/numa_vamaps file
Date: Wed, 12 Sep 2018 13:24:02 -0700
Message-Id: <1536783844-4145-5-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

Allow lseeking to a process virtual address(VA), starting from where
the address range to numa node information can be read. The lseek offset
will be the process virtual address.

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 fs/proc/task_mmu.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 1371e379..93dce46 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1866,6 +1866,27 @@ static int gather_hole_info_vamap(unsigned long start, unsigned long end,
 	return 0;
 }
 
+static loff_t numa_vamaps_llseek(struct file *file, loff_t offset, int orig)
+{
+	struct numa_vamaps_private *nvm = file->private_data;
+
+	if (orig == SEEK_CUR && offset < 0 && nvm->vm_start < -offset)
+		return -EINVAL;
+
+	switch (orig) {
+	case SEEK_SET:
+		nvm->vm_start = offset & PAGE_MASK;
+		break;
+	case SEEK_CUR:
+		nvm->vm_start += offset;
+		nvm->vm_start = nvm->vm_start & PAGE_MASK;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return nvm->vm_start;
+}
+
 static int vamap_vprintf(struct numa_vamaps_private *nvm, const char *f, ...)
 {
 	va_list args;
@@ -2052,7 +2073,7 @@ const struct file_operations proc_pid_numa_maps_operations = {
 const struct file_operations proc_numa_vamaps_operations = {
 	.open		= numa_vamaps_open,
 	.read		= numa_vamaps_read,
-	.llseek		= noop_llseek,
+	.llseek		= numa_vamaps_llseek,
 	.release	= numa_vamaps_release,
 };
 #endif /* CONFIG_NUMA */
-- 
2.7.4
