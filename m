Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98E0BC282E2
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3039A217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BCXKlsgU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3039A217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1BE6B0007; Fri, 19 Apr 2019 19:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7691A6B0008; Fri, 19 Apr 2019 19:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6098F6B000A; Fri, 19 Apr 2019 19:35:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 247B76B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 19:35:57 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id p11so4289006plr.3
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:35:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=CfvcO8vti3twykYANcJx0ucggxeHBxOuIW3oPk1HmoU=;
        b=YYtXvH1SsO0EhxsNfukb6wx0zqw4XrBSAdm42Vgy4VJ+ETZss6s9e5sXl0h3YnOd34
         HTG/JYZ1Flba+Ems4G1maezZGHtWYp4CIsXbvYLQ1xSNQLYgxF6i4tQzJAtMb2Mh5dWv
         cJuzXmdpfzknxoL6rkIAi8aexV/KhcbMISuPZrZ03CB9lPtlBqY8A6X25/88rUNycQ+X
         Gvn0QNBRCrAL0h/fK/aIhC+nZXsfla1YfxMy5sccpL20jVz4R05o7hod3SDJhvr7Id1Z
         Lf60jsFNkwfqA1Q3h0meyMjhCCLUz2FqOI2OfUKW2+mTPHKVgvMJTmX/9uHq9xkX2uTY
         oKrA==
X-Gm-Message-State: APjAAAUapdtM6AnOV62G4kIQ7yKBvEJAzDZVPtZ0NrKnluQHB4wNYZMm
	dl59vGbImHYtDjNLvKRhEVnno9YXAb64tuDwPktlhZRIhHJT+Vc68ZWLaaj10OXD6U4Q/fAjF7L
	tNWG+yYXvvS+vb1cR5a90wIt8Lk8g9yB7ercBFd53YmOfnyQ5NkZ4Iq4rM6Ro0F2zXg==
X-Received: by 2002:a63:1601:: with SMTP id w1mr1554122pgl.258.1555716956775;
        Fri, 19 Apr 2019 16:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWnlreBhysn1OzDO/rrhSeJ8NbJfL2shq6HYbme6t4GGkuw0s/47dvBsTiyOTCOnHzefFJ
X-Received: by 2002:a63:1601:: with SMTP id w1mr1554074pgl.258.1555716955977;
        Fri, 19 Apr 2019 16:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555716955; cv=none;
        d=google.com; s=arc-20160816;
        b=WyQzOJDlDR+Q56XX1qs8u/uwagLKPZ3TNS9xtwegEwX4A1zh16T+JM0ipZtWPcNBpg
         AGT1p+zHsPtD0xglOXrTw+Lz/ln3U5YdsQwR3+z3KT4pMY4xofMHxxgYsKdaoSjFNvYZ
         QFBObN+9SSpsWb/v/5s+iQ5F4HyuZEJA9cke9MTUatB8K5qd1/3GuES1fakW0dgGgLNr
         62WOSoI7hhHjowiO62/0tjcOO/ivrqxdRrnxeFDtWnSFnlNr6FvooY2FwTCtHOoaTPHH
         UOqtpYiEiaiN9HftS5rdHjjOBnJBQeoNLx8GJ5hLHOFdgQGxqg0YEcXJ2NFbNX6vyiXT
         PvDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=CfvcO8vti3twykYANcJx0ucggxeHBxOuIW3oPk1HmoU=;
        b=wd/L7H9x+iycJvGuTmp4lVQpRUInWO07//qqB+tMJEksPJbjCvTGJjsS37HqjMKDGH
         qgQdR9GY9aRhIqbfmFRYNDMFRZVQGiRRXcBa9TAHpxKs8WHqaq3MSEPhrZtwH8vsAgHP
         a51s97FtJ50HmlM7xM3eIPWHaqTzrDC8hHUrQdJ35zNbtCf9BPBdAiZqiW4ndRbb9zky
         1W3hRwkH6K3x1UAOvVPRp9nouVNkJ9lNPP/RwzjEZK+w/6RRHPEQmh8/S0BcN+wnmGwz
         LKz8GCkYU1OcNJpymvxEoapzMnj6pr2HV+N3MF3G4coaFivZU4rk6Jb4Mki5XyIuJV1P
         oGhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BCXKlsgU;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d6si6865880pfh.177.2019.04.19.16.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 16:35:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BCXKlsgU;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cba5b450000>; Fri, 19 Apr 2019 16:35:33 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Apr 2019 16:35:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Apr 2019 16:35:55 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Apr
 2019 23:35:55 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ira Weiny
	<ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, Matthew
 Wilcox <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>
Subject: [RESEND PATCH] mm/hmm: Fix initial PFN for hugetlbfs pages
Date: Fri, 19 Apr 2019 16:35:36 -0700
Message-ID: <20190419233536.8080-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555716933; bh=CfvcO8vti3twykYANcJx0ucggxeHBxOuIW3oPk1HmoU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Transfer-Encoding;
	b=BCXKlsgUqrl6trofbhM0tSZXI9Ex3bUSnmbrWJ+XWphmX85PVCYhlL1oVgW0dUltN
	 o4+MmXNhN9EzOrChpQlAA3PbPw8tCZD7hRClEFkwkRbylXBAqJWM7qszyPzEtQCGNp
	 iY00x/VC0wPz5SiEJJ1WYeaxqCfqaxg9axv7An8eLSc2NBSzFuVje14hz7IZjMQHxL
	 QrMjth1ijfqVB66nUMiyqDSKeERIdu2zHdtuceWHJIGPcqR66Hzxjs0aiVZn0T+I4/
	 uDsg1SDx+WwlhGrbNF3Xuy9lzqg5VIK0FbZcM/Pnm6c9K+v14Ji0+vTELzx4CbHzdw
	 zKsp12F92dSpw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

The mmotm patch [1] adds hugetlbfs support for HMM but the initial
PFN used to fill the HMM range->pfns[] array doesn't properly
compute the starting PFN offset.
This can be tested by running test-hugetlbfs-read from [2].

Fix the PFN offset by adjusting the page offset by the device's
page size.

Andrew, this should probably be squashed into Jerome's patch.

[1] https://marc.info/?l=3Dlinux-mm&m=3D155432003506068&w=3D2
("mm/hmm: mirror hugetlbfs (snapshoting, faulting and DMA mapping)")
[2] https://gitlab.freedesktop.org/glisse/svm-cl-tests

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index def451a56c3e..fcf8e4fb5770 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -868,7 +868,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsig=
ned long hmask,
 		goto unlock;
 	}
=20
-	pfn =3D pte_pfn(entry) + (start & mask);
+	pfn =3D pte_pfn(entry) + ((start & mask) >> range->page_shift);
 	for (; addr < end; addr +=3D size, i++, pfn +=3D pfn_inc)
 		range->pfns[i] =3D hmm_device_entry_from_pfn(range, pfn) |
 				 cpu_flags;
--=20
2.20.1

