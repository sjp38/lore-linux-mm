Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB87C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F74D2166E
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:23:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sMT1RFNI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F74D2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10E856B0006; Tue, 14 May 2019 17:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E6116B0007; Tue, 14 May 2019 17:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3E076B0008; Tue, 14 May 2019 17:23:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC89A6B0006
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:23:24 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id v16so164315otp.17
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/OYdIOpBJWCaBVUA2Ic/FHOWBWsqkzG28ElRwkV1PdY=;
        b=qEhz6GDa0PiD9aheX/4ItIA21LylYr9OGwyOhkXY3dXOcnvvrZ1t6dnW8iDlRCeBZL
         BStkr/wYJqrlU99GWWo/nDr7XxhdZ2993wkd0139dsUDMAmr0GkTWG+r6FomEYiuM/NN
         DSDTFRi0ltuRjJuBaBcctUwg+FZxMoi3p7NxRQvDClBRAL5nraJACwt+BVAKUzkurink
         tFTwvwLh9kmBZZB2rP4p4CTZ4zlUxZxOb4E+fjQ0veP4vChKpX1B/lLjMEDpOkAzuzEU
         ozaJuW0wAqoCwWw26POqeNW1atXtY3Ivu/dUtIOcfmT7QL6adZYsUld6t6aiASAji116
         WGEQ==
X-Gm-Message-State: APjAAAXwGO1sm132FAY/AtvC3iF6Q7foX2LQr0KBQPw1j3p7r/MCt4nH
	X4u1OvoL5CL52IUakWXD9bbGdVgBKkCcprypoeN27OLcGnlCIEmBQA9wcNEMAUeAs6jhfgQtfgF
	cVliwPJwrUIGb3Z0q4sOYZ1cq3cWYrRRYNuejbqELokvxN02tEEtIhw1M8n3rjpIQFw==
X-Received: by 2002:aca:e0c2:: with SMTP id x185mr3965245oig.0.1557869004392;
        Tue, 14 May 2019 14:23:24 -0700 (PDT)
