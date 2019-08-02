Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8E03C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74B91205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DBN1w3/7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74B91205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E59B26B0287; Thu,  1 Aug 2019 22:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E097F6B0288; Thu,  1 Aug 2019 22:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF9686B0289; Thu,  1 Aug 2019 22:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9838C6B0287
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:21:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y66so47106361pfb.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=NNtXbjqLaBnQBdRLndzNGZoQ/ekOvc3276huPEgcODaCJs1bhAXuF+rZaj9C302DEo
         1xDft1hXg8Yg1ptpgacv13OIlVAx4ZteKjkj6W8NDAlBaicgriCa/MOFkzN7pNoKILKd
         QOYm3FgtssjuFGEWmsfqIlgyY0agjLzJT8OfuqJi4DfyLZ6IHfwbmG6ABZwBD7RN8z+Z
         F+Zc7yzKx0uiv93a/gPdsQDtVQqCxM5Eyd8XaV4auKEuCAw7GwkdLVmLjKr5U4mblS3V
         pAUg65ql+66Sy34YPdh9nUbCw0K029Lf7/aDD03u/C4dvVmk8iH2VoekJzaJ/a1F46Es
         3bIA==
X-Gm-Message-State: APjAAAUi+iPF/erXJvFm4lUeppE0nSaN8cZI81+RsCdxMpfL5/EoX6Ru
	Ebjr8Nz6k02COHS1wOoh6uMytTXSFLUbQEzQcm1qaa8ot8pJSboK1GSuZcPWqDmgPpEc7UU5wA5
	LZgydjEfH6pBNzKskrR6ApthPF9w3lejN+tdZyr1R5ZxQSgBZI3EUmuT+8y1pgTFlyA==
X-Received: by 2002:a65:6850:: with SMTP id q16mr86409286pgt.423.1564712466190;
        Thu, 01 Aug 2019 19:21:06 -0700 (PDT)
X-Received: by 2002:a65:6850:: with SMTP id q16mr86409242pgt.423.1564712465486;
        Thu, 01 Aug 2019 19:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712465; cv=none;
        d=google.com; s=arc-20160816;
        b=E8DHUJ5kL3zgMxyPV6lPAnMeJujqee2YbstX/lKFoFn6v9wLEg/kHA0biWIEopy3v0
         M0B+8aLgjirhWDHDwwN8BN1nNcz7sWxb9eLBAmcsfYWmb1OVoze/49Veu0CHj80cow1S
         273omC1a6ZIyankT6RG9jsC9YEJJTjohDBwLGkafqy9hXlaNeTx0TDjh104N4+g5VCuG
         FlhtwkiFV9IqrcPq19dld/kurSFknw12hzLzVNUT0MN4x7ywUGJ09hVEDj1+dh38qZOV
         IQ/y1y3JsH3uyHgO6q1neqJ+QTyxSfhHIfY6pKGsxlNrq1S5Em7kY+25qYWwBufa+lKu
         SYFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=x0lJq0I7MeMZI0kTeKWXF+/SSOm4Nt0pah2fbGzcrfjBCz9wv7iI5y2tx8tU0Z4P9w
         64aT+TpYxtmGLDLq7PI1DNcLalpOx7P4E+iLoFxTNrSYOSmLUzb0UYuOTq6rqA5NHJd6
         sjWtpl9UWRuQjHK49yYxTHtaVjEwdqRBoLyh08NcGuK/HedBMwSw0/rTz9jJ3gR4VjuC
         GK2hfuAiAvM64j04zA1eu2aoEISb1Bo5Q8C4I49Je+w28KoQjjKC6ywMb0OIl+WayfqF
         8UEIlnfa+U0fq0uvWQilq15Lt8vkzH+IC2eRwLi1GyQyfwKIVwq18omzH6KQPwlKnN6s
         hKWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DBN1w3/7";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor8275693pjp.16.2019.08.01.19.21.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="DBN1w3/7";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=DBN1w3/7Hxm2aTYhnTNoj1HADN0/qC4HQ/EIZkVxJXA/K2S11Q3/N9TAattYeDs6aQ
         J+nm7tV2AKcpGrK2TkCrU1wyclxrRwBj4vymoXpkg4vkH9XlaJfQ55nzl3mveOP2o9MV
         NUxRk2vipQv8FWXVtFS9aXrUBeQOuTE0Ko4oz4Isj8tPzLI9EqzmjnQsyBDLHQ25vBM5
         q3jhgaW+xd3z7DYehUibJdxR/1EjTpgU+Bek0hJIqh1wGhpzFJhljWoUMm0t5/61KoNk
         q3ATC6nVfWca/Nm/vukTsQm8ST5Kyw83g7ix2hN//xECaTu+OgVyIUA+IQWq3fIPa/3T
         uZLw==
X-Google-Smtp-Source: APXvYqyVNDRGKP1+FIQlU/b+5yAYmGOv3Rdk0fT5tiuKvQ+opVgMWL9GCqpjN6ICYNfQCU9j4FRWrg==
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr1859934pjb.21.1564712465215;
        Thu, 01 Aug 2019 19:21:05 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.21.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:21:04 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 34/34] fs/binfmt_elf: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:05 -0700
Message-Id: <20190802022005.5117-35-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

get_dump_page calls get_user_page so put_user_page must be used
to match.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/binfmt_elf.c       | 2 +-
 fs/binfmt_elf_fdpic.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d4e11b2e04f6..92e4a5ca99d8 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2377,7 +2377,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				stop = !dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				put_page(page);
+				put_user_page(page);
 			} else
 				stop = !dump_skip(cprm, PAGE_SIZE);
 			if (stop)
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index d86ebd0dcc3d..321724b3be22 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1511,7 +1511,7 @@ static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				res = dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				put_page(page);
+				put_user_page(page);
 			} else {
 				res = dump_skip(cprm, PAGE_SIZE);
 			}
-- 
2.22.0

