Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE06CC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A72820665
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A72820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28AA46B0005; Fri, 24 May 2019 04:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2135A6B0006; Fri, 24 May 2019 04:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B41D6B0007; Fri, 24 May 2019 04:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCF5E6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:12:34 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f18so4116926otf.22
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:12:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=4R/uufAPwtuljdUbYazquyT8ebzhE1yc/BRhOIPgoI4=;
        b=G1kFogk6qpJ/izYH8Ct8GqBHoexJWMJO2cdLjjpsxlW+hTzgwDCzmAQCw3bQwcoKTQ
         YbX2EYpXMjA3GAE2wntOr+4G1VKT3zPydrdrMaoLVimlax4hZJxHNcMbm6Bcgm3ztFf1
         0A5aoevcYPCQE9mcg4eWYRt+hwk5fBYQxOLBsMKTZ7MZdgYpZFTDnbqT/7A2oyIsuvgs
         eO7g5Y0KJlPzt4JHzN5WFmExymkKFQzl1vewE2ZBESoX1OQ4WK7qDEke0bh5Tqf0++u8
         h3qylX/PyVX8Fjm68QCv2a8WHhHDCp/Uqhy5BMwboN72mbfQAC04WhOscGbt931T+rYZ
         8f1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUK3MF9Vbv9Mgz1fhUQxuJtFktF31Us1O2v1rXL0BV7lNUnh7kG
	h4wusYCC4xbnPByfUJ54GoofypPtyuxKxGNbZ/lw34AtJ2ZUhsa2S2GKOzRDzYq2E6Xvs5jvTbk
	/5wTTjs+wlzx8buar9nBKcXq1S0B6qRCQYbTtXh45Y0dXxVJLNsoseAPI4hcSoHpj2A==
X-Received: by 2002:aca:f2d7:: with SMTP id q206mr3201764oih.52.1558685554427;
        Fri, 24 May 2019 01:12:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHEeLnG7yxYEywic6iMghQ5TShRo0SG+6IrVeZOunqdTlCxp0XQQ2fWZulE98a0tJDCnnD
X-Received: by 2002:aca:f2d7:: with SMTP id q206mr3201741oih.52.1558685553698;
        Fri, 24 May 2019 01:12:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685553; cv=none;
        d=google.com; s=arc-20160816;
        b=JBCDpYt83px6APbHYlBDEgMZ31GUQOcaRwYGVowKvFGtS0ahz20cqox9zXMyMEPPQu
         43SNQCh3majux7o91vM9tX625jiph8O7TaAt0SJwExi0n/OVHwd3rCfX9KDnQebE2rac
         7fYucrFj5S8Z3gjIatKa4Oj8kBdgvrHTujIrnIN8hPL/KMQ86WAG4FuB3gHWgYAiU2SD
         ADBxkoUXf0jO0tbgI+kqLxbKlu+s/yyKkhQizj1njpMKKzmG45TyGMrRnZGziHCEOlUh
         n8IpruvkihhK0ArPeoGGNGLQpyK8upj7mOkfJWdUHTUO21GL67Wv0Rb+tRMV+sBPBOUc
         6c4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=4R/uufAPwtuljdUbYazquyT8ebzhE1yc/BRhOIPgoI4=;
        b=CZwX+p/dajrvjicxOueZmkU8GGfFo2Wo0/jJh0xGLorHbUvbiL/8d2TnWeTWa1o9OM
         B4UXphE+WXn8XTwHoOGzqDzo1rkvfQmU68lwWUx5UgQN/CorGL4mAdpOikcDkLcsRXFS
         D7ijwhqEXksJXE3FNF2Zsc7eXE//K2MIxlfJcKPT0qomD+mfmDQfx+G5wQYMCmGxyedW
         FaGmXsGavRp51BCuKVdhnMHmbra7oSvhdgdyPwI7TB0DexlpfXYCo88NbIcrsfkOxM6F
         UF+1cIcvqPq8p5lDrosQDG9WynLZEEtx5cejP0lcLwRoss9tiF6TVnRs9V+vcMsCTQ0H
         kN7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si1067513oti.59.2019.05.24.01.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:12:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5C814307D851;
	Fri, 24 May 2019 08:12:31 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3C7ED19C4F;
	Fri, 24 May 2019 08:12:20 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	peterx@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [PATCH net-next 0/6] vhost: accelerate metadata access
Date: Fri, 24 May 2019 04:12:12 -0400
Message-Id: <20190524081218.2502-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 24 May 2019 08:12:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi:

This series tries to access virtqueue metadata through kernel virtual
address instead of copy_user() friends since they had too much
overheads like checks, spec barriers or even hardware feature
toggling like SMAP. This is done through setup kernel address through
direct mapping and co-opreate VM management with MMU notifiers.

Test shows about 23% improvement on TX PPS. TCP_STREAM doesn't see
obvious improvement.

Thanks

Changes from RFC V3:
- rebase to net-next
- Tweak on the comments
Changes from RFC V2:
- switch to use direct mapping instead of vmap()
- switch to use spinlock + RCU to synchronize MMU notifier and vhost
  data/control path
- set dirty pages in the invalidation callbacks
- always use copy_to/from_users() friends for the archs that may need
  flush_dcache_pages()
- various minor fixes
Changes from V4:
- use invalidate_range() instead of invalidate_range_start()
- track dirty pages
Changes from V3:
- don't try to use vmap for file backed pages
- rebase to master
Changes from V2:
- fix buggy range overlapping check
- tear down MMU notifier during vhost ioctl to make sure
  invalidation request can read metadata userspace address and vq size
  without holding vq mutex.
Changes from V1:
- instead of pinning pages, use MMU notifier to invalidate vmaps
  and remap duing metadata prefetch
- fix build warning on MIPS

Jason Wang (6):
  vhost: generalize adding used elem
  vhost: fine grain userspace memory accessors
  vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
  vhost: introduce helpers to get the size of metadata area
  vhost: factor out setting vring addr and num
  vhost: access vq metadata through kernel virtual address

 drivers/vhost/net.c   |   4 +-
 drivers/vhost/vhost.c | 850 ++++++++++++++++++++++++++++++++++++------
 drivers/vhost/vhost.h |  38 +-
 3 files changed, 766 insertions(+), 126 deletions(-)

-- 
2.18.1

