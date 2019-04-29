Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D862DC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:14:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CED420675
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:14:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LNHMaVmc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CED420675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431A86B0005; Mon, 29 Apr 2019 13:14:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E4456B0007; Mon, 29 Apr 2019 13:14:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D1736B0008; Mon, 29 Apr 2019 13:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8BD76B0005
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:14:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g92so5736863plb.9
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:14:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ZJZw+a1zAAS2yXCulVsapzFNzx2HgPG8quVXkMNIzRA=;
        b=hX8hgto3xuSMRMZjfFzYd1CS4pwYNwnsEQkpHBHtG1sxtid5tpRu5Qkqsz4i9j3kY5
         3xoYdJCgzz6YqaJEvnp996ZnnEXwk463wH3w8oQ+Qc7fO3zL+w+zgaoAyXR6bDkcerFW
         kPFNzr+uMVORCT4RlH/fHrPflxPw98dNcstKuBNmz8iWqm5cIFxCH4MdrYoneVowhjKN
         jXlUcCeiMufcmysTDNiCPd8/bed0aKt5182pYOFXTwdmM4Ix+R41GSZvAANSktAN+UMo
         5mYKpChQ1VjwLPDw6pHxg6zXjsnrEea2bbKHsjsresFPtoVDK4hVm/FG+KORnBaVMRK6
         FyNA==
X-Gm-Message-State: APjAAAWPngpm8xpfp4yuvtU9Fqg7idh4UIerd8G7k8elX3MYkOh1KzkZ
	dgpuUEnXME1A4PF2ZqwlE1wb1/Bom+BZkicM19K2Xz9k0Hlha9cJ1J8RX0+56wBcoJ85VL0iOLS
	ZOUPhA6JkQMEE3PW5eDi8vPs8IsbfmdWipLoCQdQyGJ/8Q/uUG6TOyqwCVi2iEB69Pw==
X-Received: by 2002:a17:902:7205:: with SMTP id ba5mr42150050plb.285.1556558044515;
        Mon, 29 Apr 2019 10:14:04 -0700 (PDT)
