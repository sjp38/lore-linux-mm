Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C77AC04AB5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3D9526341
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:58:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3D9526341
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F7C96B026B; Mon,  3 Jun 2019 21:58:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A8E56B026D; Mon,  3 Jun 2019 21:58:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5975C6B026E; Mon,  3 Jun 2019 21:58:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 251E86B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 21:58:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z10so11271199pgf.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 18:58:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6IOvL+6dcNrPEVtgL7SQd0w8cn0B9vsvkLojsAnxj1M=;
        b=Np0qpVHDGrQ/jlPUx2W3gq1p/ab/V8kfvkKyom9mlW6Na9RGNrEEeqOM7j4mir2XAm
         acp+N1cXEkkeKV87Xhz1SkzryCatQbUo0oHXEfOVwVMPYuy2TDyaZSr+OLrAq8k8pUmu
         JuzINLC0Ip4XGH1fDOdWDuWglfeJkh0kIg2CLx0tKCuxax644kbUXzbAckTU80YhJby5
         d5oq9djUWO+B2IQOAXgl6B/k9WD+Yt+7iHJqIvDcaIiJOobivG5nNV5cL2VQEdg2MWlj
         gEDQT4xrU+rD5etjc5mrrSwcdiCebF83lStpn0+tN5In2IYNloaFI7cc47kBgbPQqVwo
         zIbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXahaJDe735X/viugRRLznYcOg+LGw6VUBsPGUoLI5lGmxDXK4/
	6DxFLeE3Uew+2an2PRGTIonYNziU8b0CmIey69JlMMcSGhfraMC1D/suJwRzEWsfC1eMVUyqwaM
	N8Jes6Gvy5h78Ya5ERT2IQB/VNAPXHSsi8vUXmnHzV/wRfgY0sWvItJZeOG+7o9i5KA==
X-Received: by 2002:a63:205b:: with SMTP id r27mr33108842pgm.330.1559613528844;
        Mon, 03 Jun 2019 18:58:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0XFPpGt6Fy5KXuxYwq0Zvq63t7FJzKPgvT+AA183jNvPLnXj4C7tXqaXE6ZMNF3UHm5aw
X-Received: by 2002:a63:205b:: with SMTP id r27mr33108760pgm.330.1559613527872;
        Mon, 03 Jun 2019 18:58:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559613527; cv=none;
        d=google.com; s=arc-20160816;
        b=oSblpQ1YKZ/SV+j1cEh0WTS0fXXI4LdM4F7coknK4z1r6KbbjFpSDpEZkUseGAndBG
         CcZd800oFxuNvKp08um4ldwBoqdDA0fOVSd+5CLDhCtT0kuWWb7MMtQJZXjlFOXace2d
         cqLHJoP1braC0I0A5ts/vorMpZ51h8w3XayDhPho7dCZps9tvc+Z9nJPdhGBd1uq59MK
         FYIXSo2zpfBw/FqkzK+HCmL6xZNCBf+5O6Im7QhjY4fxnvAx5GuySg5JtO3z6RWBEOF2
         40vVOcHpNWab8rN2Y+jz/ZDTn/UTqZoB2QEpYw6dDgD4WfBSR8PNvrhelWcL2w9D6jwx
         GkeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6IOvL+6dcNrPEVtgL7SQd0w8cn0B9vsvkLojsAnxj1M=;
        b=M7I0V0pvCIeqcN5u6iaqPAYHaOeVXtjlrXWZI8tnVH2NTQZ89OXW9ItO7nOuGy8hBm
         YyXpdAGxIJYQcpVJegjGXCaKqE84qB8/docpPW7lxN7W4CkRaPiWJx5AX21aWrbzCN6N
         9LS7yyaM3/eBopcHC0iefRGKPBs4O25K2En3FIo6TaOHd2NixpUQHQvYdnjorNu+8K5e
         r0uckSp+Icsa/WtwP8yXxWB8IeYxS4gv5RwnQpKn+w4KgRKc4YbKOa2P/jk23CBxUf22
         Z5kStWMJFv5WVy1ZXZWXM0zLDU209Tb35X81RoPzWmsHL4DzEYq69NZtxiB7iYcDXpkr
         zpaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id i2si10560778pgs.265.2019.06.03.18.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 18:58:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTNnVwF_1559613512;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TTNnVwF_1559613512)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 04 Jun 2019 09:58:33 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: linux-mm@kvack.org,
	cgroups@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Caspar Zhang <caspar@linux.alibaba.com>,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: [RFC PATCH 3/3] psi: add cgroup v1 interfaces
Date: Tue,  4 Jun 2019 09:57:45 +0800
Message-Id: <20190604015745.78972-4-joseph.qi@linux.alibaba.com>
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

For cgroup v1, interfaces are under each subsystem.
/sys/fs/cgroup/cpuacct/cpu.pressure
/sys/fs/cgroup/memory/memory.pressure
/sys/fs/cgroup/blkio/io.pressure

Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 block/blk-throttle.c   | 10 ++++++++++
 kernel/sched/cpuacct.c | 10 ++++++++++
 mm/memcontrol.c        | 10 ++++++++++
 3 files changed, 30 insertions(+)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 9ea7c0ecad10..b802262ecf8a 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1510,6 +1510,16 @@ static struct cftype throtl_legacy_files[] = {
 		.private = (unsigned long)&blkcg_policy_throtl,
 		.seq_show = blkg_print_stat_ios_recursive,
 	},
+#ifdef CONFIG_PSI
+	{
+		.name = "io.pressure",
+		.flags = CFTYPE_NO_PREFIX,
+		.seq_show = cgroup_io_pressure_show,
+		.write = cgroup_io_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
+	},
+#endif /* CONFIG_PSI */
 	{ }	/* terminate */
 };
 
diff --git a/kernel/sched/cpuacct.c b/kernel/sched/cpuacct.c
index 9fbb10383434..58ccfaf996aa 100644
--- a/kernel/sched/cpuacct.c
+++ b/kernel/sched/cpuacct.c
@@ -327,6 +327,16 @@ static struct cftype files[] = {
 		.name = "stat",
 		.seq_show = cpuacct_stats_show,
 	},
+#ifdef CONFIG_PSI
+	{
+		.name = "cpu.pressure",
+		.flags = CFTYPE_NO_PREFIX,
+		.seq_show = cgroup_cpu_pressure_show,
+		.write = cgroup_cpu_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
+	},
+#endif /* CONFIG_PSI */
 	{ }	/* terminate */
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ca0bc6e6be13..4fc752719412 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4391,6 +4391,16 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.write = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read_u64,
 	},
+#ifdef CONFIG_PSI
+	{
+		.name = "memory.pressure",
+		.flags = CFTYPE_NO_PREFIX,
+		.seq_show = cgroup_memory_pressure_show,
+		.write = cgroup_memory_pressure_write,
+		.poll = cgroup_pressure_poll,
+		.release = cgroup_pressure_release,
+	},
+#endif /* CONFIG_PSI */
 	{ },	/* terminate */
 };
 
-- 
2.19.1.856.g8858448bb

