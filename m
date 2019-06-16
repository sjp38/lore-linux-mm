Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D645AC31E54
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A65F21473
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A65F21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 467DB8E0002; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1038E0001; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26E0D8E0002; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF27E8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r4so3218520wrt.13
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PJSsC+ETTbEm0MFSswbRZG13yzb82K1kjBPqEvVe/Y8=;
        b=P0WQjDPi6yIdulLFN8DFjT64Da8/ylJn5kmWZncfaEltTd40HK7Mi99ezEvEfr1c2R
         RXuTjKwFfPN+wTtNRDQJBz6qZ4xL3tCOmARi+SzcX7ZtykrCzwd0A0YzGTwhxdATGd65
         YX+FRTL+sbrd+LiWnZp9/lwIik7R5CrDmuymBvioxQAslViTJjjkN3OMdxiGwUYC2f/T
         kR3PSJxYLZF0odWVsOl13x3E57HUCW4wapT734b6pAlnObO+CVKZSDZRMnMiGrRi0e65
         S2iGr76J3sGnHsIR7b1yyu/aLZvmfVIctHVoZlJxsYFrbKs5exfTRoUzzmOKg2L70d5s
         CNTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUoRYadEOLHEmMoFjtrN3nINH/91M8KZymKoOasDjGYQrZs/rta
	n2hWea3MeAEW4a+Tqfkbiui15FN79Ei74cuQ2cpi3ZlFbW+3b4KaYNubsYkmYrnnW5+1lIChe5S
	74E8gWqg3oaaUycbqvl04NEe9tp0IfonpNwEqQ5Rpwg5dHbQNSGn+UbFmMX2YU9M+Uw==
X-Received: by 2002:a05:6000:1203:: with SMTP id e3mr7210657wrx.300.1560675521207;
        Sun, 16 Jun 2019 01:58:41 -0700 (PDT)
X-Received: by 2002:a05:6000:1203:: with SMTP id e3mr7210586wrx.300.1560675519931;
        Sun, 16 Jun 2019 01:58:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675519; cv=none;
        d=google.com; s=arc-20160816;
        b=z1oXcwUvdaIS8iS7VG/hvPEWA+7Xlx73nEZf5+5Wi4/VehfzGANoeIbXmAgv3q+qWL
         RGlpek7+FtSAe7UjD6CkLMh7MvGHIA/lzpXibhkg83RRo+TN4Vas1EJPcfpRfU5jsOb4
         wwqBGa7Sq4hQN/M6V/7T2JmvPwxJDLnBc+PbRUk85oHwfL/aLCetfcw1Wt9EhYnKU3lu
         4rBJQYKXYhYM5O8o7QGcITfKsL+Xx+VGnbUaF5jPD+BqwJ5fvHpzPPrFDTp0yG6tsMqB
         tAv7mXQh/YZQGlC86oceETv41GZ7yd9vrL81r585gyo2y1mhQDFPQWEbVlgpASUw0im5
         3+4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PJSsC+ETTbEm0MFSswbRZG13yzb82K1kjBPqEvVe/Y8=;
        b=ni84UP5OX55200Bo/kaPNvZiodFkycu3flxdoyl2hGRC2v8JJJFxXm9rnAyihTcR35
         YEQH8Oy/0h0tsFpR30UCvXYdhXLFXbOw973xBlalXvQxnZNIRD+BiminO+zzXEEs+ZKX
         gyuCORdcmdiJ8BJq1p+F4Dt/udMW0BdQDGLhZMa8mDLNTjgaeKvdSxobxb+gSeevXVXn
         OQUQB1HGYgciRQLMUSW2ZpS0u6stXUPf/7/KtZ758PqAHZ40Dz1PzAN8ho2Ud0rCdEaw
         XxAjSqOoLTRlTixHdjb0So4ul1drs9enrAVi5Hj/KbO/d53zvig+fRvGER6wFYtbkGle
         3XUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b203sor4307600wmh.13.2019.06.16.01.58.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqziZjswyLaPjH4zzuukgwYGgZMcx72QbU3TZfm0v5QbPhsR4W+rR5m+8XGdtVYkv9SHvMzBoA==
