Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D27DDC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95C2D20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="eYn88Fgu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95C2D20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DEF46B0270; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08FBA6B0272; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC4526B0270; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97BAF6B0271
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so706408qti.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dvkFkBeOW+6z/DYza2/ra7fU7bkF8TW6bEZ+9Ch/ZO4=;
        b=M9MS6UX3cOW9vrXvXtLfmEmtTEickPNgtPSd2m9dRwCIhvKycetbe8zqSb7qFy1wug
         vX9ohmvxsHpfr2vd4BMO75UtDyuTf0WqO3bJyiznB+OX+5lvfKEMJubBCh+IVWSaWWXz
         E2FRYqNMSdeaozR9BzrlgXJYC7ryZjqPW3KqXriBBhGY3WPIpfycjrGiImGRfGIkEmQ7
         1cNKaSpQhHcJ/MFbxAfGM/a++alO0wBSexdSl32E8PvkKv8Z9sG2MNCly+LywCgBquCB
         hZugafhSMuUf5DkPl6mbnppJhYbivwxBEka2FGuZ04JBa6os9vKkkJ+ZKt1oVo6jksSk
         95Lw==
X-Gm-Message-State: APjAAAXICNtrF/DHS9PXCnjuAYKa9TNTybUpYp0dG66dc1Pzp+1m5AAx
	EdixC/jvN+/rvo+TOEfV1wsawzgMxZ8PNu/aBWTbHT+EnkGHX7P6+t6HHV438LN/YcSxZADHFLT
	My/mBL5nAugGGG1Is89TelmHYsHyjulwkNrbsW3LLQGWGhU1zWBMsOJaBLFQpbkXngw==
X-Received: by 2002:ac8:224d:: with SMTP id p13mr57455900qtp.154.1560473098395;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Received: by 2002:ac8:224d:: with SMTP id p13mr57455877qtp.154.1560473097878;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473097; cv=none;
        d=google.com; s=arc-20160816;
        b=DM9ueje5cRb9guKVmU97/QU5LSGSybIpF5/KGZ2fIHxD1uJ0bY4GqrX/DGvFk37jzE
         4yuEBLJqQW7aMabVBVKV6jgzOxNP3OT5Yy9hooeuR+SCzDhmFRTLZH+AlBgp25AiiCdq
         ULsLsvb4cUPi1Cqm51qXu1bx463uDkAfzpdjDzK4BQFLZPZrOL7KrF9XJ5O8uQBYlgYx
         4iBpWVxLJwYaE/g8fWCbIEiEdeqItjox1m7JyUgIOHoO0MSSOLRLN0iPt+aGEMDfZMQN
         tdg2E1TVf/igh01dRKO5U51NxxOtgixs50rcV9zNpElCfSlGGQ4JCfqhEENIkUi4VTuI
         LnLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dvkFkBeOW+6z/DYza2/ra7fU7bkF8TW6bEZ+9Ch/ZO4=;
        b=G2qkK27fBTlmt1t+4apd7hayw5BW0ydWN7ZKyLMIcOHvyzlxpd0ouITmMmZ+si/8ls
         GmSHpmeFjqmtZatNM1NLBjBurzetpgwBPa8KK++VTwlTXXUkcPxep26zcHuW5V3Uk68A
         11ut/rwlXpUnHHquU1giPy2c2yz8rbs2rkjXN5vmMYimNq05DbsSz1HFIsOzd5IRq7jQ
         pzzSoZEgWJBHwUgsu+YQaCogArz4R5i7PzkaC+uuiuD/o+5mAGRV3ULURF9UZETBwebF
         TeuuF9AbuWdNgajEq04GHtQQ/Jwy/runq8UXZRPOuSOOH3cDAxiR2GfJ2yWvJxwbCYDG
         5iEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eYn88Fgu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q38sor2362635qtc.33.2019.06.13.17.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=eYn88Fgu;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dvkFkBeOW+6z/DYza2/ra7fU7bkF8TW6bEZ+9Ch/ZO4=;
        b=eYn88FgunOZPk+YyYFR2JnEf7f2u6p9sflPJ4sT+jetqG8JYSyAB8le6N712NkSohY
         Xwi2VyaEkzxPEqC8yi2d5vTAq6YJehvf3luJZZZ4GvsaI+jdZ2gVqX0uxK3KJG8fUqJN
         3FvqnY5Sb8nnX+WQ++LovwzB8U/d4qUmUyh+DIkLwGIxK2N5g7LSrT+GUNIoWzDFfVad
         ehBIjCCC/XRamOtEckjvwtqZSft++bwMX6ZPisONHj3wc7uPh1GqiR5ueIOcNZHjO+1j
         aWPQ70BMw6QV6bP5mmW+tRl6mOixqkIWqtgj8Ext78+i143gu4SmwIuthYXP1wzIHsDP
         faQA==
X-Google-Smtp-Source: APXvYqwehM/5YZE2rHAarSGtvnt4dD381MX43AFO3OEKYtZwTgDkAYkIX/giHqXAhpmFto1vVdJqMw==
X-Received: by 2002:aed:21ca:: with SMTP id m10mr72204568qtc.97.1560473097656;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o27sm688657qtf.13.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005K8-TQ; Thu, 13 Jun 2019 21:44:53 -0300
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 07/12] mm/hmm: Use lockdep instead of comments
Date: Thu, 13 Jun 2019 21:44:45 -0300
Message-Id: <20190614004450.20252-8-jgg@ziepe.ca>
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

So we can check locking at runtime.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2
- Fix missing & in lockdeps (Jason)
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 58712d74edd585..c0f622f86223c2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -253,11 +253,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
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

