Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20835C04AB5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D727626341
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D727626341
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8315F6B026A; Mon,  3 Jun 2019 21:58:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2026B026B; Mon,  3 Jun 2019 21:58:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F7AD6B026D; Mon,  3 Jun 2019 21:58:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39ED86B026A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 21:58:43 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d7so11278532pgc.8
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 18:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=on4qaNQS+1if1412TWdtwWGg4zWyVqKU95StefIcbeo=;
        b=KFpV5UTuzRNtUpo1be2kdQOVzyF01ihxJx2raFeufbEiGzEDACggtD2T2zdHrRRd3z
         HzProdnn2W7VIhjVC0VWUnX0HcWum/F/7qJoTzLL74AGbVFtZxFw4zSVi2wa42asBszJ
         kim63e9Pt27ysYFu9vAGkYZFSL85TZDiDgeeQPPAUmbtwqcw2b4sRgTrEcTPQ/W0DkiM
         9dvpKbbVeZumUEolj+pbQszbtfN/M70rf/2/FzNPmwKQoGKWFYwfqlYS88mzQMpR5aDz
         t+bcEAmCsNzyaS0+dhzkI0Q7so/5kTjS6vS14bpTncPBRIxA9v8zDJOKtqJFMiKfMRTm
         5ulQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUYxwZ5Rk3n7jeoeMNlVf3Gt39RFQ2gMdFLOmXtOxXibZ3GB60i
	utHrx8wjm6Z6rmfY9Y5DOJOLQe9Cpl6wvOvfVBVoZfI3usgzwYAhJuo7aVC2+Me+QH4clLc8dCN
	+DbPVJ23VLy5DAsfO2Xm1a2mOAmx8xvHUmDHh1tS2ybfn6Fi+5xC2s1z9VYRNDh2FDA==
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr32682483pgs.343.1559613522922;
        Mon, 03 Jun 2019 18:58:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfTQbEomQya2EOWjdBVf52jSc7oQCelAs5rLU3EHSgb9mEdGP/d7KyajFf8/e1v8PbDBCD
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr32682362pgs.343.1559613521698;
        Mon, 03 Jun 2019 18:58:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559613521; cv=none;
        d=google.com; s=arc-20160816;
        b=gf7mUCzWN/2Ftu8dF+nCMdAJ1VnVAedIK2YnxvqR+P+/EJ3uUvkjyz2IkxgIXpM/TI
         lJ9/Ra7kliH6zeHhnA6TqQWrKjd7pJ8seKlnMCY1k/GejLPr9xyolaNC+XI38F9wUOyt
         HLbXNGhRbTW5sjMzKSNVKNT4B6watQOauaYQltqVRryoG/GSBaK33epysakKFrlXVCHm
         9EG1zzMVHlZaEFXabJR+CHuUbPEDEfCv5qOfvkjyQzmr4Cl46IlKr4Zqmthe0gRKUhL6
         qjJcYAzlmlOV+yX2IjshfmzXlhpemcly6lVfc8aunWru9RnHTg7lL5ehoeVWPz3F94Kw
         xusw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=on4qaNQS+1if1412TWdtwWGg4zWyVqKU95StefIcbeo=;
        b=0lfB5zfXc6MpLd9UxXBrJu0NpxfoaxtN7KGI/zKvxIAy/Xw3IThjfTiPy2MSxDvvK7
         ECHOMzDwrlZT+EGTkJA6mXIb/13yhnHd0DdBKWQujA28UYSGBiwxHC06/W+3CYhweyCo
         oePF2SiJZrkTG21Z9r8uJUTIet1vS3YQY+9FrlVI/8DMkXTi6WM7+HWOxPPjqpSw7R+B
         dZUEKZRVLvoM1alfIU3yvwnxNc2fwRjGTJjmf2hr85WX7yw7/tCXUxEeEgn91o+niux6
         X/zDAz+pzZLWKv2nPgsADb+n3cAks3LsHpFtivmSvoBidbmJOXp8TSJOg+QOf8rsSPYZ
         gngA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id d15si8761544pfn.56.2019.06.03.18.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 18:58:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTN908l_1559613506;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TTN908l_1559613506)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 04 Jun 2019 09:58:27 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: linux-mm@kvack.org,
	cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Caspar Zhang <caspar@linux.alibaba.com>,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: [RFC PATCH 1/3] psi: make cgroup psi helpers public