X-Received: by 2002:aca:e0c2:: with SMTP id x185mr3965213oig.0.1557869003637;
        Tue, 14 May 2019 14:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557869003; cv=none;
        d=google.com; s=arc-20160816;
        b=1CzImp0NsleVx18Tikr3xWQ2ZLZq8nJQX/C+8/jxIUO0DuJ277f2Lx4kJNvYs2Qovl
         XlS5ZI7Sqh9YJoGPPVKnvHS+2Sa0rypFl8zCb5tOWLG56W4QP865fcZuAXB0+4TK82CG
         upM71TY20S8U0UH/FTLwsNfGQ5b4QNCCUXQoxgyAeq4ckOgV3ZC3E70ZtbFqeYObv1qN
         zeC422NEJS4DtBXN+izvNRdFycIJkGS65hUD1xhgEj6CC+46zUTVVYxsSk5uV3MmqD23
         0vgsySdQR1WfK1kIgh5q4xexQc070eNGCTxkS1qja04SNQrjXbrzFVO9czOUH+TQEoBs
         363Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/OYdIOpBJWCaBVUA2Ic/FHOWBWsqkzG28ElRwkV1PdY=;
        b=yFScqdSFnSA91UhTIETCIiRZWENlZrbrm9duMohyoJMfmEZYaeOgOncI3ModFJxQwY
         8Id8hFJRwu6nyVcZJq4meMQc7b9ISDRgrsC4oXx6bYbWxjCWcXZ9vsF+XXB8W2V+Ouwi
         JtW5YyaGUtpNm4uhIig45v8SOhPDpPAYR9uuorCNYOojf+xPU+8X8jcT1Vbsm41CRhaF
         C54um+9rcpb8IOp3NQMoTLCD9FH8iBP2MG3575yJVZQZhuV1ZuyqcCiao2haDcwwv0/1
         0VOt/NbBsFIs+kVpX8Vz64E4iMqECOEMcfdn1le+dFj9aw38r4zleaR3UVQ0EyjiNk29
         Sidw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sMT1RFNI;
       spf=pass (google.com: domain of 3yzhbxagkcig4tmwqqxns00sxq.o0yxuz69-yyw7mow.03s@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yzHbXAgKCIg4tmwqqxns00sxq.o0yxuz69-yyw7mow.03s@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r17sor8770512otg.84.2019.05.14.14.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 14:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3yzhbxagkcig4tmwqqxns00sxq.o0yxuz69-yyw7mow.03s@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sMT1RFNI;
       spf=pass (google.com: domain of 3yzhbxagkcig4tmwqqxns00sxq.o0yxuz69-yyw7mow.03s@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yzHbXAgKCIg4tmwqqxns00sxq.o0yxuz69-yyw7mow.03s@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/OYdIOpBJWCaBVUA2Ic/FHOWBWsqkzG28ElRwkV1PdY=;
        b=sMT1RFNIRx5Pslx1X+QRbggc6ZXdETqqUAmpYgQSfraDuAQ8m+rCMJk9uGbN6XrtHs
         tNkvdtsnGfHoH0GanvDXD+Fs6bm/IXQXFezj+d5P3ki8zYgnqAS/EoN5nDZJYNmbLDDZ
         AD+gARqdfYcjkA8KcwkxfSVO5a9PAtkxFAxt3FbP4bS2eGGNq3CxcOuewuBwbiFTdBqU
         r7UgPx4uwRpQE1MDB1pPgHNp+1PjjD8hA3bPI3U9YQ0+0oF6F4BpTGINJsrUutnPzVQ4
         YwgfaJcSrkTC6Jzttdasq2d0xMgnfgYbpVVOKTamjEKDeaSR84z3dR/se+nCH6uaSBCN
         i3MA==
X-Google-Smtp-Source: APXvYqym1Fqm5pNm2/VExHxbmxANidF+rxgp75ZamTBrHNj9XD2E4iXLCfQcbSoRxPswid69DBp+ecjJ3EluAg==
X-Received: by 2002:a9d:5f13:: with SMTP id f19mr121436oti.219.1557869003332;
 Tue, 14 May 2019 14:23:23 -0700 (PDT)
Date: Tue, 14 May 2019 14:22:59 -0700
In-Reply-To: <20190514212259.156585-1-shakeelb@google.com>
Message-Id: <20190514212259.156585-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190514212259.156585-1-shakeelb@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v3 2/2] memcg, fsnotify: no oom-kill for remote memcg charging
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
Changelog since v2:
- updated the comments.

Changelog since v1:
- Fixed usage of __GFP_RETRY_MAYFAIL flag.

 fs/notify/fanotify/fanotify.c        | 5 ++++-
 fs/notify/inotify/inotify_fsnotify.c | 8 ++++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index 6b9c27548997..8047d2fd4f27 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -288,10 +288,13 @@ struct fanotify_event *fanotify_alloc_event(struct fsnotify_group *group,
 	/*
 	 * For queues with unlimited length lost events are not expected and
 	 * can possibly have security implications. Avoid losing events when
-	 * memory is short.
+	 * memory is short. For the limited size queues, avoid OOM killer in the
+	 * target monitoring memcg as it may have security repercussion.
 	 */
 	if (group->max_events == UINT_MAX)
 		gfp |= __GFP_NOFAIL;
+	else
+		gfp |= __GFP_RETRY_MAYFAIL;
 
 	/* Whoever is interested in the event, pays for the allocation. */
 	memalloc_use_memcg(group->memcg);
diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index ff30abd6a49b..ca1a9dfff0b5 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -99,9 +99,13 @@ int inotify_handle_event(struct fsnotify_group *group,
 	i_mark = container_of(inode_mark, struct inotify_inode_mark,
 			      fsn_mark);
 
-	/* Whoever is interested in the event, pays for the allocation. */
+	/*
+	 * Whoever is interested in the event, pays for the allocation. Do not
+	 * trigger OOM killer in the target monitoring memcg as it may have
+	 * security repercussion.
+	 */
 	memalloc_use_memcg(group->memcg);
-	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT);
+	event = kmalloc(alloc_len, GFP_KERNEL_ACCOUNT | __GFP_RETRY_MAYFAIL);
 	memalloc_unuse_memcg();
 
 	if (unlikely(!event)) {
-- 
2.21.0.1020.gf2820cf01a-goog

