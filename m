Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 487E4C04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E20252087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="U4L0ZESX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E20252087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23C2A6B000A; Mon,  6 May 2019 19:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19FF86B000C; Mon,  6 May 2019 19:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E716B000D; Mon,  6 May 2019 19:30:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF51F6B000A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:30:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t1so8896688pfa.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:30:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=7sEAG7BmE97PPZ9CLmnt92JqaAHK4dBbaboJKD5IMgE=;
        b=UDa6Snofm5LI9OLB4JznxPEnPGBfRqH9f6RyaxtTORh9hQYajDslSehVxtu+vNqMlc
         11dIltVhf5/arUPIiJNgs0oN8RIiPeuDa47uJQ7pdvTg2zFzlTYwuVBMs8FYGrnHQSgS
         Z2T3GMzWFskvtaQdqWbT8pFJea1vj6NAKfmFo1HenwkT4Pv3uEmsSSAFIq0WRRoiBDuL
         f0E9pQfUDTUpwkFei23KzSKwVrWw0NZDauBa36A22Z4iJ8cBBVliSADTDeCJifGETRNx
         yonG1o5cp/DuRpiNI6w8rZx7EWJdWDp7OcyCv7FJJaBkZsmfkmaemDgqztSwPvKwP5g/
         OxXg==
X-Gm-Message-State: APjAAAVAWZQv2ePAUR7FylLgKnlWK+OhRjz+kPjCROvsD3CDLMAgnWhl
	3+zZ7qVIqWoCZbBdgdMQZjdAfnKWWvJSDBxQQ2JVw11f/xDEOQwRdeg0SHVkkZAaLUttgCc1/aI
	TtN73HJudpXlOkuEYMH+2qzu9wfaoeXVmhSFfRMfHwHzzZ9R1/4Yn6exp89u+eh0evA==
X-Received: by 2002:a65:51c8:: with SMTP id i8mr35389149pgq.175.1557185453437;
        Mon, 06 May 2019 16:30:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg5qTfs7ImDRij7VBIXQfWOkcv3bqmHO7YJxwt6yCVz6wILXOcvUyscym3ORVGWCIFzaoJ
X-Received: by 2002:a65:51c8:: with SMTP id i8mr35389072pgq.175.1557185452488;
        Mon, 06 May 2019 16:30:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185452; cv=none;
        d=google.com; s=arc-20160816;
        b=NsiwZURVZRjfAH/sh27AkrxFaNzXTr3ExkZ98Ir7Z50f2v/czaX8721bZqk1oA+aaM
         Mm9BpYtMpthFEu7r6WyGdiKhpLQyD9p2OXcG1hgO2tq1/Uscncg6IisDrJdtXhQ1POlq
         CDVoAFsXhSl4RoUZ9kj3lc67Wt+7NAnuha49SkraWxXHog7Ju8rnQj6YZhHr85tm/MaA
         C5H8Ty/PfXDeVKXvNiCvZKW3ck5q3ESBfQ6puxaoPYOfUtIDixQHb+WY4l78GOFBr+nh
         wkjzOc/qdpVHc6YvMKmZvgjSfego4CONtFKAXa1ZdYthnttVnbmOaKEMwlXDgLOGXe5U
         YEOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=7sEAG7BmE97PPZ9CLmnt92JqaAHK4dBbaboJKD5IMgE=;
        b=cTYddpPDJlacNIscGpoKV4rVAEh7dwVcqE0GbC7pOJn1qS3pxfNsZngO3zHzZLR2zj
         iz9vP/3FePpLWekBKSs5CHqSPaKT0qHEh/hKAM5LcDB3RHE79RUsXvIiEm+E6AL3gXud
         Lu7/Ot5nXCrTUSnCo/AqoFnAC0uRJfjOyb34h30bomamdyxnwtbA/rHNzzoG9/s7Q6TI
         3YmTxcnnIwenCFbkEgl04sw9wlMoBBLboxh0i/8tNjE8wFEe1bVTprPJYdA6o0AvIW5K
         qWjzXUFmv7hYCnJgxR7MQKdhcpkgaZbHZn/ngHUYNN6pJK7kZ9x0uwuvcTBxAwXT8CpP
         b9Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=U4L0ZESX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v10si2561674pfe.87.2019.05.06.16.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:30:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=U4L0ZESX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd0c3a80000>; Mon, 06 May 2019 16:30:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 06 May 2019 16:30:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 06 May 2019 16:30:52 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 6 May
 2019 23:30:51 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Souptick Joarder
	<jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
Date: Mon, 6 May 2019 16:29:41 -0700
Message-ID: <20190506232942.12623-5-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557185448; bh=7sEAG7BmE97PPZ9CLmnt92JqaAHK4dBbaboJKD5IMgE=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 X-Originating-IP:X-ClientProxiedBy:Content-Transfer-Encoding:
	 Content-Type;
	b=U4L0ZESXdXyu4HWeu/nKyyIqj74DonoGBT6SFnyPRAxU2VVbgRApkhErj1Q1lHVhn
	 hDKrjw8OaE+4TPmGG7K+tvEa0IPgVTVALNe10MY6RAMneTRUExBPAa9QTbcSXgjawc
	 YsETYgttxPSIe5L+FFEiF/0y/82hiXtBq78QwYYYkVXC0McXLmVwZXXAIkAsozuDto
	 U4+R4b0iXWXeBU/tcZFJoxYXX7qb+74B6xFTqzHr2cOTdo37eAj4WGbYL2vcvUazhl
	 7hehU8zjzQyFMHe1OtBiBzHA74ngo4oL5rgwjQ5tply3Wwok7XgXIWx1tDz48a2D1b
	 hOAXoOVT2c3PQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

The helper function hmm_vma_fault() calls hmm_range_register() but is
missing a call to hmm_range_unregister() in one of the error paths.
This leads to a reference count leak and ultimately a memory leak on
struct hmm.

Always call hmm_range_unregister() if hmm_range_register() succeeded.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 35a429621e1e..fa0671d67269 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range=
, bool block)
 		return (int)ret;
=20
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
+		hmm_range_unregister(range);
 		/*
 		 * The mmap_sem was taken by driver we release it here and
 		 * returns -EAGAIN which correspond to mmap_sem have been
@@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *ran=
ge, bool block)
=20
 	ret =3D hmm_range_fault(range, block);
 	if (ret <=3D 0) {
+		hmm_range_unregister(range);
 		if (ret =3D=3D -EBUSY || !ret) {
 			/* Same as above, drop mmap_sem to match old API. */
 			up_read(&range->vma->vm_mm->mmap_sem);
 			ret =3D -EBUSY;
 		} else if (ret =3D=3D -EAGAIN)
 			ret =3D -EBUSY;
-		hmm_range_unregister(range);
 		return ret;
 	}
 	return 0;
--=20
2.20.1

