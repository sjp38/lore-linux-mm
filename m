Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD1BC04A6B
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 16:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B64B2146F
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 16:09:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="i3YEIaQI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B64B2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 895F16B0007; Sun, 12 May 2019 12:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 844F06B0008; Sun, 12 May 2019 12:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734F96B000A; Sun, 12 May 2019 12:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55C0C6B0007
	for <linux-mm@kvack.org>; Sun, 12 May 2019 12:09:58 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id c4so20771807ywd.0
        for <linux-mm@kvack.org>; Sun, 12 May 2019 09:09:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=pNYDYF29KQTiDsLTir5ePdeguGYagzUQEsurF8lSHbY=;
        b=WFRynx6DlwdmXm4bghDOm3RJ+vi+Nu8gFhhWaULEiMiUlKEmp1GaZcive+TivS2jNC
         uygYEARQQZGrv2oNBD44En0soakNIVxXTTQOeHiH2kkSbtliS7R9c5l1r00uI8XAGloT
         8XtvrsQvGveCmTIARHYTmbv/EqyvNnsLjCyrF03YMTa8YShF8pGFg1l44uDQh4hJHMPD
         WYub+ltCguRqRfZQM3ZNxlS41fmnF1nrVjZ/y8RHC9Dj1kO7k2+GDHhBqpdXOalwh06L
         KjnyAXJkdv7ET0FPqEGGIIg8Dh6gE2PILih+9IMUL9s6W8/xEm775fLgejde1ZLFTU7Q
         swKg==
X-Gm-Message-State: APjAAAWEogQ/Xx7A+S4nOidfLjy6lS0+pAWvhxcsCudIyFVr0JSNghTb
	EBsj118fbaXnvW4+lRWTzbUw17Hedfp5qPETIsuayFNALG8kkiX7zAHaOGX6QhLjtaqTpKBdr3b
	ASKGXrb2W24t8ELSGOQr/Hy38S1Xji4HTW7RU6ttQKJFthWvHpo8/qVHl4zFIaq6WDg==
X-Received: by 2002:a81:55ce:: with SMTP id j197mr11272003ywb.435.1557677397983;
        Sun, 12 May 2019 09:09:57 -0700 (PDT)
X-Received: by 2002:a81:55ce:: with SMTP id j197mr11271971ywb.435.1557677397267;
        Sun, 12 May 2019 09:09:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557677397; cv=none;
        d=google.com; s=arc-20160816;
        b=xopfTLU6XjuDt5sGhCUJGEjBIndRBsjfBYzt4/iMbKYVwFOaXuDtG1a5OqYlLqbEcD
         7ynFfGpjzpK3WcpTjPsiMqmmHh5WKdipfd3Fk2zW8wQvTgG7djnPHBlsWGlW/k4Lvbdn
         QM7O+TTkakWoYwTd1F/Kq8o41kx42zD2vv4OYZpYSJuCT7guUDfI1MH1z2Oh0QxaSkDi
         rmyeC66GTcpJm52TCt9yqJHIG+szlklx5qTzurHimv2h9rNzWGWOxsOuaQVp2qg8Ddd6
         ct43P0lTiVON00TYl3S6GccswP/QX53FOrW5bR/gkJnGp523xwK6xm6OmJjRgFkAIL1/
         qTSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=pNYDYF29KQTiDsLTir5ePdeguGYagzUQEsurF8lSHbY=;
        b=PLqcdAtlBXDUb28WPUnCIAe5ZI6lVwrmlYEZTFTok9i9SepANVC0y8K+Nm8M6JuFqY
         oPvBgqLDk9t4YenvdRpS7MHAbkpcSP6Ka5xBDITF9o91TTHPkFFUVjXHSM7tQHRs4DR4
         D38B31Xkzj/ZhtqsYK1jVUlKSt8MoAGmhYMe67HSAdWu4RVEQC2+hTrCbaE9WfGgRWhi
         mJ/aAQrQtpcZeP2lF298V4aUiSCSoQhqGO79GwADyn0U7+7cMciBePfb6u08hyA9vRYx
         gX/3fWCDowbPtvLLRO3wBAkcSqTE+HUv9BDcGbQour7CWlL4Fk9cTUbaN+JvYzIG1rdI
         NSuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i3YEIaQI;
       spf=pass (google.com: domain of 3vexyxagkcc0bqjtnnukpxxpun.lxvurwdg-vvtejlt.xap@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VEXYXAgKCC0bQJTNNUKPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i18sor5603361ybp.28.2019.05.12.09.09.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 May 2019 09:09:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vexyxagkcc0bqjtnnukpxxpun.lxvurwdg-vvtejlt.xap@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i3YEIaQI;
       spf=pass (google.com: domain of 3vexyxagkcc0bqjtnnukpxxpun.lxvurwdg-vvtejlt.xap@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3VEXYXAgKCC0bQJTNNUKPXXPUN.LXVURWdg-VVTeJLT.XaP@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=pNYDYF29KQTiDsLTir5ePdeguGYagzUQEsurF8lSHbY=;
        b=i3YEIaQIHO/PR2+mMIFIpaGHrsGtdYQBTKhgEeVGdXy6IjrQUWW5WGYFsXSjxoy4Qa
         5xlboHTgv9cyDLZ9V2BO/jEBAklDBwaVlu3TrXjcaV9JkSH4r/P/p1LzRbEzXM8NGGqh
         aRossIettQVPYRP2lRDcOH67U+qYdSZGyj8FX4IOWj8uCAckk7xaZVr5GB9pAj4t4hz5
         tsXRN5yNqBGxFb7yJ9dJbrVjuLxoYHIHNy5JGiw3cCLlaZQjNXt/bf4IpwEQgLEKf8BV
         SFS4JqfbN/IHML9PTuVHjyceb1Le0/n+fA3YtuBOVoJ7+b6QgRQjGdnyBJBvvSOkAeon
         Uifw==
X-Google-Smtp-Source: APXvYqwFjUEgIaKr0kbwdw7yEWcBwWFgnrXBu4fdjexDy0pGsGSbQmVSEDWFzUFaVoq6HIRtK7D5ckxThWerQA==
X-Received: by 2002:a25:585:: with SMTP id 127mr10890358ybf.60.1557677396951;
 Sun, 12 May 2019 09:09:56 -0700 (PDT)
Date: Sun, 12 May 2019 09:09:27 -0700
In-Reply-To: <20190512160927.80042-1-shakeelb@google.com>
Message-Id: <20190512160927.80042-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190512160927.80042-1-shakeelb@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [RESEND PATCH v2 2/2] memcg, fsnotify: no oom-kill for remote memcg charging
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
Reviewed-by: Roman Gushchin <guro@fb.com>
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

