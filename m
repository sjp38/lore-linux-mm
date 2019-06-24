Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62A3CC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:33:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DD2920663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:33:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gMJNqHRI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD2920663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78846B0007; Mon, 24 Jun 2019 17:33:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4FA88E0003; Mon, 24 Jun 2019 17:33:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3F8D8E0002; Mon, 24 Jun 2019 17:33:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 593C76B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:33:07 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b6so6917187wrp.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:33:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LXLRo2PPKRMD0FsdNO4kvH6cJWSg4ysuh5L5UkxtS4c=;
        b=RL6e357Oo0qdKw2VDAEM40Xk2uEOTy5Kz5oJwwFTPesWT3N9h7vHH3nSoxeWK+yc5X
         4DXw6zC1UU7K76Z5kdbajFHhB5T0QFkUuq0C+IxEwXgI4k1qqCX2o8+zbtw7XmotKwS1
         JATHrVvXWrHCg+/AqQVLygDSjv1gZYKfEqrEl3CiI6CjZYRdYm4/TtEmD7NsaJUhCiw4
         RAUO7hqpEUW9IcyiTHX4X0736PITM9j9p9wFXo2FM66PxW7mMhHT+5d0tjBRDyG1nGmh
         RA4Ld0sjGGKHlDG26RrGLxd4HXt0jev7uwQqUTiFVYfTKR/6B3WCLvi79HcutZPJL2dx
         e09Q==
X-Gm-Message-State: APjAAAV1Vg5Otqn4NdATDhoX58rhyEAPnKr0KuvI4YS+ZEdrS+K2BtN8
	21MNto6WDsrYcmfNfx0GCuQQ+DxnQNXJSAh7gwcR3gH+Yb71uCF1auWIgO2wy6FczkIgBpgQHl1
	ArpAmVz8FHQsDoVvBeAG0qiu83o1BHI5ADJObe2xn4h/3eBg81jbPvbNr071K+nyJ1w==
X-Received: by 2002:adf:cf0a:: with SMTP id o10mr33570695wrj.37.1561411986784;
        Mon, 24 Jun 2019 14:33:06 -0700 (PDT)
X-Received: by 2002:adf:cf0a:: with SMTP id o10mr33570668wrj.37.1561411985967;
        Mon, 24 Jun 2019 14:33:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561411985; cv=none;
        d=google.com; s=arc-20160816;
        b=hMg6f9rHEo4HnFXNTetWHElhDPWfCH0W6ZUWU+hQIsPIbdS8H7xoNHYM34Eg0CMXcK
         2AL5JRuum7RwOErbUoLfUDA+/jf9C5VDO3/MEVaW6+1dTUH5n3BtmdUqrWjEndrSVb6F
         uSE3QRMpUgjw0gk8qQ3/oJ4FY1DETFndkz90O0rw69x7n5Mn5XmBaPEbokT+ZXYS559Z
         W2wlt4KP7LUTvCWmwvt/LOrAVVsv2qAn+CLDcOMBVfYIxQwtfxFILeQwlk99tfNUuply
         U3WSM3vMIHgyHIXDdc0e4O03KJOoXvG+NKIlqN5JJOqiEyaQMtcA22EcAd2/+/rikCHF
         fEAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LXLRo2PPKRMD0FsdNO4kvH6cJWSg4ysuh5L5UkxtS4c=;
        b=lkD1kvhCweQ2WYJWLIG5gtqb/A5MKOxwd/dMKUSI8fYnkDr+PxhbODYqyS4Q9EOuXd
         MDw/2TxxXwsHl00a83Xle/5EmX6kFq9Dr7O4Y+rgsuPQa5BISA7KQhrFpqR5ernuSGlf
         84MCwUC2hssOIBnac7F6wnasFEOvGU6Rvr9pvRcHdWyO0v9eA1Yc7VZ2dWHPrPuxo8Vc
         u80PwLCNgQls0edUbNXO2sRetMlFy+NsyTJJuX304K76W8mWURyfbIS/hN0Txh/8Ktd3
         CPJd4MOLI78OFK78fAQksXIguhjgIkb2LwPD7lHrLOuuSMcPER7fbmO9pBEic10FThsr
         dfiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gMJNqHRI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u18sor391242wmm.18.2019.06.24.14.33.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:33:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gMJNqHRI;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LXLRo2PPKRMD0FsdNO4kvH6cJWSg4ysuh5L5UkxtS4c=;
        b=gMJNqHRIngzsRcDJSRqNGhhAFj5qszbwfHp7sWjkREH0cC5Wg+51IUv6Ztnp6y1sQJ
         4s8sZl4zFkpY3KIjUkN7OCuNT+5pVhM4Z9P2VYMGh6zz+dgJPGQTFMmyTF8pYefOKxHb
         RQC3U3vsTjMnbDULYbk6PEP2Dr94o6uyCpK8jOxwldZdOsr7VxS3+nUpYxsCXash5XQk
         7PaTVmaPpwPfDGC4tTkJn+amRntW1ha7ej9YjFLte5PbAElDu2HZyg7aDGR1mtYjhEC4
         a5es/TsjfPiC+icZkrWdCKcFqlYMm30vlAIazLUZsF/W2Ct6q9aWO4iYeVJJJbe9l0jw
         3AYQ==
X-Google-Smtp-Source: APXvYqxpgSLdOjxG4AEMzxa4goOMrAbz+ND9ASIrtQwBg7DrjmWk1TBdaulquFyqhwOqbOtHtgBWrg==
X-Received: by 2002:a1c:407:: with SMTP id 7mr18250094wme.113.1561411985569;
        Mon, 24 Jun 2019 14:33:05 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id r4sm18908060wra.96.2019.06.24.14.33.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:33:04 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001MR-U4; Mon, 24 Jun 2019 18:02:00 -0300
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
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <iweiny@intel.com>
Subject: [PATCH v4 hmm 06/12] mm/hmm: Do not use list*_rcu() for hmm->ranges
Date: Mon, 24 Jun 2019 18:01:04 -0300
Message-Id: <20190624210110.5098-7-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <iweiny@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 0423f4ca3a7e09..73c8af4827fe87 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -912,7 +912,7 @@ int hmm_range_register(struct hmm_range *range,
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
-	list_add_rcu(&range->list, &hmm->ranges);
+	list_add(&range->list, &hmm->ranges);
 
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
@@ -942,7 +942,7 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del_rcu(&range->list);
+	list_del(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-- 
2.22.0

