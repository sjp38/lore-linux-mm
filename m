Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F101C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CE47217D8
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:53:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CE47217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 985316B0008; Tue, 21 May 2019 00:53:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934096B000C; Tue, 21 May 2019 00:53:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 824E16B000D; Tue, 21 May 2019 00:53:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3165E6B0008
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:53:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5so28782033edz.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:53:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=rX3tmFnDBHq8c3zM6clbCsU1d9V2kYeDMHx4D3qEo4Y=;
        b=gSQmRDLZx0W+pmLAYw7Lrzl2P6EgkI5gk6YETPAmb1xO5ODq6HMOgPqVqjnSeFks1W
         cRxjN87al/u8cVhMO/BUaT6zZ36V7l8WS+jUEvvM0NzB+mKmKLv3R89Qp3CGAzELmZaI
         J2k/R4bJdkF/UYoOUZ0y1tQ6rt0gpitNg/Put1Nm6QJ01yhA1at36H85yVyvaZxGzvnc
         5SGv8av9k8U/g5A6Q77QLkEQjGDNu6Ql9h5NS+n2KRvUxai0er92IEhbyPKL1D+sIgUG
         bvzKoNLHovrhX/1+NavN9qE1oIfNB6fgkYtv4hv7Dn30esEXZ12F6LPc068VDIU7qYW2
         qS9g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAW33zBg9SbQWBfzH/2PyGzoy7p9dkvo9b3VMqZfXYQXxMpY62y4
	IDypBwLOfSsT7Dx+AwO2XTeFYtqCRW3wu2mzoSBbBSyxBkTAT+YtyGGSrZzMIF7RcqaHVSL7Ets
	LrZhble6kjtGkq9134R608SAEtV0MJ1qmjf9gqtT6KXBSK7M8AFKZ6c1/vxy8jmI=
X-Received: by 2002:a05:6402:6d2:: with SMTP id n18mr81019394edy.122.1558414413729;
        Mon, 20 May 2019 21:53:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbK+p9fAfqMrC5d+YcGF6t64QMdOWKUR75Q+FBTSBqkNJyx9ZMO1RwQMPnQyUaOyNAMIW2
X-Received: by 2002:a05:6402:6d2:: with SMTP id n18mr81019336edy.122.1558414412578;
        Mon, 20 May 2019 21:53:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414412; cv=none;
        d=google.com; s=arc-20160816;
        b=qTPdnp3QErdFZkT84CsNEg+EYrtruRdyXEbz1w3qExxPzqXU9JO2KH8tFIlAHYXOlt
         +3Jv4ivSBpQ49sPbhqxeR3OWEAtbG5rjyaexphxK0ij4cqu0Il0Wo4fhvukp+MzDbzVr
         1/c7yYZIHXrzUWVEu0Gsb8swBN0bTi44s837BvFOIwWWDmM352huqbDb1co1wZQVFzcP
         07Krp7j7yMN52JM7Zn8cSBf33cDrqovoaZ/mrLnUPhngFrVBAS7kQIKUfs8IKmuekJUb
         RM7YJ+k+eDYcg+9o7R+k0LgZx1ZUJ/4zsetKnlv3UTuOSKIAlNaQI0aQczmPbCveHRXm
         euqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=rX3tmFnDBHq8c3zM6clbCsU1d9V2kYeDMHx4D3qEo4Y=;
        b=HMmWdxuNSVns6enIXrLsgR42ALQomvZmmB9XXZRYgXBrB46MDoGXf780QqZs/0mEbr
         cj6PsW8vvbqBosjvSIeosPhXNEicVptTRghbMWAqXMTpllg2nZIaso4KFqMtGO5Fa4gl
         8cyh27fDHF6cADRAfjA1PT/05jDG1Xust+7pcX9eKF30pH0DvQ1KEHR+MkB4Ie0/USmO
         0nYCQFmQ3cZ4Tmq01iW5r4pRIkqTOEemnUT/f69KxX3t57JGkmPAYsk4xgvbv/Ub9Z4p
         hU6v9bHAC4B/BEwGtdK/0HWUgXP51c90tWQIOL2jV8yJod6QQFCUYoqJ+/GyO2KxRKPS
         cCHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id w20si2516375eda.95.2019.05.20.21.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 21:53:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 06:53:31 +0200
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Tue, 21 May 2019 05:53:01 +0100
From: Davidlohr Bueso <dave@stgolabs.net>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@kernel.org,
	mgorman@techsingularity.net,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com,
	dave@stgolabs.net,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 03/14] mm: introduce mm locking wrappers
Date: Mon, 20 May 2019 21:52:31 -0700
Message-Id: <20190521045242.24378-4-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190521045242.24378-1-dave@stgolabs.net>
References: <20190521045242.24378-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds the necessary wrappers to encapsulate mmap_sem
locking and will enable any future changes to be a lot more
confined to here. In addition, future users will incrementally
be added in the next patches. mm_[read/write]_[un]lock() naming
is used.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mm.h | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..780b6097ee47 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -12,6 +12,7 @@
 #include <linux/list.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
+#include <linux/range_lock.h>
 #include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
@@ -2880,5 +2881,80 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+/*
+ * Address space locking wrappers.
+ */
+static inline bool mm_is_locked(struct mm_struct *mm,
+				struct range_lock *mmrange)
+{
+	return rwsem_is_locked(&mm->mmap_sem);
+}
+
+/* Reader wrappers */
+static inline int mm_read_trylock(struct mm_struct *mm,
+				  struct range_lock *mmrange)
+{
+	return down_read_trylock(&mm->mmap_sem);
+}
+
+static inline void mm_read_lock(struct mm_struct *mm,
+				struct range_lock *mmrange)
+{
+	down_read(&mm->mmap_sem);
+}
+
+static inline void mm_read_lock_nested(struct mm_struct *mm,
+				       struct range_lock *mmrange, int subclass)
+{
+	down_read_nested(&mm->mmap_sem, subclass);
+}
+
+static inline void mm_read_unlock(struct mm_struct *mm,
+				  struct range_lock *mmrange)
+{
+	up_read(&mm->mmap_sem);
+}
+
+/* Writer wrappers */
+static inline int mm_write_trylock(struct mm_struct *mm,
+				   struct range_lock *mmrange)
+{
+	return down_write_trylock(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock(struct mm_struct *mm,
+				 struct range_lock *mmrange)
+{
+	down_write(&mm->mmap_sem);
+}
+
+static inline int mm_write_lock_killable(struct mm_struct *mm,
+					 struct range_lock *mmrange)
+{
+	return down_write_killable(&mm->mmap_sem);
+}
+
+static inline void mm_downgrade_write(struct mm_struct *mm,
+				      struct range_lock *mmrange)
+{
+	downgrade_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_unlock(struct mm_struct *mm,
+				   struct range_lock *mmrange)
+{
+	up_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock_nested(struct mm_struct *mm,
+					struct range_lock *mmrange,
+					int subclass)
+{
+	down_write_nested(&mm->mmap_sem, subclass);
+}
+
+#define mm_write_nest_lock(mm, range, nest_lock)		\
+	down_write_nest_lock(&(mm)->mmap_sem, nest_lock)
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
-- 
2.16.4

