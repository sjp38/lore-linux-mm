Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 047ADC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5FEA20872
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="PxwcFgRp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5FEA20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88EE86B0281; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81A6D6B0282; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A6626B0284; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 344656B0282
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:50 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s9so2863440qtn.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GDhglHPFaykanjjoF1gAri47ISjb+fimKQAKOR+h9MI=;
        b=tO4FD/SbHgiETxLGb9hLMpAwzlHPiZHkk0+0wkJibu2dgPrDC3cX5/k850N6ngjB5P
         CnYfy50/9rUk/kLoCepBZdk1baGcvd87SrmwxwAIT8dSXdk+WxwvikByXvJ3FNIy5dBJ
         7FLglnDyvwMqxpn8h/gnpOL+1yrgedr/IlMhZUq6y4lokzPX4vKPO4ChK4HHnAsI7Ujv
         7zMfQWHZ+gn/qYZEahBvg8etA6OP73t3/GV5zjt1Elk1m8NdRM3TANACMLLkWLsY+CyJ
         SnIw+7qItAJqQnIBysB8lXtBquxR0VI68LYwNd/v7z1IX4BPZ2U4gPlUKcV/lmCKvNbT
         MIBA==
X-Gm-Message-State: APjAAAUHCYoyZHTbuzGlRa9aSVIZ6VYUjhDq9BHZ8iCOW++nbzPb5fpZ
	FAvIR8KIs+lwdh2szWpUkiKe6sFiN4QHhtVjdk1znsbDLz9qJ97eCWoQu5HXaeJtDAUHGyjSXei
	h/zW1Zj7QEc7jDW1ITkSyFPdWYkNs4qi9xmGb8DhOaviMLWpKg/vpI9TE3HuhA8afwA==
X-Received: by 2002:a0c:d604:: with SMTP id c4mr40051398qvj.27.1559846690000;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
X-Received: by 2002:a0c:d604:: with SMTP id c4mr40051358qvj.27.1559846689293;
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846689; cv=none;
        d=google.com; s=arc-20160816;
        b=xJW0NbnkGBRTP+AlZMbMyibBV5NnWze1mtRqICpJ0weC54uCMYqjzlUO/CaVvr09ey
         H7Wyij8J1R6FMa+jjA/lQ5yXHNQj9pnEqJ0YVwdsWR+VfjwryPscMoJHALblKWXvL2Vy
         rD1M/M0Veyv86Jv+QhfhoeyjgI+HD5CmqSmNlY7MzaL/oCCb4VEcZdA1H0LHlInHzIex
         J0NwWV0Hogt18GXe7oLtjiD44RMfyV4fi2LRa6kxAIRHGy5VWd5hiNFPjumSKt+nWxEq
         qGrC0jhi5nuDnPc5PVLJyUqN1oz3bbiNl/ngOBhxkWVq2FG6QAhc7gj1VzqUZ6QV+Qzz
         8DLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GDhglHPFaykanjjoF1gAri47ISjb+fimKQAKOR+h9MI=;
        b=wMT981rFFxjntoBzu+wQTNIIBn5R4xsK4aQ9WgrZmcj1PrTXYqzBfvlqa0BWQ9DAne
         SfilKSdJodi7cE8Yv/CrUGBZ6w9EgjzG5eKwzwGgN0IDkx+bAmP9ZdPxMj6JNUI8YFap
         9vodllTTPou17ntcrZO6p9tT7YegmjwIrw8BenI9JJKVn3g9wYb3jE3l3o4YYE8fkOIM
         sLf3uFkmpxOrzdk+Xx7vmAJw5bIHvx/fID2e7ktcpxUva4Y1qxs9XadZTn0TlIQdk9sV
         9ukwBMrKCnTWOKAyPqsDCzk5+2ywt5Lon1j8THdDMWA0asooi8xxSSYm30PgAuGz6Zxn
         SIsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PxwcFgRp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j34sor3178805qte.42.2019.06.06.11.44.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PxwcFgRp;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GDhglHPFaykanjjoF1gAri47ISjb+fimKQAKOR+h9MI=;
        b=PxwcFgRpu1yKtgG+aowdw5x+8tofPqN/iG+sZlMS+1BEgLEa2wfuOLDwkMIpgzpwcd
         07df04JSrSYFDPlOBaTxTsHwx7kBZmstHd0a4oVfpGuC/g/Bhpf3Lt5nSoYeD6uPrpsQ
         QII6+kEeEkW/MUSdxlhOd0i2T95D5HdQdwlL7Ozqf48joL6SQYTkyLT5peB4+TMiTij9
         aIRgom5VV0qkHk9b2ZOSyXv7P9Z7i69saCcXZ47LPPfmx+ZPD9nsxaz5ycev8w2P6F6R
         TEDZZY+v7m2CrZJVilSqXEyPa+l6AO++F7IzKVzBSzLlDLqpq+DAzeUJPhu5fEg2sxO9
         4usQ==
X-Google-Smtp-Source: APXvYqyc+KhO/w9mb/yqATHQoXsEv3qzyCLAVUEuPTK/WR5bBDKxmiMb1le/dUnjSV/gm3c3d4B8Pg==
X-Received: by 2002:ac8:f0a:: with SMTP id e10mr39961260qtk.325.1559846689071;
        Thu, 06 Jun 2019 11:44:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id w34sm1260252qth.81.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008If-OA; Thu, 06 Jun 2019 15:44:45 -0300
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
Subject: [PATCH v2 hmm 07/11] mm/hmm: Use lockdep instead of comments
Date: Thu,  6 Jun 2019 15:44:34 -0300
Message-Id: <20190606184438.31646-8-jgg@ziepe.ca>
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

So we can check locking at runtime.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
---
v2
- Fix missing & in lockdeps (Jason)
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index f67ba32983d9f1..c702cd72651b53 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -254,11 +254,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
  *
  * To start mirroring a process address space, the device driver must register
  * an HMM mirror struct.
- *
- * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
  */
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 {
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
+
 	/* Sanity check */
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
-- 
2.21.0

