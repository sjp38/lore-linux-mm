Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5460EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17EAE217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17EAE217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B3C18E0003; Mon, 18 Feb 2019 16:07:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 762798E0002; Mon, 18 Feb 2019 16:07:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62B1D8E0003; Mon, 18 Feb 2019 16:07:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1AA8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:26 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id p9so147480wmi.0
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=DTLxh3djzB9SKwUXR/L2I0nZ73CHOVSFf2wiNk36N+4=;
        b=TcP7sKtbHvJEffCOap7m33bE4StNje4rDHSCmp41mOm3TVuPlo8ghZEDd8sFVnhmzy
         o+oSVFtggXnHijnqVFb2a/E9bVNVHWbX5b7Ikgt5t/N9vkUhsVSzhYbSOy1Ujv/YD2GZ
         +GUdfWjjG/vY8E9amRCgM/Vu5nzJK0BfGB8nzyvppTp+riLPgy6CZGP4hIyb5y9tDOP1
         Ygg+P/CIiSqCTvEKOD86J1/tREZR7Lhmns2visji0XSQ+HKwG9uE7qs2JqlsyPAI8Y18
         WDNbFgSkpoNltVBbzxgF38gXkRaJXK1QTEJjiOCxp6gw9iAx2JNNCF1/vnXDi0wI3LrH
         JMdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuaajXBVibYS+VHxKPz5fW0OmOyQIhynA7k3LDVf/5WlGzA7sGWm
	WPXgvKBDwbQtvpP+OjnWV5N/HlZ2Tnq4fmG+ZDcwLwQYAWaLmHWy9GNesrf5/iLcKGB38Ck1xdO
	5wFBjfRoTy5F7Ejcap8AFoAM2yDty4InOKoV3slfsohxL0AWK33mbMqNCkKN1k+6JDA==
X-Received: by 2002:a5d:5285:: with SMTP id c5mr17015507wrv.167.1550524045531;
        Mon, 18 Feb 2019 13:07:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYjSkOA9kJJqiskE+8mRlV1zXvjLtVvvsntNp+Lsbkl7oGiiJmVzaFUx5XgXEOwRvRpDx5q
X-Received: by 2002:a5d:5285:: with SMTP id c5mr17015463wrv.167.1550524044452;
        Mon, 18 Feb 2019 13:07:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524044; cv=none;
        d=google.com; s=arc-20160816;
        b=WJyFFAQ7VgJeqKtiQy9Bhp1InUdJGLOCU6047aEVAt2fc40UVposfjsUinXFn3Qiq2
         VwJfyAwER6GfiJdQh21FVe/5/SIR0zv9N6BHL3brruaMCgmNqBXXplhlTzcqu8hfy+LO
         2tvIhBozaV2SynLXnEY/X2WHwBwWLS2BUMAAF1+cQ3PwKTp7RvMwWfmwqjVZdI8ooNMM
         +JlkBizaWAEo91h/7xIro9Zszg5x6Q2aBZRR2YrYUqboEfATWBxY33EbYJXTBgSVX9Fv
         U3dmjWIHDeAPgbztF9pnbSqGP4Vl9FyXC/mb9dtlI1o8aBgcakSKZIJLIlcWgC+ezVpo
         8QWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=DTLxh3djzB9SKwUXR/L2I0nZ73CHOVSFf2wiNk36N+4=;
        b=S7Wk3eCK+JUDEygoGSHnWfUlzer+ly1QBchWlzDK3RRGKlC0aqLK89ZM6/ui+ZWPf6
         fWGXQWipDYGrb1Mz8kpbSLXpk7T9Te9drwZv1AlVZPf6q8OsqczhROBIkx4dLYinUKuj
         4j4DfEIaMl22nO1CBsCmomfzHvR+lZCeOTMRK0N0qynXLHhaajOe4CgU+vWrZwYr+DNi
         JkyPWz4KpaAOHSjV2RdOnoRri7eUM+KCWcojv12ZE1/oZdW1pTWF2JZtS3P5axHQMolL
         OQl+JoLTBhKEI8p6Z9s9xDFXT+DCq+BThBR6mPsv6oyONTvauAthhIBN45DKyYr/Y+jd
         VZOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id h14si9086753wrw.256.2019.02.18.13.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:24 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id AEF5D27FD42
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 0/6] Improve handling of GFP flags in the CMA allocator
Date: Mon, 18 Feb 2019 16:07:09 -0500
Message-Id: <20190218210715.1066-1-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The main goal of this patchset is to solve a deadlock in the CMA
allocator, which happens because cma_alloc tries to sleep waiting for an
IO in the GFP_NOIO path.  This issue, which was reported by Gael Portay
was discussed here:

https://groups.google.com/a/lists.one-eyed-alien.net/forum/#!topic/usb-storage/BXpAsg-G1us

My proposed requires reverting the patches that removed the gfp flags
information from cma_alloc() (patches 1 to 3).  According to the author,
that parameter was removed because it misleads developers about what
cma_alloc actually supports. In his specific case he had problems with
GFP_ZERO.  With that in mind I gave a try at implementing GFP_ZERO in a
quite trivial way in patch 4.  Finally, patches 5 and 6 attempt to fix
the issue by avoiding the unecessary serialization done around
alloc_contig_range.

This is my first adventure in the mm subsystem, so I hope I didn't screw
up something very obvious. I tested this on the workload that was
deadlocking (arm board, with CMA intensive operations from the GPU and
USB), as well as some scripting on top of debugfs.  Is there any
regression test I should be running, which specially applies to the CMA
code?


Gabriel Krisman Bertazi (6):
  Revert "kernel/dma: remove unsupported gfp_mask parameter from
    dma_alloc_from_contiguous()"
  Revert "mm/cma: remove unsupported gfp_mask parameter from
    cma_alloc()"
  cma: Warn about callers requesting unsupported flags
  cma: Add support for GFP_ZERO
  page_isolation: Propagate temporary pageblock isolation error
  cma: Isolate pageblocks speculatively during allocation

 arch/arm/mm/dma-mapping.c                  |  5 +--
 arch/arm64/mm/dma-mapping.c                |  2 +-
 arch/powerpc/kvm/book3s_hv_builtin.c       |  2 +-
 arch/xtensa/kernel/pci-dma.c               |  2 +-
 drivers/iommu/amd_iommu.c                  |  2 +-
 drivers/iommu/intel-iommu.c                |  3 +-
 drivers/s390/char/vmcp.c                   |  2 +-
 drivers/staging/android/ion/ion_cma_heap.c |  2 +-
 include/linux/cma.h                        |  2 +-
 include/linux/dma-contiguous.h             |  4 +-
 kernel/dma/contiguous.c                    |  6 +--
 kernel/dma/direct.c                        |  3 +-
 kernel/dma/remap.c                         |  2 +-
 mm/cma.c                                   | 51 ++++++++++++++++++----
 mm/cma_debug.c                             |  2 +-
 mm/page_isolation.c                        | 20 ++++++---
 16 files changed, 74 insertions(+), 36 deletions(-)

-- 
2.20.1

