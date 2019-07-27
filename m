Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F4D3C76190
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 17:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50F5720693
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 17:11:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50F5720693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D65698E0003; Sat, 27 Jul 2019 13:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D15D78E0002; Sat, 27 Jul 2019 13:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE688E0003; Sat, 27 Jul 2019 13:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA518E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 13:11:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t124so48138331qkh.3
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 10:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=AJ7loeqFGHMLZYzh3gmTsOBzBuH6fHrUffoC1Y5VsnI=;
        b=UnNmTCyFd2kSyTd63MVItTb+FlUjZ5XNtBwoM9Y49Ch1Y39omw6DGpoFL5iRr2ElL4
         B+j8q8Lv1MsSmGsAzjaKnMBqmAOT+yQEUiTJp/iTbKLbnET3b+F6Dh4lt8BxC6FlHccr
         DZ4j7SlphHMT/EEEvoEibGqjRjpW/L+YxaygCPmDJXgyGHStDz27wGqYCkH5L5huumK0
         uIaeX5C6mFlGoEmlXQ2kbuVxfTJh6gegHA9MMKSoBfztsdltMsjqclzqDL6F30Ztwdtw
         Biv9p5qmKdxdNCKu4pHUU0VSRif0lyZ1vPOkXJkrWt22//RloisZbz/HHICT7XKoncqP
         kYgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6l5Py15kbXYVbmrYm3eJ4hYAqKuQn+Gn5s7Z+SVe2diDArRlu
	Q4t6DbNEjvEaToxffJ+qAaYQV3c/am6vXOH3bkMSwzahll8fkWmZlT03z4j0oGHhtIaqnU54Azi
	UXIb9VhN6D4RsuC1JjNARLKWaoqJYH/ZGgM0thcqyNZrn67ln2lO0txWJRkCwlT7Czw==
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr70319053qta.169.1564247500343;
        Sat, 27 Jul 2019 10:11:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjlaHkdJt2bpJ6dPc6nssDu/zRfKb6lGzssl7lQIyw8U2of59tbMsF6AS+kY/aUmHCZwcH
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr70318981qta.169.1564247499084;
        Sat, 27 Jul 2019 10:11:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564247499; cv=none;
        d=google.com; s=arc-20160816;
        b=lBTa79z6ylERjr9QRJgOxQ2/c8vEx3Si/jEEk2CtH1u/k1KD+RrWgOMcUEKaNJ3SPd
         RqfiLzMvg+kINjRc712bpkgWbUlzBFkOGVc2OxWiKErxHDDqXYGXBMlP6qqNcTurshIh
         WxVxXGf9habqwvOztxW4CI7+m2j4ylODi2TMuVz4Xpb38sXjZVu4u/bFJ1nS6QNwx5wr
         J8nlt6qv8FjMMcvwMD+JyDEoZfm0a7SpAuZBLaY8Sum9JeftIarWVi3hwIBSsuuitTp2
         2QxTl7W+8cfA8TbEmDG5Jcxwx2SH1HmWtS036fqB0TasT63R3YAaeq0cokuuI+xv59nh
         qcEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=AJ7loeqFGHMLZYzh3gmTsOBzBuH6fHrUffoC1Y5VsnI=;
        b=puDRDkNR5hrAHMS7tH+tJueVzCOn5KMcfJ+fzoD34c0QVncLUcGZ2X10Pm3OJiV0xc
         gIcp9zm/6E7bGQOmbRYjFZaXpQq+OSofV1CNBSoA3H3EQg7/YhQC3sQlM7UMi3xBC94e
         y8XMXNnW/5VTIs3taA/Tyw8R91/KtoQRJlmQVXE2oMHKFyHytNqwmewFMgkpeQJmO0vu
         KSFbHjADCg3mkLdkD25mXehdPMX6INRtxEqT+aTlj8s8C9nX3SCNZt+uZIXpJryWOWOt
         tCmirEnzViHsciXP0mnaEQVCNLT4IQ5KnxLZ+wAKQjFYi4HS+0qea4AXRDfmHpBJITd2
         4v3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p67si34438614qke.10.2019.07.27.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jul 2019 10:11:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1918236899;
	Sat, 27 Jul 2019 17:11:38 +0000 (UTC)
Received: from llong.com (ovpn-120-96.rdu2.redhat.com [10.10.120.96])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EBFDB1001B07;
	Sat, 27 Jul 2019 17:11:34 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH v2] sched/core: Don't use dying mm as active_mm of kthreads
Date: Sat, 27 Jul 2019 13:10:47 -0400
Message-Id: <20190727171047.31610-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Sat, 27 Jul 2019 17:11:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It was found that a dying mm_struct where the owning task has exited
can stay on as active_mm of kernel threads as long as no other user
tasks run on those CPUs that use it as active_mm. This prolongs the
life time of dying mm holding up memory and other resources like swap
space that cannot be freed.

Fix that by forcing the kernel threads to use init_mm as the active_mm
if the previous active_mm is dying.

The determination of a dying mm is based on the absence of an owning
task. The selection of the owning task only happens with the CONFIG_MEMCG
option. Without that, there is no simple way to determine the life span
of a given mm. So it falls back to the old behavior.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/mm_types.h | 15 +++++++++++++++
 kernel/sched/core.c      | 13 +++++++++++--
 mm/init-mm.c             |  4 ++++
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3a37a89eb7a7..32712e78763c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -623,6 +623,21 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
 	return atomic_read(&mm->tlb_flush_pending) > 1;
 }
 
+#ifdef CONFIG_MEMCG
+/*
+ * A mm is considered dying if there is no owning task.
+ */
+static inline bool mm_dying(struct mm_struct *mm)
+{
+	return !mm->owner;
+}
+#else
+static inline bool mm_dying(struct mm_struct *mm)
+{
+	return false;
+}
+#endif
+
 struct vm_fault;
 
 /**
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2b037f195473..923a63262dfd 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3233,13 +3233,22 @@ context_switch(struct rq *rq, struct task_struct *prev,
 	 * Both of these contain the full memory barrier required by
 	 * membarrier after storing to rq->curr, before returning to
 	 * user-space.
+	 *
+	 * If mm is NULL and oldmm is dying (!owner), we switch to
+	 * init_mm instead to make sure that oldmm can be freed ASAP.
 	 */
-	if (!mm) {
+	if (!mm && !mm_dying(oldmm)) {
 		next->active_mm = oldmm;
 		mmgrab(oldmm);
 		enter_lazy_tlb(oldmm, next);
-	} else
+	} else {
+		if (!mm) {
+			mm = &init_mm;
+			next->active_mm = mm;
+			mmgrab(mm);
+		}
 		switch_mm_irqs_off(oldmm, mm, next);
+	}
 
 	if (!prev->mm) {
 		prev->active_mm = NULL;
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a787a319211e..69090a11249c 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -5,6 +5,7 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/cpumask.h>
+#include <linux/sched/task.h>
 
 #include <linux/atomic.h>
 #include <linux/user_namespace.h>
@@ -36,5 +37,8 @@ struct mm_struct init_mm = {
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
 	.cpu_bitmap	= { [BITS_TO_LONGS(NR_CPUS)] = 0},
+#ifdef CONFIG_MEMCG
+	.owner		= &init_task,
+#endif
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
2.18.1

