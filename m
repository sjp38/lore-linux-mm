Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 884E1C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40786222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="LMQQ6Foj";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OIv/vxn8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40786222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EF7F8E000E; Fri, 15 Feb 2019 17:09:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A09A8E0009; Fri, 15 Feb 2019 17:09:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167218E000E; Fri, 15 Feb 2019 17:09:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E33498E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:19 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d13so10342786qth.6
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=s+M9Q1Dn/74r7Hqs3gLQcg1STi/Xk0kU2xFV7ZybJ5M=;
        b=L2BFguBpr/DNcgJm9VMuViyDOxQdf/4C/jefn3WFBRU6yJRfAiyoejkcQRrYuICDSr
         n9Tx8HJzQmZQpGWh2jA8uqij5RHPl5Yd7wbnLRXWi7G1+rYsnqiLnvMhRMgJhcN/3vlb
         sau1P8bw0aV74H/N+YHQd4cMpXkWf7aoTM+25gm441OjKJZULJdffc5UpEQIdcjXGHfA
         0e+ydcPCooP9KdkFmAlEgRNV7+tjr0LB6lM6kcXeO1U/g9qlis04vItD9z83nVRJCnDk
         Ll5g82YfWFG/KPTWvLzb94C2nncxIfc7S7M9190BhXXr+3luuG+hdkiTfIVgFZ3sLIFI
         JskA==
X-Gm-Message-State: AHQUAuZeQ2c1iT03XzPUofPOoxEEuRVPC0eKVZTxDEhBKOFxCvwH+Gq4
	wnZ8jRRg1T+F8uYqW5kZk16CQMKq//umwihxgHR4/VWBHHuIUVxiJKDm895AU5wJNqUhy9QgEir
	zqlLcOGuWb//CI39Sw6KUJk61cXpZQ8APcaZrXybW7cFd7ptn+DNLQqbMxBpPIo097Q==
X-Received: by 2002:a37:9a13:: with SMTP id c19mr4963184qke.48.1550268559730;
        Fri, 15 Feb 2019 14:09:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbwqqwK27XoMgTt+/+jBduorQua0qN+eUAcWGWBZ9goM5CEW7XbIzXbdUJfUtXsDJIsBMyq
