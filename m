Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C44B7C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2F221773
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b1oxKsey"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2F221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1B146B000D; Sat,  3 Aug 2019 10:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A560D6B000E; Sat,  3 Aug 2019 10:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944C56B0010; Sat,  3 Aug 2019 10:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEB06B000D
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 10:02:08 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s25so67324255qkj.18
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 07:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=nLlHstn4NE1DLTa8MBcCUwC1TFpRtd2dCdrLnBskzhg=;
        b=ERsIH9B5dQLL/Jg6hmvc2Ny5Ua8OifVyix0mvPsH1iU4UGoed9sQUi7rHH/JlVWATc
         arPZYQkdQdn7SII/j0Z9gvosWDXbyoRAaROx7cmwZfEYkd9UAvy72TJTCJRIFAWA0l1k
         8fMNhlp4Fpi/iEE7Z430++NgjzU2qOvSaxXvGyFbCqbtLbEb3LSVEqVQMoOsUFDoG/z0
         miMvr2xTsMwNm0sSLKRPAE/VSlu0qFgzS+utNmj+oafH+CDLxh1kdIxWNARy01ITnVXS
         Py/wTgmP2lOod+nBTPdnN13x4ZHFCCIyiuZdHblBGgzRUK2/h9SHcUqQzh2Bu2iF/AJ3
         bRIQ==
X-Gm-Message-State: APjAAAXr26WHNwkeULbfSS0sksloCjJgqXi81zo1iYHskfznyFkw7HS2
	2Mko+3HrWZnMp8orNx4GywB+8a8qPb4D2RroHchyBuqno3AbOXHvLWvf8DrfW09UFXB5QqTt8df
	ezqLHxH1tv3J9IlGNBEPmmxOHWq4citXf+KEPaB2b2fZqs7JIdANJjtkAzFDhF44=
X-Received: by 2002:a05:620a:12c4:: with SMTP id e4mr4464285qkl.81.1564840928235;
        Sat, 03 Aug 2019 07:02:08 -0700 (PDT)
X-Received: by 2002:a05:620a:12c4:: with SMTP id e4mr4464208qkl.81.1564840927355;
        Sat, 03 Aug 2019 07:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564840927; cv=none;
        d=google.com; s=arc-20160816;
        b=xt8yoiA6NVKNpuOp9GDu7mKlonMnwcaQ8YbSv33lmbfClspZT2Ssvgzigs0Nq2dt/f
         iJwzUH5C/v+CsnlEfkCVvJDcAMofBIUtmmyDd3ymKP/IawS8GU/0jDp3rBGRfUFg1oh9
         Q2M53S+Am30at2d21vO63NkyTOiXAP9FH3ZjhmZ8F+nzQK3Q/ANQx6GL7tOvKse8UnHF
         qKBsQjQT1cPY7WmQJJh6ewlDGMqCKAaIHY9l7EAt/g+r8RVFNNMzrKQm3wa8k7MVpTCZ
         de53W1BDQdn3UUBwVJ3jk4xg9/0n+QHgshCp4cqJUrVIZVPGYo2Zq2QeejRwKdv0ItJH
         oVFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from:sender
         :dkim-signature;
        bh=nLlHstn4NE1DLTa8MBcCUwC1TFpRtd2dCdrLnBskzhg=;
        b=h0vMLZvf5R9MgsX9zvELoKJ3MPP5/l+6utelzrUfUwF4fHuoG3ly69lcw21Biww2ck
         N2hoLwndNgdRJFvwG7pvnCregqoPuZZag+FE+ZXZMf+IuTwlc4YSqw1WdezdEOHfXzNg
         UgmLjgMUZWDjqP6H13hPUJvk7+hRjHxKyDCCtkH00yKVdH4Z8xeVNeNC+wxhFOZVJlCs
         aqef14KmnSUWMEo6XCf2gNxbB178iURcMrX0VYDSx9y3nhHYbMpAnDk4Ui6yyjLMC/Cd
         DDr7SqtSkOLaJNJXBrRFmbdnP9YDr6QRb5MucNGCWT5lV+eMztLOBk5mURxzz9evWk+2
         vCdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b1oxKsey;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u27sor66605789qvf.16.2019.08.03.07.02.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 07:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b1oxKsey;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nLlHstn4NE1DLTa8MBcCUwC1TFpRtd2dCdrLnBskzhg=;
        b=b1oxKseyt1LyDYjoudvzC1hpTJo++RG9fGoMA1s5KW/D/iHMPVK750EZAfJwkzPSC6
         uURCombHdllFO2iJlD57v5pIos+dxvvSVQwNR38Ny/GBOnKlw3SJFzjyc2Qsuc8Wwc4N
         Nv28xKTg1sJX4TSYvunTzqqhf8k+Oc6jCcIbufFqWeH3EwtZeLgDx/DSQPLU8DuSyjcQ
         tXnApdDsE/ZGqpT6H9+Ft332dtpil1zcgHKQRF3ZYGzFf9LB7cESicyzbnyBG2Jh2Q+8
         1RzH6XX1hi4m9gPi55cwHUJjDsdDWzfPe3th0+5QgvDKEqfhnUeE8IgKdzsVYoJsOxdk
         oCMw==
X-Google-Smtp-Source: APXvYqzMiari5I3bSyI7xBIGI8+SdQjIZjsTWhlYOhUC+G2ITji3BPgjA4OSJA43R/PapwQ5OGKLAw==
X-Received: by 2002:a0c:895b:: with SMTP id 27mr99111155qvq.94.1564840926938;
        Sat, 03 Aug 2019 07:02:06 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::efce])
        by smtp.gmail.com with ESMTPSA id z1sm38529457qkg.103.2019.08.03.07.02.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 07:02:06 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk,
	jack@suse.cz,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	guro@fb.com,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/4] bdi: Add bdi->id
