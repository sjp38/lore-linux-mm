Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57BD2C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0460C216FD
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 08:58:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0460C216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 616B36B0005; Sun, 16 Jun 2019 04:58:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C50B8E0002; Sun, 16 Jun 2019 04:58:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48DA28E0001; Sun, 16 Jun 2019 04:58:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1A2A6B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:58:39 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v125so1032924wme.5
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 01:58:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=tyLCtkeeaSbQ0/DZJIU/kBEIiONfg61xJ9wYqMhu3iQ=;
        b=PL8ZFFqlTEC0gVlqGCrPs/Qde1sBTkY/OsSe0DxlKyrFCpQznUV8y0tuckZ2gnlLNL
         WttTAKKwVJCViWvcXtzpVzFjkJLcxq1RZziVbemxfhXCRUKhV24LvkAj/wt7nDwhUfSy
         T82NfBqZqd/U+3WmTqlRRVeVaekAzwydn7cDXtxDKuQc423TYqQIkzx2sjffmr5vMh6J
         uiiy9KyUlp6Kxza5XOVPgPd1YaCmbyCr3T8NHdIe50Zgmq+DpLkoeNT5VGkh+ofDijkW
         R2XYn8Z5Zzb5gLoVVg3DLHjtNJ7S5BgE1LZPytwvVGPit2nnCtSPtfS942Dh6vzl9uZ2
         8SfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUh6Dm7J92eF2WTy+FQspXUPww5smFLF+yOBGyAPgAT2b8Rbjv
	skBmKroUpoiOwYRN8oSy40R3t/ogOyToEsKzFdGKFhgaatj7ezW/oSEa+5YQvdzPzaPvc35eg6+
	rsPceE3TraipgiTfcv9W+WMUrWJ5eAJzNcqHZBpiO5szJRGN6eLxyeVPNsJXgm/vnLw==
X-Received: by 2002:a1c:f918:: with SMTP id x24mr8146363wmh.132.1560675519353;
        Sun, 16 Jun 2019 01:58:39 -0700 (PDT)
X-Received: by 2002:a1c:f918:: with SMTP id x24mr8146316wmh.132.1560675518452;
        Sun, 16 Jun 2019 01:58:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560675518; cv=none;
        d=google.com; s=arc-20160816;
        b=bobDoeZ+GSdbW5ih9guEMV55ydpgScZC7V/VntLIRf9naatjl/DHaul1o/V5XDmGdk
         212oWJ/Fi8bmzvR3qyFDqpqANIXi5GFa8YBbgn9OdZHq+KT6TsXClvw7tEVs4jVssc3C
         l87r1qTWRwm/x7ah3pAhJlfWryZ05ts4FRoxde/tKdZkulYNUNbb9pbz2Rqcw7jB7odF
         XHl9Vhr4kF+nXq0BQ0tGkUWMPsj03UusF08cRmjIuKwbG6avltLA8f53OL7xM/vhlxsl
         dXyRzJN6Xg1hONK4QILmZgIVrK4Fa7BwyJmJmYhAJJWJAtR1d3W/TyMsMyus5Dsg9m+6
         zYqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=tyLCtkeeaSbQ0/DZJIU/kBEIiONfg61xJ9wYqMhu3iQ=;
        b=jsKid7TpQ5FlzlgrAMy5IMIbASHV8bWElYkvqhAjjFvvTZnVbiNAf8LzgwDvu0HDot
         L/GwxtJasxPuSv9wFEJLmBzNIMd0yNzM4zw5YokxWxXrUkQfawgvxEfdlVVXn0BLDX+s
         oAt32bfJLXhfX9DHS7LIOCC5nLX9f3u4HsETneeZozaRQBjDbFt7AHlt9oTJYxQJ1y9m
         Zoz33FZysvLSUaL1ldwX2jl0v/dagAizdsyoaAuMl9OUfI42ervd/fmaL2Vs7j+4bRDl
         cw1KSL5eaY5yamif3JeXZAntyyj4E1+EgQHUawjHPmBafcMfvb/tSdAXGEAWH1FW+tBO
         r21w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor4205635wma.8.2019.06.16.01.58.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 01:58:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwKzUqg8BlO1Ylb95tRjzIGZjsZsFmWcv2rFYrJ9MB+V7yC0LnQN11PT1XceFWw6KKnypDx5w==
X-Received: by 2002:a1c:7503:: with SMTP id o3mr1885273wmc.170.1560675517908;
        Sun, 16 Jun 2019 01:58:37 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id j123sm16804248wmb.32.2019.06.16.01.58.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 01:58:36 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH NOTFORMERGE 0/5] Extend remote madvise API to KSM hints
Date: Sun, 16 Jun 2019 10:58:30 +0200
Message-Id: <20190616085835.953-1-oleksandr@redhat.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Minchan.

This is a set of commits based on our discussion on your submission [1].

First 2 implement minor suggestions just for you to not forget to take
them into account.

uio.h inclusion was needed for me to be able to compile your series
successfully. Also please note I had to enable "Transparent Hugepage
Support" as well as "Enable idle page tracking" options, otherwise the
build failed. I guess this can be addressed by you better since the
errors are introduced with MADV_COLD introduction.

Last 2 commits are the actual KSM hints enablement. The first one
implements additional check for the case where the mmap_sem is taken for
write, and the second one just allows KSM hints to be used by the remote
interface.

I'm not Cc'ing else anyone except two mailing lists to not distract
people unnecessarily. If you are fine with this addition, please use it
for your next iteration of process_madvise(), and then you'll Cc all the
people needed.

Thanks.

[1] https://lore.kernel.org/lkml/20190531064313.193437-1-minchan@kernel.org/

Oleksandr Natalenko (5):
  mm: rename madvise_core to madvise_common
  mm: revert madvise_inject_error line split
  mm: include uio.h to madvise.c
  mm/madvise: employ mmget_still_valid for write lock
  mm/madvise: allow KSM hints for remote API

 mm/madvise.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

-- 
2.22.0

