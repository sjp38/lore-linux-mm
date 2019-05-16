Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DE2EC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C17522082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C17522082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07D946B000A; Thu, 16 May 2019 05:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F232B6B000C; Thu, 16 May 2019 05:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9A556B000D; Thu, 16 May 2019 05:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD626B000A
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:45 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u124so573832wmg.1
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZZGnY1AeO4vEIRNllzlClW+UmlSDLeAarYqLIOTY4ZI=;
        b=tAme9xoqakKQsO1U8b6VwZGq5TD8zvz4Ij97dS8SKHZagz2nX9iMb346hys/iK8bwD
         v+PfkIcJ/PVwOrQHvemDsN/UgDTkV+AoGEzLwyUT/dxeEAoIp0RE/J4loZ5R717pNSip
         F3AdClfZYC74Tba0t5jjUTjtjoXaWfV1eyErRrnqBLU8EcetvTe2f6km+GA261WBGat5
         e75s9hDj7KO+Nx4rV5AK2CgRC/JfM0csnjMT2m3D5xn5pO6PUJ9ybZ5iyJIsBK+SxATB
         /k3kYrYcfEb1nNj4s4W/f5ffv2Mhmk1dtxINkfN2BcXfOOY/Pbj4rGND6/HFcR55kDMT
         8Qgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWy0YZD2dGzAK13gWFXDW8/qndZj8IjwiV4NE3AlGqgcgxq7iIf
	6VV5C/i0v17uQedz7pU7BXWFNBKtHqo+1eVGIWBIH4Ktpi4A+TLgz85ja5+Cyr6FbkYI6QSkfQz
	2e76H3WmI/8bVshHfG2CEncq7wSSp7zid33XTqSr4tje2w76C8dKqPMQX5sOKhLuVbA==
X-Received: by 2002:a1c:1902:: with SMTP id 2mr25859559wmz.153.1557999764980;
        Thu, 16 May 2019 02:42:44 -0700 (PDT)
X-Received: by 2002:a1c:1902:: with SMTP id 2mr25859473wmz.153.1557999763561;
        Thu, 16 May 2019 02:42:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999763; cv=none;
        d=google.com; s=arc-20160816;
        b=afD/KYhXQQHNPwbfkSa8XSPZbIctjt9WzY9jSFfMtRFKC2YUGmUypW90dLhx76JZby
         IgbjaR4+HfrVCQoHO7Y3VGnuOzVr8cjm/IMx0j67izSwSTLzkrcw6uBfqwjV2HiJvxj1
         6GhyS4vXfN/8OUGXBgOa6O5wBirw0dyTTDjR3PT984mpNoHsVscOli28Vqfj1nMMH8uG
         9NEZLR36PgKEcIqY9x6vETlZrLGrpegkL+ShFmrmlJ3L4XSE9OmlnI5qK9p879BWq6LA
         tnIVlv20TFWMMqGpz0Ermk6fXYpmtIrIVSXvuy5QGv4QWJZ5ngxRRdr6/ljxLQ9sA0Jb
         Hq8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZZGnY1AeO4vEIRNllzlClW+UmlSDLeAarYqLIOTY4ZI=;
        b=bMGpJc5CxIW1ag0BBJBZVPAgpdsYeDuNYn+HPtHbNOGbRcPXQw1RMh1jOO+XGMLfeT
         AG3daLTX/2EO1iubfFnzchAI6OocnVPeH2DFRLrvEi8j5jUcvlsiObK+tzPVA55ubO/S
         k43ry00agGqpTquCZRRNfygs7khc5H1Dl2WUMQjCJ+LrGBF6Nh7bKbtSt28EEu4+Iua3
         ZAnS7UGTF6vgx2HrlTiB6NqPvha8emSq6KqHXErG8kHCnRcImSjZpy6PNdEsF6/dp+XV
         8sC8ht4iQ6wRDl/9URvnoE5ewfGQAHNDfFWbURGLCRrYAd+aw8YchlRZSf8d0s0o6vAE
         qFAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h76sor2885791wme.12.2019.05.16.02.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzGCZsfZTLnp32ZXX+p/N913HP7wOvaTxVvqZVz8kRuhkb2Lox0z5g/+tp8DehjQ+5iLc3ZLg==
X-Received: by 2002:a7b:c8d1:: with SMTP id f17mr14149157wml.45.1557999763188;
        Thu, 16 May 2019 02:42:43 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id s18sm4074000wmc.41.2019.05.16.02.42.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:42 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH RFC 4/5] mm/ksm, proc: introduce remote merge
Date: Thu, 16 May 2019 11:42:33 +0200
Message-Id: <20190516094234.9116-5-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use previously introduced remote madvise knob to mark task's
anonymous memory as mergeable.

To force merging task's VMAs, "merge" hint is used:

   # echo merge > /proc/<pid>/madvise

Force unmerging is done similarly:

   # echo unmerge > /proc/<pid>/madvise

To achieve this, previously introduced ksm_madvise_*() helpers
are used.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 fs/proc/base.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 51 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f69532d6b74f..6677580080ed 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -94,6 +94,8 @@
 #include <linux/sched/debug.h>
 #include <linux/sched/stat.h>
 #include <linux/posix-timers.h>
+#include <linux/mman.h>
+#include <linux/ksm.h>
 #include <trace/events/oom.h>
 #include "internal.h"
 #include "fd.h"
@@ -2960,15 +2962,63 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
 static ssize_t madvise_write(struct file *file, const char __user *buf,
 		size_t count, loff_t *ppos)
 {
+	/* For now, only KSM hints are implemented */
+#ifdef CONFIG_KSM
+	char buffer[PROC_NUMBUF];
+	int behaviour;
 	struct task_struct *task;
+	struct mm_struct *mm;
+	int err = 0;
+	struct vm_area_struct *vma;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+
+	if (!memcmp("merge", buffer, min(sizeof("merge")-1, count)))
+		behaviour = MADV_MERGEABLE;
+	else if (!memcmp("unmerge", buffer, min(sizeof("unmerge")-1, count)))
+		behaviour = MADV_UNMERGEABLE;
+	else
+		return -EINVAL;
 
 	task = get_proc_task(file_inode(file));
 	if (!task)
 		return -ESRCH;
 
+	mm = get_task_mm(task);
+	if (!mm) {
+		err = -EINVAL;
+		goto out_put_task_struct;
+	}
+
+	down_write(&mm->mmap_sem);
+	switch (behaviour) {
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
+		vma = mm->mmap;
+		while (vma) {
+			if (behaviour == MADV_MERGEABLE)
+				ksm_madvise_merge(vma->vm_mm, vma, &vma->vm_flags);
+			else
+				ksm_madvise_unmerge(vma, vma->vm_start, vma->vm_end, &vma->vm_flags);
+			vma = vma->vm_next;
+		}
+		break;
+	}
+	up_write(&mm->mmap_sem);
+
+	mmput(mm);
+
+out_put_task_struct:
 	put_task_struct(task);
 
-	return count;
+	return err ? err : count;
+#else
+	return -EINVAL;
+#endif /* CONFIG_KSM */
 }
 
 static const struct file_operations proc_madvise_operations = {
-- 
2.21.0

