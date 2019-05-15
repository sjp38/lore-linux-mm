Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FAEAC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 177A02082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="bJzcjZX6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 177A02082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6FF36B000D; Wed, 15 May 2019 04:41:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1FEE6B000E; Wed, 15 May 2019 04:41:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C0F26B0010; Wed, 15 May 2019 04:41:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 357226B000D
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:41:15 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id v136so432806lfa.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:41:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=on37xMtDHf4i5spIW0sgEiVZh+kGUSg0VAm5Sv46Das=;
        b=iXPPlJN539idl5ggRQfdQlUrvls7zPq2mZ4U/UsPBKgcDy2dmdiYob0gwf6K6Ae4Du
         YZb578D/P2hcq1YlsgxgxHe0Nu3Lqo4UuJxJE9wDSdUsuIgiuZQi0sGru4hpIfXn89UA
         nQbh0WfMEAdMgRqTqqpwjU2lK8rjAmNGSaERrj1F1YD5P6ADKgcuH3rdmUgmDy6UO92n
         X9pJGrei7cOHYQ5w6DNFVaEnZ5/Zfuy5xR7g1eGapFIajLV0fHspV0GW5f+lfyUbxup9
         CzLCWSNPpKvquo9o40eSIrhPmVkA+l1CuRYykYW7un4vsJvzYYvfMAEmDpcB9lMFNyC8
         zT3Q==
X-Gm-Message-State: APjAAAWTyjgh3jjoPZxrUgxCcaMY/Kmcs4jSeKN92ehp2+HUygV6zbYS
	gnmW892tTc2963J9KgcWif6TilOXyqGv8wjnxYyE3xVU849aIkVtoAv+Nu8WM34cENl83QQb/4v
	aABHjOwLyzY6aAZHLJ+bZe/cILfJSyPi21NkDmGUlNtFxZWm0/qJqkIf9iIrq8M7Stw==
X-Received: by 2002:a2e:8796:: with SMTP id n22mr7297016lji.75.1557909674679;
        Wed, 15 May 2019 01:41:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkbDJRr8vZfaKipfaeMo4VIFC+JhTOjLGZX4usy4KShRCZVVyUtluxGQ+qWIKcOqbKjr1C
X-Received: by 2002:a2e:8796:: with SMTP id n22mr7296980lji.75.1557909673843;
        Wed, 15 May 2019 01:41:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909673; cv=none;
        d=google.com; s=arc-20160816;
        b=fAkbbfw2WyTNevyqflXhEJyFRIH3xKh9pLpEqDyr74sByC6D5/rWACi8VYApagMugP
         repvkqTI2rAyee7H2uXCqr2soKZKWADILz4kGKZEBQBGVLqBYQgVqU+SQOOixJ5p0dKL
         C4H4XMR86eRz9uW/w1qLCb2QFXCilpcUjS0F204zqx8FULSTh1VdpXCh1UyE/iDkxMzX
         OMjBn0CcrTdPWYYLygnEuf6aWGZP5Y6Lr1DWUj8PwCag2u7DZ0uBoftcdt57qkY3mnsg
         AvJNzpxHhGBvCHZRrbf/0eHR9BVQ394IliZ5BVjQUXlH0mfS+vy4VM/8YScw842OcavT
         X0NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=on37xMtDHf4i5spIW0sgEiVZh+kGUSg0VAm5Sv46Das=;
        b=ehIDNmZ/jRUqgN7Mtiv2Gpf5Nzpd9ST8+/oJrIlcz8w2h6OdzRWSmejksDs/E24VNG
         jR8PsV3IBCt9rOOnS9FNIzrL3ltclzMvRnbpn0WnQVqez7+pVUrGMZ8uzGdVyvURRAN/
         eVdIvWY30nK/iHe7mbkW83mL5EaREq8Czf6qLJkcDH+PL7jwCAgsAfG9qB1OqAlHc7gI
         jANWbQBr5cSLJhHJuqTBk4rndJwwu7XlzriGoCMNH2MEjUDGKLaxqs9VEd4tFxdl9LWo
         cz6uWGdJXoOwtZ/XxJMad/lE/HpH4M9rZSa1SwOVEgEappJm8UaKqGAqD+Jzo3+Rb+3A
         /HvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=bJzcjZX6;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTP id v7si1003096lje.199.2019.05.15.01.41.13
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:41:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=bJzcjZX6;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 917962E14C0;
	Wed, 15 May 2019 11:41:13 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 7l8bZ6vz9S-fD0GwFgT;
	Wed, 15 May 2019 11:41:13 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909673; bh=on37xMtDHf4i5spIW0sgEiVZh+kGUSg0VAm5Sv46Das=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=bJzcjZX6IIAUCNZqdyJas7Z7fGK9P92gcfgKNFGVYrbxnXDJ17C82J8LRWdyyAtHl
	 EqAUj/W8BAy4Hpaw7JwRetWb/oFU2VFVtGgph3dPKN16Nxj069xSvJi4qjWeh07zl9
	 r+h/pSCIwWSvsMqVdHCAPlw4g0drkv+mbzc+HnWY=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id dM2CepgjQa-fC8SnGfC;
	Wed, 15 May 2019 11:41:12 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 1/5] proc: use down_read_killable for /proc/pid/maps
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 15 May 2019 11:41:12 +0300
Message-ID: <155790967258.1319.11531787078240675602.stgit@buzz>
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
This function also used for /proc/pid/smaps.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
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

