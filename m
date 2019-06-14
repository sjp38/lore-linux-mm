Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDE1EC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96E8020850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="fmkDVzgS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96E8020850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6844D6B0272; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FCC06B0273; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D6CF6B0274; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023466B0272
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:45:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v58so732771qta.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x2xcZ0hUzEe5obPQKOQJn2EFwkT6zfHmS/ojlfdj62g=;
        b=IggjAGeOwnSmGbaPpkQdZWJfEvKlQiCV+sdWcYZYtPsx8c1XuulvcT1D9mPYZsGmza
         XSG3Vj9q1wsroP//rnaQjto3BEnfZbueCFSJW3HFE7arkM4jHPvifZVibX4mAwI3CpXd
         s7u0oIGblbcqmcNe1uFCQeLolnTUQvwYqwqk1Kp0SGUJuWyy5MRKB6EoQOjGG/+OPOJg
         AoV7+l+mpoMmwpy6Avna6ryU5gbp3UfHAl84cyhvKLJ9VUp5p9C4H3AGHix65eqx9Heh
         xYQQ5LA4pv+4mwg3utrmV0eiX/cqrTCWzuIp9t8Ee1SKRWxyuPnn2osMmdWLrJGf6cRE
         GVSQ==
X-Gm-Message-State: APjAAAVhDeP3Har2+kintKtWVs3tvz2oJyPp5Kpag35GCHuU8WfAXJGv
	GgIZWLDuWV+CTW/72moK/yGc/3IytwubAX0mUKU+TZ7np3G3AyHzEf9zlxZtX2p5qNT1cCha6O+
	PcVR/0NnfbPpnNit13dLn6exmSotO9AOOsusypC5z79T0yGWPWKzRjJVQbOAf3dRs/g==
X-Received: by 2002:a05:620a:147:: with SMTP id e7mr72760190qkn.247.1560473099774;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
X-Received: by 2002:a05:620a:147:: with SMTP id e7mr72760171qkn.247.1560473099240;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473099; cv=none;
        d=google.com; s=arc-20160816;
        b=CUR0TfA3K3vfWeZIs7st+ut8PCNZ07pJRZFW/V4UQgwAif2KWkvFWo5ngvCqF7VoAt
         +sDHWA1vkpCR2KDBNCNIRssORnAlBPTw0Z1OkLOuOmfBFJQtCyPKi4FpOkZwrQgd+ZPv
         pwUEwiN63IB6dqwsIFBvNC7vp8hO7CfEl3YS8N6NZ+Mn5I7JC8iSTFMdEoDRTsz2WF4R
         eBGvPbZBSxO8zxRByPMXaEUdau2iUmXyXVE7ygzRUuem8zzKvfDlSq1gNe1wlGqK63T7
         4yQPKgSiWmraeySPKWoRmadYQItMly+70QzBzK788cA72TT6n5HzBLGxqGlSlippSJq5
         XulA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=x2xcZ0hUzEe5obPQKOQJn2EFwkT6zfHmS/ojlfdj62g=;
        b=ruaOOkho3g1o3z92j4gOLmvzbxwGJETCy1X9AVkpXMU882YcROucZo7L7bBSZzEWMW
         9cDXs2DSU2jJ6/cfdhuOdbtRjxP0sYeAXtif91ALq0K2sgyYJVwXConjp0DdgtWpCP5l
         IAMfIeiNjU3j6bH5CBW9mNW7gAv7Ny+pbCrGfcmlxqRZTzcmxgPZkvk52UlHxllDyS20
         2Muc9qCndQLSBg3FMj1TR0+5TmeR3+MX35CiyypwmsAUCRkS4O3dkSLNzC1QDkfiDbQJ
         j55CDCH7jI07hQVYmCBUsIixkTGshA9Tdtc2QlWTS9Cq8953XUIzlol1NjieIC+HZaA2
         yNWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fmkDVzgS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor1033422qkd.102.2019.06.13.17.44.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=fmkDVzgS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=x2xcZ0hUzEe5obPQKOQJn2EFwkT6zfHmS/ojlfdj62g=;
        b=fmkDVzgS2vVrdEiIFYVAnbf6P4BATGmI5DV7vsT+OeMjI4tAox+P6sovJkfdiZ77nO
         TT+3owVCCkhWvSGoSNguAk+3EcblRkw7UWgxiYOoQUIg3Krv9JVjCiJAQm/Z0vfo/EQO
         KilEhiFU8QK10vlLGWCYF1bTI+QT+GOn8FgfKnRlLwynY8K2mvFNbldzrI4Lge3bpnfB
         LwwdBdhl/qwje1Wf18PrfGX26/MhvkXIgT48JtyA/Mh0PWYhgZzhVUdAvgS8HFf+7d0p
         m4F365LJ+Y/0qG+JXDxYUTDe3aQRit0hcrauKtBkjsXKtLtzRJ2lxMjKyKDLXCmxU6K9
         9xfw==
X-Google-Smtp-Source: APXvYqzCPZOcBvdDvO5A/+aWYFKA+YngTOxLtxM859wIOaaSHbD/Xj8J7AD4AHMtWoKrqY+ZKezZsg==
X-Received: by 2002:a05:620a:1661:: with SMTP id d1mr13812583qko.192.1560473099006;
        Thu, 13 Jun 2019 17:44:59 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q56sm978355qtq.64.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKs-0005KQ-1j; Thu, 13 Jun 2019 21:44:54 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ira Weiny <iweiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 10/12] mm/hmm: Do not use list*_rcu() for hmm->ranges
Date: Thu, 13 Jun 2019 21:44:48 -0300
Message-Id: <20190614004450.20252-11-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190614004450.20252-1-jgg@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
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
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ira Weiny <iweiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e214668cba3474..26af511cbdd075 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -908,7 +908,7 @@ int hmm_range_register(struct hmm_range *range,
 
 	range->hmm = hmm;
 	kref_get(&hmm->kref);
-	list_add_rcu(&range->list, &hmm->ranges);
+	list_add(&range->list, &hmm->ranges);
 
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
@@ -934,7 +934,7 @@ void hmm_range_unregister(struct hmm_range *range)
 	struct hmm *hmm = range->hmm;
 
 	mutex_lock(&hmm->lock);
-	list_del_rcu(&range->list);
+	list_del(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-- 
2.21.0

