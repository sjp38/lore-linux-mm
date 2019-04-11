Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0522EC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B565C204EC
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:44:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VQ8uE7fS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B565C204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E8A56B0276; Wed, 10 Apr 2019 21:44:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29EF36B0278; Wed, 10 Apr 2019 21:44:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C43F6B0279; Wed, 10 Apr 2019 21:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id D43FF6B0276
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:44:03 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id z31so569401uac.23
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:44:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=1R5t7+lNOeidJ8ZneBm0ViFTLutFvxRUicyozCMV/Ds=;
        b=StshEQ8DU4IRS2evIaCOC+ejIBbQP6l+BwwOX8QMH47WY6WzLQe6XPQXR4Bn20+h1O
         eRE9ABBD9nrex5LdU4o0pyfU3jnVj+GtbYuOR7/4r4ZLgb4znLXLULflIq9aHX3Ai905
         YYVTPZOP5q/y/qqzp2Mt3+Rdc9sfQbmA90+sb3gAciAnKOwv2xGNWpSY8zpYZINtfefw
         BbyjdosAvOr0dRjy8hfkbPwJbsnx6bNu1dPycAKls6Difea5L7m2wt5ozJp2Jd7xgTDo
         UE7cvY/mhKUlbvy8jfag3770+tka9J/IrG3ca0tAuW2gG8R0v9ReP+4sKlV9cxaMXvB/
         ulgA==
X-Gm-Message-State: APjAAAWQuOC5ZYTmOhKhoERzs0mn8EXQ7heR/9B2TkSK8ylx+215OUMG
	RkWUtBoMUS1K/yi4U5J9+LTo+/9jyFhaon+U/GVw8CvWfUMi2bEed1ICySf8BYOInKed4+5fRdU
	AxL7ibIAJzk3w15w30EWShUw+hz/uropIgUgFLfFJVxLmExhMQ7ZaclvIaFH0Q0Os/g==
X-Received: by 2002:a67:b44c:: with SMTP id c12mr15735701vsm.169.1554947043509;
        Wed, 10 Apr 2019 18:44:03 -0700 (PDT)
