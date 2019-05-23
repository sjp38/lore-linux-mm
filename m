Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67654C46470
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A12F20863
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:09:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QSVcDQxM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A12F20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A488E6B0008; Thu, 23 May 2019 10:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F9636B000C; Thu, 23 May 2019 10:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90F6C6B000D; Thu, 23 May 2019 10:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75BF86B0008
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:08:59 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q23so5442819qtb.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:08:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=D7sWcGrnemG2fJlvPocz+9qvuECqs/5cXOH/D7sSQhGTT4aYEgtCmvogbg4TJeG+cM
         P98/Wy6WzpOKM2uYwAWATc1qw/v8X0swi5tobk3HJdn5swPoDf7GlGbdWDkvv2ZYI6CG
         KO+C7ZqkcwLBAgo6zGaPZHj2m6unb/2hC/94NuwR+9L7K9QOJGrehVe+fvGoDdiVsd6n
         7+Yd7YkpBxvP4323iLT6izVWsoNdMLlKZd5Nwz0VkYC6jdb+A2YNUQ7rV3UQwxqcOIk6
         vzhYB+6H7rdM9GGltwNcTdVxuuQ1Jow4oalONzdyy5+pJHp4gRf7bRkDZl+3VZlymo8t
         thQw==
X-Gm-Message-State: APjAAAWb5wFzi/1Qj93xn3KV6mwfQtWkqrm5eGWJ1Vsf+zbqZVpPk5bU
	Vc1KC3vPWz3ZqzgjH3pgfDnPV8gonjXjYORYiM4nXXiZ6hEFETnpytb839z3KVYVwM+c5YjU3d3
	WQQsUiEbJKZeKmkqEPWvzqykv19nZraX5LAkCQNAXkfg8ND7HjrefWR9RFfhNJS7EdA==
X-Received: by 2002:a05:620a:11ae:: with SMTP id c14mr9253307qkk.85.1558620539211;
        Thu, 23 May 2019 07:08:59 -0700 (PDT)
