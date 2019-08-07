Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DED6FC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C34A217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gZINIBPp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C34A217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF6E6B02A1; Tue,  6 Aug 2019 21:34:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28DCD6B02A2; Tue,  6 Aug 2019 21:34:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12A926B02A3; Tue,  6 Aug 2019 21:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB3956B02A1
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l11so34611432pgc.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=gospEh+j4BWQAjE0L/2lTCwBovwXVUNBbBNSn3d+9efQbrCvDKHzHG3QEkDVPEQ9ut
         1VPeYEw2t2h6KHpLPhyD8Nh3apkqexAYbhDXWc6RZTgVAcebCa5gDzPVd9unRnVw5gi4
         PBYLaootNAU32vli5e7xxraP53jH5Rp9UhsmN8AtJtCq0lIRuql0GBBz2zKC9jsyYCh4
         e0riteocryZ/t4IYT396K4C6V3NrcRaN4x1lw/brsgGgn2AcaUk0qtWoxNWTkD9PTdd0
         b6XykgWxrTOVG8aHc9oo8z9jtoHQHb3WB1oy6NDcS+UTbicKYIj0UNeqyZTkOrfxsga7
         ftsQ==
X-Gm-Message-State: APjAAAWyJTS5zXJYnv16MtG1+vXdn9ceRGxAgQBLkDaZe1YYHxaKiNjY
	05ZllkjXmDKOC8oqd0AyppB0Q4yQe2BqJz9FKMvx4m5OtjRryBmBTXGgLXNN59XFPtyJHd+LeWf
	7mQdbXiraQ3ZQsc/hPxQa5NZrPDAPqRE8MMCTmriRe0RDd64JMfYECOsdBSTHEKalWg==
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr5943705plr.198.1565141683510;
        Tue, 06 Aug 2019 18:34:43 -0700 (PDT)
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr5943659plr.198.1565141682537;
        Tue, 06 Aug 2019 18:34:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141682; cv=none;
        d=google.com; s=arc-20160816;
        b=hgi10YUfIoQ6X5JzP+J5bIxpwv4Vyxn4pJgB2CN1j9f1h8O+XiVgXwDplqA4aDGzqI
         NTDcoQoZruvwHIrQo2rOpZgku3Yi8bNhYvESQBnhE9MPPcA4U7/sQmi0RUxYH+VPTZaP
         bUY26nFFPihNdaAn4kVNfYlj23evR++eFLtx4rTsSK0tIC5f9xaS1ztw9iRd1GU/tZRu
         yWjlc56Ht5jn/hPiq9z1UCMMcRfxUFcO62l9K420Z+OQAuAzEJ2gEGJFUMjJuYG3STea
         zo920xs6DbDIY9CJR2ZBIZk8kPMdnqb/Xos4ztX091QV0PcL0goVdFRwww0yD92sifr8
         TBTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=XmI+mQwR8ob57MYMI4FYIsRAd/6dY3UwltM/ngdBguJQWaTBGRWDhvlaJbk4dSmdwm
         LIcaCNWt/sMqFWJTgMa40FOJAz4BKuuilt6K9jnObtsCnCS+aqx+8I3TLDlDf1hGxkW1
         ovEcelXDHySLPON7S9fLT7r0r+JJUiFT7YvB4xBmzCsx05WjH7uBxotV1kFPpqY2wlVr
         TI6Go6R9ucQ35FdlGwxXtHcRVx0kzZyr57Mf6f85sfB48l8yE//J69hwsBTUiiQ1AZqt
         eVx3QKwqgnWyWdY+jP4lmq/mZk53GIdyx1mWvc9vFBMdWDldtuk3g084VGbwb5agQ12l
         wk5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gZINIBPp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor70528491pfa.53.2019.08.06.18.34.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gZINIBPp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=gZINIBPpiSlkU+80KFQT2S/tbeKnfN8Fqd69WGW6s9PoHlp7eF6XztSLcUxuW4oRoZ
         aif7qo6403jD2jU7LBsHpubuYdPGQryF8kiw1ZTc3iFqoyXR++oshdcjJ7vxHU3SStmv
         hRrnv/6QnmfU9YFS9vFfR/LY5o8S7tCbaokKkpmJCmaCQPMpBAUHfIH7veXkFUWyuI/D
         QxXzz4jXTjDqbca8hg8XrnqAJ/u2yXOWeQAohMq1NTArxvWPC4Z+YJ1UfdhghSe68uD6
         jg98gaM28Wf1Jgr/YOooV8Oz8uSBvPGIEINpe+ifSuk1KD3Z7HL09IvdAtxhoavy3yVQ
         XT/w==
X-Google-Smtp-Source: APXvYqzSNe/bSKcNensRQ/IJ84TBXlUJvFYUKsvrq7/hKNH55OC+L+xYYWdqI5nDZFgfOlgeKmaOXw==
X-Received: by 2002:a65:6256:: with SMTP id q22mr5554856pgv.408.1565141682238;
        Tue, 06 Aug 2019 18:34:42 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:41 -0700 (PDT)
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
Subject: [PATCH v3 36/41] fs/binfmt_elf: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:35 -0700
Message-Id: <20190807013340.9706-37-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

