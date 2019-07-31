Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90946C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5581F206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5581F206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF6908E0003; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3C98E000D; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7B08E0003; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 441BA8E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so42678079eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=8we86U6BZ89U18xVZ5Mv4qd+dqLJCUI8fI0+y76c8U0=;
        b=Pm1pv+MBPivf8UPF5OmlKQ4rZ+6yi8VDK/i3J1VYUc+xXKdnU4De56eFLKZ5NCzcQg
         mk/znKo2f1fsIFYI0NO1WoMyHjiwqNIfRoc6pWBWT7lnpDNq8uDzNsUCmEsFvb/1UDjl
         ee+4VcZKGuljLXzIGvsCdkWQdbYdSqcd/Re0/2JRzgrrkcwbzT20dFmaST/lpjeecsRO
         P0zojmWtMQ1wvQ6SszVvLKsfEjYobCi6qOsB631w2rmzLJb33+cVgZ08UkDWqz1uhzVf
         58cweCBScBJcVAF9t9Gxm4GAT/nuEhYvaQJhXVMyEyfTbD/6qemK+O/u6ExOs5C7cqD4
         cErQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWQwGwjpfa5Hvx8zn3AYEzZei/f+dRqV+G3930XQIeIYLUIyMU3
	ccYhkcxXU5AiGk5aedGlEHVPrFFrIsT/6CQRdJRN1oEgQgd08gxPzWqoYESqKvThX7xgBKom1js
	EX+C6hdd9zUKCIf8NS9JBt4pI5wG/+T/R4q6k0KQpcDfUO1xZgJks+wfQpt15ERXsbg==
X-Received: by 2002:a50:92fc:: with SMTP id l57mr107823856eda.206.1564588082833;
        Wed, 31 Jul 2019 08:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF3CGMi3mu3MeELD30RE5fvz3q6wndldri+VRZbkFc5+MAfFuOGtfIiWUz+6RK3APvX37S
X-Received: by 2002:a50:92fc:: with SMTP id l57mr107823774eda.206.1564588081701;
        Wed, 31 Jul 2019 08:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588081; cv=none;
        d=google.com; s=arc-20160816;
        b=skLNUGhMDI9N5xCOTE2Y0jPVhXRDT/1/wBPJ7nIJP1ZhYLemYm8P6Hy9KUia72Ix3X
         omMFIS0turB28oYfk4ZdHukGPdfk+zdtXhUMN1hLS9omnE059+WBFJLdXVDITxAGIt/v
         JJUsU5pCH0BcLLhQDAMpJxtobXKqnn/H5sT/nK54Nz4bkuzseUW9niuixdSx7g4C8rpv
         rDgEV5I/BqHe+FC4qqdNpTA7M/lBmI8iz4gX3x/pc9/OHZcqZ3H0lq+WZApUKTWPs6m6
         ecVISLB6AdqEAZQjkmuPmqF1YMA2sqfYeiXVjYHwI5xDUfe3vcs4ihQkCSNIizq4aM60
         hkLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=8we86U6BZ89U18xVZ5Mv4qd+dqLJCUI8fI0+y76c8U0=;
        b=rXVW/YqrIBcx3wIDkJsi2VOzkqI6kt63Zh3WFeHC6uI2T9mSIpdR6Ia9Cao2wKZIl5
         kC+opoECVUUoGaN8nFDs5UPiGJ3GdhQNhFxsXYOS1LU+SJJHt8Gk0ORZmGxdYqno9s44
         Mb5E11xFsGFLHrbNQaOi0rA1EzuGkAcXUcaqSMW1QBo0g6x69ZkqawHb4F1dXrbuDUd+
         ahfc61aFq95I0uuH6DOe0E6Hno8w+MYWsMziIepbAkMvYYHRTeBZEO1sSeRBGacbhHOt
         C020hQaXEW5L0DPYMAqj9k5XuQqvVT0KS9uTcePzLboS5GK+WB6mmrzeyJwKxH0QnhNt
         ZZng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si19351308ejq.312.2019.07.31.08.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D13F2AF9A;
	Wed, 31 Jul 2019 15:48:00 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	linux-mm@kvack.org
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	will@kernel.org,
	linux-kernel@vger.kernel.org,
	robh+dt@kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	frowand.list@gmail.com,
	m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org
Subject: [PATCH 0/8] Raspberry Pi 4 DMA addressing support
Date: Wed, 31 Jul 2019 17:47:43 +0200
Message-Id: <20190731154752.16557-1-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
this series attempts to address some issues we found while bringing up
the new Raspberry Pi 4 in arm64 and it's intended to serve as a follow
up of this discussion:
https://lkml.org/lkml/2019/7/17/476

The new Raspberry Pi 4 has up to 4GB of memory but most peripherals can
only address the first GB: their DMA address range is
0xc0000000-0xfc000000 which is aliased to the first GB of physical
memory 0x00000000-0x3c000000. Note that only some peripherals have these
limitations: the ARM cores, PCIe, V3D, GENET, and 40-bit DMA channels
have a wider view of the address space.

Part of this is solved in arm32 by setting up the machine specific
'.dma_zone_size = SZ_1G', which takes care of the allocating the
coherent memory area at the right spot. Yet no buffer bouncing (needed
for dma streaming) is available at the moment, but that's a story for
another series.

Unfortunately there is no such thing as '.dma_zone_size' in arm64 also
only ZONE_DMA32 is created which is interpreted by dma-direct and the
arm64 code as if all peripherals where be able to address the first 4GB
of memory.

In the light of this, the series implements the following changes:

- Add code that parses the device-tree in oder to find the SoC's common
  DMA area.

- Create a ZONE_DMA whenever that area is needed and add the rest of the
  lower 4 GB of memory to ZONE_DMA32*.

- Create the CMA area in a place suitable for all peripherals.

- Inform dma-direct of the new runtime calculated min_mask*.

That's all.

Regards,
Nicolas

* These solutions where already discussed on the previous RFC (see link
above).

---

Nicolas Saenz Julienne (8):
  arm64: mm: use arm64_dma_phys_limit instead of calling
    max_zone_dma_phys()
  arm64: rename variables used to calculate ZONE_DMA32's size
  of/fdt: add function to get the SoC wide DMA addressable memory size
  arm64: re-introduce max_zone_dma_phys()
  arm64: use ZONE_DMA on DMA addressing limited devices
  dma-direct: turn ARCH_ZONE_DMA_BITS into a variable
  arm64: update arch_zone_dma_bits to fine tune dma-direct min mask
  mm: comment arm64's usage of 'enum zone_type'

 arch/arm64/Kconfig              |  4 ++
 arch/arm64/mm/init.c            | 78 ++++++++++++++++++++++++++-------
 arch/powerpc/include/asm/page.h |  9 ----
 arch/powerpc/mm/mem.c           | 14 +++++-
 arch/s390/include/asm/page.h    |  2 -
 arch/s390/mm/init.c             |  1 +
 drivers/of/fdt.c                | 72 ++++++++++++++++++++++++++++++
 include/linux/dma-direct.h      |  2 +
 include/linux/mmzone.h          | 21 ++++-----
 include/linux/of_fdt.h          |  2 +
 kernel/dma/direct.c             |  8 ++--
 11 files changed, 168 insertions(+), 45 deletions(-)

-- 
2.22.0

