Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B141C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:40:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1A862082E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 09:40:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1A862082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C16CD6B0266; Fri, 12 Apr 2019 05:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC6926B026A; Fri, 12 Apr 2019 05:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB6F36B026B; Fri, 12 Apr 2019 05:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 711AD6B0266
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:40:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 132so6213348pgc.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:40:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=e5UOhWPs4vYyBzZ91K9WNi7wJmosoxJwyaTqEjIunrQ=;
        b=PtYK21k3uvlhFGPZzeMuUmtOVOb/E/+qLjBTyB2SWdJtI4Uf9vSApEllwyzGxJ8YN9
         0KAPisPSRpuAOj7zgr9cqGSwcLk6o8Vm1iU+OT2W+n1DIkfrp9rAsITkJGSTcRCQA3D9
         GPGl7WbWKM5st+DPldNfWzuqzDNEbCMexrYR9SkTPPnMtGTNhhOhMjitLSWffPQ0CljQ
         AZJhBDXaQozJpiKY07wf1O+owC0LZL0NuaGmMm+U0pV9NOOEagvHOEEXbI94G72V/536
         AgdmiUYPu+UtVE/bOROmwVMoQYfjeiIDJj1NrV+OZlQMxvKOoQsLuiViLVpnuQv0saUx
         pUSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUBMWKYAqtVqbup6Em27iFYShdzZ+Q3DTsYw2cB8pQPbzQuFCst
	GZb6/JguRQdZZn87BjC/FB47eeR9bLUtm1OkA1IMEznsnOtSkAgVZa87QCkOL4QWsUNjFibWQ6o
	TWRd0g1FomnO4KRbOJdHAn4paDrwGjuFsqAh1B/m2z90fFpP41uGgSYL2mGkzyzR7dg==
X-Received: by 2002:a17:902:2c83:: with SMTP id n3mr54178172plb.281.1555062011676;
        Fri, 12 Apr 2019 02:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkEXiXyypq5BS8ycXwk7Yo4LiKhIIJ13WZy8fJVd6QVGDNq6+F21Ct884yRNpt9cZDIS1w
X-Received: by 2002:a17:902:2c83:: with SMTP id n3mr54178086plb.281.1555062010723;
        Fri, 12 Apr 2019 02:40:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555062010; cv=none;
        d=google.com; s=arc-20160816;
        b=VxRbVbUnr9GtNV/UX44HjaO2CxBmRQyb/ClOJw/2EaLWeKJAC9nJo2+OIUykCiYLyM
         CSe4+1zsz4UyydbMXQvDpx/LKEgKzFKaFST0+E2knfPBiXz0DWuoCfoRMcM5sEUkuI81
         uHr+QRebUdl6jvugFXSMbpYKy4dkjbkS+vcvVGH40RDF4opISau9IfssA4++jMufUGMr
         9DN/EZTJZ5auIDxeIZiiY5wiTngcOHsBQ5HoZQwGjaIM/PpAQL2LUvEzbgTCOa2Ma/h2
         TKG5I4puv67GaBuSZyokxzkJz5HqUSDDGVir+2dGXW8YwOpZTjvo5sQtMvdxHslP6I0m
         ctkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=e5UOhWPs4vYyBzZ91K9WNi7wJmosoxJwyaTqEjIunrQ=;
        b=F+f9KAqVGhTxA4AzrbNaOLsyR9IdZg536YJa6MiOufJGt5xgMDp4QFg/mjSfD08Qej
         gGcF4Jfg48zWCq7B0irVmlJRtQ9QhBTTztURr7eMK2evHtGsjLuVW6bG+hB+kPMBt0y3
         G4u2HAQky2fAYD04ZUv4NFOb1YbyBiw++Awsu2EbdRMBL5k4M+LIvuniMH/mqSg60pfG
         5pzErOECf3AzKsLOc/G5RM5FRLMp9yLFByX7NaBJDpd20uKs0lvDmU4o2eYGZiOA5NWi
         DxzyvynCQnam4tCGqsvYIPOMq33Fdi0LALEblenzYdXmqyeWUGbsMPjltfes+5gt5aYR
         pRXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id c18si36347117pfi.198.2019.04.12.02.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 02:40:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R801e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TP6Ws3Y_1555062008;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TP6Ws3Y_1555062008)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Apr 2019 17:40:08 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Cc: tj@kernel.org,
	akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com
Subject: [PATCH] fs/fs-writeback: wait isw_nr_in_flight to be zero when umount
Date: Fri, 12 Apr 2019 17:40:08 +0800
Message-Id: <20190412094008.97859-1-jiufei.xue@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.856.g8858448bb
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

synchronize_rcu() didn't wait for call_rcu() callbacks, so inode wb
switch may not go to the workqueue after synchronize_rcu(). Thus
previous scheduled switches was not finished even flushing the
workqueue, which will cause a NULL pointer dereferenced followed below.

VFS: Busy inodes after unmount of vdd. Self-destruct in 5 seconds.
Have a nice day...
BUG: unable to handle kernel NULL pointer dereference at
0000000000000278
[<ffffffff8126a303>] evict+0xb3/0x180
[<ffffffff8126a760>] iput+0x1b0/0x230
[<ffffffff8127c690>] inode_switch_wbs_work_fn+0x3c0/0x6a0
[<ffffffff810a5b2e>] worker_thread+0x4e/0x490
[<ffffffff810a5ae0>] ? process_one_work+0x410/0x410
[<ffffffff810ac056>] kthread+0xe6/0x100
[<ffffffff8173c199>] ret_from_fork+0x39/0x50

Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: stable@kernel.org
---
 fs/fs-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..6b4136bf1788 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -900,7 +900,7 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
  */
 void cgroup_writeback_umount(void)
 {
-	if (atomic_read(&isw_nr_in_flight)) {
+	while (atomic_read(&isw_nr_in_flight)) {
 		synchronize_rcu();
 		flush_workqueue(isw_wq);
 	}
-- 
2.19.1.856.g8858448bb

