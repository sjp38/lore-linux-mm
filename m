Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AA5C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:03:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F7D020850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:03:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F7D020850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A6526B026B; Thu, 11 Apr 2019 14:03:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 054EE6B026C; Thu, 11 Apr 2019 14:03:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAC626B026D; Thu, 11 Apr 2019 14:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8BB96B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:03:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x58so6374197qtc.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:03:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=8J9fw/5KcumUfMxmqt75E7CG7dVNV+nGFyw6PXr6yvY=;
        b=K+Lssvo4vDsO6dGKTbQUqZ/Kq5uHYH6VCjZpsHr7R4wEnQK6wofLWQktPkRJzQXsfe
         wcoqMunw/mIxzylenPbziiMlaF5XBGkQodvexKqDxLJnaf4Xqp1XESTgITSl04u9zUdd
         /nGu8dABQfib+PM0o1h52uz6bYWKdQElgX2+n9UlLGsenvbPynQaGncdH4+QqPo48YLW
         8z08wWNbDtxe9uJc1RavbcEAOyyyWaV5r3RLMoEujRFevZ1uwNXyHrnlUouzy2aCfP6i
         3hskx7bB87ahnsVPKt0hW+wLzcGfBigJxUpKTLZg6lePw44RIEpDsDPZFW8SiJaBeZxR
         swLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW9L9NPkN8dB6+4GX5RuKLi8tWOc/3gxfwwKgagmTvIsRqikS4v
	X5NAL14Jt7b6zVCxYld1rj0RNAJ3uMjCuJELvWbx+Kx+zWgMCv1AJmygaW/6GlktsGck0olSsb5
	imWXd8PdiBgM7xwQBCFytod1ooadVuOsKW+6X9RoP51r647sXsjTEFQdb8byT6qu1Yw==
X-Received: by 2002:ac8:3789:: with SMTP id d9mr45079160qtc.34.1555005823574;
        Thu, 11 Apr 2019 11:03:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8FdUKjo9ey/zKfU1pvAFUSKl+T6Sx7GYxM8ybslkVnRstT2cTBBf6ZqrlUFoSnvVxAeCw
X-Received: by 2002:ac8:3789:: with SMTP id d9mr45079105qtc.34.1555005823045;
        Thu, 11 Apr 2019 11:03:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555005823; cv=none;
        d=google.com; s=arc-20160816;
        b=f4YLwlNj4O87A2uCffYxUSnPjUEsVYUGMzXOHRjcYboA7CIZ4cniZzjyNy1Bv0rnvX
         J35Fcqe97FGKUWulTTTGqJ7nGTuRfeBQFfZtBKg3javQq/qGnRN6Pztcfzz5htv+IhUa
         OKmi5wFjOVPz4rcxMiWjYk9D/Ge2sehHgXkvsVdxLFgkLRmeFD/ldxQn72O3L73ghzUh
         MzCQphMonoT3TUSjz4QmcOMw+FfB6bHVnRctTzfkbqgh7Q13hih49NL7D/ImYRa5OUZE
         vuxE4x0nGi04N6sn69m+cwmMr3iSQlOdiI8My7doMy7GM1aJulittTOtdkBohbhbMLts
         Co5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=8J9fw/5KcumUfMxmqt75E7CG7dVNV+nGFyw6PXr6yvY=;
        b=0xTHbt2S/rwikNUi/evN9grMkQWaFNY/0lPWs0Qunx0IxvZYe/pJ2vQ42H91KZTCPL
         W23FAVXZQVjBi7oFRidaozye/NP9wViMoQX7xYxttBFUqveMrZjOYIzIQj+CCwkSekkw
         W3hAb6GX3EANvuusjzsjMv4kfznURmbmuq4tfNthG8uapn6PLuYhk5evBmgv0UJDX4j1
         /fseYeWphz2/Ojw9uyND6/louF4fwT8jd/M7bhUxiXgC3H9jB2sV4fZGHQqVz1t1PXSE
         M9P9PbCsmzL0GeTP2si79eKJUvRxC7IqjN/wxHE3ytjnQIEYp6BIl/J941PXPPp2wOVs
         tRKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a77si4555591qkc.262.2019.04.11.11.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:03:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C43581219B9;
	Thu, 11 Apr 2019 18:03:30 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E94405D9C4;
	Thu, 11 Apr 2019 18:03:28 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH] mm/hmm: kconfig split HMM address space mirroring from device memory
Date: Thu, 11 Apr 2019 14:03:26 -0400
Message-Id: <20190411180326.18958-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 11 Apr 2019 18:03:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

To allow building device driver that only care about address space
mirroring (like RDMA ODP) on platform that do not have all the pre-
requisite for HMM device memory (like ZONE_DEVICE on ARM) split the
HMM_MIRROR option dependency from the HMM_DEVICE dependency.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/Kconfig | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 2e6d24d783f7..00d9febbc775 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -679,12 +679,13 @@ config ZONE_DEVICE
 config ARCH_HAS_HMM
 	bool
 	default y
-	depends on (X86_64 || PPC64)
-	depends on ZONE_DEVICE
 	depends on MMU && 64BIT
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
+
+config ARCH_HAS_HMM_DEVICE
+	bool
+	default y
+	depends on (X86_64 || PPC64)
+	depends on ARCH_HAS_ZONE_DEVICE
 
 config MIGRATE_VMA_HELPER
 	bool
@@ -710,7 +711,8 @@ config HMM_MIRROR
 
 config DEVICE_PRIVATE
 	bool "Unaddressable device memory (GPU memory, ...)"
-	depends on ARCH_HAS_HMM
+	depends on ARCH_HAS_HMM_DEVICE
+	depends on ZONE_DEVICE
 	select HMM
 	select DEV_PAGEMAP_OPS
 
@@ -721,7 +723,8 @@ config DEVICE_PRIVATE
 
 config DEVICE_PUBLIC
 	bool "Addressable device memory (like GPU memory)"
-	depends on ARCH_HAS_HMM
+	depends on ARCH_HAS_HMM_DEVICE
+	depends on ZONE_DEVICE
 	select HMM
 	select DEV_PAGEMAP_OPS
 
-- 
2.20.1