Date: Sat,  3 Aug 2019 07:01:53 -0700
Message-Id: <20190803140155.181190-3-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190803140155.181190-1-tj@kernel.org>
References: <20190803140155.181190-1-tj@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There currently is no way to universally identify and lookup a bdi
without holding a reference and pointer to it.  This patch adds an
non-recycling bdi->id and implements bdi_get_by_id() which looks up
bdis by their ids.  This will be used by memcg foreign inode flushing.

I left bdi_list alone for simplicity and because while rb_tree does
support rcu assignment it doesn't seem to guarantee lossless walk when
walk is racing aginst tree rebalance operations.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/backing-dev-defs.h |  2 +
 include/linux/backing-dev.h      |  1 +
 mm/backing-dev.c                 | 65 +++++++++++++++++++++++++++++++-
 3 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 8fb740178d5d..1075f2552cfc 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -185,6 +185,8 @@ struct bdi_writeback {
 };
 
 struct backing_dev_info {
+	u64 id;
+	struct rb_node rb_node; /* keyed by ->id */
 	struct list_head bdi_list;
 	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
 	unsigned long io_pages;	/* max allowed IO size */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 02650b1253a2..84cdcfbc763f 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -24,6 +24,7 @@ static inline struct backing_dev_info *bdi_get(struct backing_dev_info *bdi)
 	return bdi;
 }
 
+struct backing_dev_info *bdi_get_by_id(u64 id);
 void bdi_put(struct backing_dev_info *bdi);
 
 __printf(2, 3)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e8e89158adec..4a8816e0b8d4 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -1,6 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0-only
 
 #include <linux/wait.h>
+#include <linux/rbtree.h>
 #include <linux/backing-dev.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
@@ -22,10 +23,12 @@ EXPORT_SYMBOL_GPL(noop_backing_dev_info);
 static struct class *bdi_class;
 
 /*
- * bdi_lock protects updates to bdi_list. bdi_list has RCU reader side
- * locking.
+ * bdi_lock protects bdi_tree and updates to bdi_list. bdi_list has RCU
+ * reader side locking.
  */
 DEFINE_SPINLOCK(bdi_lock);
+static u64 bdi_id_cursor;
+static struct rb_root bdi_tree = RB_ROOT;
 LIST_HEAD(bdi_list);
 
 /* bdi_wq serves all asynchronous writeback tasks */
@@ -859,9 +862,58 @@ struct backing_dev_info *bdi_alloc_node(gfp_t gfp_mask, int node_id)
 }
 EXPORT_SYMBOL(bdi_alloc_node);
 
+struct rb_node **bdi_lookup_rb_node(u64 id, struct rb_node **parentp)
+{
+	struct rb_node **p = &bdi_tree.rb_node;
+	struct rb_node *parent = NULL;
+	struct backing_dev_info *bdi;
+
+	lockdep_assert_held(&bdi_lock);
+
+	while (*p) {
+		parent = *p;
+		bdi = rb_entry(parent, struct backing_dev_info, rb_node);
+
+		if (bdi->id > id)
+			p = &(*p)->rb_left;
+		else if (bdi->id < id)
+			p = &(*p)->rb_right;
+		else
+			break;
+	}
+
+	if (parentp)
+		*parentp = parent;
+	return p;
+}
+
+/**
+ * bdi_get_by_id - lookup and get bdi from its id
+ * @id: bdi id to lookup
+ *
+ * Find bdi matching @id and get it.  Returns NULL if the matching bdi
+ * doesn't exist or is already unregistered.
+ */
+struct backing_dev_info *bdi_get_by_id(u64 id)
+{
+	struct backing_dev_info *bdi = NULL;
+	struct rb_node **p;
+
+	spin_lock_irq(&bdi_lock);
+	p = bdi_lookup_rb_node(id, NULL);
+	if (*p) {
+		bdi = rb_entry(*p, struct backing_dev_info, rb_node);
+		bdi_get(bdi);
+	}
+	spin_unlock_irq(&bdi_lock);
+
+	return bdi;
+}
+
 int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
 {
 	struct device *dev;
+	struct rb_node *parent, **p;
 
 	if (bdi->dev)	/* The driver needs to use separate queues per device */
 		return 0;
@@ -877,7 +929,15 @@ int bdi_register_va(struct backing_dev_info *bdi, const char *fmt, va_list args)
 	set_bit(WB_registered, &bdi->wb.state);
 
 	spin_lock_bh(&bdi_lock);
+
+	bdi->id = ++bdi_id_cursor;
+
+	p = bdi_lookup_rb_node(bdi->id, &parent);
+	rb_link_node(&bdi->rb_node, parent, p);
+	rb_insert_color(&bdi->rb_node, &bdi_tree);
+
 	list_add_tail_rcu(&bdi->bdi_list, &bdi_list);
+
 	spin_unlock_bh(&bdi_lock);
 
 	trace_writeback_bdi_register(bdi);
@@ -918,6 +978,7 @@ EXPORT_SYMBOL(bdi_register_owner);
 static void bdi_remove_from_list(struct backing_dev_info *bdi)
 {
 	spin_lock_bh(&bdi_lock);
+	rb_erase(&bdi->rb_node, &bdi_tree);
 	list_del_rcu(&bdi->bdi_list);
 	spin_unlock_bh(&bdi_lock);
 
-- 
2.17.1