X-Received: by 2002:a17:902:7205:: with SMTP id ba5mr42149944plb.285.1556558043731;
        Mon, 29 Apr 2019 10:14:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558043; cv=none;
        d=google.com; s=arc-20160816;
        b=NHv5lClEpKdZjKm5bjjz2Oy/FewiNVxfJMbi3zdGAq5wJZdl2lVM3+sdnimHm1RFLw
         v7yxAEXzx7PzJwsbCK3YPx4S23q5wv+U8X8NNVyPfOG/Kv8GfTUZOSaVrV+Dv06DJI1j
         w1H2L07OPAX7iTl60R652OW0UasAb+o8ucF6+N0jEt0PJbVxApdzXZWUghwhXJPYRkoU
         kZhJ/Q3iXTiwmujN645wiBhIs/jzqMb/ieA/C9lswqD1xbLB8H4F7sNBqUENkfFjC6so
         Ru6LwvC6fOvSKvhqktB98h92JJgebUGhL+nWhansHPco140Pz9ibxLgKedvd25dwgau6
         fS8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ZJZw+a1zAAS2yXCulVsapzFNzx2HgPG8quVXkMNIzRA=;
        b=L/fZP5Cc62hmQfoc3Ae0+VX0iQKZkFUAW2nmlFiKM3e2hvZgGbOFY1M5w974HsxjUu
         410jIpaSx9B835JnzWZPypXYVkraXYZdzLV1x+508jnG7UKcj3UmB2eDXHowB3V/lA1a
         h098BcbJMJ+rBJFR34TOZFnmT8nlafHoLnowCAvAToa14jA7tGRQWI6iBXCcWK9C+ho4
         vX2Kl4TMzvv+X9YX+R38Gg1lyVakEu/+R2YCtZ6cNpNewjQt2MSLos+L48V7zSHwJnXl
         BPoEJhmpUajADYZy+HemV14rLoxWRO9JTN0DzcNKwr55GQQtoH/WM2n0RRL9Co5o14Rc
         MYaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LNHMaVmc;
       spf=pass (google.com: domain of 32zdhxagkcey0pismmtjowwotm.kwutqv25-uus3iks.wzo@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32zDHXAgKCEY0pismmtjowwotm.kwutqv25-uus3iks.wzo@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 22sor9811014pfo.32.2019.04.29.10.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 10:14:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 32zdhxagkcey0pismmtjowwotm.kwutqv25-uus3iks.wzo@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LNHMaVmc;
       spf=pass (google.com: domain of 32zdhxagkcey0pismmtjowwotm.kwutqv25-uus3iks.wzo@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=32zDHXAgKCEY0pismmtjowwotm.kwutqv25-uus3iks.wzo@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ZJZw+a1zAAS2yXCulVsapzFNzx2HgPG8quVXkMNIzRA=;
        b=LNHMaVmcposMzXiBxo+LfVRrsXl/hzH7pjhT+t1iPGrPl3ttT6JqRtwLI+LmJZzfO3
         6dooMjOh7leRjuHd+y/PjbfED8ng26vganF2W2sFFNwLnXk6AO6Gnk27hUJRFq6vMHnD
         V/8GhLSaHioBm8HlcVfQcAoSlyZLZXgu6P3IdkSFLTkVAt1kTaAXh3IygzCUzwkRkMO2
         ABs/JrSSCGKRasEP9mu0SQTJMLHuHvq8LSeIkgusJW0LAXLmHG7xmCeCdF9OyEsbz3k2
         Ag2CxRX2t31eXoE9nTs+JsO7/i88GZiSYPqm/ZR7APmhOvzuNg5tIpU4XhI4eSSqDaiw
         t5+g==
X-Google-Smtp-Source: APXvYqzTjNvJrvL+jBUcp6W9VnuxIBNtyu3+LblRTc2xOWy1Rbb1xQgUwgBIVo88fNW8fifpkQ8drzhLbu6dhw==
X-Received: by 2002:a65:5941:: with SMTP id g1mr60655155pgu.51.1556558043109;
 Mon, 29 Apr 2019 10:14:03 -0700 (PDT)
Date: Mon, 29 Apr 2019 10:13:32 -0700
In-Reply-To: <20190429171332.152992-1-shakeelb@google.com>
Message-Id: <20190429171332.152992-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190429171332.152992-1-shakeelb@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH 2/2] memcg, fsnotify: no oom-kill for remote memcg charging
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit d46eb14b735b ("fs: fsnotify: account fsnotify metadata to
kmemcg") added remote memcg charging for fanotify and inotify event
objects. The aim was to charge the memory to the listener who is
interested in the events but without triggering the OOM killer.
Otherwise there would be security concerns for the listener. At the
time, oom-kill trigger was not in the charging path. A parallel work
added the oom-kill back to charging path i.e. commit 29ef680ae7c2
("memcg, oom: move out_of_memory back to the charge path"). So to not
trigger oom-killer in the remote memcg, explicitly add
__GFP_RETRY_MAYFAIL to the fanotify and inotify event allocations.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/notify/fanotify/fanotify.c        | 4 +++-
 fs/notify/inotify/inotify_fsnotify.c | 7 +++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index 6b9c27548997..9aa5d325e6d8 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -282,13 +282,15 @@ struct fanotify_event *fanotify_alloc_event(struct fsnotify_group *group,
 					    __kernel_fsid_t *fsid)
 {
 	struct fanotify_event *event = NULL;
-	gfp_t gfp = GFP_KERNEL_ACCOUNT;
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_RETRY_MAYFAIL;
 	struct inode *id = fanotify_fid_inode(inode, mask, data, data_type);
 
 	/*
 	 * For queues with unlimited length lost events are not expected and
 	 * can possibly have security implications. Avoid losing events when
 	 * memory is short.
+	 *
+	 * Note: __GFP_NOFAIL takes precedence over __GFP_RETRY_MAYFAIL.
 	 */
 	if (group->max_events == UINT_MAX)
 		gfp |= __GFP_NOFAIL;
diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index ff30abd6a49b..17c08daa1ba7 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -99,9 +99,12 @@ int inotify_handle_event(struct fsnotify_group *group,
 	i_mark = container_of(inode_mark, struct inotify_inode_mark,
 			      fsn_mark);
 
-	/* Whoever is interested in the event, pays for the allocation. */
+	/*
+	 * Whoever is interested in the event, pays for the allocation. However
+	 * do not trigger the OOM killer in the target memcg.
+	 */
 	memalloc_use_memcg(group->memcg);
-	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT);
+	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT | __GFP_RETRY_MAYFAIL);
 	memalloc_unuse_memcg();
 
 	if (unlikely(!event)) {
-- 
2.21.0.593.g511ec345e18-goog

