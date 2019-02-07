Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF81C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18A38218FE
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 05:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18A38218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AED618E001C; Thu,  7 Feb 2019 00:38:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A97DF8E0002; Thu,  7 Feb 2019 00:38:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 912178E001C; Thu,  7 Feb 2019 00:38:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37A6C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 00:38:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so3850706edc.6
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 21:38:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XjTZPZGlz/MNyU6aOr7ZZyAeRmtbqpb7D/yFa34GyFM=;
        b=c/rH5aPmeNNOxD/hWafdxz0VIFueeZtlcBi/aaCnYzZ5QTuHOblvlCyJzV/QXFLowp
         R8mq1BkmH9IWoEOxq/KaLhjYGCOzseA5eHzkeHeVvW1l/pGTug8XsA3xieto3llRuuUu
         MLSWN7G5Psxh2yc2ZY1lHggXXjfAK21ctaW0ytfXoj/6dbaPr6QTAM5VSaI5WtAyKcf9
         ws9sA4mKsYJRSzNs06bGkgiHlnLSN9Ms49OGGkCrK9h3P8aW4CpjoT+VS/VPJXq/ubII
         lcTolSYrYZKRlgHP3svugbMaGC7DhpU1JyinMxlDirXNw9XP8WYGyqMgwCyi47o25pXD
         CfNA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYOcJVSWnd7XriN6L6CDWVEdtd3tvnK/CLc3MATAcfcls55ssKb
	ATNHjqGCerfK2jwMlpLFfg2DCbXu1LodGr4Qc1a3MQYpmFjwPlsZc15NiaMLJWSz9mWchhp0uhk
	sKo4Qy+Z9Nz30+YLradnOPFHWyGW+uAhWEHUem84tbkVXhFtN35xQGDEspMDbQpo=
X-Received: by 2002:a05:6402:1347:: with SMTP id y7mr11043750edw.114.1549517918729;
        Wed, 06 Feb 2019 21:38:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKqzn9IEpqAR0mtnlI+yD+9akH08xpX+yV1VfxpD++69kTjTULOPByjODy8fhwok0jXIbK
X-Received: by 2002:a05:6402:1347:: with SMTP id y7mr11043707edw.114.1549517917858;
        Wed, 06 Feb 2019 21:38:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549517917; cv=none;
        d=google.com; s=arc-20160816;
        b=F+O0tRxRq7v4/108uPOJUfxDpCmcNNEV4cv5kBccOn94g8nI5eFyoIuRnWg9HfClNp
         mvrwIJ44D61Q4P8Ansf/N7pdUOCyZXb/AC76Nmeg7PMbw70vO2X92/Yg73juTrColJwG
         85kbDKvXco5EBSajwdmuKu/4HsehmKO6sn0KqHQIRnDEOkuZoP3FPF7m27bc5QgEPxSJ
         IwQ3CV+xkUPjihAuINpGNU2b/jjMSjT5DS7qEcCCWky6aEIVKEJRP2AsFcXTxMLtgnQ5
         6hUALeLLdwEwG0xd3rh6GcmHkhY5gnHpGRvGJkzGT9fzx+szc1zTaIjiyVT7qkPVD3I7
         yzMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XjTZPZGlz/MNyU6aOr7ZZyAeRmtbqpb7D/yFa34GyFM=;
        b=z2zH2QDv0Rd1tkEUXXo0ehjQo5RBq/DqSaiSXB8f+6gC3IC5gr1R4IIAFNJKoDjZqS
         /p/6wd7y+0i9UKsZaoCmigTKWsg0DywbjcjWJkI6ycRMMMMzjEf7WO3L8PXTA6DubKJa
         3fmZh5NqJCo3JmxVOtqzMUZGYkECgqTTUpHBbEQ1UiTQZdX6SZSACLZdL++PDw+dhue6
         +6dfr+lgkvZGDbJKPiWQTuBgar8MPus26fllCSFJ0u8y8K+H21mg1pqpkt7VUVl1tzE4
         E7hLFytQ0CPVzwzGL/zIRSHs+2GhSK7pVH/lvDFvQ2/MkErb/OK4uL+d7p7cTWzeYdnv
         xuVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id b17si1362602ejj.243.2019.02.06.21.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 21:38:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 06:38:36 +0100
Received: from localhost.localdomain (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Thu, 07 Feb 2019 05:38:05 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	dave@stgolabs.net,
	linux-kernel@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 2/2] MIPS/c-r4k: do no use mmap_sem for gup_fast()
Date: Wed,  6 Feb 2019 21:37:40 -0800
Message-Id: <20190207053740.26915-3-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190207053740.26915-1-dave@stgolabs.net>
References: <20190207053740.26915-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is well known that because the mm can internally
call the regular gup_unlocked if the lockless approach
fails and take the sem there, the caller must not hold
the mmap_sem already.

Fixes: e523f289fe4d (MIPS: c-r4k: Fix sigtramp SMP call to use kmap)
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Paul Burton <paul.burton@mips.com>
Cc: James Hogan <jhogan@kernel.org>
Cc: linux-mips@vger.kernel.org
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/mips/mm/c-r4k.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index cc4e17caeb26..38fe86928837 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -1034,11 +1034,9 @@ static void r4k_flush_cache_sigtramp(unsigned long addr)
 	struct flush_cache_sigtramp_args args;
 	int npages;
 
-	down_read(&current->mm->mmap_sem);
-
 	npages = get_user_pages_fast(addr, 1, 0, &args.page);
 	if (npages < 1)
-		goto out;
+		return;
 
 	args.mm = current->mm;
 	args.addr = addr;
@@ -1046,8 +1044,6 @@ static void r4k_flush_cache_sigtramp(unsigned long addr)
 	r4k_on_each_cpu(R4K_HIT, local_r4k_flush_cache_sigtramp, &args);
 
 	put_page(args.page);
-out:
-	up_read(&current->mm->mmap_sem);
 }
 
 static void r4k_flush_icache_all(void)
-- 
2.16.4

