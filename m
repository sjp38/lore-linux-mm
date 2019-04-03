Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60A4AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB3E2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:33:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB3E2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC49F6B026A; Wed,  3 Apr 2019 15:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD3DF6B026B; Wed,  3 Apr 2019 15:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4DED6B026C; Wed,  3 Apr 2019 15:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 891486B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:33:35 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id a15so132970qkl.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UDx0XcOY0ZN0vAPqmojaKaNgTIVOXpxM0dk8s8AwFyQ=;
        b=NnYHtv8Rh1V0HcGN9VIkpLT2T/v377XXBjV6seqzVldfn/KNb+MbwU96inas/fQp6M
         50c36ChVYHl5T9pc6ZlZ3dMY1lZ0mGlJnJeKgtn4ehSOUEIr2OMwJRvz4nKaaxJDbS1o
         f8DwLX8/4BwpMLXVvw6gX56UC2gE+yR7PQIgKI5G1h2H35BtqWEDI3xcDlpfogAZE3kz
         s1PhAsUC5qQlPW6UwVawWANWi008YEb4px2gm6v/x//VY18iZMCQ4Zf/HuIEl3/yKMdc
         SiU8/MtwCOeF3qocnxWTAgPGPXVKkiA/rQmNXzrGYJXBasx6rmydYjbVBAbUHLoIkPbH
         yVUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWG/A8cVu9pxi2F4Db3u0AuJleiJ599SDaTShhzdPKPUjbw970b
	ZXko0HhkvB7W/BHN4U5oI+nOJ/zxVwQ/lgs8Kv+hyc5RgZ1p2J9mEB0tQqzTMdrkWKi8Qt/iL1U
	CNJWsig5gj8HtHCzmRIBkuI3xPGemXSLrUo3WVajTmW1YoJNL9mTv/OZqw7J5hplmJw==
X-Received: by 2002:a0c:d849:: with SMTP id i9mr1162828qvj.207.1554320015333;
        Wed, 03 Apr 2019 12:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+X9qp/eozZhq1gwce701VmRcrPSAKf7GnJZbKyKCPTH0oInw+UMb55X91FNDP4EY8xTSP
X-Received: by 2002:a0c:d849:: with SMTP id i9mr1162597qvj.207.1554320010982;
        Wed, 03 Apr 2019 12:33:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554320010; cv=none;
        d=google.com; s=arc-20160816;
        b=0pORkpabbo1XRzl9yzjrHDtlXfu1AwxpVtBYgBPxDC7LfNcdMmMnDFxi0niB9FYfpu
         wascAjUEYEPR/NjMkVG5vlXzrIynZq3fTyzHrf96SHXoCr5hLpe0ibLciO4Cr6H/5uGK
         k4WgHzfYM3hDR3Z+l7d2Tf7KkoCup7KYm52jQmK9OkBio8n0UirpWrc+njc7isrG20gs
         gz6ecLnN1LBprX0wrbOUnyVcF/DSonqRaj7K6dRggtyE8HCeIqPyaV4w5Hxwjz8W8R3P
         mnWUP4pOM0qXh7fsA5wIiD5X/5i/spvlBh3QnnCCVgJ7A1X2qVx2addVYYsGfzYpYB27
         Q9PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UDx0XcOY0ZN0vAPqmojaKaNgTIVOXpxM0dk8s8AwFyQ=;
        b=PJZuRk6BcnjJDX2lKLfwecbX2iu0llMYVxu+3OLO35HOF1EOSmLuWMoqUvSs++QmZj
         kMIANnzMrfn6XS1Z6ZJcfj6PrN1O6IwenBPAi2lUShzgJ0Nz+P4FBylwUo+fFoQLRTWR
         USoL/5ydc1TIpkrTIKikXUef09pPztAoD1hrOa/BHcIba/twn/C6k6WJzlN9rjSwboB5
         tIcfsQPvaqHTd26ai2pvq0Kp0EfScwKtm9FrjL2Bge4oeBs1co8+gewvkukkoE99ulZB
         3GXqIXl/qL6c8IsnCk01W1ZwEQ+YV1c3L32+L7yt8A3aYIHJnrQK4Db4DH312iRS/gJK
         cOHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si6497722qkb.201.2019.04.03.12.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 12:33:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FB2987624;
	Wed,  3 Apr 2019 19:33:30 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-125-190.rdu2.redhat.com [10.10.125.190])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3FF8F6012C;
	Wed,  3 Apr 2019 19:33:29 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 01/12] mm/hmm: select mmu notifier when selecting HMM v2
Date: Wed,  3 Apr 2019 15:33:07 -0400
Message-Id: <20190403193318.16478-2-jglisse@redhat.com>
In-Reply-To: <20190403193318.16478-1-jglisse@redhat.com>
References: <20190403193318.16478-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 03 Apr 2019 19:33:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

To avoid random config build issue, select mmu notifier when HMM is
selected. In any cases when HMM get selected it will be by users that
will also wants the mmu notifier.

Changes since v1:
    - remove select MMU_NOTIFIER from HMM_MIRROR as it select HMM
      which select MMU_NOTIFIER now

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..2e6d24d783f7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -694,12 +694,12 @@ config DEV_PAGEMAP_OPS
 
 config HMM
 	bool
+	select MMU_NOTIFIER
 	select MIGRATE_VMA_HELPER
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
 	depends on ARCH_HAS_HMM
-	select MMU_NOTIFIER
 	select HMM
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-- 
2.17.2

