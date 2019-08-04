Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D36EC41530
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57B06217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TDggbkgR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57B06217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3406B0277; Sun,  4 Aug 2019 18:49:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD62B6B0278; Sun,  4 Aug 2019 18:49:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B77236B0279; Sun,  4 Aug 2019 18:49:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD326B0277
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so44988282pla.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=ouZCKs42E1SGdTPN4yEmDgH4V06kWgGz/SKjZ2cUf4NnH3XkCrMM7uT8q6kf8+JYl3
         M0l36zNhQwyetIFGmDjCsQeCVTK3uhV3pCi9hvpVtaywnD2/OBwrYR6einYDf6FsJcmY
         nBSzFuwPr7R6TmZlAv2ggBvsoUjiQjnofZ6wp8pFllD4R0OAga6oo7yG3XiEsEWQxfpB
         E8CAwH15jFF7IgpmV+fr7Rt6MafckGdUUKMFZz6HRSrws3DtH57TYzxKw3yMlv5vATkv
         0t/wjAqwTvzNB4DGZwev4QlgF94rhRx9BVQ0yCV0RPPu3tN4wBJoO5J1grCfIQbz/y3e
         4SDw==
X-Gm-Message-State: APjAAAWRr9Vcy8ZLOSKpic/H1q0FfQy5D1k4oYeN6Iyf+m6YP9b+AtOa
	nEook9uN4wx5KKHfoALWLNyTnaHYXWmdoEMx8OBxiFSnUk3MDUuykHXw1VHcFUF7xaLLRoapPeM
	L/8w7nCc86JueXPPeXr5MSc5wIvNPNCD5CnfjR/PUKZsJ/IaRVHgLZMgtrMFgwc9qMw==
X-Received: by 2002:a63:f50d:: with SMTP id w13mr133559320pgh.411.1564958997055;
        Sun, 04 Aug 2019 15:49:57 -0700 (PDT)
X-Received: by 2002:a63:f50d:: with SMTP id w13mr133559269pgh.411.1564958995775;
        Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958995; cv=none;
        d=google.com; s=arc-20160816;
        b=U7fwCtsOWIcUS4J32lR6r6LMYsbucFtW1LLvdsyHZJO0EupxU3hRZ3kC3N/ylgPVgZ
         9NiRORvRGqPEqVMXd2boLjRV0jUsFp+2vpoyu6x49CBzr8MtGI4FvNMRqUeuvbZvY6Vt
         4+jVnaZKjd+uyuOVFznIkuV+Qg6iSUO9lgbK99dLPADLDOey9lZ69PogOZvh0B0RT7B6
         wK06DBGm0jMYy26wxJJrQtDIxXiSwA2omglJridVwFvb5Fj1syh3fP2mTE6cduXxoEGv
         Fp38PbVV0buUJF9Os677llJ3uq42PEqIn8+0AAGZYuVqn6kH3ywrAlvkqfhSELVaLziT
         OPcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=DXn07Azj2cO4Hzwd3QZWp5Nkj9gVhrh4KhRsZcIipv37lTUwBB0ntVikrkC8Lh4djo
         yf5fmptPxDHz1AkDbntFVUl91xdexDqL5Kz8SCPAYO92b2AhBvBqeHILKiyhn+Yj6vl2
         mx8dJsffOdEK1YqGbz108OZiFzc01VyKiTTJ20r+Nw8c60XSmHSiKYSgqloccJTm0Um/
         ViVADusr29JjB1jORQ89505zRG3s9t0p/ZdHlAcejJIi+WLCmpMLIcXS1PdjP2jfULEg
         RQguw5TuxLnkUMQonQcsQ/cUpOhKfiEquwF5qt/7rQz44N+56R4+9UHW7N1dq60Er2y+
         TDyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDggbkgR;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor97069794pll.17.2019.08.04.15.49.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TDggbkgR;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=TDggbkgRiGIAFGZg+jjgHpzcEiYccMBQ6jptVLtuAINCBCAa7tBLSYJdtzRqQAkVQq
         tQ08R+kd1zAphQz9pkaaBX/hg9RvlkTaePPnO2E1bu2f/76JhzKynqi5fDXQgm3u+sje
         C80KY3nOvFeOz/PfxhVfGvol35idNxGJp30wpqdrZCtYSNKWJHD3OZzPkmpz9TZ2iydK
         zGtAdXJa7uyuK2GhTVtmCk46eJaIXB31IST9V3s1VEcpQHy9Y1uuVubQ/wNf6EoCYZeE
         iY7ztWwDS8B1eHyY4QnXS4dvWcICmGOtU1XZ3uVoXugfKVLMqqSM2fvbIrY7TrJ6h/xd
         OTrg==
X-Google-Smtp-Source: APXvYqxpyFBswVwCpmbWWUYW5zokWhx2pCk/sdTQw8977867DfmKTOqoiHBx6Glc/HUCem3kZHec6Q==
X-Received: by 2002:a17:902:8689:: with SMTP id g9mr131877551plo.252.1564958995585;
        Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
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
	John Hubbard <jhubbard@nvidia.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH v2 23/34] uprobes: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:04 -0700
Message-Id: <20190804224915.28669-24-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/uprobes.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..4a575de8cec8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -397,7 +397,7 @@ __update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
 	ret = 0;
 out:
 	kunmap_atomic(kaddr);
-	put_page(page);
+	put_user_page(page);
 	return ret;
 }
 
@@ -504,7 +504,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-	put_page(old_page);
+	put_user_page(old_page);
 
 	if (unlikely(ret == -EAGAIN))
 		goto retry;
@@ -1981,7 +1981,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 		return result;
 
 	copy_from_page(page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
-	put_page(page);
+	put_user_page(page);
  out:
 	/* This needs to return true for any variant of the trap insn */
 	return is_trap_insn(&opcode);
-- 
2.22.0

