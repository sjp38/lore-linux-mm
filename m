Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E428AC32757
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E8F217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M7iDvAmP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E8F217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 584876B0281; Sun,  4 Aug 2019 18:50:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50F356B0282; Sun,  4 Aug 2019 18:50:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 388DA6B0283; Sun,  4 Aug 2019 18:50:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00E126B0281
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x1so2531227plm.9
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sx0x91HVjVXCVkLMMHrdncyqT4rW2sU28Vf+3l+oloA=;
        b=o3LLBmjoIH89Pr4csnci3Ok9e/HqE5eLwMCLTglLWpTTk7raxxN8C+xtANGEukKraJ
         aILL+pkXoi82MRPQfxup3J/8J7LA1rBqk2Jv4ZGqjKkkbexB51P2lfVPsComsmq+JBer
         jJ0OIgv3JH4XYiLcn9poqd6KhH+tvKK+BPSW8nYSdhqo18GvWP8u+fUp7YSLdmw1/d6C
         STO5vHSpzEb604MCRgwpxrjhgql+VzXFyoWSy9k+GrRQjDENm+AX6T5n4JD0CdxULxlD
         /i839K7X162GnrSjzMSZWoknhEZVK1H2EAo1bQT+W+nBI8gmTJdWa5Vs2LIoZokxmiLF
         OZ8w==
X-Gm-Message-State: APjAAAX6/FfG2Mu137pRBSV30J8nS7M3+XM3eJ/4x76HGzLsiXPUWjVb
	bAYohUUSde9WZx2sKIKrq3cpt05m8eaq9LiZGoxkyeMaRZU74YIkKohoB1uk3HB9Vh9xNBSx8lx
	u3Fmayl1GsTQ9gxrdvZV3R6hEZWsc6XlmT9ZFzjzDgdY66NS1rt0+E9Rsfh1I3O+Qhg==
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr14790121pjp.98.1564959009647;
        Sun, 04 Aug 2019 15:50:09 -0700 (PDT)
X-Received: by 2002:a17:90a:9f0b:: with SMTP id n11mr14790088pjp.98.1564959008823;
        Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959008; cv=none;
        d=google.com; s=arc-20160816;
        b=nO8YMy/C6XKwyFgGgnGX3dKUGsFxxPOCaQMszu+15YGtwzVJ/OBjmwB2Ls82AON7oG
         U7LqWE1yZw4ZDhN9CCJxSnIl55d+KSLaELRby+CBL4XSb3XbkUThBr9TbrgdNQlJl/u8
         nqL2aSvg4eErY0WuMvfE8p7N9no622hIJOHu5ZqaPEnAJHzdAxo2OHAIq+QyNLRO1X35
         6Y02hoRLR/OaccMNCgngVQkn5kyZl1ZtsfLJO8NmMzqcFd06n43GsuLUTE3Ih5D4G6D0
         C7NMJxw8Y8i1AmsEc7aL/gtkpsmLNgvLNcMcTQNRAho3vthtf9BFSOrxMVjmt9sMGxsg
         TXww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Sx0x91HVjVXCVkLMMHrdncyqT4rW2sU28Vf+3l+oloA=;
        b=kaowJxsZ+SPa688OhbW9FYSy7diQw0TKyCMlqR6cbd6LwUAf6C7KHoGflMd45zMe54
         2x8tvKZM0LGUzNHvgR/aNrZ9jeyQhO7o20aJCYZlFftKTrDsGTUhc7Sa4MRAi+8xwprn
         KU89X1Nq6oOFVUmrjEVO4wR7fMvV3O59VUOENX4+jCq0hCV84OuQT5TuS9I8YVaD8sIp
         XGs68xfSkhHhM5B6cYzdSvO/dh4aly3dVqzv+3Vmxy+HQLj0K9ohlflVZYxN7bYm9cVP
         eduMx0n83+ECBbTGyUCLZT16SN7CVKD1QIgl/noxHfgntktKRALMw9+T/yZvnoyY43Sa
         /N3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M7iDvAmP;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor26068335pgb.81.2019.08.04.15.50.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M7iDvAmP;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Sx0x91HVjVXCVkLMMHrdncyqT4rW2sU28Vf+3l+oloA=;
        b=M7iDvAmPBRpGJcJpcoqgvaoi3nLFkyQK4dkSIj4ojX3FvseJtfjnZyfckr18kI2oDa
         LHzSPof56TngxWHSp0ym44XehwQNp0Dvit6wm4Dt65OPXwL2baR6+4zLMuIAexRHFzmx
         ZFMgjeYMSC1sErMdOV/WNMAc2Iu4rRWK81eLPAWfZwZdfeXx16tZd5680zs185LTKzUq
         VYv2LHkMnMPv4yg/Pui3fxt3Z+TxPOd1GexxLj8LbBhnNpT3XVb8jW9mQwG5C5+4ClkN
         g/MAUKuZK56HuoBkHT35BiifdFKR3pPYOWepAjU+8QcCzdVYmtG3jMaPBQTkt/nS1dsZ
         WZ9Q==
X-Google-Smtp-Source: APXvYqzdBAOi64WyR4vf0DFOxQNVALmaSa46GoCIBIpjxflBtAErOscOmlieUmCz4Qhdah1mimse2w==
X-Received: by 2002:a63:7358:: with SMTP id d24mr133542074pgn.224.1564959008549;
        Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:08 -0700 (PDT)
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
	Calum Mackay <calum.mackay@oracle.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH v2 31/34] fs/nfs: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:12 -0700
Message-Id: <20190804224915.28669-32-jhubbard@nvidia.com>
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

Cc: Calum Mackay <calum.mackay@oracle.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/nfs/direct.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0cb442406168..c0c1b9f2c069 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -276,13 +276,6 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	return nfs_file_direct_write(iocb, iter);
 }
 
-static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
-{
-	unsigned int i;
-	for (i = 0; i < npages; i++)
-		put_page(pages[i]);
-}
-
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
@@ -512,7 +505,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		put_user_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -935,7 +928,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			pos += req_len;
 			dreq->bytes_left -= req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		put_user_pages(pagevec, npages);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
-- 
2.22.0

