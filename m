Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5443C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 14:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D2F1206BB
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 14:52:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qFtjqSrc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D2F1206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF6F86B0003; Sat,  4 May 2019 10:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA7A06B0006; Sat,  4 May 2019 10:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 996E06B0007; Sat,  4 May 2019 10:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC36B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 10:52:52 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k8so8996635qkj.20
        for <linux-mm@kvack.org>; Sat, 04 May 2019 07:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=Q+yvnmyjVEzdFHEWBcoadDmmU/3yK5ganIOIoyEwouc=;
        b=GlZXCFkAAWHxuy6Yh1tSlK0AVSmPesmTEn3C3SlE5MvT8e1M7SER5apSj8GwFgy1Nc
         qsUCiuW8ciE1KGhvut6RWBZWB8oETynM9rj5n/gzS9MGOgP+GZkQx60HPwmg/T9AyWSv
         ZOFFBcpUBHgrDfY3zn94dxgsRJg8zfVvRyuRCfUGnc8vbe6NWdq5uwGKONtJarIZPGXP
         qCiVu9SKlGW2wcOmJ86yHDfH+OML6FX8PXLD5xmEhQkrYZmpn9kOpdAcZhcb3eW9+jAh
         ohNh50QM0UZT3MHpcI4cqz7oMyQG527+L7CGAO/K5XyPvZzaBJyFTwAiBdAkkzGys6f9
         DJyA==
X-Gm-Message-State: APjAAAWIf/qZxslS2gel5P6rBe8YxzCwUFvVs24Nc4vfrWn7pRdFy8xC
	WG8gr4TlhXHHILlf5hRyxp1GKTuTYrPVmj+UVf67GDSTMYV9qbPkIUn8m7MVzm7QnU5SBHlpaHe
	8prY0imspXrnW7EtTibUsgh6e1uIa/nh1imtcK1ok7QzHzmAMvLhLLQ+vL2adR1Yaiw==
X-Received: by 2002:a05:6214:201:: with SMTP id i1mr12875502qvt.235.1556981572229;
        Sat, 04 May 2019 07:52:52 -0700 (PDT)
X-Received: by 2002:a05:6214:201:: with SMTP id i1mr12875444qvt.235.1556981571037;
        Sat, 04 May 2019 07:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556981571; cv=none;
        d=google.com; s=arc-20160816;
        b=HhUv4KhJHgbZmpOeehDZV1qBuyZJ+uWvzKFSupVySqQrIf+WL59d6FWXn7a+B4afh3
         L/U6VYRDwK4lF6QVIP7ibN2QaxyJG5nrlm/7FtxlSUbBgzLzfMbxUPV7SrDEXVX28XQb
         3L33pT5xp9pQWVOiS0XPn1p1HeTIjGrzPZFKdluRhaeDKM5xEsPT2Iwfv3R45yYwtZPA
         R9r85tgDqSwy/Si4NahG69iv0AzrXf52e+jzV5vIZa0EFNgoS+U2jKK1Jur4+GwhwGzq
         dfvpy/Sab0FGwq/IvXhXPUn9Y35NRUjDlA8lzHjR+KMHmi7j7ZFItUahRE28sA6W+Zz3
         Ckxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=Q+yvnmyjVEzdFHEWBcoadDmmU/3yK5ganIOIoyEwouc=;
        b=x+DAEWTg/J8LlrqVQEXZ/hxHBaylU8oZmoFr6kATtxuiXtFFTiLKfopVF+RKgPq789
         brYFMHvfpbUguF8/wPzfI6cYFCPl2/k/lwC48UBCLJdgWaXkmmOftmaKRnI6hAR+DR9r
         r0wCzWrLBH4Lj3n84SzzCE0gZBwOs/vVTXzB+aN6Qh5NkTjHROrH2I1kEORYgFwulnQT
         X8LNGuQIjTLUnXdFx9qBxTTiQ9F4s+emGESnTY7XUETUmY3xmcNaB2VbAl+F4pe8SMgJ
         1bk+1/RxykE+gid0vjCNb/rW3JytGyhD+V8g+dCDUG6W4H+fLubPtLAcfr1AsWo47gEI
         MDYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qFtjqSrc;
       spf=pass (google.com: domain of 3qqfnxagkclmlatdxxeuzhhzex.vhfebgnq-ffdotvd.hkz@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QqfNXAgKCLMlaTdXXeUZhhZeX.Vhfebgnq-ffdoTVd.hkZ@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k186sor3016390qkc.108.2019.05.04.07.52.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 May 2019 07:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qqfnxagkclmlatdxxeuzhhzex.vhfebgnq-ffdotvd.hkz@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qFtjqSrc;
       spf=pass (google.com: domain of 3qqfnxagkclmlatdxxeuzhhzex.vhfebgnq-ffdotvd.hkz@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3QqfNXAgKCLMlaTdXXeUZhhZeX.Vhfebgnq-ffdoTVd.hkZ@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=Q+yvnmyjVEzdFHEWBcoadDmmU/3yK5ganIOIoyEwouc=;
        b=qFtjqSrcM4UGgRoJ8/RzfeaVyMan+d7Ts2pByis/59NTZYLaxr1drG0H5BJleMrsrh
         MfXyUTFpANjtUv9d/3lln9gmv0JiZwKgSmPn/unKXf6ckvtwaiukK2EpBgYXSp2zaMVT
         oBZSmqvUFGBLW+493GEBswqRKrbAhreW7h3pvJZKJyvSY9xqc6PSChOyIBpwKVl7OcOV
         OYC8eGUnH5wq7H0Hf6xM8doNcgTcKdvF+OGgfSn2qK2KmkPDC1b9x7Pj9K9UegrblR69
         dmm+H2DsQQ2Abc1ZsllHD5tiuI6keEcXuEUtH1k4JAzFM/AERoSNSFeerIz2sPD+jA9M
         2gsA==
X-Google-Smtp-Source: APXvYqzaEcIiqQDURcZKk/Ciux9eOBC26QDYKJQb+X0sd9obaCdABR9WDozc3I83/n6peCeKM9N158e14DQdFQ==
X-Received: by 2002:a05:620a:1015:: with SMTP id z21mr3134470qkj.229.1556981570541;
 Sat, 04 May 2019 07:52:50 -0700 (PDT)
Date: Sat,  4 May 2019 07:52:42 -0700
Message-Id: <20190504145242.258875-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2] memcg, fsnotify: no oom-kill for remote memcg charging
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
__GFP_RETRY_MAYFAIL to the fanotigy and inotify event allocations.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Fixed usage of __GFP_RETRY_MAYFAIL flag.

 fs/notify/fanotify/fanotify.c        | 5 ++++-
 fs/notify/inotify/inotify_fsnotify.c | 7 +++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index 6b9c27548997..f78fd4c8f12d 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -288,10 +288,13 @@ struct fanotify_event *fanotify_alloc_event(struct fsnotify_group *group,
 	/*
 	 * For queues with unlimited length lost events are not expected and
 	 * can possibly have security implications. Avoid losing events when
-	 * memory is short.
+	 * memory is short. Also make sure to not trigger OOM killer in the
+	 * target memcg for the limited size queues.
 	 */
 	if (group->max_events == UINT_MAX)
 		gfp |= __GFP_NOFAIL;
+	else
+		gfp |= __GFP_RETRY_MAYFAIL;
 
 	/* Whoever is interested in the event, pays for the allocation. */
 	memalloc_use_memcg(group->memcg);
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
2.21.0.1020.gf2820cf01a-goog

