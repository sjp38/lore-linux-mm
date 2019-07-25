Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E925C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED0722064A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="fUCU73su"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED0722064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F0288E0035; Thu, 25 Jul 2019 01:55:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99F8F8E0031; Thu, 25 Jul 2019 01:55:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FF28E0035; Thu, 25 Jul 2019 01:55:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2098E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:55:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so25626421pld.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:55:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uEzjuY+xrs1gxfJkRlgVH6ex7tEhwAMuVuUkA64XteY=;
        b=eslRequ7NCkzaEJLzf1ZNb1jqFtTw5TgvbUn8Y/RYvjeU65/fbQ4T1KLgB8JdftuwI
         MZIe4lO9LNz0iHy03k+OS0lWAvSp9QvnTwpUrOOlhcVrLDr4aJhBk+aPeM7TXT65ezGj
         wOwTsxOiWJLytGvEmuZXmRyk28nSHcCKKEoUFM8LfVN8rL0+MvPHa147KW94HJ73osLi
         GbK/hX3IYXupetXdnwogX4RU22el5aPzRuGTc2uun687cJEKhhVlJ7Tw1C2SoZ7zwvIR
         yDYOwGfKxEo7O9MTyFsRzki69/HT2kWR0AIEP58alEYQRwJzuOANV4RZekqrS//xqRwT
         J5XA==
X-Gm-Message-State: APjAAAXTO6N6LFnCDw6nTNcDkN8itJOn8fqakA4vmQyqCLJ6p93aiA6p
	e2Ld7TJeCzA86y6Aypxu448uJyZWM4uSGhzNuOx9w1NmTjL1TDN5Y8FU8VO320lPYNziBwx7rQN
	PS7vYtGu5IIrparx1a/vZfKQMDbze1vEApz/sdm3PIIaxAhldsWbEWetPMN9Isq4gHg==
X-Received: by 2002:a62:cf07:: with SMTP id b7mr14994716pfg.217.1564034130922;
        Wed, 24 Jul 2019 22:55:30 -0700 (PDT)
X-Received: by 2002:a62:cf07:: with SMTP id b7mr14994683pfg.217.1564034130156;
        Wed, 24 Jul 2019 22:55:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034130; cv=none;
        d=google.com; s=arc-20160816;
        b=Ndoyo1iYCzrWec4kKQV1ueCUqHe3mFV9icPDVJPj3s1/mdXiBgtdARJY6b+xQ4YJGH
         yMPEKmAVkjLPsJWUGP5KphEMSrF+qvVfHhI+b6y3jfkOwlDD881qd2SOpmA/F3IPHJzB
         N+SJEx1SfT5mmKRTIxw9c+L6oZwu8EiFLrHvVFsr4GUY2niERjRu/T1osFYsnCgkxCkV
         dVpW8+fYV8zoEqVzTbNArAZKIJJqvUVFuM+PWSBQv+Ur5Tljs4UU4JatraY1WBJh5xYp
         cPq6pD3elWMb4yNyPvpQs+pM/0kI4NeVKD8x7IE01OGO0qO9ZP6//i7ZSyqLqRnBA+6D
         9JEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uEzjuY+xrs1gxfJkRlgVH6ex7tEhwAMuVuUkA64XteY=;
        b=XVume7zqIgbHV2IFioITl6Dw7IrIgS9W4dZ7KCnCi4OddMTUXzTP3S4fV8YpnBuEY5
         cLQBwkvi/02IeSmdIiy5UzdMKejrdCZp9TjgM6vqkZ7c3iXtZfAedn9WzqjOm+Xaoccw
         K9/z4mXog+p2tKhh0YpD/ayCh5YzNxV9WKQFlgCGQrpNneyXWq6aWkmQABNRVYRfGmYT
         rEIoehh6q+7/sv21Oa7usFSrZyfQa/R/YH3jT8A177oJoq15L+GpsmytF7RHZwuybbwF
         Y6PilnwkvYFgSFdF53aXGEFr4wsXHlOQLM8g532oYDbQC44Z+FrpGrM1n8Ll6Airs4SR
         Do7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fUCU73su;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f41sor59202584pjg.15.2019.07.24.22.55.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 22:55:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=fUCU73su;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uEzjuY+xrs1gxfJkRlgVH6ex7tEhwAMuVuUkA64XteY=;
        b=fUCU73sufuz7pngPFfvBxrLPvfhAn++p9SdbYahXJI6VqwYxcibmOnPDoNn5m7wRjg
         XFD7NvpCkVLiv4WGtYhKTcEIXlOKCHAwS7uqfXxTDQSDvMnMrai6m+O2j5UMFTHAXv6H
         pRV3cG4PjWpP0gZZTDVJueXLhlShPNRt2Of0o=
