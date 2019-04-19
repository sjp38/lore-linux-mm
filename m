Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3510C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 01:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90726214DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 01:08:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90726214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1D6A6B0007; Thu, 18 Apr 2019 21:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCC716B0008; Thu, 18 Apr 2019 21:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBDBE6B000A; Thu, 18 Apr 2019 21:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 927F96B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 21:08:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r13so2389958pga.13
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=mYriDKxpxf4DvwDzBctP0HCwHj7Z8j8CRYhgzkOlfFw=;
        b=eXqM41TlN7WDoXm5m7MpbP4YTStUsqwBKjGXs2IG0IR32bHTOzuvoyJKmhU2ayigL7
         8AMs0KaSiJID0SCtWoq/CfhBxZXL/TBrI59S5nWBUNvyl7MTCeDQHBPupJUYeMhBuL/d
         M80bW46lCypeYidgJYnIwjxYy3pIYOhKko6io8P02W6D6e4OLysMTMFT6TOhLQuW9oWk
         OJuGT6pPYUvsC//KcdqGsElWwmjwHArBcvZ4wpSrht+xvdgqTFCc6AKOdTGW/iFvGFvF
         GIE4wpx87RlzZgZcBDjy9VRtpNveT1H36DvL9CCwjMjQcfrkzfzcr//Acurt9vlIMxwm
         vPuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV4vFZGMkw4cpjnosfzhxiU/WqiWWso5Jnj6NfrOXWrm5Fjn/5+
	1akG91EqxWYybhc7b8TUPPi6WyF6M1Hufxc/D1u6ABW/rapMMDg/cvrNR+IZlSgC4qOqfKKFpS4
	QDRWSv2xqw3iHYuBHmL5HyOLlgMUjpSzfTC9AjA691o+2NnFRBQnVe6aKJDRTUp/aXQ==
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr766650plb.147.1555636109173;
        Thu, 18 Apr 2019 18:08:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUNmBOifQ/XjpzJbUcPdkWK9ELa2edX8Fwew2heuua5u1+LeB2g6jUVJqXbul0SIIcOE1B
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr766560plb.147.1555636107902;
        Thu, 18 Apr 2019 18:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555636107; cv=none;
        d=google.com; s=arc-20160816;
        b=xrhHFC7XU4iFa6LH0DxK8iZocYxeirv+oH4PcJMnNSlj9SvCgrvuW8TtCcRSQD+aNT
         oqnDrJhn4WGQXx+I2TPzw7D/ToJnvvU8dcdTPmyrOYdWrctKwQVHcEn/MegZOJ0LSTjR
         RkQdzZERKZRMJvHyAm8tpCJ5KvMdn9Ho3Us2FlV35EzymEaEh1ILAyRKGXEY0V5XZQhq
         miiDFumpGymaEFqoeoa5J3h9xWpMyTzvrMZg1pllsF2iYHnww96hh2e/wGlr71CgkejL
         NqAEbY/tf5YgVu6/QyOGVRtWqGEHEoR/Tbj3CpMTEojsexlcmMCgHmF0QLq/NOqJwMTX
         1GNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=mYriDKxpxf4DvwDzBctP0HCwHj7Z8j8CRYhgzkOlfFw=;
        b=kXzBJG1ncwcKYg750gACqQavhgdkbFggWHmvqYQin0sPv9Lq4o3j1V4pxmFbTUqe9u
         8wkl/B5uOL1bHINssuaEXm8oYr01B/YLzRG1JmNYieab+9pkntsEXjyHK9O12DG0zo1+
         YZulo8XB3wYZoztgQmGHFkM4wUEBSeEIbNIaFFZe0g17br6Pds6qLUc7evJb23R5D+hY
         Xl7q6oXxopfw9F460Faej0innOLNcLbz0GxWplSo6y4/ZjorX/IdOLD1oZurO/Y64yz4
         bGt9sI2qkV56vMzQXU1uRfAaWazRbHRYHlXUefTAGzjCth5B3siwMFZt56s57wuYH10q
         iUUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id 73si3544214pgb.414.2019.04.18.18.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 18:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R441e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TPg--qB_1555636105;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TPg--qB_1555636105)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 09:08:25 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Cc: tj@kernel.org,
	akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com,
	bo.liu@linux.alibaba.com
Subject: [PATCH v4] fs/writeback: use rcu_barrier() to wait for inflight wb switches going into workqueue when umount
Date: Fri, 19 Apr 2019 09:08:24 +0800
Message-Id: <20190419010824.28209-1-jiufei.xue@linux.alibaba.com>
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

VFS: Busy inodes after unmount of vdd. Self-destruct in 5 seconds.  Have a nice day...
BUG: unable to handle kernel NULL pointer dereference at 0000000000000278
[<ffffffff8126a303>] evict+0xb3/0x180
[<ffffffff8126a760>] iput+0x1b0/0x230
[<ffffffff8127c690>] inode_switch_wbs_work_fn+0x3c0/0x6a0
[<ffffffff810a5b2e>] worker_thread+0x4e/0x490
[<ffffffff810a5ae0>] ? process_one_work+0x410/0x410
[<ffffffff810ac056>] kthread+0xe6/0x100
[<ffffffff8173c199>] ret_from_fork+0x39/0x50

Replace the synchronize_rcu() call with a rcu_barrier() to wait for all
pending callbacks to finish. And inc isw_nr_in_flight after call_rcu()
in inode_switch_wbs() to make more sense.

Suggested-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: stable@kernel.org
---
 fs/fs-writeback.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..b16645b417d9 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -523,8 +523,6 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 
 	isw->inode = inode;
 
-	atomic_inc(&isw_nr_in_flight);
-
 	/*
 	 * In addition to synchronizing among switchers, I_WB_SWITCH tells
 	 * the RCU protected stat update paths to grab the i_page
@@ -532,6 +530,9 @@ static void inode_switch_wbs(struct inode *inode, int new_wb_id)
 	 * Let's continue after I_WB_SWITCH is guaranteed to be visible.
 	 */
 	call_rcu(&isw->rcu_head, inode_switch_wbs_rcu_fn);
+
+	atomic_inc(&isw_nr_in_flight);
+
 	goto out_unlock;
 
 out_free:
@@ -901,7 +902,11 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 void cgroup_writeback_umount(void)
 {
 	if (atomic_read(&isw_nr_in_flight)) {
-		synchronize_rcu();
+		/*
+		 * Use rcu_barrier() to wait for all pending callbacks to
+		 * ensure that all in-flight wb switches are in the workqueue.
+		 */
+		rcu_barrier();
 		flush_workqueue(isw_wq);
 	}
 }
-- 
2.19.1.856.g8858448bb

