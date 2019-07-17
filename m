Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E7AC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05A1B21850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 00:15:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OvNb5yTx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05A1B21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96EC06B000A; Tue, 16 Jul 2019 20:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E528E0001; Tue, 16 Jul 2019 20:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80D676B000D; Tue, 16 Jul 2019 20:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 634576B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 20:15:48 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h203so17457923ywb.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=dQvYVBMTRYc3SjF1PkfCIGikt9DQJqiS5LuvPJGyR14=;
        b=bJqTgDyCup/dYj1HNrpOeVGBUmBabqkcviGyOUPdLrFBBTGQzwnGQmUA3NwzWOD3Pv
         00lGpyL7kwDMNDh/Nwz0fOJv9379GW9s/QQgt8iq83+es6HdiBnYWLL711xZlPD3oL9d
         l+0bu3saJYEy0mBQZRL8DRjtAd0LbH33vF0gLQ0rcZnNDK+80AztJ42why9uc9vtZhiu
         hRE97XYQQRP25JWHgffg0ltS29yTbIq6fBX84X9WIPfMQvtsW4Zmix9v1QVanPr5f4Yw
         N3MS0q0dd4Q9J0QJyQ0gv3xcnpki0lXkEWL4jmZsB/Wh9i78U5lI7QUkYlOJgf8l8Zm+
         fySQ==
X-Gm-Message-State: APjAAAVf9tjyTmqUFuuxWFcl0/KlW810mNTsR/dFDXEktbvfVvg4ztkb
	yRzhXMLkzm6+pHouGhWHDUu2CGtlmeJxuQDOQHIwHvs9i7solRZqlx/MPKIYdjloyGTLBRC99dH
	qkUTlpU4JIhnB6qXR9nxY7ZGScFr94gXFtPwfiEhcn+6YHFW1z8VxZ0TfDFkyq7Ggzg==
X-Received: by 2002:a25:41c6:: with SMTP id o189mr23181423yba.110.1563322548126;
        Tue, 16 Jul 2019 17:15:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjVUejQC/E6WVDcv4cjEDCYXOW6AIo6d3ESaorp/o7KYAN6xvvuLBfa0f/1rosbaagn3kk
X-Received: by 2002:a25:41c6:: with SMTP id o189mr23181396yba.110.1563322547630;
        Tue, 16 Jul 2019 17:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563322547; cv=none;
        d=google.com; s=arc-20160816;
        b=v4OcIs6ALJXpRjOyTiabl4g7E5KYkyOMmjJWnlZZrQM2y+iY0jpiJXTJmzlErV1Pxz
         0WmP5O+tRiZKHETOP9EZlo8jlQv051W6bXVa3nGENeArlQN9cZZgzlj0zQ3ydegySDhS
         uN55OlbT8WNMufVdBXR2MgG4S+SJUn4Lh6KTw4RYJUHptG+acJqXYBWAamDvJqFt3IJF
         ARpaC2PF8+UpDjB1EnH6+6Z0CjpC4kpfJFRSB+ESeI4FP25+tdO+tN76F/LOMYMc/Z88
         TVn/ZIYH5z944SbX29i8ER3xxkN9z2hkJ9Zdxv9kLGVGKq0kmEl03aQroe4hMqeuaSYd
         6zvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=dQvYVBMTRYc3SjF1PkfCIGikt9DQJqiS5LuvPJGyR14=;
        b=qRca0tPtbfj9noAp3Qi+TVHuoWfTXe+2GYJ2wROCmtieCMB4OWbrN8ws2btiWKH+9q
         /ZSSp3AYGUpDoqQGTCZm4UyUkiSvn4KHNxiF/02a1rmWpw9ZhckxcseCLPdQ0ipyGByV
         hfQpuAQeWxIkN+GXa9iZk5mgt3bL+9J6tymHvjfnUe0l0ShZMVagFr31t7pQnVFRJb1V
         OE5MWmqCM1azSze/IEfmsakLGQjGklsws0/fed0sYeUSIfEGlMiHif8P8CIydoVzFPO9
         tsgwBGBvjebGLm/FojQHWWB0y47w2Fp14kYVlj8rIH3Df437Yj0YV0mpcM6SVad4KTED
         EioQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OvNb5yTx;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id p188si9262417ywg.204.2019.07.16.17.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 17:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OvNb5yTx;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2e68b90000>; Tue, 16 Jul 2019 17:15:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 17:15:46 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Jul 2019 17:15:46 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 00:15:43 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 17 Jul 2019 00:15:43 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d2e68af0000>; Tue, 16 Jul 2019 17:15:43 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
	<mike.kravetz@oracle.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, <stable@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: [PATCH 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Date: Tue, 16 Jul 2019 17:14:46 -0700
Message-ID: <20190717001446.12351-4-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190717001446.12351-1-rcampbell@nvidia.com>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563322553; bh=dQvYVBMTRYc3SjF1PkfCIGikt9DQJqiS5LuvPJGyR14=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=OvNb5yTxS0yQJ/QFCE+O4SUPLwvoCMYAUHOjDwGSxYfeA1s4J/mA35mjyGpfefFUp
	 073C33WyN1TcgFCRmljuxkv/yP/G7JpuRxl+7h3pCLo8uhRNryeGc3ILxOMvxAZYqI
	 MsZ1qQWuqITEjYO9PQUmuc7GegYK+3RR6Rm1IMpon66Mk9LNCVjhy0crsVH35ow5X8
	 PwWlDzE+p3qI1hdOSLU0ZhwcMc1aBC865suP4f+l7DrrSh23BlRaZ2I8dLfTO8rR5Z
	 eOYvJA2qp1GRRBUkEmlbC4RJH3BuFWJIbrA8MKrcUq1TC22VYponvU4B+FIrlUKCv8
	 I2xExWbJO+Kww==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When migrating an anonymous private page to a ZONE_DEVICE private page,
the source page->mapping and page->index fields are copied to the
destination ZONE_DEVICE struct page and the page_mapcount() is increased.
This is so rmap_walk() can be used to unmap and migrate the page back to
system memory. However, try_to_unmap_one() computes the subpage pointer
from a swap pte which computes an invalid page pointer and a kernel panic
results such as:

BUG: unable to handle page fault for address: ffffea1fffffffc8

Currently, only single pages can be migrated to device private memory so
no subpage computation is needed and it can be set to "page".

Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE page=
 in migration")
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
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

