Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DA55C76186
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 01:33:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7336206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 01:33:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HZV5K3sn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7336206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4185C8E0005; Mon, 29 Jul 2019 21:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C9338E0002; Mon, 29 Jul 2019 21:33:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DF0E8E0005; Mon, 29 Jul 2019 21:33:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1898E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 21:33:25 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id x22so16551248vsj.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 18:33:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=b/Hytcc0xqegBFaTKL6R+kd3384LuXWfhFGA0xp7obZXl3YOMDJA9K49azLkwKb0QU
         gwgkhWuN2UeElvcIAQlqS5pR4SCtALuGUk995TGqi4hQNH2F/c1ILh0flzE9MAvlFjJ6
         0eAmg1M3nCb8nMyeXamOihkRZUI2g6Q/8yoh9aOiaQMU8F/mizVRO6czLEy32M1LMTcD
         Jx92YWkJS9hsJYaBvJ6xUokC6MHE4F/luigx7A4r1oXw8e0vz8NOpPQeUELCeOZ5PYgo
         1xH639BpIzFk60JjdoMjyqtXsEMyt8Bpa6cF5OyY4jkc9cQ8Ls+I//S68AKcsmvbw5iD
         3Viw==
X-Gm-Message-State: APjAAAVJ2GkAzBw3LgEDunSkRhz1YNp2L+oq9tBn1s08uYi33CTXxfBT
	yGwnxUN7FBnlQJn08/C5LZ17o5Lp8ehZa0q08Q8m73cW+6LMnDeh9EWTok/JIadXGfLo8fPr1DI
	JW+7KqFyqbcSeN+bsJxYpfQWdhdfD1Z03XBhmjD7vg0QYQF7b6qfQNjoc9phpOhpzfQ==
X-Received: by 2002:a67:db89:: with SMTP id f9mr66947130vsk.150.1564450404699;
        Mon, 29 Jul 2019 18:33:24 -0700 (PDT)
X-Received: by 2002:a67:db89:: with SMTP id f9mr66947105vsk.150.1564450403937;
        Mon, 29 Jul 2019 18:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564450403; cv=none;
        d=google.com; s=arc-20160816;
        b=rEESWNT+ZswQoNgMafUj0JPg/ebAnDXghdtz5Q5S6wFUQAOnGKxeN3IqLJSzwNHYLG
         LIjDfxJDfo7KA2MiipFtaMhwY/htIOVeX9qKnD/RHiqlpj1beymzdCuaOBw9RGxKFJCc
         UYAJAonVdnTn197e3Na60etWIRclKrhY6nZKpMan+nh4DrbQTBk053TFzui75NDAixNM
         13Rv5rRYnDR/uZUUhy681Bfa+U9gSA/sE6RynroSTtlFKgnRgdc7tKtLDBDuazcSxaoS
         EUPrZ/NpoLPYgeVhHQzDLdkocq3warvXIKGHfA4jkRgWTRQTBdTmDhRJksSC/2PxOX3u
         JPkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=sDgjhsywimPMW68QqK90+hpKYmYc/M4l3Khlfeb5JCpX0EAbusAPWRYuimdgolvizT
         kBfGR5hyfjev1FkSgLl4+WrPNWrSZ3+XrIy+n+hNGdJUoCGibRYwCd4MtEqNrueqtmTO
         Au2ZtWn1UCV2W/rJr4F0aJTaL1sKw7PspOeA28PRF5+csUUho68hKkCXX/ODmKMsbrg4
         uJk/PBMAr8uVTgt63uzFKa0GZADyvLZH7Y+BrvMYimrGcHYdV5KFdYKUAWCRetbvBMPt
         Wwxe4W5y9GekLkzjv9TVRX47b81GCpN83UViazPViKIXcOPn7zrZgYbkgyNmmxYauL52
         FTIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HZV5K3sn;
       spf=pass (google.com: domain of 3y54_xqykci4ac9w5ty66y3w.u64305cf-442dsu2.69y@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y54_XQYKCI4AC9w5ty66y3w.u64305CF-442Dsu2.69y@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m12sor31082680uao.68.2019.07.29.18.33.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 18:33:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3y54_xqykci4ac9w5ty66y3w.u64305cf-442dsu2.69y@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HZV5K3sn;
       spf=pass (google.com: domain of 3y54_xqykci4ac9w5ty66y3w.u64305cf-442dsu2.69y@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Y54_XQYKCI4AC9w5ty66y3w.u64305CF-442Dsu2.69y@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=Frj/SS/W3AFZFbyzaOV4LWLnrMlPxcryoFLQjik2HTI=;
        b=HZV5K3snh9+hZYi0hyCp//JyWT/fXpO3R4ntivO3tTKVGtiJDw32+qKHYjRImOIIZW
         VxTiXkHj+VspcOQwMQmsA2V4AKt/XjP3LHtr1xFiKnUbnM3QWXE/wSzzzjwb8HARp0NL
         NnuTKiG3/MUCJOwH8yeiqO0PT9JR5nFtwF6U8A53/0E2cI+PwTcE9W+5puIoSJsXHcYY
         pGpqdjgsz/Gm/zNNZuQ/PWKC68R/embIB/nPMOQPIpfTsQj4rmJs4brzVzJl1hn7d19A
         ijF6rMV/AiriXix/ERN3pm4aTwkganjyHVi9+SBcKd4uYnPHslwXHHddmjlMGT2iycj7
         WlvQ==
X-Google-Smtp-Source: APXvYqzqfX8t1uXNFJXNaDwGRiqkwrH6h4jiFWfc6T5iZhZ57KmlPWww1KkuiFIxc6pVEcoJJlMga4+hqnw=
X-Received: by 2002:ab0:740e:: with SMTP id r14mr68442936uap.108.1564450403321;
 Mon, 29 Jul 2019 18:33:23 -0700 (PDT)
Date: Mon, 29 Jul 2019 18:33:10 -0700
Message-Id: <20190730013310.162367-1-surenb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH 1/1] psi: do not require setsched permission from the trigger creator
From: Suren Baghdasaryan <surenb@google.com>
To: mingo@redhat.com, peterz@infradead.org
Cc: lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, 
	dennisszhou@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, 
	kernel-team@android.com, Suren Baghdasaryan <surenb@google.com>, 
	Nick Kralevich <nnk@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002958, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a process creates a new trigger by writing into /proc/pressure/*
files, permissions to write such a file should be used to determine whether
the process is allowed to do so or not. Current implementation would also
require such a process to have setsched capability. Setting of psi trigger
thread's scheduling policy is an implementation detail and should not be
exposed to the user level. Remove the permission check by using _nocheck
version of the function.

Suggested-by: Nick Kralevich <nnk@google.com>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 7acc632c3b82..ed9a1d573cb1 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -1061,7 +1061,7 @@ struct psi_trigger *psi_trigger_create(struct psi_group *group,
 			mutex_unlock(&group->trigger_lock);
 			return ERR_CAST(kworker);
 		}
-		sched_setscheduler(kworker->task, SCHED_FIFO, &param);
+		sched_setscheduler_nocheck(kworker->task, SCHED_FIFO, &param);
 		kthread_init_delayed_work(&group->poll_work,
 				psi_poll_work);
 		rcu_assign_pointer(group->poll_kworker, kworker);
-- 
2.22.0.709.g102302147b-goog

