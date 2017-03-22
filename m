Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1B8D6B0333
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 23:38:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n11so174560821pfg.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 20:38:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x15si152856pgc.190.2017.03.21.20.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 20:38:22 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2M3T7eY060753
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 23:38:21 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29b9vn2juc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 23:38:20 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 21 Mar 2017 21:38:20 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V5 16/17] mm: Let arch choose the initial value of task size
Date: Wed, 22 Mar 2017 09:07:02 +0530
In-Reply-To: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1490153823-29241-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1490153823-29241-17-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

As we start supporting larger address space (>128TB), we want to give
architecture a control on max task size of an application which is different
from the TASK_SIZE. For ex: ppc64 needs to track the base page size of a segment
and it is copied from mm_context_t to PACA on each context switch. If we know that
application has not used an address range above 128TB we only need to copy
details about 128TB range to PACA. This will help in improving context switch
performance by avoiding larger copy operation.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/exec.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index 65145a3df065..5550a56d03c3 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1308,6 +1308,14 @@ void would_dump(struct linux_binprm *bprm, struct file *file)
 }
 EXPORT_SYMBOL(would_dump);
 
+#ifndef arch_init_task_size
+static inline void arch_init_task_size(void)
+{
+	current->mm->task_size = TASK_SIZE;
+}
+#define arch_init_task_size arch_init_task_size
+#endif
+
 void setup_new_exec(struct linux_binprm * bprm)
 {
 	arch_pick_mmap_layout(current->mm);
@@ -1327,7 +1335,7 @@ void setup_new_exec(struct linux_binprm * bprm)
 	 * depend on TIF_32BIT which is only updated in flush_thread() on
 	 * some architectures like powerpc
 	 */
-	current->mm->task_size = TASK_SIZE;
+	arch_init_task_size();
 
 	/* install the new credentials */
 	if (!uid_eq(bprm->cred->uid, current_euid()) ||
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
