Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074E1C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1F2E2133D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1F2E2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3283D6B000E; Wed,  3 Apr 2019 15:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D6506B0010; Wed,  3 Apr 2019 15:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A0306B0269; Wed,  3 Apr 2019 15:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7D2B6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id m8so159607qka.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=/sjvrgwrNlY9OVbtMc06+FPKtsX4fSyiAnlQmRvuCmQ=;
        b=gBpUyPE3kZXL7DstazmgPxr152hZUfJBd51EptT9R0Pp/3f+2hhHIUHibNwckPmH1K
         U/64PLWUigMKUn0Rswlm3nkmLTYPLtpljm5rq2xMU7N9Xj7Xp8UW0PRm8gG4ezVjAsZJ
         zI0Bq4fbx0LIbYqQbPplmeaGCkNX+7VGGFaQGE0oWOWwYXXAaCEoXbooNNbqcN492s8r
         MRpbO7jdqqrAZpHeEnn3nJwRtLijBVBtsfKcmXppyAmnQfyAcyq6hiElKKYrxIQdyXRq
         l9SZ6jD7rl6Ll8LH6cigPrkRG5MVH+MS9T6xyS4O9UJGqLgRZe6bTFILhxDwN3N+52zc
         eIow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEqIdi73RUszS/GkVK4nxINYiGSeYtIYfPq3YeN7kM9AbcmsjU
	c2ikCbb6qnCfsvXMsAu4WZNa2/6ppufAOrCYrkhcoAaGvJ2RGb6axZ0YOL/soIr8QVEjRUc5reO
	pX2y9rskX6feIcCaZrc4FLCtM4iZ2H8dt9vRlNdBr3yRBo6oU+dfcfEb1ZPwiq3qzRQ==
X-Received: by 2002:a0c:986d:: with SMTP id e42mr1233317qvd.51.1554320010618;
        Wed, 03 Apr 2019 12:33:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfyVYtywDLT4HCH1A0idcP6hiv7iFM9R4QbYNyy7obQjBL/Ro05cI7B5bvpS7QEBnDhdb5
X-Received: by 2002:a0c:986d:: with SMTP id e42mr1233291qvd.51.1554320009994;
        Wed, 03 Apr 2019 12:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320009; cv=none;
        d=google.com; s=arc-20160816;
        b=MoFKHIfC4OjtdtdMDerGVKRaSxlzqu44nGQ7F4B8fK8behjhkFIbyq/puiBHVJ9R0+
         nJm8Zw0MBpKwY2vHyYzmEhdg7m3tBEXG6cxOd1AjUrErb03q7wnqLaxWZSsjhRvhezAs
         6/FBY05uObDdpgLU8K2ioAnPcRfGV49QeAGkU9XQR24IoU5dLdZQ7o1kphVEfqLyGGRm
         M7KWQCLQaf/J5kDYXFbgsMwnfZ+jBan9YvGpIUajuYOXTj49LuanHBmTAvQQcJsZRVwW
         QSnCAHfVudeWhaiaVVooifiXFqZr4OzAlv8SAKHhqIvlR6LgnsGwD8RWqIbecNwK3+dV
         pxWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=/sjvrgwrNlY9OVbtMc06+FPKtsX4fSyiAnlQmRvuCmQ=;
        b=aVGOTHJkeAqrWAwdJmTbTPW4fALgZ01W6etmbrLElV3k7PnD8KMP+Nphj99z9KZoPF
         BE3c/wNGOfILXSSwROJAOG1cko+GpM+ixITje9RsaAyc7R2Oxw6LkS4waCl1mCDvzPSG
         JKojVZhe4YL6ltYYVf35JlStwIubPNWFTVsm4axgY1C/jGtTFKTWuBpdMH3AXUi312Dr
         bpoOAt/zeJEzjvaJo1p7htLdfMj16YQNSeHwx4LJDV/lK+kcTfz/tNB8gfGyexXf/+3J
         j9tzsV6TH0wO4Pen8fDSls7cWUgtFRp6rdtpkrwDY6+GnjuqtscSxlFsmH0QI/7uoTh2
         RbOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l6si872073qkk.80.2019.04.03.12.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 15AEC3092667;
	Wed,  3 Apr 2019 19:33:29 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D211360156;
	Wed,  3 Apr 2019 19:33:27 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Balbir Singh <bsingharora@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v3 00/12] Improve HMM driver API v3
Date: Wed,  3 Apr 2019 15:33:06 -0400
Message-Id: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 03 Apr 2019 19:33:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Changes since v2:
    - Improved the documentations
    - Added more comments in the code to explain things
    - Renamed bunch of functions from popular demands


This patchset improves the HMM driver API and add support for mirroring
virtual address that are mmap of hugetlbfs or of a file in a filesystem
on a DAX block device. You can find a tree with all the patches [1]

This patchset is necessary for converting ODP to HMM and patch to do so
as been posted [2]. All new functions introduced by this patchset are use
by the ODP patch. The ODP patch will be push through the RDMA tree the
release after this patchset is merged.

Moreover all HMM functions are use by the nouveau driver starting in 5.1.

The last patch in the serie add helpers to directly dma map/unmap pages
for virtual addresses that are mirrored on behalf of device driver. This
has been extracted from ODP code as it is is a common pattern accross HMM
device driver. It will be first use by the ODP RDMA code and will latter
get use by nouveau and other driver that are working on including HMM
support.

[1] https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-5.2.v3
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=odp-hmm
[3] https://lkml.org/lkml/2019/1/29/1008

Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>

Jérôme Glisse (12):
  mm/hmm: select mmu notifier when selecting HMM v2
  mm/hmm: use reference counting for HMM struct v3
  mm/hmm: do not erase snapshot when a range is invalidated
  mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot()
    v2
  mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault() v3
  mm/hmm: improve driver API to work and wait over a range v3
  mm/hmm: add default fault flags to avoid the need to pre-fill pfns
    arrays v2
  mm/hmm: mirror hugetlbfs (snapshoting, faulting and DMA mapping) v3
  mm/hmm: allow to mirror vma of a file on a DAX backed filesystem v3
  mm/hmm: add helpers to test if mm is still alive or not
  mm/hmm: add an helper function that fault pages and map them to a
    device v3
  mm/hmm: convert various hmm_pfn_* to device_entry which is a better
    name

 Documentation/vm/hmm.rst |   94 +++-
 include/linux/hmm.h      |  310 ++++++++---
 mm/Kconfig               |    2 +-
 mm/hmm.c                 | 1077 ++++++++++++++++++++++++++------------
 4 files changed, 1054 insertions(+), 429 deletions(-)

-- 
2.17.2

