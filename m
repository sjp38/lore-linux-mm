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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45D6AC433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D33217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AoEeK7A3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D33217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D25F36B0276; Sun,  4 Aug 2019 18:49:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C620C6B0277; Sun,  4 Aug 2019 18:49:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A662A6B0278; Sun,  4 Aug 2019 18:49:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0916B0276
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so45050225plp.5
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=A+ANHmGOatZbXg4VTaRfFxtjdua//tmg8zwUAOriv/TZoINddYFXf/t+6rI67Moba1
         bhHAAK+/4hm/JSYGKyIhxI0Ikdhl7S8XyG9kz7D6dN7y+wLSE0DnKLs05KoYCKyO1/6w
         tuvpvojxc7cTufo81shbnwUQNydiz+GUA7HxMwtQpgXJWVueIXZMVjClgGk6hwst4w/E
         ROpgjNY78BFnQC3NtPmvd571HZrKG+VEHfxtDbWKgWOgSh6C8bib2XrqAh+g5e3zRduZ
         0jJiF9klsLcyVZWpWnbT+2EMcdDZxEi8J8/ffO0yRVyDt+Fkp0Svw3n2gGlmAvoTwXps
         aeiA==
X-Gm-Message-State: APjAAAUQi0vUpJWFd8f2dfDtB1JqvNVh/mxTlQu5BipsJsfjmS5PsVse
	0MSOyNp4kCPNYYVj4OPJrQb0Y27PekTdq0k5rzqHVHlgFHREpXKpdB891duHGxybCqDe8hltNRr
	cMZHFPljSzntmf5N9TTxff7RSPxylJGbC5e9wh+PZBYF1KVUjq9nKO4VTXUBC81Csjw==
X-Received: by 2002:a62:764d:: with SMTP id r74mr73018451pfc.110.1564958995141;
        Sun, 04 Aug 2019 15:49:55 -0700 (PDT)
X-Received: by 2002:a62:764d:: with SMTP id r74mr73018416pfc.110.1564958994230;
        Sun, 04 Aug 2019 15:49:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958994; cv=none;
        d=google.com; s=arc-20160816;
        b=hd78xO+K/qkD6xZxPYN6FKg/VYawbN4oWsgnEwAg3cMjKvU0FWZUNlakQi5evro/IR
         Ez5sVDflaXt0pq1M1TirVqvWPZpQhF4Zb5Aku6zI/jKZ3K4M5RS8IxhcprvTssfz8Zu0
         6XCEBOVv/k41YBtHSQsXlQ11YlzMBD7tUBYu+V3WmncczrYHFBIf8coipVMuSN6mzOn5
         K5zYE1Izal2osbx5jMlXK3dBwuGq4MuKD3Ajo1hjF14AlCoIqUPB7JkkI4ngeb6BINZv
         eJHr82/fc3bRB7BmTvOQNTy06+9R+RFXg5K2MyP+WnxlnNIES8HwP+aAsYkTx5d0/yGO
         TYkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=CpzmB98e8RHutBsyPKk3d5xQRcNGOrUnKcNLCANrC3BWW8uaDDtSqBB1gYSediIAsZ
         IjiWVT/ntIRrhQUpeCH0OCyyUTWcE/HXGtFGcJzmFr6KzCJRmwBNWPZORdoPKpxTdDRZ
         ti6xvshXDOm4VcWW6OlI5xZSmSLj5bAw3XNYNO8AREylEQFuhf/Cmpo50xRdWjtZ1V2W
         XMmnS6zN4YnrEesLaZO93CrxOZ8Bj59xYhslwiCa8jcAJuzfDLV2RzbFM3VNCsUFwlnK
         v5WBZm19aF9gM8QGZJji2X8dHyacaWDNKbAbT7uO5dDNSZ7/IihtukLW3CxGdAvm76/x
         VrhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AoEeK7A3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13sor97201174plr.24.2019.08.04.15.49.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AoEeK7A3;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=AoEeK7A3WmgkZN5yC8Z1Jl1RH2bH2yfr/Iui/v9Stf0ZewCCNe6BmkaFiQSbldZriZ
         wW6aM88ICV9MKKVMW7cufc693tFEoxlowWoPmOWeXRs1MOQDftxRpNdG7ZpLAs0zPCzH
         tfODbi7MeStQ2PUxDbHxfxCmnrrt0CpHHVErZgkFlHG1WBD9vc/idnDis+fOVKQL9lLN
         eIKxSh7vqFmdHH8HbCmTpqdNHN/40uH9dLamfPKCEqx0SSFV0Cay/FKPEfRs3UtCWLvV
         asJlUv7lGILmIRMgD+7Ndejmes/P11ltUT9gXu0ECiydPknotiGsbwT49fTUX3pXXK/J
         hBPg==
X-Google-Smtp-Source: APXvYqzibwwPUnTUuHH+RVhfMiDAHi4Mt1y6avGQzxyYdtLRtPBxbmwrSqheIPeJWHdiQ7pwZ9ajtA==
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr138434091plp.227.1564958993951;
        Sun, 04 Aug 2019 15:49:53 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:53 -0700 (PDT)
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
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>
Subject: [PATCH v2 22/34] orangefs: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:03 -0700
Message-Id: <20190804224915.28669-23-jhubbard@nvidia.com>
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

Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: devel@lists.orangefs.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/orangefs/orangefs-bufmap.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/orangefs/orangefs-bufmap.c b/fs/orangefs/orangefs-bufmap.c
index 2bb916d68576..f2f33a16d604 100644
--- a/fs/orangefs/orangefs-bufmap.c
+++ b/fs/orangefs/orangefs-bufmap.c
@@ -168,10 +168,7 @@ static DEFINE_SPINLOCK(orangefs_bufmap_lock);
 static void
 orangefs_bufmap_unmap(struct orangefs_bufmap *bufmap)
 {
-	int i;
-
-	for (i = 0; i < bufmap->page_count; i++)
-		put_page(bufmap->page_array[i]);
+	put_user_pages(bufmap->page_array, bufmap->page_count);
 }
 
 static void
@@ -280,7 +277,7 @@ orangefs_bufmap_map(struct orangefs_bufmap *bufmap,
 
 		for (i = 0; i < ret; i++) {
 			SetPageError(bufmap->page_array[i]);
-			put_page(bufmap->page_array[i]);
+			put_user_page(bufmap->page_array[i]);
 		}
 		return -ENOMEM;
 	}
-- 
2.22.0

