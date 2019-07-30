Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B48BDC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A9322087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:59:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A9322087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 241518E0007; Tue, 30 Jul 2019 01:59:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F2D38E0003; Tue, 30 Jul 2019 01:59:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA758E0007; Tue, 30 Jul 2019 01:59:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B24B48E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:59:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so39623916edx.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:59:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WYZFBi/mDjw2AHO/7J+UsrC2CAAthlR5mqmiph32kXg=;
        b=BGCfhbweHiJT01yGaec2i7T0VHrVVApnqQ7au3jU5hvr3B7tmQyZ+iXampfJBBxWF4
         1Q+54KZ/xAPkqnGGOY27FTcEtfSMgwhOXXiqke9TqZ6UTcaYFNiUjpROiuZP8WvdUF+0
         W8ey6eGIaXd11EEY9AxUs3Cd0n+9tkYV5xiSFgw0/4h0T2fznmxeErE2Lo+KCzVRFPFO
         loK/fBDgybM/WBTS6gtIgUrNSqb9kIxXV4xTjCQweSKcEsn/DGFW3xzrj9jvWFbjpPyA
         +1Y9JwW9TJoN0LyiZgbeEd+/HHor+OzVTn2KrHzZchzbWTRKgqemVJ18SjV8AcQ14vnp
         7Fdw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVkgCrwfgc23DKVnJim2oSxcubI98U5krWhCTvTz+vowbIRcrzr
	w0TLgG3h5gDcSNNy260WiITqUgS0Kll6E7ycEiAti+sUUnLbxQI3Gy9e8s0LF65X7YJsmwYeLyb
	+sfNJMz8DQxG93/rl0StGdJpo/4h6twjalbteh2mDzfhBqTIt4WsJ0704UvnxGPQ=
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr88739426ejb.68.1564466349306;
        Mon, 29 Jul 2019 22:59:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/BzKvIyetov07il2Kg1v6FLrQ8sh/qMqY0/NLKJ/VvhigsqW6JL4RMg4fJBZalCx6s8O/
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr88739384ejb.68.1564466348378;
        Mon, 29 Jul 2019 22:59:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466348; cv=none;
        d=google.com; s=arc-20160816;
        b=pA0zuqLD2rTpS/dkeeRtZXHO0Fw9QKuZ1XX+nt6LPXC3nVJ47UfmLYE8WIA75UUZ9B
         XT/pT22sa67GUAKTttVBSzjLtBL+9lVAvZzr6LFJSCeeNiPfNblKrgykgQvuxu+X+IGw
         lAcXRTdI+67+WYHKafxSIcQiBXDgdGUyUyHopdaUd+Xk16DlApfsO8w6tLBncm0dPJs4
         Z7epOb63E+lyXzvmNxHWkkN0GBQUHd/x+XkmaYp2cFQFeIn0Bv5vp+mBTDa4pwFw3KkJ
         cCAP7LGd4ub5ZMpLtXJlt7oGPuQMG3ANb+B15k5yrbcj9l1c2DAvFJXXlrovL7wEg4qR
         eXpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WYZFBi/mDjw2AHO/7J+UsrC2CAAthlR5mqmiph32kXg=;
        b=QMXH91/gIE7Rze4UqJUD/Y8RAZ7v8ta+CtOihusOXYgSaz4Eb4D7Cn2TOslbWUz66l
         dzqkesJnkCNt7VlCcN58Lu9FdBnspVcYDpRLyf/K9FqwHIBxHG0+7McPH6Zl2NkRwHSu
         MSpCblth1hLBVmuv64c5Vco+rak/cwWFQJz5WWFeoEPK/PrFYRJrA9MzPhsEfhAg8yWg
         RCNjWGCg6R8d1xtgRBAvWIuJk4O8QHcIt9D7uxnVAKyBhISYVI/yUUlrC5I80/GPmrGm
         5PMX+5/Dkaq5VuKmT55yZHP2AVJUs6/pUuELRhqXQ7VMLCfFimsnYdz0P9G3qm2ADRnJ
         A0jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id d24si16507465ejt.166.2019.07.29.22.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:59:08 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id E90EC240007;
	Tue, 30 Jul 2019 05:59:02 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v5 07/14] arm: Use STACK_TOP when computing mmap base address
Date: Tue, 30 Jul 2019 01:51:06 -0400
Message-Id: <20190730055113.23635-8-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index bff3d00bda5b..0b94b674aa91 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -19,7 +19,7 @@
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 /*
-- 
2.20.1

