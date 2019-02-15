Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C97C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4096222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="GAhYBfQM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hJ8TkaDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4096222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622BE8E0006; Fri, 15 Feb 2019 17:09:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D48B8E0004; Fri, 15 Feb 2019 17:09:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474658E0006; Fri, 15 Feb 2019 17:09:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED988E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:09 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id y31so10419662qty.9
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=0R137jNOULA0X2GJv6mEJu5LnxgF5CPDaCLQF5uXUrw=;
        b=GGz6zFB3zQm2YwpBP+tlHl/q+VAnRTNFuPwsWBKo8vgW8NF7QM0KUYm8zO4Xoy+ROD
         TFxpXLPYe8r0KgZSCF7h4/EDawHGoXxxxzJEooOF56XSYeSW8x2Xo7tTj38EkttskuBQ
         l1R9E+iO1FPSJNccpiOkh5C6SP51WEV65q8HGlvHJCzmi2Q+tUHapfmpyQ/jXwKgVJwL
         3ZHwyyeoV0do7nEk7SNU69C+9aCtjPGDBT6MjcGNicVenuKQRHQOvxl4epNGIUqw9Ddx
         MoiqmoAzmnroexVeKkXC1Qtx6s0aLALy4z1L68SZeP6zc/Ni9bjodBd2enGXkYcSCvgA
         96VA==
X-Gm-Message-State: AHQUAubFHwHd4C9s11Qf0e6oyGsL3y89CQZJKzx1ea3R+V8GQjJdcCPO
	cB+dkyE1/zLOF0KcBBfUKviGvlCI2Uh/FjCk/8WdRPsv1hTneyM8fSXLCq6Kf9vn/brtwDsnd3o
	uT1RAi91EaWoP9jta8i192q06OjtbSm+3Fc6u1pJ7uG/NZO40usfNYUCC7cXiOxTlyQ==
X-Received: by 2002:ac8:2e16:: with SMTP id r22mr9431298qta.384.1550268548887;
        Fri, 15 Feb 2019 14:09:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZbSWF2Z2jC+DlQkwPSoo+Vrp21BvAxrJ+QnRaN6JDClxLbqomy95WnCRfRLwBuxG69PqTc
