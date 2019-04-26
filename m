Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B463CC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76760208C4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76760208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3259A6B000A; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFD026B0269; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7916B000C; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 472196B000E
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so1673794pfo.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=7Md7xvkom3K5hLhPxiS37AK9ZnciGjjzxPUMmpNJC18=;
        b=dfAmGzxZnius6IVGxWILeFsDz7y1mRrqxIqYnmkstAfhLUZnGsqYw4pbkx6swqG2yr
         tXGvxgmdiYlwh/x7oOOSav/acKRxfPYevHihkQ8urFpn5WfkjlqVyMrBK7hU4RfRxmMW
         F2IZUokXQhavOmCVhiXD5mOJLOEJ5prhIspemcGGnttlB5bCGyiT//7NMJxXspptNe/y
         UYvdsTXMP2EPOJpBgwUrWzAKBBz+z5yDoDTS7yzq+Nal1zzppFrrXZKNrPWINqhKRVx2
         hXBXzHECEyyQ+b0WZKZYDjqzt83wFrmTYe5h38/ShCsbp5YBh+mX/nX5c2yReAmw+dea
         3erg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXD+x1Lmr237k0v95q+/Qr8P4S9sxYHgCZK0TvT6deLRKWVQw2c
	UJkI1hN6Agu+tLAdONqXzOOPthQ6Rhv0hEWfFAiqwu5hL3QkazylbUKA14Zua+gIJM31CbVntDa
	TOLBEHo19nyc1HvCKVbo9D4rLxbNpcixl/xi+6HeHxQpw7GZGcQ7Jtx1/k0IcPT4YHw==
X-Received: by 2002:a17:902:5a0a:: with SMTP id q10mr4449803pli.101.1556263907926;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyehdSxn3q/nvH7dd3PEarUeZL+IdOWjQTIoTRM2NDXoHrtcO6ehnODm8K9bFAb3Oc22FMR
X-Received: by 2002:a17:902:5a0a:: with SMTP id q10mr4449709pli.101.1556263906766;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=VnXSr0jo79lSwDDC7yk+JCojLj/m/1XHBRlkIsU/CJ5R5yAmpUA9EjabbdOH4bmiIJ
         t3ZRDrMHfzoqMWK04Pi3/Sg+Kc9lhWPw1QU27DHMQfAA1PAoZ7Q3xOq+R/FhKiIDVMMk
         IpHtrqvHEhS52IA0mOgKIkaxs8i8cuogxIzpZIUtvKpvHpDAYK+3ZfzTT5XugfIas9pP
         EHK+YMVANZY9gsd/glHnQCIvljMHkUvDnpjv4pr2vlDUvcFVo9zU60240d2U4mRuIARC
         xTBA4OsvVFFf3FUinA5A5ZkX+zhf5QcTlzkAfn+eIt2vWO80rcGmfxCcKycpG3LIUIhA
         kpUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=7Md7xvkom3K5hLhPxiS37AK9ZnciGjjzxPUMmpNJC18=;
        b=WNcoU9sr/guP2j3BE8H7jynGJUCwxvrOXjwtqol5w9viBNBURFkiCZSsvB7u1wr0xO
         hlp/WQC9L3+HR3YKdO3prSy1Q1M7tatW72cm15WyJnT3mYQzeDE+r7qULttB9dJcHv9T
         iDItOUqPtvhqW/XBVd4kdcbqiJ0TjYF2S+anD56ZnKAP+0/k9zF8bQiwkf4mjmxQtE6B
         98fE5v37kRawtJ0QdL4jV4FEODmxzgA13hnLT0clAV2cQe9vUOziayPgxab+v4w2V5T/
         J++EBBBNiN560XOFSLW7abJIYX8IqCLfssccUHAixFhLpoEdwFxYRrleKUIe1uoaTfym
         iVDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 87E8C41298;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Kees Cook
	<keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>
Subject: [PATCH v5 05/23] fork: Provide a function for copying init_mm
Date: Thu, 25 Apr 2019 17:11:25 -0700
Message-ID: <20190426001143.4983-6-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index 2e97a2227045..f1227f2c38a4 100644
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
index 9dcd18aa210b..099cca8f701c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1298,13 +1298,20 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
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
@@ -1371,7 +1378,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	}
 
 	retval = -ENOMEM;
-	mm = dup_mm(tsk);
+	mm = dup_mm(tsk, current->mm);
 	if (!mm)
 		goto fail_nomem;
 
@@ -2186,6 +2193,11 @@ struct task_struct *fork_idle(int cpu)
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

