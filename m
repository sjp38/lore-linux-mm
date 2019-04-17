Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D092C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55E8720674
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:25:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55E8720674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC85E6B0008; Wed, 17 Apr 2019 01:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E511A6B0266; Wed, 17 Apr 2019 01:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1AB76B0269; Wed, 17 Apr 2019 01:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA116B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:25:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id u16so2254054edq.18
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:25:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UDJJoD0qMDqsEKa5fIO7G8qbJZY7SvtJV8LUclcf8SQ=;
        b=P81WpQajIivj1mIEwqj18ekZXFOhMNKg87EdoxRCBRXyS6tOqv4I3DdBqLj/vR0Rx0
         hTEwsi3re+7qhxpPb0c5LrZAUjZ1exFx2Ie06NRU3WbB/0/AwCAf2Ajz0eamXQ+vVnKJ
         uiFG2kKJvSLtmkpvmf6PdtaDx1PqLIsaCtsn/yrdI0wIz6HkPBnnZPZHRtTwgVIVsSgf
         krZEDrjBAHaIgfe7Yrhxv9UC/7isVAI52B6ILLsluAGXnksV1UQySTj99C/tKO3MH0r7
         JK5r7DN4QPQzPH4uVmqqtK8ttzoyDkGYZcIZAixfZfyYhbFs45WnurXNlHVN5OICzovs
         BltQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXOqs515qilXemhvtafS6jTjL9sLXCuX0Hn4sByItbIfF04lBvx
	omUIKVIGJJJ0wHvooTYQaFTXGilMd0hHPtsq4ccxLIdiSEWA7L2wKRJpanqrgd5lUaG3LNch9aK
	CWtkP0LgDOH8DkKWs8jeDbPzBNJZKUHmU3F1/TEXYDZx5PAFBeO+miwDA6T3okH0=
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr2530221ejm.185.1555478705947;
        Tue, 16 Apr 2019 22:25:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfv02vOETR069SY4BYmR/MPl3ISoPu1IU7G59wGQ5SfDZugR/Uvz6O4E/kWJtvJEzfml+q
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr2530183ejm.185.1555478705123;
        Tue, 16 Apr 2019 22:25:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478705; cv=none;
        d=google.com; s=arc-20160816;
        b=Eg1Sqn8yF5MJEvH5Zm6+WajMFoBFkApER6JRT/+IUxgPOZBi/JSnaZk4+gVDvb71Dm
         nanM1iMmIZOcQ85cxkkbihXTOLnIKs/Bmdmqr2CQdtjZEzCe0a89xabYAfCJXxNGR3ao
         WUGb7Vwb5qmFyNhSFzabndiwipNWGNjCyXxJl74B4uyNFpnBm9MqvBXLgCO9MTkwIFuf
         lJuSnjg0NjX7tVt+KMWbdlfNvh+F7jrM1UCROQ5L/CTFVc+mnkMgvgokQjhoW2/STn1k
         qO1jr1tpdkQ1EIXJ991RLFmxjJWsy2lW+9BuD0B8wL8wDN6zyHsbZ1g9NX7TuT+QrY7z
         Thgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UDJJoD0qMDqsEKa5fIO7G8qbJZY7SvtJV8LUclcf8SQ=;
        b=YRAVXIwjFLnfcAwobhqqM4ueA8xWrAdmgmL1TA4famJL6VbSmm+YguO/HcJ+pfvCWp
         +sf7NjOLFVTxZoxHRukzievATw6KaaAYgdFLRQfYGqhap4ii4Xg67yxXiVOAX8beMcfS
         Ug/QT01f4lt9w3kCRbknhxQDh9SLuakwpne6NkLyqxP3V/zGD84SORPT0M+gc/ApJpUf
         nzk7JFAE40r/mXUFu1XRUk0wZRpvxcDd8xDJiKdmFc/ypeJtkdo39g1n5ZwRl9zFJf4o
         4Xo3zfuI+Cgu1tcyUOETjZ5X+uqfI3fBIm3jII7sMi8XNYVemfLpPZCJqIKHBmIVEYgH
         rP/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id e9si3077855eje.110.2019.04.16.22.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:25:05 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 61127FF805;
	Wed, 17 Apr 2019 05:25:00 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 02/11] arm64: Make use of is_compat_task instead of hardcoding this test
Date: Wed, 17 Apr 2019 01:22:38 -0400
Message-Id: <20190417052247.17809-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each architecture has its own way to determine if a task is a compat task,
by using is_compat_task in arch_mmap_rnd, it allows more genericity and
then it prepares its moving to mm/.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm64/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index 842c8a5fcd53..ed4f9915f2b8 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -54,7 +54,7 @@ unsigned long arch_mmap_rnd(void)
 	unsigned long rnd;
 
 #ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
+	if (is_compat_task())
 		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
 	else
 #endif
-- 
2.20.1