Date: Tue,  4 Jun 2019 09:57:43 +0800
Message-Id: <20190604015745.78972-2-joseph.qi@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
In-Reply-To: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
References: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make cgroup psi helpers public for later cgroup v1 support.

Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 include/linux/cgroup.h | 21 +++++++++++++++++++++
 kernel/cgroup/cgroup.c | 33 ++++++++++++++++++---------------
 2 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c0077adeea83..a5adb98490c9 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -682,6 +682,27 @@ static inline union kernfs_node_id *cgroup_get_kernfs_id(struct cgroup *cgrp)
 
 void cgroup_path_from_kernfs_id(const union kernfs_node_id *id,
 					char *buf, size_t buflen);
+
+#ifdef CONFIG_PSI
+int cgroup_io_pressure_show(struct seq_file *seq, void *v);
+int cgroup_memory_pressure_show(struct seq_file *seq, void *v);
+int cgroup_cpu_pressure_show(struct seq_file *seq, void *v);
+
+ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
+				 char *buf, size_t nbytes,
+				 loff_t off);
+ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
+				     char *buf, size_t nbytes,
+				     loff_t off);
+ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
+				  char *buf, size_t nbytes,
+				  loff_t off);
+
+__poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
+			      struct poll_table_struct *pt);
+void cgroup_pressure_release(struct kernfs_open_file *of);
+#endif /* CONFIG_PSI */
+
 #else /* !CONFIG_CGROUPS */
 
 struct cgroup_subsys_state;
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 426a0026225c..cd3207454f8c 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -3550,21 +3550,23 @@ static int cpu_stat_show(struct seq_file *seq, void *v)
 }
 
 #ifdef CONFIG_PSI
-static int cgroup_io_pressure_show(struct seq_file *seq, void *v)
+int cgroup_io_pressure_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgroup = seq_css(seq)->cgroup;
 	struct psi_group *psi = cgroup->id == 1 ? &psi_system : &cgroup->psi;
 
 	return psi_show(seq, psi, PSI_IO);
 }
-static int cgroup_memory_pressure_show(struct seq_file *seq, void *v)
+
+int cgroup_memory_pressure_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgroup = seq_css(seq)->cgroup;
 	struct psi_group *psi = cgroup->id == 1 ? &psi_system : &cgroup->psi;
 
 	return psi_show(seq, psi, PSI_MEM);
 }
-static int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
+
+int cgroup_cpu_pressure_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgroup = seq_css(seq)->cgroup;
 	struct psi_group *psi = cgroup->id == 1 ? &psi_system : &cgroup->psi;
@@ -3598,34 +3600,35 @@ static ssize_t cgroup_pressure_write(struct kernfs_open_file *of, char *buf,
 	return nbytes;
 }
 
-static ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
-					  char *buf, size_t nbytes,
-					  loff_t off)
+ssize_t cgroup_io_pressure_write(struct kernfs_open_file *of,
+				 char *buf, size_t nbytes,
+				 loff_t off)
 {
 	return cgroup_pressure_write(of, buf, nbytes, PSI_IO);
 }
 
-static ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
-					  char *buf, size_t nbytes,
-					  loff_t off)
+ssize_t cgroup_memory_pressure_write(struct kernfs_open_file *of,
+				     char *buf, size_t nbytes,
+				     loff_t off)
 {
 	return cgroup_pressure_write(of, buf, nbytes, PSI_MEM);
 }
 
-static ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
-					  char *buf, size_t nbytes,
-					  loff_t off)
+ssize_t cgroup_cpu_pressure_write(struct kernfs_open_file *of,
+				  char *buf, size_t nbytes,
+				  loff_t off)
 {
 	return cgroup_pressure_write(of, buf, nbytes, PSI_CPU);
 }
 
-static __poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
-					  poll_table *pt)
+struct poll_table_struct;
+__poll_t cgroup_pressure_poll(struct kernfs_open_file *of,
+			      struct poll_table_struct *pt)
 {
 	return psi_trigger_poll(&of->priv, of->file, pt);
 }
 
-static void cgroup_pressure_release(struct kernfs_open_file *of)
+void cgroup_pressure_release(struct kernfs_open_file *of)
 {
 	psi_trigger_replace(&of->priv, NULL);
 }
-- 
2.19.1.856.g8858448bb

