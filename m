Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1976FC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE41C20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:45:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dyouVytY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE41C20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 486536B026F; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435D86B0271; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28D6A6B0273; Thu, 13 Jun 2019 20:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E45156B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:58 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c207so645909qkb.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qJP3s5LCTJOa2Bpv3WsF12kBeuFb/g7s2rVIALekTDo=;
        b=bQnaDIl18YZpYEmrZfK0KhxIyd/TI8FphJc+j2k18CkxnqPBV3gr99PmPgwcYG8yGq
         ZO4KcnwFyxiSb5kVLxxMs9+Tr66nRXOnagWODasTL9IMc8nRhhIfhL8fIQtbMcqW93za
         C0G1VPjjL/2QucOEW2pKVg1+8N4nyMWYFchyfWc1AsG1SfrD7wDQtVMb7RViYMeMjbzo
         f6MZPvcUZ75+bZ3pA6sX3jgfPHwA4zMWM5Pv09ZWl6GRbWjmP4Rl8TUZv9ZJ7hseSEro
         DvjE5fXrSdd/7x219+QuDHYQ6ueRGOe0ziVgj69J6/jkZBvgFeW8RT+jf3kJ5EMoNyoe
         gvcg==
X-Gm-Message-State: APjAAAVHv9RknFHGRdYQ+nou/r4wGEk+qjuHUSFY9ZlDZprwA/Ngit/y
	m9AFif9OnY6GR5a4XoMNtWw8bIi57Wi9BH5CMrkyuAgFsajAVwKO7qx9BR+MNXxFPpvyr0oXIuS
	iTt3R77VEtsRiaOlAjo1Xw4VmGHaRbmr5U9tiKq4GAUo2H/QCEGTLmKdxjeW4to/7xQ==
X-Received: by 2002:a05:620a:152:: with SMTP id e18mr71948262qkn.101.1560473098711;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
X-Received: by 2002:a05:620a:152:: with SMTP id e18mr71948239qkn.101.1560473098175;
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473098; cv=none;
        d=google.com; s=arc-20160816;
        b=jbEvCUpC9GITi4VbaLZxY42BCz3OhBpSVtk0sUTpqpCXLTswC9JAf0x3nlGkuh7rdH
         rPzYgfNyv76UpQ4pVphJ5d4b2xYNoa8ZGoGJT3C8pIMLS2JXmrPTWD13itdrmjsTvNJ/
         0mv1oDn+b2GyBsZngjjq9UUognnpHojBktVwqTej2D7iZBjpBtjha+ESWxbUnnCf5XBr
         XRvnefJpSXCjp8Lz/AmJdMC/Jark/feDQoVxETlIRkaMjAdMjN8q4r7L8M/5bOsFMT0H
         e7UQxfHg32z41aHqlh20u3mEBMN4cccpA6YH/JeWAGhudOajuRFt+DdRKb6eOAZEAEeE
         9lpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qJP3s5LCTJOa2Bpv3WsF12kBeuFb/g7s2rVIALekTDo=;
        b=a5bQFG4F3m76XRce2wVx/sHADOHzL4rWmmrT9BHcs6lSQTFUqUCPK9OKNbS/1xFhBE
         94KF1xaSJqf9hUJUBXQGvO8y72A87jDJL+5/Wv5nS4XdAj3sUoNjwpcJjsy3eMW46RTQ
         fdLwKKUS9QtsA5X4vhKl7l641x/PuPDS8FCl4vF2Gr8QWTK9AQhUyYpYNP7FSMnYDkwo
         ngK7mMxw648SvIzNGwWqTDYUxIrHKNEGqhucnkl/jjpKCDBDG8bi13RRJ6f2rl8Gc6Js
         w6xdLT3bM/uzLA08YzWOoyqpQsZfb526QwbPguAdZb9EFvRYW49p0sZEMQoaHnvuPsuO
         1Fgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dyouVytY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 136sor1077907qkm.23.2019.06.13.17.44.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dyouVytY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qJP3s5LCTJOa2Bpv3WsF12kBeuFb/g7s2rVIALekTDo=;
        b=dyouVytY+jmXKdkQ6AEcE55kZQEWs6bscsYHu17tMqMjO0ykbKjOyu4AZmogdzcKOO
         okRY9yuPH0h4p3cAV4QrnZ4n34NPuyuK97/dkGmB3VzQKnqK9s/XAJtvvIAGZkXqI8Jd
         kp8Bb3YU8e6ArRWr/jcI134rAI1zQOreSW9nSzEGghOTmJk/pJslGcpZKvhe05E8ekCA
         wMSMERjmVYizkkeqJXXp4Y3n+nU+hNQwdsuP0lS3FbYfoYhnJGG75bzPsyyRZjGeXB24
         rhFdNEenuxIK01r0M01cZSie0WszSDebNOB+aFhxWAf9m8Ut+WvZhCrUuTgOing0GJS6
         L08w==
X-Google-Smtp-Source: APXvYqwYuZdBUIyBE3tnoT2pvasr4EEIwX7YCMbTNFDbznpFFTMobqSAyRGm2KIgVEvCZYbf+NYJww==
X-Received: by 2002:a05:620a:144a:: with SMTP id i10mr72376829qkl.130.1560473097962;
        Thu, 13 Jun 2019 17:44:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m21sm498643qtp.92.2019.06.13.17.44.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005KE-Ue; Thu, 13 Jun 2019 21:44:53 -0300
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against double-unregistration
Date: Thu, 13 Jun 2019 21:44:46 -0300
Message-Id: <20190614004450.20252-9-jgg@ziepe.ca>
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

No other register/unregister kernel API attempts to provide this kind of
protection as it is inherently racy, so just drop it.

Callers should provide their own protection, it appears nouveau already
does, but just in case drop a debugging POISON.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c0f622f86223c2..e3e0a811a3a774 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -283,18 +283,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
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

