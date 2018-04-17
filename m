Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B68E6B000C
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d37so14930654wrd.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:33:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x23si2244965edl.83.2018.04.16.21.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 21:33:41 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H4Tugv029702
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:40 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hd67y06cb-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:39 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 05:33:37 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v3 3/9] Uprobe: Move mmput() into free_map_info()
Date: Tue, 17 Apr 2018 10:02:38 +0530
In-Reply-To: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180417043244.7501-4-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

From: Oleg Nesterov <oleg@redhat.com>

build_map_info() has a side effect like one need to perform
mmput() when done with the mm. Add mmput() in free_map_info()
so that user does not have to call it explicitly.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
---
 kernel/events/uprobes.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 535fd39..1d439c7 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -704,6 +704,7 @@ struct map_info {
 static inline struct map_info *free_map_info(struct map_info *info)
 {
 	struct map_info *next = info->next;
+	mmput(info->mm);
 	kfree(info);
 	return next;
 }
@@ -773,8 +774,11 @@ static inline struct map_info *free_map_info(struct map_info *info)
 
 	goto again;
  out:
-	while (prev)
-		prev = free_map_info(prev);
+	while (prev) {
+		info = prev;
+		prev = prev->next;
+		kfree(info);
+	}
 	return curr;
 }
 
@@ -824,7 +828,6 @@ static inline struct map_info *free_map_info(struct map_info *info)
  unlock:
 		up_write(&mm->mmap_sem);
  free:
-		mmput(mm);
 		info = free_map_info(info);
 	}
  out:
-- 
1.8.3.1
