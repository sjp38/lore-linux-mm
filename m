Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F527C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C2C02147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:10:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C2C02147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F250D6B0003; Wed, 19 Jun 2019 01:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED51C8E0002; Wed, 19 Jun 2019 01:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9FA28E0001; Wed, 19 Jun 2019 01:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E61E6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:10:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so24445722eda.3
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=YDtqX88FesVO+co+I7guJgHYPCt2IGk5xyXMQTOsqEUL88Z6sm/pv1Al5rbjQkhgkY
         T1Neu0wJKr7LqqIAS3N+f7AnNlWTiXSTb8nQTAmrVlBsk5iDTNodM5H1zaiVdGupjjsm
         QwuBMGfEj41dsdUZ2hktfYnUXWz2aYySgG4OvQy/JdDcqEnZOvbJyJBo7qPMERNpOCt3
         hljHXkigVsGCWXm+i/6n5BrFbHgflS2OstZaMhsG74wFiyw24fJT8Ddvcp9Boi4SrHOg
         6VA3u/0mglNBhBz+fEzKSzL6Szp5adzx1WgH5VSWY05CSXLjxEt9nwgnSYotNmxKeMM1
         gMHQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAU1BGpHgBhTNh1zIdu2ktIG024lqefVd6I39B2fFiG2YaMHJiZC
	rMhOsOB7zLkr1DxcKJXQx8puXgQrSJBodN+eCqjj9LdrIb7l2CWCkuWPPQlG2R51WCkeR93Aox5
	HSBNcReb+NDMM1QSfYsLc4V4SW5kIfGAjFwpRD5Mz8SjLffkSAEHT/7r81FgW4F0=
X-Received: by 2002:a17:906:1845:: with SMTP id w5mr44109095eje.0.1560921018097;
        Tue, 18 Jun 2019 22:10:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdJzhUFp8L1oJd5JOAl33GR9sFAGAjrHisw/PnLpruOEqrAeqvRtPWMK0aMETFAJ/0B57Q
X-Received: by 2002:a17:906:1845:: with SMTP id w5mr44109040eje.0.1560921017058;
        Tue, 18 Jun 2019 22:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921017; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUGG62bu1MdrJLUdoeT+Yw0G5lnIN/TMhR5UMOK2eOExjA5K6MczG7NzZvPk+btdDK
         0R7nH353P0eonQLUkUknFQihAVmqEl7mQYID6+Lf7Jg/ceJaYy+xw9YP4IUczaKUdyQl
         HWWA2gFpVHrUj8t6n6kpDDJRAPqFR3Z9eCICZ+TO6r1435iGu9GWoh+P2lTotIyChT5O
         H20V75luhbvsNVDkSfTkgvmLKsUUiRQqIluARVCdNTGp1nsXBzNhDzQ3xeJTHQG0O/zP
         UFcy0DZy+zOBNLPIkHFN/qHtccLVBawvvzf6RKR7PhrDGfX7rr72JB4PjPZbfRuyK1ad
         dkjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=suPCocrA3QM64gsofO1CrTBeyBcHKAtqoGrxzUvLo4k=;
        b=fDTPDoggLUVN70Q9ab+ghdQlG0J93LOj2LysuTLgDUjYmBDMmnqMEFe9Uf93YrRgh1
         j3je3Wh4iBSWZeakUCuvlSbD/VLAwkSA59WtMNnZ5gc7CxDNT0RXOFQK7IKYKaiMPEfl
         VYaRcpmM7poSFygLFg42mEQZ3EL7IT6rdSI8mi0oCXryZ/CX2hc/4jLMbkyHnYdYjhcs
         wkxIF6Mif8aSTEuuNUkOQ1pB7KpDIpoPv3fx0cqt7kZGHsoYY17SYt+eTLztislbXUye
         mmZgmKtPGRQp4zkL2v8XNXVz7OpHkAHoxQ6bmdI3r+cAJjv8cB8Sm05A3NV7GwKRw2DQ
         ZhXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id h40si13160243edh.219.2019.06.18.22.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:10:17 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id C1E8920008;
	Wed, 19 Jun 2019 05:10:11 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
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
	linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH 1/8] s390: Start fallback of top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:08:37 -0400
Message-Id: <20190619050844.5294-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190619050844.5294-1-alex@ghiti.fr>
References: <20190619050844.5294-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of mmap failure in top-down mode, there is no need to go through
the whole address space again for the bottom-up fallback: the goal of this
fallback is to find, as a last resort, space between the top-down mmap base
and the stack, which is the only place not covered by the top-down mmap.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/s390/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
index cbc718ba6d78..4a222969843b 100644
--- a/arch/s390/mm/mmap.c
+++ b/arch/s390/mm/mmap.c
@@ -166,7 +166,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mm->mmap_base;
 		info.high_limit = TASK_SIZE;
 		addr = vm_unmapped_area(&info);
 		if (addr & ~PAGE_MASK)
-- 
2.20.1

