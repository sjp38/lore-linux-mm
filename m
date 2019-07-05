Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B631AC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 07:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2EF21670
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 07:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TfYUFjx+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2EF21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12D3A6B0006; Fri,  5 Jul 2019 03:06:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DF4B8E0003; Fri,  5 Jul 2019 03:06:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0FDD8E0001; Fri,  5 Jul 2019 03:06:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0CDA6B0006
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 03:06:00 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id 132so6215483iou.0
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 00:06:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iL/CBlYWrFWhKhb1OSaBKQtEUlf7LDLWt3ylKB6ihG4=;
        b=uEeEXzYHfVsntC5JxILsT20vRLFMo1TXejdkBPlBrDEdnf/qKsExxZKRmXOFFEjo17
         kG/KKtT//lvdysY/J330Ova3tY4QJXX0B17CoIkspY6hK4nua+mvwRyLZPlnUcdgkbmj
         3sYce3btq1NOkUcgYBJddpCA8AyM+dGQMHjpRSZIRhBakaXbwOEcK/zCPjtBnjJHcWPG
         fv3klmzhmQ3HzCbWODuiBFsissFVwIbTRnqNvrkR/PzVgfnaT2BtzcM7UCgQKJgvSBhQ
         uWmo57bSEnYprRQa5Vim9SqJLoKpggr4eiH3+jvPOpTSUswn+4ZGzkmfWudjhsk8t/9E
         /BYg==
X-Gm-Message-State: APjAAAUesAYcwppmgpPC9k/zd35k4B6T6TPQon6m1QTFQ3fnviIJmRxi
	LfFzNEJp2kGzZ0gpUsd3LXrgd5n6P4zEXq10ZgpDBiQeRyXom17JfAPZAghrKvjYh9WURjIbd7z
	4N6xLRLACNe6bSRv6WwQmpIKGZzgh0SV7uB/NKqffWkv8GWGVpqsF3HdAKzjrNwoRBw==
X-Received: by 2002:a5d:8416:: with SMTP id i22mr2462079ion.248.1562310360571;
        Fri, 05 Jul 2019 00:06:00 -0700 (PDT)
X-Received: by 2002:a5d:8416:: with SMTP id i22mr2461981ion.248.1562310359402;
        Fri, 05 Jul 2019 00:05:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562310359; cv=none;
        d=google.com; s=arc-20160816;
        b=RN4bG/s5WtEUejKj2wXiq7Yox7foYYZExi8ZqK639LoTdm5EN9ffxokc6xqdFsmHtI
         MLMff1jI7b+w6Ot7IHVq6kQ7iCHiMujPcL41307CzkcIoyvxm0yVZy0gCCXZSjBoXePy
         8XGp1N2pf+blJPMIKae/eXgQR2Y0zKxT4NAFIv5a+AEQM1Dn4TQXDNFHVP+0E4f+FXRB
         bXmdvrgtqpQ6bVv1Eh9H1ui/0dt56Ro/5+A5zDuGfAD2rGJusE71SjwpdhC5eU2S7gms
         29UzTPzzInhCAoa1z0VTIGZzcWkt9/2XYWiZyVIPXkD1UagxJAPPhShwNQB8+0kUcYXe
         EnOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iL/CBlYWrFWhKhb1OSaBKQtEUlf7LDLWt3ylKB6ihG4=;
        b=GBes97fN90kHBMPouTMcBZGQAqBlBAlRyT7h1477jiWRu3dNpK+fsFgjECt4sIyYHO
         nPxudfNMs/voVx4HT3cojMX/jl2mUAkFUAuNJ3iZSNDhWMLOQHPHjzgbu6Ht0ck2jgoO
         L6DsI5gqRL7cxqTM+6gZ66w+WYIonYs+OnTDKLezagdUWtVnIKdXnx6JTXZjT8Cml6jD
         vMoU1A1GETGBR7uQvndBEQTUNQ0D5DqSXyVDIn8m1Z4BrXsBZaaUqVlfaVs2v2MfIhSF
         26zQ6R7eqadwYD9x/jCZ1QiAS7F0lRmQMusSUVAHYONXc+zon21Cch6P/GPc5qsSCde0
         cg4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TfYUFjx+;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor5921752ioo.100.2019.07.05.00.05.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 00:05:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TfYUFjx+;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=iL/CBlYWrFWhKhb1OSaBKQtEUlf7LDLWt3ylKB6ihG4=;
        b=TfYUFjx+89wiFQsmj3ZPluU9eUxFF0IlQ8ENAaMabpcb/noT6tEm+Not3abEoduxpD
         +PdSSjsKHTPsuLpGVH01L0ud15TcRd1DhVdVGrGeJdHW7aO9eu1h75FrlvPpQYAQeKk4
         bDoUYL8SbVW143gYy34aoWpITg2fXdn/8k+9n99ddNONIIZ4+eO3djRfuf17XxwgxhlD
         Q8Y5QGZyOM23xaGlabkv9x77bblUsRn8pFftDbq9KsgRKQ2sFwLypCahYjIP0/ioFrFq
         4DNfvCW3jOlK46daRRqiC0511UwnvXd+wRaBPwDryP09Nb7wTbYjBvZ2hzsbieBk20qO
         HHMg==