X-Received: by 2002:a1c:99c6:: with SMTP id b189mr14663437wme.57.1560675519453;
        Sun, 16 Jun 2019 01:58:39 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id 6sm8148471wrd.51.2019.06.16.01.58.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:38 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 1/5] mm: rename madvise_core to madvise_common
Date: Sun, 16 Jun 2019 10:58:31 +0200
Message-Id: <20190616085835.953-2-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190616085835.953-1-oleksandr@redhat.com>
References: <20190616085835.953-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"core" usually means something very different within the kernel land,
thus lets just follow the way it is handled in mutexes, rw_semaphores
etc and name common things as "_common".

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/madvise.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 94d782097afd..edb7184f665c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -998,7 +998,7 @@ process_madvise_behavior_valid(int behavior)
 }
 
 /*
- * madvise_core - request behavior hint to address range of the target process
+ * madvise_common - request behavior hint to address range of the target process
  *
  * @task: task_struct got behavior hint, not giving the hint
  * @mm: mm_struct got behavior hint, not giving the hint
@@ -1009,7 +1009,7 @@ process_madvise_behavior_valid(int behavior)
  * @task could be a zombie leader if it calls sys_exit so accessing mm_struct
  * via task->mm is prohibited. Please use @mm insetad of task->mm.
  */
-static int madvise_core(struct task_struct *task, struct mm_struct *mm,
+static int madvise_common(struct task_struct *task, struct mm_struct *mm,
 			unsigned long start, size_t len_in, int behavior)
 {
 	unsigned long end, tmp;
@@ -1132,7 +1132,7 @@ static int pr_madvise_copy_param(struct pr_madvise_param __user *u_param,
 	return ret;
 }
 
-static int process_madvise_core(struct task_struct *tsk, struct mm_struct *mm,
+static int process_madvise_common(struct task_struct *tsk, struct mm_struct *mm,
 				int *behaviors,
 				struct iov_iter *iter,
 				const struct iovec *range_vec,
@@ -1144,7 +1144,7 @@ static int process_madvise_core(struct task_struct *tsk, struct mm_struct *mm,
 	for (i = 0; i < riovcnt && iov_iter_count(iter); i++) {
 		err = -EINVAL;
 		if (process_madvise_behavior_valid(behaviors[i]))
-			err = madvise_core(tsk, mm,
+			err = madvise_common(tsk, mm,
 				(unsigned long)range_vec[i].iov_base,
 				range_vec[i].iov_len, behaviors[i]);
 
@@ -1220,7 +1220,7 @@ static int process_madvise_core(struct task_struct *tsk, struct mm_struct *mm,
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	return madvise_core(current, current->mm, start, len_in, behavior);
+	return madvise_common(current, current->mm, start, len_in, behavior);
 }
 
 
@@ -1252,7 +1252,7 @@ SYSCALL_DEFINE3(process_madvise, int, pidfd,
 
 	/*
 	 * We don't support cookie to gaurantee address space atomicity yet.
-	 * Once we implment cookie, process_madvise_core need to hold mmap_sme
+	 * Once we implment cookie, process_madvise_common need to hold mmap_sme
 	 * during entire operation to guarantee atomicity.
 	 */
 	if (params.cookie != 0)
@@ -1316,7 +1316,7 @@ SYSCALL_DEFINE3(process_madvise, int, pidfd,
 		goto release_task;
 	}
 
-	ret = process_madvise_core(task, mm, behaviors, &iter, iov_r, nr_elem);
+	ret = process_madvise_common(task, mm, behaviors, &iter, iov_r, nr_elem);
 	mmput(mm);
 release_task:
 	put_task_struct(task);
-- 
2.22.0

