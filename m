Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BF2FC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA02206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA02206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBD348E0005; Wed, 31 Jul 2019 04:47:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6D978E0001; Wed, 31 Jul 2019 04:47:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A83E58E0005; Wed, 31 Jul 2019 04:47:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCB08E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so60951995qtb.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=3D6gBoxJOGt4vALoZto7iLJIGDq2ey5aEjXujJspkhM=;
        b=nLYfKB7s6UeHSByokPFvTe7LavETPF/a0vDMbLTyE5wlOPgqRUOfKOHpkmhbRB8xPr
         krMtRWSRjLeYFLZCQ6FzN7r8+KpXPhKKifZ70NWnausplUyn8oc9nGRRtwV0bHjsq2UJ
         tk0tx93t+0EZ2sIcSKIiURzBAshBHoKmBvwsc+Qy4Ht1zy8FYfPmNcdFfNNwxEpHWhlP
         hhKacaSQx0QtTOYqaHCGkknHtx5Bia4GhGgYC5fNduNM+zJN1PzJ3XoQXF8DENO2rBkc
         h4HW4YBA4r5Xszojld3M8UEMDG1hOWzARP8R+JzyY6tbB+h/Xn/4h/NUgarC7LAyrkut
         MJVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/Wz2i/ZfTfSxXvMnLVmzC9n0cplDdXzbGaZMVG1MSDCamaCKQ
	DkCvdkBglKCkloXzvVVOGejnUEWTFYSOcwf2Sbw35ZaQ3icEBqh+u5NP+7pCBIg1KfmytKdyezc
	V8gxdliXw1GiOPMN09AKOUhZ8GVXEYQW7ZvLiTQGSwHa6bKWjdZ9S0CKEk/USapv4ZA==
X-Received: by 2002:a37:a413:: with SMTP id n19mr74870234qke.98.1564562824336;
        Wed, 31 Jul 2019 01:47:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzepAPJkQKcE+pqmYwKrLZt/rsBGI4T+xq3vxxlepSOMBEfPDBWZntcabO/JzA1M+l8JQFP
X-Received: by 2002:a37:a413:: with SMTP id n19mr74870204qke.98.1564562823492;
        Wed, 31 Jul 2019 01:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562823; cv=none;
        d=google.com; s=arc-20160816;
        b=K2agFsLhb6/T8gXlGAKtvdXTdV8+8JekPIdmAGhEgmgNs5uXANnyCqvEMhiyQwJJab
         tz3ggxVSDQeCXtuRh6CvwshsuuUT84m/8T6L6RHVHr2k3P7T2irnmxQGCS8KzBfY+ZjX
         kL+pFiFz/d4C0G1Pt51S7gO36k2XtBOTNdT5AMgVyejKBvnL6om0P3iaS2+g26WB2SCr
         yVu//JIny9MmSgCSNF5uYxPnL41uDG8pIeDsFL4ZyNRbJZqjZJkqmRXt2T1sDxoU55ud
         AEpRc6WfeXCPQjGCF0dmDkRE3C65YhgHSWjS01dZl2Y4SH4SeA6+YsR88COR/Gtbp3gp
         5eAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=3D6gBoxJOGt4vALoZto7iLJIGDq2ey5aEjXujJspkhM=;
        b=vlM50jmCDI28bpiFbY7nlbgn3/ZfHbVqg+t3KLL3eUzMVq+Lw1fXatT8FX8H7tabTq
         73eRLyz4XoS5qkt4+TcmoBkk9Pcuu9pm/gikGHPfzW04Khrn/nBjzRNBLz3nqgHGEA07
         9LOr32veyIG0EPJr0ETRZBagwWNXdyV6otlbuzPtVj+5dcKSJaVihsMwfmPuEy/6hCmN
         hMWPVB8KeV7vgje2flkydywCzWjOoWKKVGXaQoJTIrs3T9WnYZ/5umXDmVNLTak9Gz7I
         miAF8d3hvo3gxxQcH9839jtJwXNAHtgzUaOQWh11OFUb8NpzqnZ6ymD81vbXGBndCzdb
         OwNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k123si33606986qkc.353.2019.07.31.01.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BD25E30C1346;
	Wed, 31 Jul 2019 08:47:02 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0A0E2600CC;
	Wed, 31 Jul 2019 08:46:57 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 0/9] Fixes for metadata accelreation
Date: Wed, 31 Jul 2019 04:46:46 -0400
Message-Id: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 31 Jul 2019 08:47:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all:

This series try to fix several issues introduced by meta data
accelreation series. Please review.

Changes from V1:

- Try not use RCU to syncrhonize MMU notifier with vhost worker
- set dirty pages after no readers
- return -EAGAIN only when we find the range is overlapped with
  metadata

Jason Wang (9):
  vhost: don't set uaddr for invalid address
  vhost: validate MMU notifier registration
  vhost: fix vhost map leak
  vhost: reset invalidate_count in vhost_set_vring_num_addr()
  vhost: mark dirty pages during map uninit
  vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
  vhost: do not use RCU to synchronize MMU notifier with worker
  vhost: correctly set dirty pages in MMU notifiers callback
  vhost: do not return -EAGIAN for non blocking invalidation too early

 drivers/vhost/vhost.c | 232 +++++++++++++++++++++++++++---------------
 drivers/vhost/vhost.h |   8 +-
 2 files changed, 154 insertions(+), 86 deletions(-)

-- 
2.18.1

