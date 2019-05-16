Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0F38C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC5A92087E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC5A92087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DFE36B0006; Thu, 16 May 2019 05:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86AC06B0007; Thu, 16 May 2019 05:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70C096B0008; Thu, 16 May 2019 05:42:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 265886B0006
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:40 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v5so1100768wrn.6
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ec97xsumF3Pkv1YQN1NPRzLcPj4UDGH/s6YIE0YJh6Q=;
        b=oB1GqouR+1EXjTtNWfIxq1krXW2cbI2ng5pq5DN1/Ih7vOvWcUKvQMsUVHiOyV9kL4
         BsypbQSFZFLYJYnIOtI/nF96kLLQpwc3KtIUYYbAlI2PuR16Gq8OAc1RWEKpAl6UdtnF
         4XfiVST+YLVXwY2IWuLHFZER92UoWFyfir2snqnMYPLp41/jPVAB85zwq8lymFa0Zucl
         YPjNPm+DksX2NRqBJ0BqUW1asOi7GMpfw1zquN3BBXtGyIGvc47hMVq2Nl1LriePGF4I
         kmDVe06J3tHBfwj9n8DXZuFg3wWguttCMBl/pl4iRoekfIW1HAbHmu3uy5KrxWpOH9Ex
         qx4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVxvUMfxmu7Jk5DpHWBCgOofyGSoGIUyJ6xVNpOPdg0ax/5M97B
	2Ey9QToTihY8BrKubOrhH4xAZU1S3SIZeaTSJcmPrvn1Gnpi7G0OyJsIfa5VgAFlDHRipn/gqAJ
	PpRJ2JQ1zkRgaJdekpbSOXluNWw+VjTHpx6LiquYXGs/rWtLT63PmigVz7ONEqTQ2eA==
X-Received: by 2002:a5d:5506:: with SMTP id b6mr27601652wrv.221.1557999759713;
        Thu, 16 May 2019 02:42:39 -0700 (PDT)
X-Received: by 2002:a5d:5506:: with SMTP id b6mr27601590wrv.221.1557999758670;
        Thu, 16 May 2019 02:42:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999758; cv=none;
        d=google.com; s=arc-20160816;
        b=Npy5C9p1pvUqbLbOL5ekWBUXArxtMNWFPxxjEFy6GYupr8DMzJRJztKt0i7MJPFBmV
         8tIISPa4fCLdkjtZKG9S+jojJ7SFjJOEdNK5UFwARUIKLF1jt1bRZIKnDX9GB7juzDgF
         XDqtI3iUOJmdF1iHRHOADnVdKi8v6yGezcIRw5Xf1xXvI7S02KLRDyVJz7mIBkzC3cse
         BW5ZWVpLvs3+11+SAJ8kn9PZNNbzqGS0rJo73MhzHD8xKTT6eQ3NEShhNxAFAaMqgisn
         2jlHRU3H4C/ImT8cnmPJYMLP2COJQlPxj0bMB1s4lPNkHBmo56K0Q+7twTJRBl5iXFuy
         boZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ec97xsumF3Pkv1YQN1NPRzLcPj4UDGH/s6YIE0YJh6Q=;
        b=zW1bp2aqdxyJ2QkMg9mUGzCwgBZosCy/Qp3SMHYujhtrvOMcHPp6TGMLWg4rhyCh/7
         MSUOGtuihHmPF6ThXB0q7ZVfzIK0v2F1f6RhwHLZEO5adq4p/SOwF8Hmj/2tcqIoY3SP
         /S3a+rxDvnHnwEhWzGH2GiOQ2LolTH38bVZXP2bsp+gwaMceuWYWnu4G1a5SwNEfhSFL
         4cqDsddpHL30IuTcwbo9CmhYtpD6Dd7u1iKng7vBtjgmhYFZivQEBxlB4Wxq7FDmBc0U
         IbEm6fsw6muDo2DRlBzmUD2kzocQJz/On1It3LAx+jdkQwo6eGSr//psT1R917AiM1EY
         U6ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16sor3871548wrx.15.2019.05.16.02.42.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzL4YP+rxRXtwxz4lhwPcqqtNNojy1+KdB1FfWoc/WFzJDav/U0UgURDFche4Hrog/mqIRD1A==
X-Received: by 2002:a5d:4647:: with SMTP id j7mr24112266wrs.280.1557999758291;
        Thu, 16 May 2019 02:42:38 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id t18sm7663093wrg.19.2019.05.16.02.42.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:37 -0700 (PDT)
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
Subject: [PATCH RFC 1/5] proc: introduce madvise placeholder
Date: Thu, 16 May 2019 11:42:30 +0200
Message-Id: <20190516094234.9116-2-oleksandr@redhat.com>
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

Add a write-only /proc/<pid>/madvise file to handle remote madvise
operations.

For now, this is just a soother that does nothing.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 fs/proc/base.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 6a803a0b75df..f69532d6b74f 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2957,6 +2957,25 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
 }
 #endif /* CONFIG_STACKLEAK_METRICS */
 
+static ssize_t madvise_write(struct file *file, const char __user *buf,
+		size_t count, loff_t *ppos)
+{
+	struct task_struct *task;
+
+	task = get_proc_task(file_inode(file));
+	if (!task)
+		return -ESRCH;
+
+	put_task_struct(task);
+
+	return count;
+}
+
+static const struct file_operations proc_madvise_operations = {
+	.write		= madvise_write,
+	.llseek		= noop_llseek,
+};
+
 /*
  * Thread groups
  */
@@ -3061,6 +3080,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_STACKLEAK_METRICS
 	ONE("stack_depth", S_IRUGO, proc_stack_depth),
 #endif
+	REG("madvise", S_IRUGO|S_IWUSR, proc_madvise_operations),
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
-- 
2.21.0

