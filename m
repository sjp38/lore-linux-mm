Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48DE7C73C5C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 22:36:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDEFC20665
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 22:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="THZRHUUf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDEFC20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 316758E005D; Tue,  9 Jul 2019 18:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29FDB8E0032; Tue,  9 Jul 2019 18:36:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 119058E005D; Tue,  9 Jul 2019 18:36:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0F488E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 18:36:11 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i73so79786ywa.18
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 15:36:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=WmDfProy1Dp6O/d7UXR/pCuB4a9yi2oJwRAiLHXR8FI=;
        b=WIlMQ0WsGPUCTFPCMUm/LoH4+v92W1ofM9K/EU+Jfajg7boi/qn+JefsaSZSOxk9sz
         Q1FrYnQ0k2owuwVQ+1TqtKzKtrImPrdGkDPltKvG3RsajKGRNhrfX5iM6DWNpS4yImm+
         aN53v1o44/9Qv7mI6ZG2iABmGc+M1TwkYZdWGQzt5jinClPbEZWQds1Kpn04qCsqK5fA
         EbZ9L9gn/6IvN0UcDGjR9yvKm6hkHUgfLo8LEokOU21rY7SXQAlVvCakWzAipQ/ESMQJ
         YILLEkiYfVAtkrkz452XrFJGvcxH2TT7H/lPttvrsHiwt9ktJnKtkjmXSg4G7pZHsKfW
         lbZg==
X-Gm-Message-State: APjAAAUlLPQnLnbJ9+INTGY1VPszSdktl/Qqv9ySIiXeQ7E4jNgdg+Re
	KIDjqOqaMjpkw+G7EerB20Ebi9svqjmRay2LTQ0gM4tT8MoF7946yltudWm6MDktlrwf+P9aH9H
	21+Op3RgfKdj+oyL87ZugCvZtv4z9OCHUTC+37PloaJ4UndILYmUP1CCot2UwWkyE5g==
X-Received: by 2002:a0d:c301:: with SMTP id f1mr15551648ywd.494.1562711771502;
        Tue, 09 Jul 2019 15:36:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTB4VumbsspSjudIZR0K7HYgyfdR+AYIAsnQQ3mLAsaztlJHjoaqSawbztRPqCgRTj5ERN
X-Received: by 2002:a0d:c301:: with SMTP id f1mr15551621ywd.494.1562711770827;
        Tue, 09 Jul 2019 15:36:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562711770; cv=none;
        d=google.com; s=arc-20160816;
        b=ZyAFt0JCOmILWQW9X2RQFhH/oILTmE4xz1B5E+wDipWT2m2Z8O8y7gm6IXeSo6LeqT
         DYiBMxT3K3N3xQYOJeUvVVP/Wslj4aX33JR1hcWFU8w6k1u9hHT+4IISLvj7NFy59Z52
         lywolGofppkfpk7+dnsI7YrEypvO2pIjOs8mjZ1qK32Yq1FWTgU64YliPi0B9SWTIyND
         n1EHF/GjOoJzZdhl4huNnjBct3KgpigjfxRnPf5tUsLxY6pFNF/Os59dRoE+gUyMmUjq
         3CwPwCqQFIOSIadeT6nW8f3wLbqK0GiSRKsFrm537zGfRX1v/k7Q6Vg+N2ZzNTYadE1t
         IFNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=WmDfProy1Dp6O/d7UXR/pCuB4a9yi2oJwRAiLHXR8FI=;
        b=hd8nDEt0zdBQGT2jImvWdbhKEEXXxwQsixQatYFCEB5TdUPQ5ZWyT52Wao9c/pxrux
         lso4xaX7fY471xmYZvPsy92RJYFJLLp5FAdyabiQLJwMeXcUl8JJm7cBIlgyMNBEQJPd
         lyM1hwXCbJQYvF7jTq6iL+Oa9JCR38uh6xQPCHpQXm2c+UPEaOpyPbeIIAjczb1FjL1P
         GcN/EJpcEy47tlPTmCIA79Sz7mkGk0piHD1rhsFX5q0S2c/szuxwGObTRt6W1tY4Ajeq
         P5dMJfHguO+ux8qXfp2NWfNxxJrtEqkVsTq9UrcxxuAEbseNvjg0mV42tgvWyZP94bbk
         3rkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=THZRHUUf;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id t187si42831ywd.83.2019.07.09.15.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 15:36:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=THZRHUUf;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2516d80000>; Tue, 09 Jul 2019 15:36:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 09 Jul 2019 15:36:09 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 09 Jul 2019 15:36:09 -0700
Received: from HQMAIL102.nvidia.com (172.18.146.10) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 9 Jul
 2019 22:36:09 +0000
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL102.nvidia.com
 (172.18.146.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 9 Jul
 2019 22:36:09 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Tue, 9 Jul 2019 22:36:09 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d2516d90000>; Tue, 09 Jul 2019 15:36:09 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
	<mike.kravetz@oracle.com>
Subject: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Date: Tue, 9 Jul 2019 15:35:56 -0700
Message-ID: <20190709223556.28908-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562711768; bh=WmDfProy1Dp6O/d7UXR/pCuB4a9yi2oJwRAiLHXR8FI=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=THZRHUUfPOzbOu0G+mUFBwdXTkVaIRyYUhTmyBN+kxFrZrkuCZMB0QIbsgRmMgdxv
	 fhWfhYtObglVZpAYUg9wae+eqbuKmR0WpWK1LgzKnYNDm90H4nC5PYbjMibG+FexFY
	 ws73FQ7OyJbc5tGO4q0fM3859mCHmEWKlrqf/SNrUFffaP+vIxlTvmLpXnU87yW+LE
	 GDaFsFG9TOopI7e6oMVFJP+A2eSqnP7NlydABKF5OpHYbq6I2XMDctzEZpY/8Ocvbt
	 3kYpx8pU7JykioEa0fCpomdY+HONkVJg0Q0yDCVmmeO9IL42bJ2OA6u2X+0WLdnjKn
	 Ki52Yfw+aFsCQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When migrating a ZONE device private page from device memory to system
memory, the subpage pointer is initialized from a swap pte which computes
an invalid page pointer. A kernel panic results such as:

BUG: unable to handle page fault for address: ffffea1fffffffc8

Initialize subpage correctly before calling page_remove_rmap().

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/rmap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..ec1af8b60423 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page *page, struc=
t vm_area_struct *vma,
 			 * No need to invalidate here it will synchronize on
 			 * against the special swap migration pte.
 			 */
+			subpage =3D page;
 			goto discard;
 		}
=20
--=20
2.20.1

