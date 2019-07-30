Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67BAEC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:54:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3722720882
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:54:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3722720882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8FA18E0009; Tue, 30 Jul 2019 01:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3FE08E0003; Tue, 30 Jul 2019 01:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C08BE8E0009; Tue, 30 Jul 2019 01:54:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 758518E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:54:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so39618548edx.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:54:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=21mhY1F6D/bVN4FBUSB5kLGwxQH8yFVmkExK3y72E74=;
        b=jrqb7JGm92QXZ0alcG82OMeczFU1SULFWeK2DHnDIB11NzHmANiQASOEfwx4CAwlZr
         OxASE4GplSrqQM0VIY/BodH5cOvuPY7L3lZ3BTqItspEDAozI/6mWDr7/S2xzzls2eBI
         T64ulChBph0mTsX9wmkYIS8vNruUO/oOgRn8JZpST/rzdRuD79AzJy1muGwED2b09Kl/
         K8tr0Xzr+l230gZJH+VprNlxWjR7mENKCJIudb1dd/dM34uSSZfHJ9619GySqljkh5Zm
         XysHsFQl6BbXLg+Kaa2SvwrkJ6OetV8uXgT2SntB1Q/50t4C4/rNGdA49xQA1rScrpq/
         gJQw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXJcPz6HfrEvrHKL+esqE2sR67a9QMkd34Hc2WBFUkMBRR8j6F7
	3xo3Ty2RgABDGqgbrQ9inKMhnxxs+bwU46RsQ7fXTfff+BEhiFdRsQqlj7jG2yhHuMp77mawirr
	dZj7hDqhqMzEDfw/VM4nYD3nqw/LP1hpYhcAqQcZL+4ccNTgbj6wAlhPAv7AMn+Y=
X-Received: by 2002:a17:906:7f0f:: with SMTP id d15mr90416213ejr.39.1564466088034;
        Mon, 29 Jul 2019 22:54:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8Bm76AKSGnSrhiG6X5Zh2BLmVFl+/E4DDFTB9Y6uzZw3q14PZ2s1C62+pB93vN37k0PJj
X-Received: by 2002:a17:906:7f0f:: with SMTP id d15mr90416170ejr.39.1564466087024;
        Mon, 29 Jul 2019 22:54:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466087; cv=none;
        d=google.com; s=arc-20160816;
        b=gww4FpjX+Bj+0bDVtTHnClfzpp5Llf/7tClIrj+IGbTGAZurKyw7GWw2UDK1evJJ+1
         QOz4BfmvnzpOTvbs++zBDulry1UPzUSwX1fDDWzwLaDRJcjywVAJ2XHAMKcrSaticiw9
         i8xzWQQVditYCR1Zz7v4/W8/Ty3ojmx9fSzCb8HNpjcyCCXE0pElZWHGG58fEbgbN37/
         eWWceK8W7wORY/ftImw9R1EvujMZRgmrtLLpwOg0tWibUC6Xaf5FlLu4HtzJUHT4ViKv
         FM5L12WavcWm05bFSMeFSXewtsFK9RZE1T4IEpwA5sbHeaBQvuYIRFVorfnchoQEGJDh
         GR7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=21mhY1F6D/bVN4FBUSB5kLGwxQH8yFVmkExK3y72E74=;
        b=OYHxJE5k3jPcym6tbZYaCSu3mYiRkjl8FRaNJ+HmTCXFa4uQ3c1cEHt/V7CJmFz54S
         vsWbnI7pLnc9FMr+E1THuMfb4GkMVodhGYD7EmTD2pcuxnxUp+oBodWA+X1YeRxZuTC5
         zfSy/bEpQGWuVxPXOjbdUHh1DXWYsPXQoEyRyw4/O1m46jXIaACx383aJWrVlI4opQzT
         yyMWrkCb7iRtfKSShHvOIw7Nh6XxeShP55Tkb8VY53SZ/HLbrEld/9A3KFTEgVziLeTA
         GQDlu3ygy4FsX6SauTlrnjkwmyvoJkCX18iMXmAW18QDmFS/Z847lxWEDQpc5h5N4mFY
         Mm1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id k34si19642635eda.241.2019.07.29.22.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:54:47 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id A580220003;
	Tue, 30 Jul 2019 05:54:42 +0000 (UTC)
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
Subject: [PATCH v5 03/14] arm64: Consider stack randomization for mmap base only when necessary
Date: Tue, 30 Jul 2019 01:51:02 -0400
Message-Id: <20190730055113.23635-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
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

