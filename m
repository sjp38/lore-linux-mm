Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F773C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 02:04:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDC912183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 02:04:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDC912183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B42C6B0007; Wed, 17 Apr 2019 22:04:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83CB56B0008; Wed, 17 Apr 2019 22:04:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 705386B000A; Wed, 17 Apr 2019 22:04:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE136B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:04:43 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id k28so369762otf.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:04:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=w6sLPutb4taZtrcFIkaA/Uq3TyeSiatryp4DDnoIiEI=;
        b=gT2htdXtqWNs8j882mW3jEoHx/JTYjr0zc3VPf1JrZsfdbmVR+zjheLe2lxFGyqKtM
         berZsmwCYih40PWMXl1AzHtC5grj9bUoy501JNI6/4I/t9VeRczCv7Qy74pSVHX9Pvko
         wabMwq4b5N4cFB7+eTZHui3A87XERRgRJvXK5TO+wNOPxCM8SRtaeT1LyQjRWks9lOLA
         DCoYmkkMDqpBWEoviqwARY7P9/rrl/FrKj7qjdvCLCxfZjA01NByAONtW+GyujKTb4mQ
         qA71jO+/A01Fg1bBItrtn1DDoDKcT/sw7e5Ne3tMgcZSSPns5s5Xc21Em2kvpzCbL0dE
         7ZsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW/++5n3VQ/3CvtnqO+pEHZIGc5wkBz5wMnctkE9F0Gylbr4zC8
	xd8p4r9jFtMqwyhw1a0ByH6VDMwfjiw6BaUFvIl8qgFIGEsebKUnI/cIb7Er6w1BkZKgTuPCQjl
	CPSs7MnDLGl7Fvh2L3BkDosY5ESC1ptNJWAYbNRrjsX7mFfY8dV7LKsCv2oXqkjGXug==
X-Received: by 2002:a9d:3b25:: with SMTP id z34mr57013866otb.298.1555553082870;
        Wed, 17 Apr 2019 19:04:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtUjzb7OEfzAekmFtSXSN1WWVn3KKeUGc5qdvMMmB02mKVh87HWfdsJoFvQalEfhYlsqie
X-Received: by 2002:a9d:3b25:: with SMTP id z34mr57013821otb.298.1555553081579;
        Wed, 17 Apr 2019 19:04:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555553081; cv=none;
        d=google.com; s=arc-20160816;
        b=iUXgHTqCTbTtZTZK7Kr8gdhWmBL4tkIsD3mj8dHwGbj3ek0cBnQahkhVRH1QsIBCJR
         VaTp/3bzLU3kdQqP1hqejOcAPGPefa/5JZUmEKOax/szXdjeA4MVpnjVN52rxrPDfHS/
         M+1NG3uO7IX4aUI0Ac2tgkVrkeuK428ngXMK5dEYaiRGPwwXeLED5K9RB1kZcVwiJ9FF
         HfgRRvYLMwtUonZ+687VKzzWmEU590d4+DIDzXQOxKms+2Aj30AsIyIDTdWo656MlqkU
         3V1Blhp5pP7QjEfpUBWxGqUl5RdkGc2J0abQhc0ysBBX8ebyaygdYzJQhUqXVkbTJZTp
         PTPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=w6sLPutb4taZtrcFIkaA/Uq3TyeSiatryp4DDnoIiEI=;
        b=ixvsWqL8B3H90WaUwKwMC2uINCtvj2N66wNyt5eLoQ+WEBkoCeXcDZ2TKvYdtkP2wC
         2emBRA1hB9bKm3vGXHQjs8VKGaMEN5fBo+mOhAr5zKshtn70OZKGjvPQj19F1zeDsMYV
         x2izofTWoUnMFskXSdUu+fU4GYznvSoTBb0f25oLBjiZs2eugoY2EVd2z7cd2foo5uzn
         ErL+iKB9pBboevlYh/iF+uQHgkniSaDz3L19s460KMBFomeuIrP0MDnSEFq+SqxFlN2D
         L0tzzeIOH6kF4DCHT47dSCnavFIiUYNEcuuaDGjjg8aMmeQH6uzdNsU9HEuDUPGFA/UF
         x1Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id w205si306180oib.102.2019.04.17.19.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 19:04:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jiufei.xue@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=jiufei.xue@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R531e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TPbWiJ4_1555553066;
Received: from localhost(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TPbWiJ4_1555553066)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Apr 2019 10:04:26 +0800
From: Jiufei Xue <jiufei.xue@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-mm@kvack.org
Cc: tj@kernel.org,
	akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com,
	bo.liu@linux.alibaba.com
Subject: [PATCH v3] fs/writeback: use rcu_barrier() to wait for inflight wb switches going into workqueue when umount
Date: Thu, 18 Apr 2019 10:04:26 +0800
Message-Id: <20190418020426.89259-1-jiufei.xue@linux.alibaba.com>
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
 fs/fs-writeback.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 36855c1f8daf..fede1f685539 100644
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
@@ -901,7 +902,7 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
 void cgroup_writeback_umount(void)
 {
 	if (atomic_read(&isw_nr_in_flight)) {
-		synchronize_rcu();
+		rcu_barrier();
 		flush_workqueue(isw_wq);
 	}
 }
-- 
2.19.1.856.g8858448bb

