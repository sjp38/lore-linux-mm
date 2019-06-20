Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B58A3C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:10:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FCD420B1F
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 05:10:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FCD420B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 263FE6B0006; Thu, 20 Jun 2019 01:10:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23B5A8E0002; Thu, 20 Jun 2019 01:10:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 103218E0001; Thu, 20 Jun 2019 01:10:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6C836B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:09:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so2605864eda.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:09:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UWpdnrbGefkQI6ssngVxJNkCRhvWsEseMpLH8MS8OO4=;
        b=OVj/KHGPS745QuAggwpmQZKTesc7ZY/k83eMdpTYzPuFVm7LdW9QKSq+oMijgYBTxt
         jevsyKAT0yUOfUb+EYvBz6IbS8mJ76UGHw6/fpcki//5yR6RQ/nAG1yuKa21xGKmu31B
         rc6TwPbzMsVYvKEezKDODrIHXHo9XIFcK0WCfSRf/r3hl5rDjJlnBX5GyGioGE4HVDXl
         Xvx7cx+EGW5be4Q/JjwWKg2HCOEe/USKlAK4oDVRDw5HyWS56DLVtqY0tAuNr4ffoK+7
         FcTYzmZ/dUKCUYKEL9Lkv3xleUBAaAie5BCVNT6ZXZH1AV/7iLLR3aCV2pCpmql9k4rI
         Cn5A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWnL0H9AUOmodDIeuv2O3a/2Tqx531Iem51Yn8kD2LoEijYqqk8
	x401N3G5EGbWAYGfhqRdSuaDGGfc4zlc6K1VkzKtgwQGZfNIqYQx5bgRTa+XbY6YUDElj3hBLSS
	6IrkaiUhRjlRccVW284rRVd1NudByoWFTC3o6h0eYaVQfzTsFyslGBoLOo3lcQ0E=
X-Received: by 2002:a50:b161:: with SMTP id l30mr117195912edd.278.1561007399282;
        Wed, 19 Jun 2019 22:09:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkEdKDSUwMh5wCzq6vITx1tq1AsGQh3umJRL9i8Ff7YZvnqxlyXGSm91KIlRlyuvmCt8R1
X-Received: by 2002:a50:b161:: with SMTP id l30mr117195867edd.278.1561007398585;
        Wed, 19 Jun 2019 22:09:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561007398; cv=none;
        d=google.com; s=arc-20160816;
        b=DzuO2CyJ/ARrjQiZAcpSjCZ80jHe2lbfyXAyfqErOy31aszkrkiQuWXbZFhLX+7X4E
         HVIQBIwTBCGQXhAT2HveUoX94TBngg3ehbKwfU8uIBoF38sym0ODLp7GTBQTyQ2Zt7wE
         AzA81MkRPDD8dgriv7iCOpeMrCHJorv9zWQMCHLxnNiQ/ktmzbOm/C/HqcyFvriweEZD
         jHQJWJ6TZHSR1LkO3xlOatOsjzny43b6AQYBWHfyilPxZfkwKdMZZS6CVOLPAmQHldSD
         G4BstymZoH0UBw09VmGjgTDIMBpa9GlhTIjxHG0fDsTyLYIHfsh1+HnDvzjmoEXvnf5b
         +3BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UWpdnrbGefkQI6ssngVxJNkCRhvWsEseMpLH8MS8OO4=;
        b=0QXR6aLToeAqx4IoZB4zzn/x7txKH352eb6Nmj3k32f1MHrtP45xQfflauByNiWp3n
         UmBrju2FVypww2tB52UewtjSFrrEyaYo8S5g7w8AesBDXwoirQfXRbqQtIxM0+r3W0k6
         TiEfGRuXBdrE2WjVmUm8vIbV15SytfsIZd5ikYEdTyaPd0gNbFArbKsWmsvWDZ6ONBTP
         /NkOnUJF114NHL2xwqOnHWX41WgHvwKc5GqEowe4TltvQ0O4brCNy/2IBxHPAU09s+53
         AqWTA2kdrmxzzlY9piWJIx5ovFqonHPfpxKLb7oA0EHqM+bIytrtru9itCB9Oynl0Sv8
         qGHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id q16si12239275ejm.323.2019.06.19.22.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 22:09:58 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id E5FC520003;
	Thu, 20 Jun 2019 05:09:43 +0000 (UTC)
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
Subject: [PATCH RESEND 5/8] mm: Start fallback top-down mmap at mm->mmap_base
Date: Thu, 20 Jun 2019 01:03:25 -0400
Message-Id: <20190620050328.8942-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
References: <20190620050328.8942-1-alex@ghiti.fr>
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
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index dedae10cb6e2..e563145c1ff4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2185,7 +2185,7 @@ arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 	if (offset_in_page(addr)) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = arch_get_mmap_base(addr, mm->mmap_base);
 		info.high_limit = mmap_end;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

