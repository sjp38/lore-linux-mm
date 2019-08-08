Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA0A0C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74DFB2186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:21:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74DFB2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE896B000A; Thu,  8 Aug 2019 02:21:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0894A6B000C; Thu,  8 Aug 2019 02:21:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6BAC6B000D; Thu,  8 Aug 2019 02:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97CE36B000A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:21:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so57549541edm.21
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:21:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=21mhY1F6D/bVN4FBUSB5kLGwxQH8yFVmkExK3y72E74=;
        b=U79cHAGvgnjnvcQSQOn7WvqZ93ofeFRBCBr6TAt/Ptb9y7dBF5JoYo68q7RTR8SF3t
         Wg9DIQqTBJt8xisREQ3sReGYJ/wiS5j2Oy9O4Wpb0xvnuZJeBE9iVVjlgRCYq/gOiUP4
         LpZrwu7I0ChB2DrE8yOsP3BY/f5qonMcDkSKgi84owe4SL3tAHZrCcMZdSx+qWRl6+8B
         pnTFH9jE3A6nIKZlJReCupvKgBOV1B1p5/woHZDLPrxYcTQJpcxOBdYn29SjQzI3slqW
         h1zQ3gbGc8jAwzySNYn4GJ4RLAsLSrKz8d1W9GlHeu5nSXhvlY9/JjrjMD0UiVvpTTkN
         ru8A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUwh5YKgHv6grbazc6x2zHBTGykMRygVVasR9c1+0Oh4bnK3ovf
	3WMK95sKt0fHt4bT6SmeaGz3Rf/pQ074c8MUhgjnMVyf5Xt8ZUivlOp7JGbILVvvZLdztHzvELd
	0zfoENrutiTFibEmsuUz8WcNafZac6hMUDN7RJp9n2L2kM98X/7ZhNQTXumaP12w=
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr11404720ejd.99.1565245286214;
        Wed, 07 Aug 2019 23:21:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylSeSOi03vFwKwaVl6DjpEgsqVcgkgm3y6lZ1tFobF5mYINLJuhsORAQYT5o/Z5OWlEKtG
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr11404689ejd.99.1565245285486;
        Wed, 07 Aug 2019 23:21:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245285; cv=none;
        d=google.com; s=arc-20160816;
        b=XwZl+pr1RKugAzque+KKFDKbtFNSk0HisV/v7DvLDfXMTTgoYNWZgS1c1h6wZlZFbT
         fbOlpYpT+m1Q0hj2QUMuLO0+dSGDh6Y4zC5gj1O/OCbhKKaJREmydHQlg0dx/xAJK+t6
         6Hu/OQFHdOdzn68pSSu1Fk62gPE4eV9bjP7RXgmZ80bL9s0XxefHfa77EKPdQCgsDalC
         W+V9NzNTrcbNb16nFaOkTeRdJZkiU93dSW6R82iXFJDGZvTpoxA9E1zQexHb1d8CtIIJ
         CchbGR47QsU5XNgZRhYfPHpfqLoo3MXJJDvoPpHrzv03SstHtYxdBVAXIIeRQ2zFn/RT
         Fj7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=21mhY1F6D/bVN4FBUSB5kLGwxQH8yFVmkExK3y72E74=;
        b=ww6UImYPceBLRK9Phg/OfLBytuTOEIJYvXS+CDAWUqhuzAp1DUOGimr/g004uCGA83
         U3SoPn6eiGikb7ahZrRJXCvPyB7NMvOI3f6znpY6OeYsWknLXalYbUa9rZkfRkVT9WT/
         t+h24V6kd77QNUCSq7CB5e4eBzUkcKgut+Ft5aUQYXKwcBcqhYRY/Q8xBavfLsBoeO5u
         ikb+Rt0wjEps1cK9PqZLLntaZMHXtp2sarTAkRRPt+ErEEMgyFDIoCjUASVsv3Yc7nMU
         /TMuhkpNE3euv6joZARZsZLKwnjktiDSQRg3qfVGrAwqloZeF3mLjmqlD5Yzj/WeCfRH
         0m1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id nq5si30507286ejb.124.2019.08.07.23.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:21:25 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 1AE39E0004;
	Thu,  8 Aug 2019 06:21:18 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 03/14] arm64: Consider stack randomization for mmap base only when necessary
Date: Thu,  8 Aug 2019 02:17:45 -0400
Message-Id: <20190808061756.19712-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not offset mmap base address because of stack randomization if
current task does not want randomization.
Note that x86 already implements this behaviour.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm64/mm/mmap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index bb0140afed66..e4acaead67de 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -54,7 +54,11 @@ unsigned long arch_mmap_rnd(void)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
 
 	/* Values close to RLIM_INFINITY can overflow. */
 	if (gap + pad > gap)
-- 
2.20.1

