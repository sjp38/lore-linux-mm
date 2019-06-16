Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F47BC31E54
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDB721707
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDB721707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB5BB8E0003; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68F18E0001; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C618E0003; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9445D8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:42 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id z202so1032403wmc.9
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3ITCIjtRiKXBETAqnfXapAAbycKyMBn7c3dUFh4aTVw=;
        b=d/jH5t02Hxn1WHwiY0sT7+YZ+EtAjGto32AlRVz1Qkv3AcS/AbsUXiDQRmNc7ASXY7
         DWpDVyo9xRyh9/BK2flhInUnU9TJs+4U5F6TrsBM519d9GKrkwtFRElf/iTwz/LQSz8C
         iHhfCgB6oPWT9Z+qyZtXfaa4JOfyRJHAXe5QeMms18tBEiwIFxbeZN9fhNQ9/MTs5PAJ
         96jqJ2wtahXZoJtg4B7Yk2ccWc++ARiaIuzkggLIZmwvTHWRIa7VC8/RAZTLqO93G7XW
         JY3XMwtrXFjmyMbNp0S1Y9Tt6DIE7p7bQ4y2tZhVmfaKOkcy+uELzEwW2ifQFeoFz+k7
         DnXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIiN+KoUf1XTvK2RkNsbXk/rgfyQnT2Vf5zg05MZ0RhhM1D8UA
	lliD61GUYtdeI5MQ05W4lZtHFklm2haG9Kd+KD53OuQle5bT+OpWmEI/COq1uJZy3i73uB07VsA
	DttIDZCfUX4VkiWzRThphvj0YAvdbP7aFtuBezJPqhAVN5M4kgadWPXsk9NwelBt4+Q==
X-Received: by 2002:a5d:46c7:: with SMTP id g7mr19309378wrs.215.1560675522074;
        Sun, 16 Jun 2019 01:58:42 -0700 (PDT)
X-Received: by 2002:a5d:46c7:: with SMTP id g7mr19309312wrs.215.1560675521147;
        Sun, 16 Jun 2019 01:58:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675521; cv=none;
        d=google.com; s=arc-20160816;
        b=Lg4TdIsZMrHXB5lhymcBDVgUQIiFTQ/8TCqVOMBPNad4+0H6MJqd/21Wx20IvVneuG
         DPMBSS0COz12JoDUxrXsjMN3zf8pgjgCrACqTJUGWlKVyBBQcuqP2Y0fSwn3JLLdvtsR
         15Imq4IZUR5lNEvFP//lWPRZVu1ewkJW6WkcqHGSYeM2ZxnS5LROKhj12HdVIxi2rGry
         49zCuSvwBZ61SphfIRRWwHvpam+/qDGU5gtQ8US02LzlBzSqM5fOjAsKZfIQtmkCDL1A
         AzMuaYuiY9GJwyYUfnWZcg8+KbHeyDCkgNTamnRZnkwWsjmgIlZfo/WKKAoAe67yV13c
         E9kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3ITCIjtRiKXBETAqnfXapAAbycKyMBn7c3dUFh4aTVw=;
        b=FlQDWWCVJdWNKTn6LbsfXX+jx0g3q6J/iDQS38Oxd1YyOZBqifsGUMa+0kR3Jwuy8/
         knyDGF9nHEGxVwXuHok7zMl7u5gArCNIqq81NGgYJoGJ+un2Qq/9/b9cElbmGVdxqpud
         OrDKsoTzvF/4NSow8uhm5DOSmRbR7MZ73rTRHyIRRqxzoZOACb+pNH8B3i2qgLgLih8f
         l29nFZWO6Z32pcoasRnvK/FxaYaPD3ohVj5JVnFGNS1lBbyMvdDdPbCg0lHIJCC72Hjc
         HcGdpMpspQBOD1k9/66OuBfJGNuVuZ8zzYFMcSckzDiEHTG9zoqGmAZi0bX8LiVmABFm
         7bmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m9sor5754549wru.1.2019.06.16.01.58.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzQMjvzDFYnOgTdFM99hcnJUp0/uTV59QLuRVfafS23C/DUgS5gTgJZNRO0B4DaEtyvurzykA==
X-Received: by 2002:a5d:6a42:: with SMTP id t2mr6432594wrw.352.1560675520784;
        Sun, 16 Jun 2019 01:58:40 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id t1sm7728752wra.74.2019.06.16.01.58.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:40 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 2/5] mm: revert madvise_inject_error line split
Date: Sun, 16 Jun 2019 10:58:32 +0200
Message-Id: <20190616085835.953-3-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190616085835.953-1-oleksandr@redhat.com>
References: <20190616085835.953-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just to highlight it after our conversation.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/madvise.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index edb7184f665c..70aeb54f3e1c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -1041,8 +1041,7 @@ static int madvise_common(struct task_struct *task, struct mm_struct *mm,
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
-		return madvise_inject_error(behavior,
-					start, start + len_in);
+		return madvise_inject_error(behavior, start, start + len_in);
 #endif
 
 	write = madvise_need_mmap_write(behavior);
-- 
2.22.0

