Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AE1DC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:01:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16B4D20657
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:01:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16B4D20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0E368E0003; Wed,  6 Mar 2019 14:01:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABD828E0002; Wed,  6 Mar 2019 14:01:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5088E0003; Wed,  6 Mar 2019 14:01:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 453638E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:01:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k32so6696707edc.23
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:01:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=Qe1iZNIFw94ucNJ1566x6+8LKb9gvA388Al+CmGXJvVUoGJuPWXeo5JJhyJcURQeG1
         OiRNvH3eHJH0BEjetM7srdo5QXxZcVaRdNrymnQuzY8z/jwRFsUlr2XFTDsmEmcpUcQ+
         JK6kZnuKETbKT8/+45u4EIRgC4emHhtjivbPGxmE/sCtw6G6eThqsu74DYNule7gqIId
         f2IIaygAQQ1JUm7R/pkEFF/osHQYckrMMbi7r/fnaR7NoOUV67TvnCndqqjLRpNXmSXO
         RIxrG+8AZO22tX5IXYBZTPJ4hq93JJq0Ctb3vy6SU+aAHpYwKkwCyUdYtkf+97qGcZuJ
         BQOw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUVS+urSpeZ8KamHSvRAZlmg2ShAr+nYSWxbYY4rd8RtnoUQizt
	jwN6tYbL4F3bdH1cG/g0HJOoplZYAFjFaNOv/XDFm4WCN3dEYVkgJwWw6wLyD7PahoA+/zPYnqO
	SO/9hyMJ/7aERLsVInvENsnToFI6HeWhh2AKsM8V0xmb7YCPCMcW27rozpygHseE=
X-Received: by 2002:a50:aef1:: with SMTP id f46mr24822825edd.184.1551898889523;
        Wed, 06 Mar 2019 11:01:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqwu86fx8NO8js7HzV7yRedfLa0aW5YWzi3RuUfs7cRd/y1FVYws9gbEh8IolgsEJNbCUU1g
X-Received: by 2002:a50:aef1:: with SMTP id f46mr24822745edd.184.1551898888063;
        Wed, 06 Mar 2019 11:01:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551898888; cv=none;
        d=google.com; s=arc-20160816;
        b=HLLAQ+4UG7BpqhBYN/uGIgBPF0Ex33iuyxVimlil6FMSkBb8RYQz16DG8V+RloI7hZ
         sXc07awbjSxB8Krx1IXYUJ43khM/GB0ZjwtDESsj4cLfv1eW+aTNLu/L+URtWsb933Hv
         jrKppWHQaoesDOTmzYKOtT6tUGwlNJdQ/dGzpjwlEmNfW6i5i7s4xqxMgK5Cu1fr+sFS
         DNwhtCfz6M1h+AArZ2NKFqwUSkygSfSkt4G5yoS3JCp0w4u2IBp19+el7st8VoshanM0
         SLNgZQ7rB8+SZxoM4JLDpud/jkMwY+woOpYRQ43tAAGrd+zFxW9do76CJXOCHjP2cPPt
         mKpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=dv4r/k0ScdSLRazdZlE1v7ooopL50U2HSk1jykXe2Arr71htXQBaxb7vo90+9lm9ET
         PhHWEGuQhsWFTOOy1v77k4cTDDFkIQ7a72jXC8c4I7R7R+8B53MnSgJ/oyck9ufzVMHQ
         0cvm5jpeDTDdtTXPSaVaSM+v5QXWQdIZRtEGjXgDesEgcDLxV26mWzFx6rhSPT50B6Td
         i9mZRnoJU7+G+sD0YCV1LxCZn32HVo3JfX1sjAdGwtxe5M4ZILWZbPrs90RjTPxh7asB
         kze9he8MojSEnhPyB3aQkOrLGCb4cL0mK6RQTAy23GAT/fv9MvPo1KifBpAmDMsZfJk2
         W89A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id m20si76901edp.72.2019.03.06.11.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 11:01:28 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 683D2240003;
	Wed,  6 Mar 2019 19:01:21 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 1/4] sh: Advertise gigantic page support
Date: Wed,  6 Mar 2019 14:00:02 -0500
Message-Id: <20190306190005.7036-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306190005.7036-1-alex@ghiti.fr>
References: <20190306190005.7036-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sh actually supports gigantic pages and selecting
ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
gigantic pages at runtime.

At least sdk7786_defconfig exposes such a configuration with
huge pages of 64MB, pages of 4KB and MAX_ORDER = 11:
HPAGE_SHIFT (26) - PAGE_SHIFT (12) = 14 >= MAX_ORDER (11)

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/sh/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index a9c36f95744a..299a17bed67c 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,6 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
-- 
2.20.1

