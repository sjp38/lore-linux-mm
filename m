Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE9A8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BE5B20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BE5B20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE2618E00C7; Thu, 21 Feb 2019 18:50:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C92E08E00B5; Thu, 21 Feb 2019 18:50:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B81538E00C7; Thu, 21 Feb 2019 18:50:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 742F28E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f5so324914pgh.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=c2nnTu8a9kXCHgnsdlQMzxixfmI/LTHdM4n5jWyrqqo=;
        b=jdbzs8BKEfPoRyqvekmzjKQiFeHYjMsYepSCaRAzI47Voo6cWcjCLGnUL4gQ+/VDmZ
         2cE9Un0x9kXi+cxf9B5Z9j7++LNScurIS0v8T20NtHF7dDAZMS/84XhIhwGNQBhEjUZh
         qbGukro7t2vbKyHkKtr+mZNkbhBVgEArU5HwVIfp3QRXNzLZRZGJDp12YIQYC9yt22/9
         4sturO1d3EmzvQeNCngUxkywwTPYgxWoiT6wTIfo7JMKdvVFE5FrWEu43bjYM6O+m40M
         nuVMTw7Gg5OgiqpyIeusBlHSwBQj5Iv75u7lAcPoQMX5wo+BowYjP20oH5cEnXMNFoZH
         ZItg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ8sZPYpQc+pozHQxRnqBRE+q6qA266Gk4yn5MQJBaDigkMMzkD
	nwZ77l47icig7vvLWp75RkFvQPlj0QOm+3lQwZBlGMgaIgnbzugJDrN5JtpZYJuu3ZO/qHkaajU
	SHE5iAVffii+we5eUD/U8OwUfduqu8tqDN24DJywNVjp/WBwYiyBCArwwGacHyICREw==
X-Received: by 2002:a17:902:7405:: with SMTP id g5mr1205987pll.230.1550793058141;
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYt/tzgxcU52gLy3kO1RHqa0WWOOOavtEwD5IohD1lrUeFyDpm7QJt4xoaXlF7pwMdyvaKk
X-Received: by 2002:a17:902:7405:: with SMTP id g5mr1205944pll.230.1550793057202;
        Thu, 21 Feb 2019 15:50:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793057; cv=none;
        d=google.com; s=arc-20160816;
        b=aI2i1hjXZkEQKrCXAbUg4bLdrRxs88OJ5w+Ifj3NZXSs8Lx3xmEhYl9RZqWn2klaxt
         Zrkf+Wv9xI8+jTZhrr/7zLHbS9DVNMrJENz+f1TJ2zCP9Kmfp3tAjNPy+mAz+nu42B/t
         OdP3u1zgTgxYpdZ5jH35pw6hs3ufyDdm40ErxMBxOCrAsz/2NX6lvkegwxPZpxp1zvYs
         A83e/BEVhB+1/7rqywBHoisUQ7PjVOD/aMjD5y8lts4cOnMHxbmJjN2X5aGB2ZMuM0k8
         cUtkULsYzlKuOmsgkOXdMvC2NqVSIR838HQcujoPPltfxHgIeu37XJwafJTG5/oiazoq
         Ec5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=c2nnTu8a9kXCHgnsdlQMzxixfmI/LTHdM4n5jWyrqqo=;
        b=iuwxZVq5LI4J0nvdX421qQmIUhPUe9QSGm10uP3a4HjuVrAhKNnT3iI9MF5H5CF1Zz
         ELuro+gmU8rq4zV5Qsr/4GPyQb2NxY24UL0+Wv6h6bkXLuv+c8QpHMXEi6E6nUbD0Y2y
         0TQTeb+2PzVqrDV0QJbBByB3hFqXlM/tCk53Zy+e3ix3bOYOidlm1zOj3Ajnn9RwNx5a
         DeSV67f74rJwQ/YEr7r6RKHIh84gY0arxoNHBLveS3bPjt4zDCvEH0QiRS9eN7XYwVCs
         IFOpdadF+l16KiSa5UoOD1tp6e1KQDqhtYWkLHoZwWTaQcF3rb7vv8mf8g5RpGv/qH7l
         QNQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:57 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:56 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394821"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:55 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 04/20] fork: Provide a function for copying init_mm
Date: Thu, 21 Feb 2019 15:44:35 -0800
Message-Id: <20190221234451.17632-5-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Provide a function for copying init_mm. This function will be later used
for setting a temporary mm.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/sched/task.h |  1 +
 kernel/fork.c              | 24 ++++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index 44c6f15800ff..c5a00a7b3beb 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -76,6 +76,7 @@ extern void exit_itimers(struct signal_struct *);
 extern long _do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *, unsigned long);
 extern long do_fork(unsigned long, unsigned long, unsigned long, int __user *, int __user *);
 struct task_struct *fork_idle(int);
+struct mm_struct *copy_init_mm(void);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
 extern long kernel_wait4(pid_t, int __user *, int, struct rusage *);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index b69248e6f0e0..1b43753c1884 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1299,13 +1299,20 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 		complete_vfork_done(tsk);
 }
 
-/*
- * Allocate a new mm structure and copy contents from the
- * mm structure of the passed in task structure.
+/**
+ * dup_mm() - duplicates an existing mm structure
+ * @tsk: the task_struct with which the new mm will be associated.
+ * @oldmm: the mm to duplicate.
+ *
+ * Allocates a new mm structure and duplicates the provided @oldmm structure
+ * content into it.
+ *
+ * Return: the duplicated mm or NULL on failure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+static struct mm_struct *dup_mm(struct task_struct *tsk,
+				struct mm_struct *oldmm)
 {
-	struct mm_struct *mm, *oldmm = current->mm;
+	struct mm_struct *mm;
 	int err;
 
 	mm = allocate_mm();
@@ -1372,7 +1379,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	}
 
 	retval = -ENOMEM;
-	mm = dup_mm(tsk);
+	mm = dup_mm(tsk, current->mm);
 	if (!mm)
 		goto fail_nomem;
 
@@ -2187,6 +2194,11 @@ struct task_struct *fork_idle(int cpu)
 	return task;
 }
 
+struct mm_struct *copy_init_mm(void)
+{
+	return dup_mm(NULL, &init_mm);
+}
+
 /*
  *  Ok, this is the main fork-routine.
  *
-- 
2.17.1