X-Received: by 2002:a67:b44c:: with SMTP id c12mr15735684vsm.169.1554947042981;
        Wed, 10 Apr 2019 18:44:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554947042; cv=none;
        d=google.com; s=arc-20160816;
        b=pbJRf59CTxk8NmATZy0wr8YNJhP3BeF7I1wFWRTpMVlh+2s1ibSlw3xAygdtpgl3Km
         SfEqse3NgMOhIYeVrOWCa4siVoMgec36KWbWcuP6yGVdo+MFdoqK9YQSIur/EfgNkpdi
         LhmwcqHwpxTHOKE7P3vLHBuHi2WSkBPdwOABZo6xZEAfy5VAlKusQjJ+GIlIF3IqaRY2
         BOTxqBHY7VpvdpknMANNZtCjBZCLuczOewNtYJNnckCNpmrOamwTY3aWY5VKjHWEu4GO
         0ERisdzQDlSOoPTxWLihtTRASWhYqPP+BjKKJLBpLyapWzm/M96/3p7bNLVndBbEWez8
         HIzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=1R5t7+lNOeidJ8ZneBm0ViFTLutFvxRUicyozCMV/Ds=;
        b=A/woA5zsGx9q5/2CI947LB46gkMhQIbgw/wODL+sx+8Otcj7+ROmujPIuWz5YJaweU
         l14Ueui79yoJP4Yi4dRSGsmxVth+Gm43UWjUp3rwfFUMHOKm3XI4cY0yrxqUP675klhn
         qYcXCCcbWG6hO14fvtB1StC9YTWH4BgPlNET38N2QJdOXlToK5G6r36eMO1Q0jhvaHUB
         GRYPRDntMWoz0y1PPsqPWNhuki9abPkkgNznUt4s0PD/Rf/GKu7kJs1QBaq7ODIrFiWf
         UGjmD7I6DjDkQzOTlAjLmZwBSCXVbJrh1VyOn1JNszKxwZLTruHgLtZREXOXM/QFx+75
         Zb4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VQ8uE7fS;
       spf=pass (google.com: domain of 34puuxaykcl8xzwjsglttlqj.htrqnsz2-rrp0fhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34puuXAYKCL8xzwjsglttlqj.htrqnsz2-rrp0fhp.twl@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w7sor15846412vkd.5.2019.04.10.18.44.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 18:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of 34puuxaykcl8xzwjsglttlqj.htrqnsz2-rrp0fhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VQ8uE7fS;
       spf=pass (google.com: domain of 34puuxaykcl8xzwjsglttlqj.htrqnsz2-rrp0fhp.twl@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34puuXAYKCL8xzwjsglttlqj.htrqnsz2-rrp0fhp.twl@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=1R5t7+lNOeidJ8ZneBm0ViFTLutFvxRUicyozCMV/Ds=;
        b=VQ8uE7fSnqdKErP7/p4dHAFIDW6jI3qLUsMTULdhHlqde5jIwhtKd6+qPR5tAHjXPL
         XCNL9Aj0wz1Y7vECvW1Ugi2US2rH7DQDFoCij9lkUZImbDw3EM60HOoIkNqQuLwD/34g
         3tkLTC/C2K922qnKAdHrHfX5GUD5eAl/+jQVn+GKGwbvYi9D4E30VgYgQkFCWpd31AeC
         TcxaOdDnIXkLAs0ERzKVT0n7FojrV/2A/02wTu15JMLHIOBjxOHCuDEJEqLdE6/3f6rP
         aZrtWVlzwBTUACFHg6sNWtO5or9++2FlOLH+28Exhs/7J9gbHRoXdTz/CNKP+55GGjd2
         3raw==
X-Google-Smtp-Source: APXvYqx9ebEgF18enAdLfuKzN1eizWR9w5VxGzxkPww+DyZ2FJ0mMzOj/JkBJbSd9g/xUnj4BFlUP2Quw3o=
X-Received: by 2002:a1f:10a5:: with SMTP id 37mr5464480vkq.6.1554947042655;
 Wed, 10 Apr 2019 18:44:02 -0700 (PDT)
Date: Wed, 10 Apr 2019 18:43:52 -0700
In-Reply-To: <20190411014353.113252-1-surenb@google.com>
Message-Id: <20190411014353.113252-2-surenb@google.com>
Mime-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [RFC 1/2] mm: oom: expose expedite_reclaim to use oom_reaper outside
 of oom_kill.c
From: Suren Baghdasaryan <surenb@google.com>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, rientjes@google.com, willy@infradead.org, 
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com, 
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com, 
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org, 
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org, 
	jannh@google.com, surenb@google.com, linux-mm@kvack.org, 
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, 
	kernel-team@android.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Create an API to allow users outside of oom_kill.c to mark a victim and
wake up oom_reaper thread for expedited memory reclaim of the process being
killed.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 include/linux/oom.h |  1 +
 mm/oom_kill.c       | 15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..6c043c7518c1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -112,6 +112,7 @@ extern unsigned long oom_badness(struct task_struct *p,
 		unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
+extern bool expedite_reclaim(struct task_struct *task);
 
 extern void exit_oom_victim(void);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a2484884cfd..6449710c8a06 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1102,6 +1102,21 @@ bool out_of_memory(struct oom_control *oc)
 	return !!oc->chosen;
 }
 
+bool expedite_reclaim(struct task_struct *task)
+{
+	bool res = false;
+
+	task_lock(task);
+	if (task_will_free_mem(task)) {
+		mark_oom_victim(task);
+		wake_oom_reaper(task);
+		res = true;
+	}
+	task_unlock(task);
+
+	return res;
+}
+
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
  * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
-- 
2.21.0.392.gf8f6787159e-goog

