Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A404C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:08:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C16D020C01
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C16D020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F0C98E0003; Mon, 29 Jul 2019 17:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A10C8E0002; Mon, 29 Jul 2019 17:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48F508E0003; Mon, 29 Jul 2019 17:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2855B8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:08:38 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id j63so27008404vkc.13
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:08:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=pQAkZdb2MdpLX83iuWv5XMam8kwNDm0XeAT4DOHX2Vg=;
        b=DPeN6lTSkC0crLR9o8TVIWZPXihcHveXbZtTM0w2gSLL+qiQIeskwYvgHKD+Yhrr0x
         QTSUDloELY2nwpoGpDNoFENK0vQ9pBcAJjNmYI3EYXeriRAtySRrYFQufBrPO9bAWSnD
         8ExMYpKUNcF5vNRi80hpcf4N7BafYb7K6EJSfTxmTvzTIYJFWmONy2oqMu2zSz5cfwgF
         M1rR01qJovmv+Mmuk84EA+XBe31eUIREALTurWdj/JYJdmuASD4xh9lqp7WZlTJ/EqL1
         SiDyY63CGTV4ikeN+THk7z9PtU+w+FYzH7ahrF3xqhmthQ96HcfWsit6c4ZJoQj4ffrh
         aY3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUvXr8Qzft/t8GyQwTpKHZiFf88NyuAy5JW5oTJr0jGeF4kDg6o
	VuZFruW1KGEMbF10kKY7yNwaz8cW31IoML2o8xo6ITEgOb6DPLybazHxDZg+cUsheXCdfv6VvBz
	2wY5CPamAUXfydQMG1HD+F2dF/8o3bEu2YJ7Cw86cgke/CFP+0Z3n5zxdK2XSTBJRKg==
X-Received: by 2002:a67:fe4d:: with SMTP id m13mr27067654vsr.177.1564434517919;
        Mon, 29 Jul 2019 14:08:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuW1xe7LsLL3V7gCqTD7pNQbUZ8tRNdzGDEHzM5Ce16rKtonSJx5DHLAl4mAAbrqbrv1By
X-Received: by 2002:a67:fe4d:: with SMTP id m13mr27067590vsr.177.1564434517248;
        Mon, 29 Jul 2019 14:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564434517; cv=none;
        d=google.com; s=arc-20160816;
        b=haLEfb6yBmyZ43Mi7oOslx1ylK2lIzW/cxAY3B1MNa5AjIRChTdxYsfA9YYZ7puf/w
         mbPm7qta2e1uTmM7xYCuaiLgdlOTfxPzcrLVVPo1jpY6PrhPd0oEHXRyCDhTHvQmBxAa
         t+N0z7HuyAFfDpNvQM5ViOiN/gP/v4PI5k89j9O09sjDQz3B5MDhfLD9RZfA9uTOguM7
         0el81qa55ZnQoQkyKeBXbCv8LfU2hDV1sGV8yej22dRWZ9gYBLvMUhSgg/6RKzYUcF90
         613OQB48ysMfu0v0WHRK8Mx+YuEMM8gX7I583BmTi8gskGIaEoMucET/ps5WqwYxpB7w
         N3gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=pQAkZdb2MdpLX83iuWv5XMam8kwNDm0XeAT4DOHX2Vg=;
        b=H4iuW1ioriiQPNeZrIkudzFB1XIKaN10G2oThzTgooRY1QaGtljMzvkeVRkO2LCfOE
         OMMZeFpXBmAFMFYSrm9l27EkvDsTsgsprlVWNIZTzOmhCt4eRYzi+Dqe/npD0QwN9NkI
         aTENR0U6qDTtEXdxaRvhG2OD4nbmYQcy9wK2RMZRdce343Q47afGYfy8puAH7ZZGZS9A
         gk84Kawq3scg3UsiuoCaPfRPT/5l/FWmTPvicKxLGJHcjhkVT3CwD/sC1VmwLtrsUCw5
         eKQzAqhieB2rtLjGBjhKbaBFfEOgVNHgMRriCPOdGC8lkq424iRT3+NEqXjxtrpFpFze
         uoJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y1si9771322vsl.56.2019.07.29.14.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 14:08:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F3F530860C6;
	Mon, 29 Jul 2019 21:08:36 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5E8175C1A1;
	Mon, 29 Jul 2019 21:08:30 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH v3] sched/core: Don't use dying mm as active_mm of kthreads
Date: Mon, 29 Jul 2019 17:07:28 -0400
Message-Id: <20190729210728.21634-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 29 Jul 2019 21:08:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It was found that a dying mm_struct where the owning task has exited
can stay on as active_mm of kernel threads as long as no other user
tasks run on those CPUs that use it as active_mm. This prolongs the
life time of dying mm holding up some resources that cannot be freed
on a mostly idle system.

Fix that by forcing the kernel threads to use init_mm as the active_mm
during a kernel thread to kernel thread transition if the previous
active_mm is dying (!mm_users). This will allows the freeing of resources
associated with the dying mm ASAP.

The presence of a kernel-to-kernel thread transition indicates that
the cpu is probably idling with no higher priority user task to run.
So the overhead of loading the mm_users cacheline should not really
matter in this case.

My testing on an x86 system showed that the mm_struct was freed within
seconds after the task exited instead of staying alive for minutes or
even longer on a mostly idle system before this patch.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/sched/core.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 795077af4f1a..41997e676251 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3214,6 +3214,8 @@ static __always_inline struct rq *
 context_switch(struct rq *rq, struct task_struct *prev,
 	       struct task_struct *next, struct rq_flags *rf)
 {
+	struct mm_struct *next_mm = next->mm;
+
 	prepare_task_switch(rq, prev, next);
 
 	/*
@@ -3229,8 +3231,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
 	 *
 	 * kernel ->   user   switch + mmdrop() active
 	 *   user ->   user   switch
+	 *
+	 * kernel -> kernel and !prev->active_mm->mm_users:
+	 *   switch to init_mm + mmgrab() + mmdrop()
 	 */
-	if (!next->mm) {                                // to kernel
+	if (!next_mm) {					// to kernel
+		/*
+		 * Checking is only done on kernel -> kernel transition
+		 * to avoid any performance overhead while user tasks
+		 * are running.
+		 */
+		if (unlikely(!prev->mm &&
+			     !atomic_read(&prev->active_mm->mm_users))) {
+			next_mm = next->active_mm = &init_mm;
+			mmgrab(next_mm);
+			goto mm_switch;
+		}
 		enter_lazy_tlb(prev->active_mm, next);
 
 		next->active_mm = prev->active_mm;
@@ -3239,6 +3255,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
 		else
 			prev->active_mm = NULL;
 	} else {                                        // to user
+mm_switch:
 		/*
 		 * sys_membarrier() requires an smp_mb() between setting
 		 * rq->curr and returning to userspace.
@@ -3248,7 +3265,7 @@ context_switch(struct rq *rq, struct task_struct *prev,
 		 * finish_task_switch()'s mmdrop().
 		 */
 
-		switch_mm_irqs_off(prev->active_mm, next->mm, next);
+		switch_mm_irqs_off(prev->active_mm, next_mm, next);
 
 		if (!prev->mm) {                        // from kernel
 			/* will mmdrop() in finish_task_switch(). */
-- 
2.18.1

