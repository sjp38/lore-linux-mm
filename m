Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E37AC28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38BED20693
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="JRKbcrjI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38BED20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D20CA6B0006; Sun,  9 Jun 2019 06:08:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA8706B0007; Sun,  9 Jun 2019 06:08:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B49CD6B0008; Sun,  9 Jun 2019 06:08:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 556336B0006
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:08:55 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id r1so1314177lfi.22
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:08:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=vE25/fE3GbSUmEmrdF2LzH942xvuS41f5y8rGOLXdnQ=;
        b=Sato27QTasHyDD+WOdwKQ5qbRG1E0vppMggka7LnB5aJQ6X1//9+6kvDDfK8LVgLSQ
         biyNOEDJxelccPF1fJRSNJgkVaJcTQAulWd4k1demPSxjbd9jxKmMyKDXvL0sg4oXk3P
         aarBLZ3RBPboM9Fc+gvIbjj/Dj+XqSX4DvFFoMyssoHK2QfzMc/JrfBgG2aAMh3x/zEK
         1gnWAShdZ3Sxcc9fBsMNg3J20YhduhqW5cRe48DZwbKkT4pnluajhCL3morShrKYvEBP
         4r+2M/lwVwow6csaj0ZXphFjOKlp3VUUjZzC3BBQJzK9/11DYEESW2p71XemeiqTdL8k
         xABg==
X-Gm-Message-State: APjAAAW0zeZYfP+0BujHb+bJqkwb3/JMNnQY7OT2YzTODydakFG6mL6P
	kYAcsPhnaHSlRD3uEwSF3lAy/wZQCYoy0M6xpDUy1NufwmoPbF/WwjZEZ4ZeFzZc7b9RjRrkZpA
	FaPeiGOpT/5YiVX2oGwKOVr8GXdxHLigEwEvQWl2TtjG0U4aU2Rv9TjcnmAd8+KVPHw==
X-Received: by 2002:a2e:8ecb:: with SMTP id e11mr8558856ljl.218.1560074934616;
        Sun, 09 Jun 2019 03:08:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXnF4rEV1bZV8Q3/qn7Sj8/Mm9O3ilEsNytr4GVWVHgC5d5Ur7iSqM0IsXC/3NyeJHqOB4
X-Received: by 2002:a2e:8ecb:: with SMTP id e11mr8558829ljl.218.1560074933887;
        Sun, 09 Jun 2019 03:08:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074933; cv=none;
        d=google.com; s=arc-20160816;
        b=gBgmky3unvWMDgG5+HvFZyKs/Jx7aL9lyx/3AiwE9jCNZuDXdHuMLJN1UXYOKKwaKG
         g3yDF1jqevf5pqe2ZXPQO0wa8frlVrfSPzCwjCBonUj8Vuj9CKzrkmcFrdQT/HdfKbea
         LCqkc64d0LO2ZaS1IvIT4tgkEUU/q9dVJ9pRTv5eKrXWRmvM3sKm38XqDZk5qV2SYPia
         ym5lK7SoB0FtWF7s8kD1+DfTLqUuUWq+o6uw+IXm8A5r1yjw/jz7C5eKbuQZqAA+Gtcl
         u7X1Lo8IEr+KlUUeBkZqTxGvC4adWTWwaPOWTneXS532sH6PNrrmWrTQgHM/xw5GenC7
         P5Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=vE25/fE3GbSUmEmrdF2LzH942xvuS41f5y8rGOLXdnQ=;
        b=K70fowrKzVGTQmeqt6/gAGehXdqdv4uwq8+/tRFpGroBl/2DzILiu8UAPSSvwLukiI
         PVNetugBSPE2kqMeq3FLbPl+beTXUwuTkMYFjvdRNzYUN4lTvAhs2kTM0uheWa016GcJ
         G8qKl2pRZRlL4syORv5sPJFqoo1OoxNVVHpi3f3JwIl33I9i5HfcUcHiMGLNyL9i8vDJ
         nbhDHpYjSDG/T3LnDZu/3UwJMu6J+7mD2e6dvU+BHvl0gUnwzWfXWn3+wkHFdxz080Ch
         ENhRgzBsUs6VCZN5flgrNfIlkOJh/0q4CfR3aUPJzVeE74aPWtWKiJkLEtSvMNv8d5nR
         dfcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=JRKbcrjI;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTPS id a6si5981008ljj.214.2019.06.09.03.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:08:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=JRKbcrjI;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 1AFF12E087D;
	Sun,  9 Jun 2019 13:08:53 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 13LYxQ2B9j-8pliI2hm;
	Sun, 09 Jun 2019 13:08:53 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074933; bh=vE25/fE3GbSUmEmrdF2LzH942xvuS41f5y8rGOLXdnQ=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=JRKbcrjIO3Qau84WEWIcAh/pGsYAjU0pBAE0iOqS7wdR0k5OSt+AWz7uKQJI4mJg6
	 8827ndi69XToznkB0q2AePqeqDvA/uq02G6iPx4++PVKEp0BXjJpvgdvNRgAY29Sw6
	 RRh4rf2ePf7A9V7TIg/fu2WM1HrJJvQgXF2H2b2Q=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 2fhLdaNKBQ-8pYaK4tB;
	Sun, 09 Jun 2019 13:08:51 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 1/6] proc: use down_read_killable mmap_sem for
 /proc/pid/maps
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:08:51 +0300
Message-ID: <156007493160.3335.14447544314127417266.stgit@buzz>
In-Reply-To: <156007465229.3335.10259979070641486905.stgit@buzz>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not stuck forever if something wrong.
Killable lock allows to cleanup stuck tasks and simplifies investigation.

This function also used for /proc/pid/smaps.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/task_mmu.c   |    6 +++++-
 fs/proc/task_nommu.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..2bf210229daf 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -166,7 +166,11 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem)) {
+		mmput(mm);
+		return ERR_PTR(-EINTR);
+	}
+
 	hold_task_mempolicy(priv);
 	priv->tail_vma = get_gate_vma(mm);
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 36bf0f2e102e..7907e6419e57 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -211,7 +211,11 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	if (!mm || !mmget_not_zero(mm))
 		return NULL;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem)) {
+		mmput(mm);
+		return ERR_PTR(-EINTR);
+	}
+
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
 		if (n-- == 0)

