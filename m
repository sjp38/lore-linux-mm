Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3A92C76197
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DBB4218A5
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="h8ViET5n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DBB4218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A4FD6B0006; Tue, 16 Jul 2019 20:15:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 157BF6B0008; Tue, 16 Jul 2019 20:15:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F392F8E0001; Tue, 16 Jul 2019 20:15:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5B3E6B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:15:41 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id b22so18294747yba.4
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:15:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
        b=Jdl/zyVnyebhJEplCUP7BfjwEdslCOYsNCVK25+iRIQcffYXScmgr6d0oGx1TJnP5i
         aGxAE9fn0fp6JuTxRElkLK+6a878Xl48hR8AWPMC4xmQIkov9xoCipuDlF99J2q/v49b
         ZbfgM+fz+XFVKJswF1DW9uT0eLd7ZZcxEZKwizv0EPMCNE4Su0FT+BIKWl2KN1Vrkysh
         GITPL4CImE8JqbbefguHodwpzw4Axfilz4fKMd1Mq3PLXPsHxlsZ4INUtbRcSNPf5RKM
         +inwa3SmCkixligA068TVeMaIkCfy+P8nPh6z5+B9XJB3RkA+Mj6eozCHhNtMmK3lBRz
         0vZg==
X-Gm-Message-State: APjAAAVymt+lLut1zfB2Q1Qymffe6/fiHb+/wSS56HRp5wdAzzM16EGP
	qn7psQDKqHfI0CeIYbGACW0h1cn2lOxgSB+FjxU+KCZ3NvyyGhEg1biVxA0Amx6NXTl6Gsj7LZC
	Ari+H1ONkCX5z+JUgAy1oQWlpAFNi0xZ/RNad8qF5+1YJ8Ewxi1/Zigbxx7R36vBnew==
X-Received: by 2002:a25:400c:: with SMTP id n12mr21169416yba.427.1563322541649;
        Tue, 16 Jul 2019 17:15:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRvhEFwecVn1XRA92JISPK6hXmF0eM7oyka/lvMAnPxDIcJJXAkZUHt6PBep+hghvYWgL0
X-Received: by 2002:a25:400c:: with SMTP id n12mr21169399yba.427.1563322541110;
        Tue, 16 Jul 2019 17:15:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563322541; cv=none;
        d=google.com; s=arc-20160816;
        b=fHdz8y2t0rNsaMLoBD6AwmRBHalvqmX/UXpYCmJMevIvt0Uemmx+1GhzAP/ICvtLGC
         CYrV6L36d5H1+lCyUTx5JvobdU6BWxACUHLvz4VvJGJ3Wrj/r4fNLTLj3YqpKgjnYU1H
         lZL8xuiC7Nu9LSAsBIAarSv0vo9ymOXJwBmXPUoVeBlrXrGRbkAh0Idcydp5axv69Tgf
         XuzMSo1DbyYeyjn5Eg3sboontD2MF6DtwBKYSAii8GBjnG9GDid794677/BBGGOf8mMP
         3gKgVVIcSYoX9XJz3KfxcUw7vem4foCAEYGyF72sn4Z065gEixTPqUcJL08gROUxrwm3
         TM9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
        b=AuHlPkwwCBBM7Jih9pPbtCYo6vHdjD+vpUA1+FMSop5TFcaG3+IU3p9zDwNpXdY33e
         0wtrPRqx5c7+0FC2ogqcycb956rDFDey+nKanxNvLV5Z1eFpo+kR5HgWOU292nQrp7bF
         8c1Mk3yMKU84FkFMRInlnP8nQs55YlCJ5MTpMBCu3wytYMXdp3xkbnmfc1j2+yE2w5w4
         ZrhtOS3rf7wKjHYiln/uHreQGPvVtos41qrGwM9uFjs9GW9kuUJG47YS/OhpZd4kiobR
         e8GijGDcpC+CNXc8Iyj1c724iXzeCPCHPvw3tiQ8AcXgU4W5hBr2HUcYTZsJje978kZl
         MBsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=h8ViET5n;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id t140si8061890ywc.12.2019.07.16.17.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 17:15:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=h8ViET5n;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e68a90000>; Tue, 16 Jul 2019 17:15:37 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 17:15:39 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 16 Jul 2019 17:15:39 -0700
Received: from HQMAIL110.nvidia.com (172.18.146.15) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 00:15:39 +0000
Received: from HQMAIL101.nvidia.com (172.20.187.10) by hqmail110.nvidia.com
 (172.18.146.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 00:15:35 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 17 Jul 2019 00:15:34 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d2e68a60000>; Tue, 16 Jul 2019 17:15:34 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan
	<jiangshanlai@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Pekka
 Enberg" <penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, "Andrey
 Ryabinin" <aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, "Jason
 Gunthorpe" <jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/3] mm: document zone device struct page reserved fields
Date: Tue, 16 Jul 2019 17:14:44 -0700
Message-ID: <20190717001446.12351-2-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190717001446.12351-1-rcampbell@nvidia.com>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563322537; bh=n97TMr2JNhrSZ7vCgIqLLYdPmnZDRy5pEGPbgjYfhkI=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=h8ViET5nQwShosN/h1iEpWwaV7U1MHGQpL145RrpAfBB7pb/hc+UNknepxfXQ+2/i
	 J+K60wFo6SunE78IG0A0ZSAQQeHwH/iXCHjF1/BHYLCYl3qTA94/TYq7La3Xwhx6OP
	 gIEoMP9B+YfuGPWfz589qTOokW9//Lnvs9yq4U6FNVX3dULjF7MDdxO3WjRTLpsJsk
	 tWfbqPbketRhICohw8wN/hPjyiSo5iFqWRtGTPq5HVuEdlwUaI8dNzNaW/yvih5paC
	 odsBDvIHPlG1zU/ocufSij+Hmh0IUQJWk1lLgIl95Wsxl/xkTE8AzjnLcE1crREseF
	 Cd6FZowRbWTkw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Struct page for ZONE_DEVICE private pages uses the reserved fields when
anonymous pages are migrated to device private memory. This is so
the page->mapping and page->index fields are preserved and the page can
be migrated back to system memory.
Document this in comments so it is more clear.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 include/linux/mm_types.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3a37a89eb7a7..d6ea74e20306 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -159,7 +159,14 @@ struct page {
 			/** @pgmap: Points to the hosting device page map. */
 			struct dev_pagemap *pgmap;
 			void *zone_device_data;
-			unsigned long _zd_pad_1;	/* uses mapping */
+			/*
+			 * The following fields are used to hold the source
+			 * page anonymous mapping information while it is
+			 * migrated to device memory. See migrate_page().
+			 */
+			unsigned long _zd_pad_1;	/* aliases mapping */
+			unsigned long _zd_pad_2;	/* aliases index */
+			unsigned long _zd_pad_3;	/* aliases private */
 		};
=20
 		/** @rcu_head: You can use this to free a page by RCU. */
--=20
2.20.1

