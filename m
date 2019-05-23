Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C9A6C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E8FE21773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DZpq16KC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E8FE21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612CF6B0285; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C7126B0286; Thu, 23 May 2019 11:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BDAE6B0287; Thu, 23 May 2019 11:34:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 081DC6B0282
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g14so5645821qta.12
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sVSVMj7qtVOG+pR++xGbUKEq7rSWx5vQVniXU7xAdVY=;
        b=nsirG820rrA70nESiqISQ30eV2KK9vSLUW60UkBqvma+T5FpqaHm9ZIIA7IcdzOeuj
         VEc4Q0+Bea7cVThWVRP+9GJxj2pZ5+zS8sOQLbnnng4Libqv6hh7fwKhzqXWOSTKtfE9
         A6vkYg7d3JTyIfYY0ZHAB8V/y7mh8NuwBz7+MSq/nnemagrkHPeR2L5+qia+HfGoo4Er
         nv4K8O+BKBRVRKoxoRdcYoXHeQMje8bHNjx7s+kLfiCisBXHGAgFTd5bPhupko2tSvNh
         XY2+r30uO88vp9tyZIHU3B/qdoV4OGyt0ZwVHTYwXP4W9eAfthdOiXAgH+ma7V5U41KQ
         NPlw==
X-Gm-Message-State: APjAAAXmHMyYaK+UEzxQFcmlD1PZiZx3VuVU+m9Q7jNVXptuOIuPYuDn
	vYfXw3WDDNqOOhf8c3+goOGnrT/pgel+H6STUkj+IMc63cPOuKUl/NtIIL+U2r22SbESadzQ1js
	gJDKly3RmScuKCujaosnGP8eAIontj9JAaZfwjDrhCgjEWhpUwGut43o0srIS9qV3hw==
X-Received: by 2002:a37:6855:: with SMTP id d82mr69485897qkc.130.1558625684792;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
X-Received: by 2002:a37:6855:: with SMTP id d82mr69485823qkc.130.1558625683997;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625683; cv=none;
        d=google.com; s=arc-20160816;
        b=SiB5eBVNNoFum8Iz8HorhmyINWnBhzhn1Jac7WfeexXyJ3TMMy4049xirZwngKIB3h
         lrSGndje4iyBwjjoae4iOn0Vwlp5WQgidi4aBvWUL+A/57fs4dl32RrJh4Ujwmn4D0l2
         rudRl1hGEL2jj1CWUu5cb7TlOgasfwMFO9bRskE08UNbdarZBoZryrKGLn55hiBYHDCG
         hVr89eP8hnxaU7w15FEPBB/XlBsEJcO6HJGcOosg4Fl/xP41CADA1qAsE2eEnkXytGv5
         LEQNVveEbDUlxgdFDF2anQF6lcopXbA7q4hA8KE/DhPAz/t6DfGD0UWeIJPakmHAsDrq
         tbuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sVSVMj7qtVOG+pR++xGbUKEq7rSWx5vQVniXU7xAdVY=;
        b=FQ/u4DrG6zTHu6LXFwG2EDLbJ8jGnDx/DH26DYK7vBp033kpHGGo20VRb7oM1+AZ3k
         E+1Du1RvtxYvrVMMA5IKMcB5jBioPIXUClqIADfK/a1ZIYeCWoarIDs3kq3OHrdtTc4K
         i4xl5zYZr8i/fxEi4LnjvAhWcy7BPql6xAqmLA6jjOmvdwPEU+M1i6qGh7OA/flsHrFE
         gRe687TLET8LW6/X9gyZejd0ioG/+L0P0alDNjI/zGhh4ecwGtALirVAXkhPN+6eAueX
         v1cVJ0Iek1OYE/V4+YvGEaOKyUZhuPjJ839SRnOaM/QgsRSPLe9GonNatq9UuKRtwS7h
         73AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DZpq16KC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j53sor19746022qtc.40.2019.05.23.08.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DZpq16KC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=sVSVMj7qtVOG+pR++xGbUKEq7rSWx5vQVniXU7xAdVY=;
        b=DZpq16KCBGWseTw+Emu3YXxJ4qAUUBYOgC5S+OOEj/qjUePnCbs18YftNrqI5k72oF
         PF78BOqbqq6gsqFCloyWSHUujhEA6iLhbwmuZW+tDHMvYXyKsgXqWsFKUjift9trNwPn
         rqocr9xDbYrprtIAWRiT7tiljZiU9eyK5kUSizlvzHsiN4QQ+GhHFIt7Cl39+kytFtcP
         YEmfFYaselG4ky3Uaic1er6GJoWtkTtMUKSq5/K7iPHbfWN6p8Dto2g7QzWwkTANGhkB
         ROp6hnDt0PpHQofzdaPfaC8krT25q9BBGFxfk+c0x0zYuBd4O1EiwzV88vfNmYBJAYQz
         bG8A==
X-Google-Smtp-Source: APXvYqwlZgmvtDLezrwrAV3Bsq4rJxczbRVrNsIiCVDFfpxHEZgg1uH2yntWWMscbHuucZ+UF0vtYg==
X-Received: by 2002:ac8:18b8:: with SMTP id s53mr76217130qtj.232.1558625683755;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id h17sm12879104qkk.13.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-000509-Bh; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 11/11] mm/hmm: Do not use list*_rcu() for hmm->ranges
Date: Thu, 23 May 2019 12:34:36 -0300
Message-Id: <20190523153436.19102-12-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

This list is always read and written while holding hmm->lock so there is
no need for the confusing _rcu annotations.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 02752d3ef2ed92..b4aafa90a109a5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -912,7 +912,7 @@ int hmm_range_register(struct hmm_range *range,
 	/* Initialize range to track CPU page table update */
 	mutex_lock(&range->hmm->lock);
 
-	list_add_rcu(&range->list, &range->hmm->ranges);
+	list_add(&range->list, &range->hmm->ranges);
 
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
@@ -940,7 +940,7 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&range->hmm->lock);
-	list_del_rcu(&range->list);
+	list_del(&range->list);
 	mutex_unlock(&range->hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-- 
2.21.0