X-Received: by 2002:a37:9a13:: with SMTP id c19mr4963153qke.48.1550268559263;
        Fri, 15 Feb 2019 14:09:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268559; cv=none;
        d=google.com; s=arc-20160816;
        b=HUqEjDukVMuD0MfWON3gH2f/DTAfI8Z5a+HDYkX5GlAApBnPdutefDek1aPr1U2zTi
         DGD7qcpN4dgdDCHctL5UyjlLmDE0RqHUM71p4MaiGpZE6RxqQ8hFL+q+KRvcUAnobXtT
         VSQw1lSBZJV0S2GxvSfSpD5XvJW6qJ294iyAx/Y8DvELE8iP5ZtRJxyqLS6sFEvT5Zgm
         3SQrXaI/sEUgrCeOngw1iE6bbpu3z8harVxo5f1DMa6BCc4Tagg9tMvd/3/i5SHAk5YE
         +cVRMFzW3KYOcJwTPnrDvUOi4hvTN/2RfdFjT9KykJqyNfRw63z9hOObbsjG0M+3khup
         X7Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=s+M9Q1Dn/74r7Hqs3gLQcg1STi/Xk0kU2xFV7ZybJ5M=;
        b=o4oVP7xRDOK9rIa8iqnlEXp2RvzhTBvsfEpLpduQbek/klUM08fKdTzHkQhrbQD4pb
         tzhcNR4QQUfytV7v9lew/AtdWvOKCIfTCxVypZpq0GLKi7rz+9pxO8V74W9rnzt/s6UN
         fH1TEn4N9M/uoLyLzf/cwjtp0pby89pSTjkvKSh1us7paim4XokU0zsYbjSv9v4k8w1b
         I5LxdTWNhHC5gmy1B4ezBPCTjCXWuNFDo/CtrgVEyfYhF8luHi1C68AuqTyyiWn12ofM
         06XAOJSzHlRrlm1keBo23KplRw2zNEu8sWxCwUzgJPti+4ZZWfHJJ2rsXOnXSoaP2Nss
         rPXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=LMQQ6Foj;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="OIv/vxn8";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id m37si509442qvc.174.2019.02.15.14.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:19 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=LMQQ6Foj;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="OIv/vxn8";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 7BBD7310A;
	Fri, 15 Feb 2019 17:09:17 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:18 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=s+M9Q1Dn/74r7
	Hqs3gLQcg1STi/Xk0kU2xFV7ZybJ5M=; b=LMQQ6FojPBEWUxYcZyupLkHS7Gi6/
	lCmVLgDcfuWz9E42THOfhFiodqUK9AGh/8qXtf2Oz92BOz8GBlswGNkO10eAsI8p
	MnPC+Z6phDvGEVAQJx3NS0hZBEIrm+Zykik8xVKRicMjNuMx/Q5Pseh/BkMkdOPE
	mVyJTbEZepYPiFmRSwzOYwIyafdxqPSjfy8tMAvmCxtYnm+Y5m7FfyqLmSfsD7be
	gHmAJQ+E9QlOo7671DKVipxixMf2koJcueOM/TJhVPBR2JG35KIyWX93ehf6wXz+
	HmTH5oKrFuZVcMTORI4XtdgikLmA6D3ixeLcAvtgo6XjQ+Wyo8Olt3AEg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=s+M9Q1Dn/74r7Hqs3gLQcg1STi/Xk0kU2xFV7ZybJ5M=; b=OIv/vxn8
	z8uHrE0XwEs5J3iyx9QT7uKYL6ToBVMAWN5DFv8SVn3iTZNUSJa8TdtF/FnfxOuW
	ydrpe04VTkGrfL2oJenrQ5PVE1XQ0mc5KNg3vxskG6exsbG63ILI6X+rRapRgWHH
	WaHKW16CkiQF1x7giugKKyZPqsUr9bh2OQTSCV7JPYHe/CwzqTd+aNnYtMASt+vs
	HLA4JPfbL8CjOvnHUBvbESMGVjEzXx4Ar7HNpQl+4aggb0Gyi2rJXOu0E8F2cZ1T
	4tU6/j3coPB5+DfUjENijh2Nd+dv0CucbaI06/1vRIFVfLjSTxVRasibOPW5C5gr
	OLmyU8z8PTtlAg==
X-ME-Sender: <xms:jDhnXBCcq1om_2qetgpMaysLFy25EP24mNfLi1FrawSH3G4DmaAtZg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeel
X-ME-Proxy: <xmx:jDhnXJlFYof067REGB9rlsC2amOjXGIKIobFc_GXDpJeS29aY-Lvlw>
    <xmx:jDhnXLozpyq_wKigPm5JLVtE3CgxRON_INRvmMBAWUCvE6vxgHJINQ>
    <xmx:jDhnXD6VjRIjEv5oawlrTA6Zchmp3QzFpVexlg8959mVhH7F6-2KqQ>
    <xmx:jThnXNZATm-XiCR9VxyMSGa5OKynws_2l_gCJuikAmxKVfn9sgPIEQ>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 922BBE4511;
	Fri, 15 Feb 2019 17:09:15 -0500 (EST)
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
Subject: [RFC PATCH 11/31] mm: debug: print compound page order in dump_page().
Date: Fri, 15 Feb 2019 14:08:36 -0800
Message-Id: <20190215220856.29749-12-zi.yan@sent.com>
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

Since we have more than just PMD-level THPs, printing compound page
order is helpful to check the actual compound page sizes.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/debug.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 0abb987dad9b..21d211d7776c 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -68,8 +68,12 @@ void __dump_page(struct page *page, const char *reason)
 	pr_warn("page:%px count:%d mapcount:%d mapping:%px index:%#lx",
 		  page, page_ref_count(page), mapcount,
 		  page->mapping, page_to_pgoff(page));
-	if (PageCompound(page))
-		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
+	if (PageCompound(page)) {
+		struct page *head = compound_head(page);
+
+		pr_cont(" compound_mapcount: %d, order: %d", compound_mapcount(page),
+				compound_order(head));
+	}
 	pr_cont("\n");
 	if (PageAnon(page))
 		pr_warn("anon ");
-- 
2.20.1

