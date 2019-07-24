Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC5D7C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88E08218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:01:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88E08218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C5306B0007; Wed, 24 Jul 2019 02:01:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1748B6B0008; Wed, 24 Jul 2019 02:01:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C538E0002; Wed, 24 Jul 2019 02:01:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF59A6B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:01:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so18424756edv.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aZSsJFYvbjj8QOQUi6BNWizJJ333ywVv4QtORhWQawg=;
        b=q8k9wnQeAy0eWA9lfhqBrMCUZY+kmQzsCBTdILAYYV/GosF9CyxL5MzwgRJPKVuB8c
         62n8go3ccIo2rAgc0kCsKS9ujDB2p1bvT5MTXf0mZYwR22OWj9OM7nAOwp4nLEHbOArL
         3lNbtHj2Efi83y6HGSji+piVSgcumP2G08p9E5/tvLC0dflfojZKQN++szTRJLwDJVKr
         ot4PeR7q3kBLn3UtthO04D2w7zZe7e4XIN/RoJsMPbqic3iwXU1zwWTAAWSu5XITb6Xp
         iVaPdh8zrPhqLYvFqtWOkvcXFr6ZjDIi+MD+gODURduXWs2wRql6L6sQsvV6qlA7XEsp
         HoGw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUB4ZoYwqf7RZHDyRos7rECgkVdK9OaPSLr5NjIXSRG8/JVIgpG
	FH7u4ExaMWgYakFni917/1iPEXW8alcVA6+CNUNLLiCSzK/9gSZ8ZM/mM0wNuNvrK9rHcaR/hb5
	oKlFZMi7t/PqLBxRzEurmCINDiDGUvwUXR4t68gKQYPnA+aFZEzgZ7f7aPwnJ+vA=
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr58876697ejb.55.1563948076062;
        Tue, 23 Jul 2019 23:01:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAYuNVYJla+HC460CqwdCtKBU3JH+w6qiHvVJ7vKCuZWZ/zkMp/UdNY9usaIp68/x0K7JZ
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr58876642ejb.55.1563948075070;
        Tue, 23 Jul 2019 23:01:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948075; cv=none;
        d=google.com; s=arc-20160816;
        b=jgtJ2IeBBuoPOLmUgdNcho7gkEpIJGNWljIEWXDnREKgT8CZRTn4A9oGByeGj2KcEm
         nuWK7eaDUn6guzkO4Cgo0lFnTiuJe5LLxIPAUDUbyp2bX3tYQbMBK7I6X8D+rgpfU9zW
         xyEb735Z+p5vkjSFb2kIah6mz6ya8rlf7Fv24InWsyODMDnita0jchVBAsOvzIIg6f6K
         8sJJ85seT2YsbxjEozI36v3Y+7I+c36v0ZClPJSCZlY+p0R905lkN+/dein7UCg3wvaA
         B4yvH7dGHZm9b7oi5FzNG6TjhiJhVyP6kTvs/R4/ngvepNN/nLoBOH9vZnFSfbdebdJy
         5vZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=aZSsJFYvbjj8QOQUi6BNWizJJ333ywVv4QtORhWQawg=;
        b=gSJRVBEfNjn+tqpU6sYmE5c3n8583XA6Ox2V39eC6KaLoZwGfxUCxBqOLv3gfMyELf
         cpUMXbBOvMmbguYzomo3TRkj+fUlwZh3rQL6i11SIauSt/7slT1KDLm+wAtzPm5QbI1P
         wgWRnfxTza/NxYEi7JuAfdAYxI1ls/eXcqhusMcd6DtHFcIU4KMk2IRnN3Hz8gJGdZYm
         jnQEARijJMdQ6kAxrXgiKAT/763nBmdKb0c94EGXqYGbbY2nuS3vnne8BSQU5SV8+lVE
         YMND7iYbIDSVj5TtwQvdKrXb94I2c3ovxXfCryYkHq/+SmRqq+STBSRvenJdHlvRl26d
         m4Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [217.70.183.198])
        by mx.google.com with ESMTPS id nq5si7000999ejb.124.2019.07.23.23.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:01:15 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.198;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 05075C0002;
	Wed, 24 Jul 2019 06:01:09 +0000 (UTC)
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
Subject: [PATCH REBASE v4 02/14] arm64: Make use of is_compat_task instead of hardcoding this test
Date: Wed, 24 Jul 2019 01:58:38 -0400
Message-Id: <20190724055850.6232-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
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
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index b050641b5139..bb0140afed66 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -43,7 +43,7 @@ unsigned long arch_mmap_rnd(void)
 	unsigned long rnd;
 
 #ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
+	if (is_compat_task())
 		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
 	else
 #endif
-- 
2.20.1