X-Google-Smtp-Source: APXvYqwe9jlCsG4A40FbUWlEW824w4BPp7Y2pULQntBlkxBwEQZWbqov90M6UZC2o/Y+eY0PmVb8Hg==
X-Received: by 2002:a17:90b:94:: with SMTP id bb20mr92504004pjb.16.1564034129834;
        Wed, 24 Jul 2019 22:55:29 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id a5sm41554212pjv.21.2019.07.24.22.55.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 22:55:29 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH 3/3] x86/kasan: support KASAN_VMALLOC
Date: Thu, 25 Jul 2019 15:55:03 +1000
Message-Id: <20190725055503.19507-4-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190725055503.19507-1-dja@axtens.net>
References: <20190725055503.19507-1-dja@axtens.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the case where KASAN directly allocates memory to back vmalloc
space, don't map the early shadow page over it.

Not mapping the early shadow page over the whole shadow space means
that there are some pgds that are not populated on boot. Allow the
vmalloc fault handler to also fault in vmalloc shadow as needed.

Signed-off-by: Daniel Axtens <dja@axtens.net>
---
 arch/x86/Kconfig            |  1 +
 arch/x86/mm/fault.c         | 13 +++++++++++++
 arch/x86/mm/kasan_init_64.c | 10 ++++++++++
 3 files changed, 24 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 222855cc0158..40562cc3771f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -134,6 +134,7 @@ config X86
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_JUMP_LABEL_RELATIVE
 	select HAVE_ARCH_KASAN			if X86_64
+	select HAVE_ARCH_KASAN_VMALLOC		if X86_64
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS		if MMU
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 6c46095cd0d9..d722230121c3 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -340,8 +340,21 @@ static noinline int vmalloc_fault(unsigned long address)
 	pte_t *pte;
 
 	/* Make sure we are in vmalloc area: */
+#ifndef CONFIG_KASAN_VMALLOC
 	if (!(address >= VMALLOC_START && address < VMALLOC_END))
 		return -1;
+#else
+	/*
+	 * Some of the shadow mapping for the vmalloc area lives outside the
+	 * pgds populated by kasan init. They are created dynamically and so
+	 * we may need to fault them in.
+	 *
+	 * You can observe this with test_vmalloc's align_shift_alloc_test
+	 */
+	if (!((address >= VMALLOC_START && address < VMALLOC_END) ||
+	      (address >= KASAN_SHADOW_START && address < KASAN_SHADOW_END)))
+		return -1;
+#endif
 
 	/*
 	 * Copy kernel mappings over when needed. This can also
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 296da58f3013..e2fe1c1b805c 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -352,9 +352,19 @@ void __init kasan_init(void)
 	shadow_cpu_entry_end = (void *)round_up(
 			(unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
 
+	/*
+	 * If we're in full vmalloc mode, don't back vmalloc space with early
+	 * shadow pages.
+	 */
+#ifdef CONFIG_KASAN_VMALLOC
+	kasan_populate_early_shadow(
+		kasan_mem_to_shadow((void *)VMALLOC_END+1),
+		shadow_cpu_entry_begin);
+#else
 	kasan_populate_early_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
 		shadow_cpu_entry_begin);
+#endif
 
 	kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
 			      (unsigned long)shadow_cpu_entry_end, 0);
-- 
2.20.1

