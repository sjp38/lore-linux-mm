Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85E4AC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45EB4214C6
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dLUUcPuc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45EB4214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 491896B000D; Sat, 27 Apr 2019 02:43:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 417C96B000E; Sat, 27 Apr 2019 02:43:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292916B0010; Sat, 27 Apr 2019 02:43:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2B8F6B000D
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:13 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a141so1877347pfa.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=PqX9u33LMatWrF2rdzOLAo8PTOZ3S7r/OUOEdwJc/wY=;
        b=bBjkvi6cSBcHFF5q+MuxOePWH2MW63t4/XLoRmYru1jIgsfZQVGUTaNY1jDqNOsU6g
         iTbzRixBnbBp3b3TcKRcu/eSYSifXfUp6hNo5O4AxOW+bt7ufqwANbKfk0q1mONTWcCh
         Dk4HfBFS51SwaaZnB04SLed2g1e5ggKNJgI5DmlgBN3AeOxfZGX1+DkyAa7lzR+kM1at
         XHTbbnU9nZetoY5C+jPsy80QVeT5uTnPLys76i0Q0+wcoRhDqxuWDp07DLI41yfYoepN
         Mdzwv1iWQPS8EVrjLTEa5DPdKHUzD9ZdRYfsRT61DX4nMfo6+zxB2AVU/Vw6XxPK1lsW
         JSwg==
X-Gm-Message-State: APjAAAXHXvKvhkLTWqjO0Q+ftv51Or3JP50ibnAdQjhuRyPa6v5PF/1F
	h1zZd0ocMlnW7/OlaLeThCMuUiCVvQScco3kUdpuHHECi+iZTrD3dKcAIeCjX8E1a6KJI6D9AT0
	PK7G4d533njqJ5B6X4frrlfA+MXcAjllwU9P6n2dYvs688ThzkSpCgBZQ8MVy4QaNRg==
X-Received: by 2002:a63:6942:: with SMTP id e63mr47115634pgc.102.1556347393603;
        Fri, 26 Apr 2019 23:43:13 -0700 (PDT)
X-Received: by 2002:a63:6942:: with SMTP id e63mr47115588pgc.102.1556347392539;
        Fri, 26 Apr 2019 23:43:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347392; cv=none;
        d=google.com; s=arc-20160816;
        b=ipZyNPV9hKHE0z7ebIX9hFgbbr9XiKI6+EcdUan70OKGyauFy8a6QVhDoaxNahplHh
         jSQ9VcF2/mTEbTGYgs3pcurYIi2l5ge6/tnSV5bwkN8jpORtrD+n6tRsVkO/mM8OJ8e6
         36tzo/1IMN6/XUZoFqNTPC8Qkblbmolz/jAVawpZzyS9FTzJypCzXGtDl2vYl6fLyZ48
         8eBNKw+1v+Tx5gAfGxareByxKeojAc2NdSqKhYQyr8M7+/dYKdow98J4CKOx+N9cobXe
         dZ20mfGF3lMg+v7aVvn2Ryrg7DKObnmdCPViYlk6Gb/cF6Fk3T0UKTtVfQKQaNJpVJrT
         YupQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=PqX9u33LMatWrF2rdzOLAo8PTOZ3S7r/OUOEdwJc/wY=;
        b=ExWfzxX1dKCiqpLrVO7azJWQPHLfBdDHy4WNjDx/N1ehL9E1jM2IfPEp5fCLt2HqDA
         /gRFDdgtXVua3+LAgP1DWj2K9QpM6spRV1+LfFsddEWDxt7I/li0Y/5LWXXWQD04H43I
         Dyq36t11RN7dk9TGTZx1FnyJHvEtJlzldj/hYlPFJ1M6y0PkacdWhW5j5Wg1sr2kBoy9
         s6K3bF7yZ/+MFgmzXRuvMdg2bsugnfnV66im5shdLejyEvIjfrkLUrlXEFf1ZEGbL9co
         aZOa4Ro+tKul2gO3kudDGT1Kc+4ipeRlZBTqf3yQpA6j7J0XZ3Bcp0Elma92+cj/ZV2Z
         psyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dLUUcPuc;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor30517841pfr.33.2019.04.26.23.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dLUUcPuc;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=PqX9u33LMatWrF2rdzOLAo8PTOZ3S7r/OUOEdwJc/wY=;
        b=dLUUcPucbWSjI0KF0GYdfa3//vc9Trf9GNL1Jxgol/lAzL/Qif+nwieAhan1enOtj9
         IEvF0toGPmi5evSU5LGqWY70kCiO3p7KKseN+96U+aK7PFiGt1LmM5YwgAU+lA6dRruQ
         txGFF06hrpSSsexZDBeyJTD8iZpafmkscb7dw3FJPuVKduR/83ccqIn9U64Bhl7mXai2
         QvPXBsrBhxIENhDIjXt5l8fioHpUH4RBLdAlGLQjejsyatNlX3PJPjeZX8AdLYgJMv+s
         txk3ENcm6pNvFPMHYkZ9djMndR8b2wvyhfIPdTbE4Wq/3iIH/ChGjSPLA1uzJUN9rbuN
         8qpw==
X-Google-Smtp-Source: APXvYqwtiOYLXN6z+omvr9q5XmanCyE26RTxB/9RLJMeynpzcv4zb2Q6alFcE2kD+WU/ILJ0eVx92Q==
X-Received: by 2002:aa7:920b:: with SMTP id 11mr49825084pfo.3.1556347392003;
        Fri, 26 Apr 2019 23:43:12 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:11 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: [PATCH v6 06/24] fork: Provide a function for copying init_mm
Date: Fri, 26 Apr 2019 16:22:45 -0700
Message-Id: <20190426232303.28381-7-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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
index 44fba5e5e916..fbe9dfcd8680 100644
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