X-Received: by 2002:a05:620a:11ae:: with SMTP id c14mr9253235qkk.85.1558620538476;
        Thu, 23 May 2019 07:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558620538; cv=none;
        d=google.com; s=arc-20160816;
        b=YHhyVDl9i29TRArWKNHcn3SmeAvUiW0hD/VEyzEnleo4ZGZsBqi5pPo7pwGYwcrTO1
         wTzi6dzBZLw7/ikmYyxl1vH/4t+YsfRn7fj/aCmQW5rL0Bdf49o4AQo0zVXYxLGsinc/
         CIkiHug66Tj/cxg0nKUvk54iz71YcQmnQcKaUNmI43s2uyirMEPGq6H2VuuO942OXX9n
         TRW+iSSxGS2uA50WfX+rmgO0eXWSLCeUW2/iRmS66ZooXmHiJYbupFozBXal87DFMLiX
         lU4sE51xwUgbeX9ph8SpesJssS2QXQcvfJMUqWiZm8wglyD2qmcBTHZXjyGF7wMlblPF
         Rt9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=Kjw34M9U3WZnmRxlIAJuO3EZi9yH73U4fDCaJrd13sukEzS2Il5vBTYA/WZAsXOUys
         HTkCCrRed101IK2ybvM3IA7dIxV9BYhuIRmS/NV4MX6UdqzDYW+gc1p7wSLP4tPXe6KH
         wxXJa2LTxAdUFYa1r7ZV3mk+MCTWV3mHgzDM+R6Ro47GtHTh1VCbVbtMe35HPjSvU1Yj
         RfwEe3hN/9xRD2Ab6hja77jngMlUiMBB1VUpzpG79nh0u14jKoCt67Yu+CMSIKgRsRrs
         p6SnxFPvxdZwlNdYsnECN8Qe5UB4ZIwPKu2oLdnIRwUeyPSV2ibka/qlRQRrR+gWbsH3
         R9tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QSVcDQxM;
       spf=pass (google.com: domain of 3eqnmxaykcfu38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eqnmXAYKCFU38501E3BB381.zB985AHK-997Ixz7.BE3@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c2sor21415012qvc.7.2019.05.23.07.08.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 07:08:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3eqnmxaykcfu38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QSVcDQxM;
       spf=pass (google.com: domain of 3eqnmxaykcfu38501e3bb381.zb985ahk-997ixz7.be3@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3eqnmXAYKCFU38501E3BB381.zB985AHK-997Ixz7.BE3@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=QSVcDQxMHDwf8m/Z00oyTMaxgkEpAavtybAzTn6owaPo+gAmLQ7/HmGrhaVojqa/Z9
         H3RWBQuoUt7y1CPFPUSYmC3KFwZXYCXhsfg3TCzVqJhn8CbhPgjm9rKJWQDX7Lu/2d0W
         Dsq823bTZbsbvOS3FJZxLzlDpc2K/sJx5F3y4OG8DQxWxVuNEHRX3wswKeIrOLGu4JEH
         1P1KizLqCGCvxfpwPbt4JvR7LuXsduw83cDbNhfkxg3jxs4SgNA4G18Cufc/NtkbcRrW
         nuizYWd0dCXGDuYT3EFJtWHxhGMyOtpdRhrfsgswuXoX+qLlyEVvHWcK2HoojRAzEzvn
         4BAg==
X-Google-Smtp-Source: APXvYqwSUxwQ8ZuNx1PgcNhs9sqtZK2tJMlDKqjgJyD1uwOWdZQSCxHOVN2MDcLXkAW2ECB0c+wPbMvjU8c=
X-Received: by 2002:a0c:9562:: with SMTP id m31mr59699151qvm.27.1558620538065;
 Thu, 23 May 2019 07:08:58 -0700 (PDT)
Date: Thu, 23 May 2019 16:08:41 +0200
Message-Id: <20190523140844.132150-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v4 0/3] RFC: add init_on_alloc/init_on_free boot options
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide init_on_alloc and init_on_free boot options.

These are aimed at preventing possible information leaks and making the
control-flow bugs that depend on uninitialized values more deterministic.

Enabling either of the options guarantees that the memory returned by the
page allocator and SL[AOU]B is initialized with zeroes.

Enabling init_on_free also guarantees that pages and heap objects are
initialized right after they're freed, so it won't be possible to access
stale data by using a dangling pointer.

As suggested by Michal Hocko, right now we don't let the heap users to
disable initialization for certain allocations. There's not enough
evidence that doing so can speed up real-life cases, and introducing
ways to opt-out may result in things going out of control.

Alexander Potapenko (3):
  mm: security: introduce init_on_alloc=1 and init_on_free=1 boot
    options
  mm: init: report memory auto-initialization features at boot time
  lib: introduce test_meminit module

 .../admin-guide/kernel-parameters.txt         |   8 +
 drivers/infiniband/core/uverbs_ioctl.c        |   2 +-
 include/linux/mm.h                            |  22 ++
 init/main.c                                   |  24 ++
 kernel/kexec_core.c                           |   2 +-
 lib/Kconfig.debug                             |   8 +
 lib/Makefile                                  |   1 +
 lib/test_meminit.c                            | 208 ++++++++++++++++++
 mm/dmapool.c                                  |   2 +-
 mm/page_alloc.c                               |  63 +++++-
 mm/slab.c                                     |  16 +-
 mm/slab.h                                     |  16 ++
 mm/slob.c                                     |  22 +-
 mm/slub.c                                     |  27 ++-
 net/core/sock.c                               |   2 +-
 security/Kconfig.hardening                    |  14 ++
 16 files changed, 416 insertions(+), 21 deletions(-)
 create mode 100644 lib/test_meminit.c
---
 v3: dropped __GFP_NO_AUTOINIT patches

-- 
2.21.0.1020.gf2820cf01a-goog

