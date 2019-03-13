Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 470D9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A02E2184D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:17:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="WK8At2Eb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A02E2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5AAA8E0016; Wed, 13 Mar 2019 15:17:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE29A8E0001; Wed, 13 Mar 2019 15:17:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F8F78E0016; Wed, 13 Mar 2019 15:17:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 614D38E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:17:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x17so3202849pfn.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:17:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Tz7z2N/5Cry04mDDSC73cwTs4v7Ec+Snj1gzzdXhPUE=;
        b=PN7gO/gqQ1kDqp9hOtUUYl898UsiAKeMk1tKosWKmeeBQmInFfVJOMV6E5eqLdEvnB
         Bavx5qC+pVyNdme2EopR2RXsjMaoOA8RaSr1Fu+kaVL8tmU+VmmhCSgAvlMODFIBv7a1
         B/n7fAJTXBgetAZryBIcri6RL743nYd+CnUsiQeg2xsH1b/G5sFT5znQCrXNWLr+XP/L
         oURga71RTYOVSAcaSFz/3ifURzhppL1eRFEIXU8NEfxSf3i4D/ArVd/r2n2ea7TCBxln
         PvpODSlF3LQ+5rIxOsd+wzHw8AZw3OnpTgPT8Arb0IY4/qw+bRz8N3bUn4vAk6ertmFP
         5hpA==
X-Gm-Message-State: APjAAAWld5tAztP7R9t2WnCIIQgG3BjLkQycdLBrmt/fXZMyTlbp3LTo
	5pXKK1n3+2hJkoApizqYe4E3Z9ybiF1c1WiVElaNjxQmBGPAAxlQzKGCnkGn9DtLN+9Nwqyk7ag
	7ZHFXX1uD/ZYd119jmTOlomu5hADaObG4BU/oOVq+p+YkfbKgpsT0sw8WrJrXZl2QFA==
X-Received: by 2002:a17:902:234b:: with SMTP id n11mr43122363plg.89.1552504652074;
        Wed, 13 Mar 2019 12:17:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRWADUssJC2XSgySlvrAePUT1kczBR1hV//82iDcOrjHTWrx9aDu7KxxBcuRxeyXZUZiE4
X-Received: by 2002:a17:902:234b:: with SMTP id n11mr43122324plg.89.1552504651472;
        Wed, 13 Mar 2019 12:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504651; cv=none;
        d=google.com; s=arc-20160816;
        b=QaCOZxEgeRPcSSHPDE9hQaTrrTt48xycvsM9QP1txHBiEA14Pb3KmlQbgCPW/E6bU1
         Pu4hstD40Ejsqb+F/AS33DvmqT3ft4Zyzv1DC9AYY/GT8U4yYUgwPpNeiWF5l84wASgN
         Uzb+VVa3AroNDRoMp/JNTXdDF7U16raQPD9rDmGc+7VlubGb3rss04FxRnhbkiWEVNrK
         7nz4jtetnSdeVVJjUfbABFGMQ+eZpnPP+1vVL4vKdAF/uDPcP4hyWR210rGOa3bCMliS
         Rl0ufTY9m6nozzwlXFM4xU1VmCam3Wc9bUZJ2EhlHYgA7TQYl/NKmhMwB60dhUEWtno6
         v+zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Tz7z2N/5Cry04mDDSC73cwTs4v7Ec+Snj1gzzdXhPUE=;
        b=dzaBZ8Ol0dQ2ylBUzg5fcq3cP5YtsH9Dw/73nL0s/e8jDFHnf0C6HJHq+Kd30n8elr
         t9kRe6webl8U2fr0DfBmMpfnNtVNsQb7nkxk9rEw2sxbIfk5D2f9WbilZ3fYC5VZ5LRl
         bJWwLZoOcXZ2XZaQYdHrhHxR1gBBmICgKefCUNFFSIR89txfVFSSMEDWfL/mQcTjUi5u
         l35618HUah2rQNRxmK4ON7HwOKp9cB9y8xDuBp0YWav7AhWqWN+p5+4ntEBxMX7io6pM
         T6CgRHI2tC0lPuwOKE4ihrpi2xra0EYFUbWfILvIRDhmXYW5a9Fk5xz5lcrFlb/9XOqu
         4nyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WK8At2Eb;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i65si11179195pfj.105.2019.03.13.12.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:17:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WK8At2Eb;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 557872184E;
	Wed, 13 Mar 2019 19:17:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552504651;
	bh=BHyHEAQYo2uAIwc7iAAUR12+1C4KpmFOrfT3VpjlfRk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=WK8At2EbHe7zIefBcpVB4hGB/+9Cif1ZBUcIDwnpnG0ofssXlKsxKF6QcofDzUW1u
	 yQ1rop2l0EvojywnCNFMbigwpbUYe64Vy2EjmXC0LWG5lHZOmDnuC0x8tqARFuD5d0
	 EwWGp4pyCLW6xKcQFAs5BSSakUImgoORfq5RgRwo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 14/24] kasan, slab: fix conflicts with CONFIG_HARDENED_USERCOPY
Date: Wed, 13 Mar 2019 15:16:37 -0400
Message-Id: <20190313191647.160171-14-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190313191647.160171-1-sashal@kernel.org>
References: <20190313191647.160171-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

[ Upstream commit 219667c23c68eb3dbc0d5662b9246f28477fe529 ]

Similarly to commit 96fedce27e13 ("kasan: make tag based mode work with
CONFIG_HARDENED_USERCOPY"), we need to reset pointer tags in
__check_heap_object() in mm/slab.c before doing any pointer math.

Link: http://lkml.kernel.org/r/9a5c0f958db10e69df5ff9f2b997866b56b7effc.1550602886.git.andreyknvl@google.com
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Evgeniy Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 354a09deecff..b30b58de793b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4461,6 +4461,8 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	unsigned int objnr;
 	unsigned long offset;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find and validate object. */
 	cachep = page->slab_cache;
 	objnr = obj_to_index(cachep, page, (void *)ptr);
-- 
2.19.1