X-Received: by 2002:ac8:2e16:: with SMTP id r22mr9431250qta.384.1550268548114;
        Fri, 15 Feb 2019 14:09:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268548; cv=none;
        d=google.com; s=arc-20160816;
        b=cdn0Anr0mMZNhARSA90SJUbRnfZJMo1uo5xDYGjF/fNzuDtPEGBb1m9nNV+R4nyLtG
         XRIZRiPH/auSQUcPEh9MEWBPW5Fa5bMl2zk3RAHFmk2rAwdrZJbBVphloupeD4GPD80A
         zVp48kQJnud1IzKlxIUZ6VKEncz9rU5IFMJwETX2aD84dwNrfF4Cf0xvDWoTs+r5ut1e
         fvSYSHtNa1QZssrSARlK3qjmPrghHShOfSk3y6PxvgMk4ThyhfoaD1d8IkCEmTHKPkA/
         GcJ9lkqRnqvR6UIeRiY7HItwbsHYn+mfMpsU7LShMYH9pE9547OYlE2/0JtoUXPXtOGB
         V+MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=0R137jNOULA0X2GJv6mEJu5LnxgF5CPDaCLQF5uXUrw=;
        b=jQa5IlOdtIGBkqQTO48BG+J5VYvZO7iYbKnsibV9gWUH9QAp9SCeMS2Z3T9xMOLz7p
         pAt0OLr/5nukhNLWhCLXOTPTcNoJS0Uy0uwL7qnamwoLCPTkX0OR7NRaLC2UIM3vtsT1
         rIg1YHb/NTaCmBylUjsTKn+FyAvvAmFVqjgOZmERaKoihpZYZfC4keeT4dJompbpD8bW
         CBOGRl/XI0L1q9OjDR4yEE2tk8PZQNObv1julO+CLdwSd1ZrfVOealBo1L6g0zyri0bx
         T6b0pa/o4XaR4wxcZ/QLoPLnfEojGaED+r5j56YhnSrFNWHoBKjvYwtCZNvyGc0vNJhU
         lYTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=GAhYBfQM;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=hJ8TkaDB;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id p2si3728033qtn.261.2019.02.15.14.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:08 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=GAhYBfQM;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=hJ8TkaDB;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 4460031E4;
	Fri, 15 Feb 2019 17:09:06 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:07 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=0R137jNOULA0X
	2GJv6mEJu5LnxgF5CPDaCLQF5uXUrw=; b=GAhYBfQMmMRzrEHYF5T9M2KOo4dry
	SLuvQ9eILeoNUaXhEQY7COUT/A3kkS2ktOFJU94tA9dmQ7FYOC+QE47OpMSvVVoV
	FPIKfIBrMFRkN0aI8Vt29uXi9f4EsBptLlzhcvDiy/9sTHFTeNpyjVy0JF2oVa9Y
	qvcXUDDU1aCMPdMVhTpsTgtsB3KNIot7yoHXl7GRjQCbJSmttB3C74c45K7ju+qo
	dj2OtrJuDC5KZy9igtlw36VqsDRcUZ9tFc/8tYhOBJ8EsRckG7sN5Tc8vtn4lP2j
	k/k24X5OlVW6DMf2JIVDUL0DOPk5ebHDSrifOCiQnwUdijrCEaZpnAsWw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=0R137jNOULA0X2GJv6mEJu5LnxgF5CPDaCLQF5uXUrw=; b=hJ8TkaDB
	yewsnxFqRp9q1orVZP7Tviy/yYFVMXM54lVvD8Mw1fVOJhRdGY+F41C0udeuWqOT
	E1ZOFzs/5e9CwB+Y8IfshApHXlnOWSJI71Usb5zjVRwI5EbZ+FcSe2Y5txfPjEFW
	e0JLu+Y1dTVLgSwR7jU2KtjOcX3i3XtZJSss2ni+Ai3M2IpquYPKUtdXung5LpqD
	zHA/Xz4MTHHXW/etVqaqYBqN4IxODCrIthiEPgM7p2eLYwO7wdmm0uofxB/n0uD9
	YiVf5ysutMlbtxgR+xtBEscxqFb/m93V05mwMUizfp16iIxo9qMBQNGTV4pIReM+
	f882ZfB1ihjnJw==
X-ME-Sender: <xms:gThnXBN_qmSXEE4j_wEV6G-M7LHvM_8HCc4CM0NQ5_HDVfypitNsrA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedu
X-ME-Proxy: <xmx:gThnXEXhVXTgW8hjrbeETRoKJEXwVEsForw_HemEcFEd61K1_DdaEA>
    <xmx:gThnXBb2SrFexQLReoIQbIlxVPDooV8f7EONQH650YJbWpCs8oqgrA>
    <xmx:gThnXJs8HGQYvHPRFBcOSmk_hRIiGc2Qh7e4Aaa-eAi-P46Kde41OQ>
    <xmx:gThnXL4to-yXfkDIAYljYJIC_I1jLQco36wk88r0tLxHVtoQ6BI31w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4187CE46AB;
	Fri, 15 Feb 2019 17:09:04 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 03/31] mm: migrate: Add tmpfs exchange support.
Date: Fri, 15 Feb 2019 14:08:28 -0800
Message-Id: <20190215220856.29749-4-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

tmpfs uses the same migrate routine as anonymous pages, enabling
exchange pages for it is easy.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/exchange.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/exchange.c b/mm/exchange.c
index 8cf286fc0f10..851f1a99b48b 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -466,7 +466,10 @@ static int exchange_from_to_pages(struct page *to_page, struct page *from_page,
 		rc = exchange_page_move_mapping(to_page_mapping, from_page_mapping,
 					to_page, from_page, NULL, NULL, mode, 0, 0);
 	} else {
-		if (to_page_mapping->a_ops->migratepage == buffer_migrate_page) {
+		/* shmem */
+		if (to_page_mapping->a_ops->migratepage == migrate_page)
+			goto exchange_mappings;
+		else if (to_page_mapping->a_ops->migratepage == buffer_migrate_page) {
 
 			if (!page_has_buffers(to_page))
 				goto exchange_mappings;
-- 
2.20.1

