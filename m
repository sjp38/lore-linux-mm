Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A91C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:46:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6224421994
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6224421994
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04A276B0005; Fri, 26 Jul 2019 19:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3D6B8E0003; Fri, 26 Jul 2019 19:46:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E04708E0002; Fri, 26 Jul 2019 19:46:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB88B6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:46:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so48817351qtj.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:46:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=frlkts6ZiLTiKiU2eqNAXFezl9wHVpwj1r4yRG5b9/A=;
        b=Fxxfy+juZszjFCz3OhOLdeVDlTNjFWz/eOo7emYARr+hT0/yyxvPRow8gPulFK8MOJ
         xTyC0sAZV2fjf5pAJ8HdF+9l/1RggRWjEZqUuuclfTX7vX/NkPnI2AbEIY2tgXzUetgL
         6oBKVyZoQB5xURqsqZJxm9cQFjl10eFUj9v2FssTj8IfNqrLhBlKE8cSfAq3TwxbDk51
         3gHLS8hsN7uWtYpDpzuvxkzjc3w3iwOv4QHyElnrBTA5+cbzRZAEIiwUROJkaGmyW0XO
         X9VCmOxVzHvWth+m3LJwMKFX9RaOY/lpWPSMzd7Nwxq7uxoKJBLZoom+srz3a+UiQ/la
         qY3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVz5ZtYMlpx2qgp1UvhpUciG2HeNeuV3MFxCFiDgEc//pVdtpSo
	yqpTnOnrPu7CwIVMSs7EVgBOfqQaa0cKY/AKENCdRp8WiQVf4eIg7Hxclh7gc42Y4ky01JYPt/L
	DXVnmZPmyRuEcKMahqMl/N0lXa46f15AtARQa10oR9FcX7rSR3QlgAr0bCJ1IXGGUjg==
X-Received: by 2002:a37:512:: with SMTP id 18mr60583932qkf.220.1564184764546;
        Fri, 26 Jul 2019 16:46:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjjw9DzJzGF21s86rCJ0fDTawaVYp2kMTxTkQm75CI7a/YLF2Tgtah8nxWbDZffrsD6nmI
X-Received: by 2002:a37:512:: with SMTP id 18mr60583892qkf.220.1564184763604;
        Fri, 26 Jul 2019 16:46:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564184763; cv=none;
        d=google.com; s=arc-20160816;
        b=TKBW7WHmHn94f/OyGIEBdUPQ0bNtTyfAPz9jzxJShcjUaHEDQvfLi8MznrZs5Dhcjw
         sM2b1RyNpRRAmw0LyJc3WXWdDMVsU1HlEZtbNTs63m+KT3cv0YkZyOXCptm9HY1Foxqb
         Mv+ZhoaOCDbVOgm2CKPgHcaZWH/ub1PU7jUMjfZRVKqKptKcOnpdYtjo7G/kGBCHhORA
         rSINkj/KpcCjt3UACzjYXdweG6VXY0UbkS7/EWnDpH2sod9gpNQzcQTjgyd2CzKZfJ+9
         tHou0hIAUaSnZjF2n8e22kZb0k5oziHp+Q0sl8RyuQ8SdOX59oW4Hn5DuulrnoYu/4h6
         +wQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=frlkts6ZiLTiKiU2eqNAXFezl9wHVpwj1r4yRG5b9/A=;
        b=yFiesNcuPhOweq4+lIXWgyQUu2qGug6yMHOYMTt5FKb98Fkec33vucJSlZzv94yZ0t
         rWaN3RdcUrUuxcdvUV4KL1PtLiLEFTXK7JCK/vInZZ5GYqTYQhOjodw4kECPzg9bcc6N
         ney4mx44hUHaxVmSWZh50eKdEVTbdkKUco9PKnFYqqQ+XWZ6/Mz8bujT7yLGT2Hgk+Wd
         ed/3W7bGUt99MKTv5pSdLz3XxAIyhTQxA2XXPm7npxuPx43hSW695I6juETB8Do7KHW8
         Bvz1ZHm6WldCtwGBYyyxkPd/HCjI8UQbUb61x3l7ZWrAuK9TJFUlObAEZmXl9PRT70ao
         remQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i1si33317978qvq.100.2019.07.26.16.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 16:46:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C595785539;
	Fri, 26 Jul 2019 23:46:02 +0000 (UTC)
Received: from llong.com (ovpn-124-85.rdu2.redhat.com [10.10.124.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8C2C319C69;
	Fri, 26 Jul 2019 23:45:59 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH] sched/core: Don't use dying mm as active_mm for kernel threads
Date: Fri, 26 Jul 2019 19:45:41 -0400
Message-Id: <20190726234541.3771-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 26 Jul 2019 23:46:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It was found that a dying mm_struct where the owning task has exited can
stay on as active_mm of kernel threads as long as no other user tasks
run on those CPUs that use it as active_mm. This prolongs the life time
of dying mm holding up memory and other resources that cannot be freed.

Fix that by forcing the kernel threads to use init_mm as the active_mm
if the previous active_mm is dying.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/sched/core.c | 13 +++++++++++--
 mm/init-mm.c        |  2 ++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 2b037f195473..ca348e1f5a1e 100644
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
+	if (!mm && oldmm->owner) {
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
index a787a319211e..5bfc6bc333ca 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -5,6 +5,7 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/cpumask.h>
+#include <linux/sched/task.h>
 
 #include <linux/atomic.h>
 #include <linux/user_namespace.h>
@@ -36,5 +37,6 @@ struct mm_struct init_mm = {
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.user_ns	= &init_user_ns,
 	.cpu_bitmap	= { [BITS_TO_LONGS(NR_CPUS)] = 0},
+	.owner		= &init_task,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
2.18.1

