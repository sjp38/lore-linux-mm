Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632F5C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A38D217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A38D217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AB6A6B000A; Fri, 10 May 2019 03:21:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65A5D6B000C; Fri, 10 May 2019 03:21:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570976B000D; Fri, 10 May 2019 03:21:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6AE6B000A
	for <linux-mm@kvack.org>; Fri, 10 May 2019 03:21:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n21so5343042qtp.15
        for <linux-mm@kvack.org>; Fri, 10 May 2019 00:21:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=qkp3uN3JmIP+V4STFBMw4M1itzMyk7qqDLAq1F6TTQI=;
        b=b9TnWTHA2i9xfPcHGHcMzyfRvD7dL1XEwwTRFZ1qRWZQbdT06464H3bMzUQdw9dzEW
         uOfyWWo0qZS2Km5SsQs6EIWZuk3kRpQ3FGWRjPo/6U20qFrPiV9ReyOYbj065gwTXnxI
         iE+Ba4DagafXUv+lEEM7jr9DEn+Mj9p1lzbRyJtEENppWrzDWKS2byjFa4JVxUorJ8p4
         o6bVhCzJXHDjRst6sJyspZTYC4Jz1Gooqy8qY7tiWZ4nJFiCvThAPUhRyfBvvzY1pmHR
         ZEsk8sBJABJyh45QWs8BUL5t+02DLHdZK541mC0FTSZ7C6ARs1dalVgsZ51liyyMsK2k
         Xteg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXPS6N7NfsShAxtvNKIqBSrtrzEopIZCnkSvpl7sxOvVb0hZ7LB
	fmhTzmauUeQDUk5gimM8NB2DCq5JlhNpy83ByHFiDH5PFfzgUwfeA1P9ePYbIaRB9upiHzH4icA
	ENkYCIc2Na83X0u+BRpbAgUebFvZ76BHfGoKp68mTMM+u9sZhj+pm043Vxu5Di3dxvg==
X-Received: by 2002:a0c:8aad:: with SMTP id 42mr7619440qvv.200.1557472888964;
        Fri, 10 May 2019 00:21:28 -0700 (PDT)
X-Received: by 2002:a0c:8aad:: with SMTP id 42mr7619400qvv.200.1557472888044;
        Fri, 10 May 2019 00:21:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557472888; cv=none;
        d=google.com; s=arc-20160816;
        b=yA8rzkHySUp6j0RIQ92pHIPtX+mSZDxMRQgPaz4IIpV47TG8SOU5S9pRiCNqt62/wR
         oVjwTzUDDP/4YoYf9vuqvynCucOWVWfedbHoJHCG1d5KzagQ54Vg2Ebu8CrFheNgvlzG
         3mtMtKRlE5UiW4DIKD1hGk2XXCl8LuqwpvfEM2SETLxQWOtnVuvA6gnXznHK7cla5FgW
         Ht3U3M3OKh4USxjYZb8dy6+YZYXRSy8Fkw0RQ7ZlOHwyVT4FKtmC/69kL2YYZIVd4o/i
         2OpaCgxuxStxDItjlZCNvVSALWgA6YBxt+j/lTN9WjEIAyZhllZloSswEIbJBlpqvDuT
         mkbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=qkp3uN3JmIP+V4STFBMw4M1itzMyk7qqDLAq1F6TTQI=;
        b=gX47RRwG3Si7HGQhk/jBArReFsgKS3WXRh6wEpZO9zcY0M9+h2Puc8IU7hLq9X9TgN
         r7KxKwG48703Y1BDRKMD5SW47MGzJRVGTReYad+HmnV9q74zvvS5g+2ARNdXssArLYke
         QxQdfiwbT0YCACsSVnC8mR23hgYfrbsiHlnEXGK0B8b4qUQU1f900S1j7FqvA2s+glRD
         Pt0R+WvtTUVo9QwIB4eMxiRzUV31iDm7mK5FgHNt046fEZvMghEB8Enljppn2aTnSZ+o
         ZkkJ1TVWsY56RSVpZvF8er/K8a9vMtGOlVDxnPPsgoEmiD/mPhKkYhxwpy2DN39Oyu55
         UQPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n67sor2450548qkf.124.2019.05.10.00.21.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 00:21:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxQmGrUW/No6yN8KlnGJEV4Aj+h/RJzKqJ9tg+pnXf3scxoRahou77rSE4Udu+LioHkCbnimQ==
X-Received: by 2002:a37:a216:: with SMTP id l22mr7397641qke.282.1557472887500;
        Fri, 10 May 2019 00:21:27 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id t57sm521405qtt.7.2019.05.10.00.21.26
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 00:21:26 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
Date: Fri, 10 May 2019 09:21:21 +0200
Message-Id: <20190510072125.18059-1-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By default, KSM works only on memory that is marked by madvise(). And the
only way to get around that is to either:

  * use LD_PRELOAD; or
  * patch the kernel with something like UKSM or PKSM.

Instead, lets implement a so-called "always" mode, which allows marking
VMAs as mergeable on do_anonymous_page() call automatically.

The submission introduces a new sysctl knob as well as kernel cmdline option
to control which mode to use. The default mode is to maintain old
(madvise-based) behaviour.

Due to security concerns, this submission also introduces VM_UNMERGEABLE
vmaflag for apps to explicitly opt out of automerging. Because of adding
a new vmaflag, the whole work is available for 64-bit architectures only.

This patchset is based on earlier Timofey's submission [1], but it doesn't
use dedicated kthread to walk through the list of tasks/VMAs.

For my laptop it saves up to 300 MiB of RAM for usual workflow (browser,
terminal, player, chats etc). Timofey's submission also mentions
containerised workload that benefits from automerging too.

Open questions:

  * once "always" mode is activated, should re-scan of all VMAs be
    triggered to find eligible ones for automerging?

Thanks.

[1] https://lore.kernel.org/patchwork/patch/1012142/

Oleksandr Natalenko (4):
  mm/ksm: introduce ksm_enter() helper
  mm/ksm: introduce VM_UNMERGEABLE
  mm/ksm: allow anonymous memory automerging
  mm/ksm: add automerging documentation

 .../admin-guide/kernel-parameters.txt         |   7 +
 Documentation/admin-guide/mm/ksm.rst          |   7 +
 fs/proc/task_mmu.c                            |   3 +
 include/linux/ksm.h                           |   5 +
 include/linux/mm.h                            |   6 +
 include/trace/events/mmflags.h                |   7 +
 mm/ksm.c                                      | 142 ++++++++++++++----
 mm/memory.c                                   |   6 +
 8 files changed, 157 insertions(+), 26 deletions(-)

-- 
2.21.0

