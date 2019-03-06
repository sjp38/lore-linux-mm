Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5BE9C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5511E206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5511E206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4D2F8E0003; Wed,  6 Mar 2019 02:18:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD49F8E0001; Wed,  6 Mar 2019 02:18:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99C978E0003; Wed,  6 Mar 2019 02:18:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 701B98E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 02:18:23 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q17so10573446qta.17
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 23:18:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=uXLVwTU8htO++Si0CJHevlBV5WBu5W104sBZxBQhsAM=;
        b=s4PkqtT1MXgtvGu096nB8YyHNQjUyb8w12aOknRUrfgGuPCZgkxwZd8GbCj5sRByRt
         jAagwxLIYgJTRt93WOmfMq55fyufNxsxdm/lahtl13uwjUYIRDAFlrzlKEqtorx/0v4b
         vqPvOuk/Vl4zEy5s5JDBK7SqcfzkKJuEJxtXVcg26bqi97ce+HVQfxGjJo10GOZMWZT1
         Iq+jFbhywLbdpc42S2MD3HP0YIDYHgEFLJnb/bGNWteBNduji8NIXz9Er5CV392VIBsM
         61qU3DW7dEe9GH4wTIMY/mnPQWrmEuYIvomCt88kpQhj6Xss8mTotWTNNJ29jfutw0Eg
         NVYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6Qicc3V0TyeURG48vcPVQobffQpXj7/j9br8QPZ+f8VdtTMs8
	HWcP73AKDS9D5vw3wUJsLIdwv9cgwUixAVUh9hoVJd809FP4jEnCP9WdxiPx8W6rgcFJHkVxuMd
	v5ei6JsfXiwcOtxwxvl4eK2kNtlrcWptqI7X2y788WJ9pvjpOWAG9084g3j75c7U0vA==
X-Received: by 2002:a37:a9ca:: with SMTP id s193mr4533683qke.299.1551856703163;
        Tue, 05 Mar 2019 23:18:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqwpykcngQ9/okA8lcjO2ofBjNE7I/01vQChYjweKQjPIZV0jkB9zG9lHYacuo2ZsZlIMBwQ
X-Received: by 2002:a37:a9ca:: with SMTP id s193mr4533664qke.299.1551856702386;
        Tue, 05 Mar 2019 23:18:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551856702; cv=none;
        d=google.com; s=arc-20160816;
        b=RW9i4l+IMfRv2rl6Eg/Pj60rKF11Ceze71/0DVROWa8hDcDax8FD8hHI66hfr+yKIt
         imrnzmhQ2x6cWNSvxv6wAE9/W13Fsi9I4mF8tKxqp0R9e3isAKptT5LTKsYTy6oNRLKz
         YoVs/SJC3lxRVMbWres7f7BnB8jMs+dSv7HlD/8h65FPiLlwrql9lj6Wm7bFJrXm05FB
         DS4hJ0LarZVnZbk66gbmdNqXE5z00yzoenGNo6H+dJisTKMx4/ayKuqJrioBvVdAaipy
         ys17+JiUMMSjEIlKU2JKuofIr9ecenKLw3XUNEbbPB6vA2YmyNypPE4NkfcHqbJDiLQP
         XjBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=uXLVwTU8htO++Si0CJHevlBV5WBu5W104sBZxBQhsAM=;
        b=AUnmx26pGA4DiumAw2J6nGLTFfFxTbkpHq+duiqNDgPduEzdvtxIuV4z2RPjbCndFO
         vC4qhhuGZw6xmMoIArCa4lgTMkDr9pGknyW3guXlP0Xt801tLxfVcwmkvsaEF+fsUP1N
         xoFyCtZxUePqoCBJNKQuimQ//Y/8N4bq26VPcSYdaYuiX2C5JA+pRdyCtwuCp06tFkmW
         XhzCjjdOgsxkzCavTnyxOEzskTxWUsBqbtVzFYvFKxypL5E+s/GjQhBTVOiw50gJJnsN
         yMSEbgCG75ywasmOaUI6ipl8sjwSjQCcRszYgh+5dcO3HCp7rcyHyfzdpcczX+vz5CZf
         nNqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a21si463809qvh.54.2019.03.05.23.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 23:18:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5867A3082E0E;
	Wed,  6 Mar 2019 07:18:21 +0000 (UTC)
Received: from hp-dl380pg8-02.lab.eng.pek2.redhat.com (hp-dl380pg8-02.lab.eng.pek2.redhat.com [10.73.8.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8E7FB600C5;
	Wed,  6 Mar 2019 07:18:14 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: jasowang@redhat.com,
	mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	linux-mm@kvack.org,
	aarcange@redhat.com
Subject: [RFC PATCH V2 0/5] vhost: accelerate metadata access through vmap()
Date: Wed,  6 Mar 2019 02:18:07 -0500
Message-Id: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 06 Mar 2019 07:18:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series tries to access virtqueue metadata through kernel virtual
address instead of copy_user() friends since they had too much
overheads like checks, spec barriers or even hardware feature
toggling. This is done through setup kernel address through vmap() and
resigter MMU notifier for invalidation.

Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
obvious improvement.

Thanks

Changes from V4:
- use invalidate_range() instead of invalidate_range_start()
- track dirty pages
Changes from V3:
- don't try to use vmap for file backed pages
- rebase to master
Changes from V2:
- fix buggy range overlapping check
- tear down MMU notifier during vhost ioctl to make sure invalidation
  request can read metadata userspace address and vq size without
  holding vq mutex.
Changes from V1:
- instead of pinning pages, use MMU notifier to invalidate vmaps and
  remap duing metadata prefetch
- fix build warning on MIPS

Jason Wang (5):
  vhost: generalize adding used elem
  vhost: fine grain userspace memory accessors
  vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
  vhost: introduce helpers to get the size of metadata area
  vhost: access vq metadata through kernel virtual address

 drivers/vhost/net.c   |   6 +-
 drivers/vhost/vhost.c | 434 ++++++++++++++++++++++++++++++++++++++++++++------
 drivers/vhost/vhost.h |  18 ++-
 3 files changed, 407 insertions(+), 51 deletions(-)

-- 
1.8.3.1

