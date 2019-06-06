Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43930C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AC9020868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EIOU+fw3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AC9020868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66A276B0282; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61DBF6B0284; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BC9A6B0285; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E16A6B0282
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id t11so2885432qtc.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W85iZVgjurkkiB2a7Xxec+qLci2n6gFQqX8RW+I6lJo=;
        b=oHZjIpUIUZNp3ghWTRDJQQLd/disIkhkgMBaxe14KTtCqmTUKDVO2WHKNMS0RcCJEO
         YNsp3OVcyG1OjE47BThwVtoZXH2RymLQoL+XH/JqQSANYIueRX4d9u/XDwXCp1BL5evl
         +YJGQucO54c8sUEo/FemGR1JdWhGmOIXqqpuMXHssmwXq3NQbIrsy7J1e1c7ZoWRvlpr
         MyPEWXGDbhEQYUNC2x5KUg2XwbqKvSXKogVsemQfrzizYIhiTRSYaY4pgJ2uOewgPBaR
         vMOv2Gt3k68Wjj8mov1dIgEXXRKosetVqwliBYO2p+JDbCsN9UEvwysfg343Z3ipsgBw
         iuuQ==
X-Gm-Message-State: APjAAAXeuHuOQ8EliKim3x7TOjBQBTk4IoggT0rdey7NDBekRQ+5frPP
	sZuM5nVL/D0dPPcBMzHRcnaUNG1Vm6AFvRkHzS1yEDmLhxzfJNJo/zzdoLEvqDEBCpLiJK6/Cgx
	H3ifzSo17Hq18kGOplQ6XvOAv5hPTHtxl87hYrPjKZ+3QA0khlxziVtIaeG1DlQzrXg==
X-Received: by 2002:a37:bd45:: with SMTP id n66mr38370801qkf.81.1559846690946;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
X-Received: by 2002:a37:bd45:: with SMTP id n66mr38370768qkf.81.1559846690424;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846690; cv=none;
        d=google.com; s=arc-20160816;
        b=VP0wpbm+Akpj2UNnTCxayJVMvns4Nq/oe9VGkpt+Bx7BHvo9E4fhI2m5DxvWrVKzI7
         GKREu8xlpqoMiNU/g47EEw8cJ/P+6RTk+DbgoCT5JkKU/uvOFrES23ydTd0y6mumEp14
         FQRUsAOqrtpXquIj/uYZFNk57gvoDI0/JeyheG+HlkgwezyP3wwKRfSBeGeFRTi7e+XZ
         a7sa0M/aXx830FMErh/W6ArI3eaUPM7lzI6nN+NxIPiT8Mok8KXDTFmLYalyMZjsNR2L
         N4+9fSg6lleC/HhK1l43A56vPb6mXasgKRcyFKOhfZ8Gcvr1Xhw7YtRv6FsHdeHy/Ijw
         ysiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=W85iZVgjurkkiB2a7Xxec+qLci2n6gFQqX8RW+I6lJo=;
        b=fwV6NKmnIFpTMy/IrdVxbSzP/FWW9sWerXuvUQ2s1kIvGmFnzaYH3CQgcKWcayGt29
         pH7tCU11PXHU05drxlDKbRU67vt41iH1sg15Ql6vSIWczW0+SHCHRh1zEnylTCdb53Pb
         gq6xtOjx5rct+w/Zm2E5Ue8/fZYeYAwpXhyNVmyyc29tDx04zM/omn6LU7OpcsAKYSqw
         7r1frfZQJJF7oHK4TrdEyb0Mxt0BDkkuMzq0ehKJltGt67OX1T3FlaZOtbjHPXQ3GqEv
         ytV623J+etWjgAxfUJS+tn+rQXtjdIoyT9t1CqFgrtyxPV+56KtsEAZNckwrVZRU5lbh
         xtrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EIOU+fw3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c8sor2108084qvj.32.2019.06.06.11.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EIOU+fw3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=W85iZVgjurkkiB2a7Xxec+qLci2n6gFQqX8RW+I6lJo=;
        b=EIOU+fw3tMulwBY+jl6o/Pd7uN1ahiKKDLJKphj0SFrY3mGFeHTn1W2VV4oFCcXr7j
         cWmZ0gDNudc595ZVgI5l/RmqYCimcWM0wl22l9mGjVDztbCe051fJtkZna0E33TmapUB
         sttvDBWVXq87dQ+6H75k5wM3twYt5qFdBFS/o7++FbtFqaun0Q5YuEHy1UH3O9BInXzS
         pIETiNwzZOWJnzWU1GfKDiH4km5IjkASxVzt5h0rLlByvN4VwKEz5TKRl7R8CRCPPHgC
         iZGZpOcpwV/Xe9ToHHJdY4NMDuY9EmTPikVd4pQhwsuT6b7FpmiV8btfYq7kPkezkCcc
         rh8A==
X-Google-Smtp-Source: APXvYqwcFvSukVvOu/ecnBzPeUt++yQE3oiNuMCzOwlWEIQcAIcfXxOQH4AMIgicmlTTSzjQ5g0HvQ==
X-Received: by 2002:a0c:989d:: with SMTP id f29mr21429512qvd.209.1559846690185;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id p37sm1643204qtc.35.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008Il-PR; Thu, 06 Jun 2019 15:44:45 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 08/11] mm/hmm: Remove racy protection against double-unregistration
Date: Thu,  6 Jun 2019 15:44:35 -0300
Message-Id: <20190606184438.31646-9-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

No other register/unregister kernel API attempts to provide this kind of
protection as it is inherently racy, so just drop it.

Callers should provide their own protection, it appears nouveau already
does, but just in case drop a debugging POISON.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c702cd72651b53..6802de7080d172 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -284,18 +284,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	struct hmm *hmm = READ_ONCE(mirror->hmm);
-
-	if (hmm == NULL)
-		return;
+	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
-	/* To protect us against double unregister ... */
-	mirror->hmm = NULL;
 	up_write(&hmm->mirrors_sem);
-
 	hmm_put(hmm);
+	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
-- 
2.21.0

