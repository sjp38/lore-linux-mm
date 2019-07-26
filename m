Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2449C76194
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9E5022CC0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dDhXdZ0f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9E5022CC0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02E158E0006; Thu, 25 Jul 2019 20:57:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F221B8E0002; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D99C08E0006; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC5E18E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p18so38204127ywe.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=D2MJs2fZHD43Md8ZpV6DlNuTDZTSVoq5UF6AxcLBY88=;
        b=RJEQ8wvIoyU4fCkV0AbnJqpjhXo5AkGfJf/4eMqc+F9YkcZ60siEWDRLoC4KpVQ0PJ
         qXKYxr+EQvqw/371smYHKItH49hA3U8DDMLrPSR1lGJQ5sNTHj/CGMAhkeU2jEQrTRve
         rgiG8hNByvnypvbH4MrexIRd2qi3dbLv/guNq7MIwTZu8Kcl6GW6ZmvviYpMGlDYig6C
         0EPk5Ve9JNNFJyMAL8BqMMsFYfJmIUpnk5OLIXsXqEUoKYZv6oWKyhsKiJZGrHqyfcQG
         HrcN2amqBqljCSR0AY5EMW0shst05bAM1iKgjoRMA2w3NyxsDH6oi1mdJjmrU4Z312yu
         1jDg==
X-Gm-Message-State: APjAAAWSYk9+i12X0z6y+wAzQwpq9eXaBC8clHTuWzVaOJlkdI/aD/bT
	1IHQjLeJVt61rpESa6D3RbAQ8/XIhX+qozjrXy8cOhk1U5B9HLzVHqaVepfAF2HUAN+Sj6Bnv/z
	sLd693d/HM3fbTFCD09S0KJbIocJI/t6rzq0R2KCgVXF0bg14GkRfygJrBZ3jPuVriA==
X-Received: by 2002:a81:50a:: with SMTP id 10mr54853457ywf.129.1564102635568;
        Thu, 25 Jul 2019 17:57:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpeOs09SRNYmukTHel+ubCL2qqgVO5+lyl06ekIC3w8Y/830Z7slTV/wKosRo3B/h5V7d4
X-Received: by 2002:a81:50a:: with SMTP id 10mr54853444ywf.129.1564102635076;
        Thu, 25 Jul 2019 17:57:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102635; cv=none;
        d=google.com; s=arc-20160816;
        b=i6Rr1AE1M9HYZwzZG8oRReCknpMUnP/3Cy8w6A7V2oVj6/8mCWrQ+dlRagIDqNNPw0
         P8gWcZ2iu0dkZtAgqVAbVjOiKqCXyhzp4Foway/pmnToNw+R5A+xUipwSW7Iq5m9aNpH
         +GAC/pH6e9mLqqb5pIzfC0KPOKsRdGxi11YO1gJVfxjlswMJhwnflHLTWjmmxeGlEXdK
         pfOE71fkIB1IxaZCZLtMZtcsWonc+ciTMlxdP6gVhioB0LWWIBp5KD/K5JNvZ3jqDAHw
         lOt+S1+L2BVBN5u0AKdX9QvJPPvDtQByA8199m3Nr5fHCpEaDGMC83kn/gvmACU3AOq+
         Ml0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=D2MJs2fZHD43Md8ZpV6DlNuTDZTSVoq5UF6AxcLBY88=;
        b=F/v2OQTzt9rtbloXj8gK8KA7TrIj+q21fiTGEeMqpVwkjaW42FY4tLBfA9rI0alWp7
         KzGywfXcGSR1ldbEN7OVpwkrkajxCiiZ26tOPYkCq47WdYFiXt+Ttd6stS0Y8KekBcq0
         s4oeNp6SJZUq0qbB4ugiX2cbIM2++3bzFceFj8/LfPyc9EXIgohdOO+JSTmsKT2LConm
         UHe+QNxLZpbs5uiPIthuVhsDmpBa9PoBsYCwgKzIcA+9CQJuPaioIY+70QEeakqiFxmn
         MZ25cm8zqMDxhXIPS/+eRneZ+1rneLOTq4AUz0VLOLMu7/qCylml+EdEbMyQMkHKWrpb
         hK9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dDhXdZ0f;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id h9si16330130ywb.114.2019.07.25.17.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:57:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dDhXdZ0f;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4feb0000>; Thu, 25 Jul 2019 17:57:15 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:57:14 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 17:57:14 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:57:13 +0000
Received: from HQMAIL107.nvidia.com (172.20.187.13) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:57:08 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 26 Jul 2019 00:57:08 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3a4fe40001>; Thu, 25 Jul 2019 17:57:08 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig
	<hch@lst.de>
Subject: [PATCH v2 6/7] mm/hmm: remove hugetlbfs check in hmm_vma_walk_pmd
Date: Thu, 25 Jul 2019 17:56:49 -0700
Message-ID: <20190726005650.2566-7-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726005650.2566-1-rcampbell@nvidia.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102635; bh=D2MJs2fZHD43Md8ZpV6DlNuTDZTSVoq5UF6AxcLBY88=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=dDhXdZ0fq+/bJJsVQCR7FJrU8TlXvz2itR9WvHA+D+zGwHRjQv48omdl45RnxXmpB
	 lVwB46LJQ7I1jmYZq8f2HDTONx4QL6yNAHgoDlCDzhsrayuWPJZUlqCiHsvrejtQAo
	 IzffaEtC6GLs+mrZgw+/TfanZcDKiKjQzJg6UcKUCcQzs0xxBR7vdmXnZdWx1QuO65
	 lsl3wTSKpIjNMBnruP2rDqPtA1oWApYCh1VuHm12T+FlHh0ONlL8rrfRqIuenKDf4H
	 l85a/V9vbnHfXJYcg4Hz8fOoowAC4ZLQH9YSs7dtBwWkS9sagT3o5JY0D0Y19kfUqB
	 dfO9F2MBE+xGg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() will only call hmm_vma_walk_hugetlb_entry() for
hugetlbfs pages and doesn't call hmm_vma_walk_pmd() in this case.
Therefore, it is safe to remove the check for vma->vm_flags & VM_HUGETLB
in hmm_vma_walk_pmd().

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 838cd1d50497..29f322ca5d58 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -630,9 +630,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	if (pmd_none(pmd))
 		return hmm_vma_walk_hole(start, end, walk);
=20
-	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
-		return hmm_pfns_bad(start, end, walk);
-
 	if (thp_migration_supported() && is_pmd_migration_entry(pmd)) {
 		bool fault, write_fault;
 		unsigned long npages;
--=20
2.20.1