X-Google-Smtp-Source: APXvYqzJ+LiiYgI/kslaEofvNPDqzFcIUAy6kSu1IYguZSFzYbJaYnSX8hO9QZf5G/mWLUxPD1BfHg==
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr3165012pla.338.1562310358919;
        Fri, 05 Jul 2019 00:05:58 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id z20sm15138789pfk.72.2019.07.05.00.05.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 00:05:58 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Shakeel Butt <shakeelb@google.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
Date: Fri,  5 Jul 2019 15:05:30 +0800
Message-Id: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We always deploy many containers on one host. Some of these containers
are with high priority, while others are with low priority.
memory.{min, low} is useful to help us protect page cache of a specified
container to gain better performance.
But currently it is only supported in cgroup v2.
To support it in cgroup v1, we only need to make small changes, as the
facility is already exist.
This patch exposed two files to user in cgroup v1, which are memory.min
and memory.low. The usage to set these two files is same with cgroup v2.
Both hierarchical and non-hierarchical mode are supported.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 Documentation/cgroup-v1/memory.txt |  4 ++++
 mm/memcontrol.c                    | 20 +++++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index a33cedf..7178247 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -63,6 +63,10 @@ Brief summary of control files.
 				 (See 5.5 for details)
  memory.limit_in_bytes		 # set/show limit of memory usage
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
+ memory.min			 # set/show hard memory protection
+				 (See ../admin-guide/cgroup-v2.rst for details)
+ memory.low			 # set/show best-effort memory protection
+				 (See ../admin-guide/cgroup-v2.rst for details)
  memory.failcnt			 # show the number of memory usage hits limits
  memory.memsw.failcnt		 # show the number of memory+Swap hits limits
  memory.max_usage_in_bytes	 # show max memory usage recorded
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3ee806b..58dce75 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -169,6 +169,12 @@ struct mem_cgroup_event {
 
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
+static int memory_min_show(struct seq_file *m, void *v);
+static ssize_t memory_min_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off);
+static int memory_low_show(struct seq_file *m, void *v);
+static ssize_t memory_low_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off);
 
 /* Stuffs for move charges at task migration. */
 /*
@@ -4288,6 +4294,18 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 		.read_u64 = mem_cgroup_read_u64,
 	},
 	{
+		.name = "min",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_min_show,
+		.write = memory_min_write,
+	},
+	{
+		.name = "low",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_low_show,
+		.write = memory_low_write,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.write = mem_cgroup_reset,
@@ -5925,7 +5943,7 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 	parent = parent_mem_cgroup(memcg);
 	/* No parent means a non-hierarchical mode on v1 memcg */
 	if (!parent)
-		return MEMCG_PROT_NONE;
+		goto exit;
 
 	if (parent == root)
 		goto exit;
-- 
1.8.3.1

