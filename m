Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 721D7C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:21:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 347A82083D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:21:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 347A82083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6B9E8E0005; Thu,  7 Mar 2019 08:21:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1CBE8E0002; Thu,  7 Mar 2019 08:21:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C578E0005; Thu,  7 Mar 2019 08:21:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFFD8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:21:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k32so8002067edc.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:21:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=MDicD2j8MQwZqaa5J7ebXXfH2gyZ7rUVX4eYiF2DyBTr9+oUjAsyvgOlbi6js03V9+
         YmeeNw/DG8Zi1GJV+0VVkLqtQeIfdqO+8CbVMZ8Oeop9IlfmDw3T/Wayu160OTKewG0O
         z4RogjEJBlA58Y7R60BlKrlVqGX+2Hm8L0xWbbVZQFEKtnbKN6olKWidGmuHKIrYcFcM
         20ttfjkZK4NsfX7ucqt6VrNnGoxI4ecqYHYSi17UIyNYB6J6MMxRu+i3wjAqsFOr810J
         y6V5r7p/DHG1Om0H53Sx/cPaYQXpcrrFjQ7qjN2l5A84ntuGtcmuDHjpwYdEvBhym1KJ
         h0Zg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWWY4z0jiYSldU8S3/jZjAxieHBn2zftAnHNHh7V2lUTXrRBfqx
	pbh5yCOa7EyY9xjWZPOBhnT2S0OM3wSXUvFaPnAynhUdaemJx9zLfSOUQqNnDIjFUjaW5BEAziv
	/ey/ba3HBbShzbyW7XGyWNLk4Uf+UQkobzHq3Wn0KAqyCRJVwXhgT7V0xzNdKSEY=
X-Received: by 2002:a50:a5f4:: with SMTP id b49mr28035872edc.23.1551964896609;
        Thu, 07 Mar 2019 05:21:36 -0800 (PST)
X-Google-Smtp-Source: APXvYqwZTiYTXMyJPIZ7tvx+fth7fwarCuD3PIZnKA6GrUKXXzxmsqk2bAmAELgYc6u+kVCgyRFh
X-Received: by 2002:a50:a5f4:: with SMTP id b49mr28035777edc.23.1551964895065;
        Thu, 07 Mar 2019 05:21:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551964895; cv=none;
        d=google.com; s=arc-20160816;
        b=v27UHvbEaKX10gplDBeM+XEwLknGSSTIq/68wAwpf+nYMBExjhkmwO22O9SNvit8tr
         8qgAHc0nzcsivmNbDJfvAUUySX2PIl/6I+iXqAeOK4Oi2LuTb8RaTiRK5JsTCVpexml+
         oYWSqpa1ma/1s0nueAJ/OcZok91ARKbJS2/6Jyq4Is/BPNdPx+bvVsLO3UdDfOS4HqWi
         UmCEeyDgUWXj16W4rzHXs4py1aa9dKI2ek7k82k+34Gh8/9ErzpUs2O1pSUDkWz6tzoY
         UrwO/FxiXZlilNETXh2NNSIQyMBuSHib23Iv6wUReURR19m/XlZTiGmL1P7jw37NXrNA
         V0Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r/Vjiixhx3FNLOyNCupP3O6rpRbR7vCnpvYlarBDlm4=;
        b=fc9di18yh1kqrVqI9n/6845X2MdkYZ2l+dYQ42s0c0I1TQZLSvvIQ4eEO7aTW84A1z
         aj+9hmp7LGKSiG17iMKcc2u9NQBLUGgvkgyYtAlv1urLjc8W+ZBbA6m1EdKJBf2Lc5GH
         nTsxBYnRqIv3CrmJiv3gOG3ASWQTUZXFFw3TY03F8BXt3cyxus1581P6OWefKz0B/nly
         z1o2HsJgJUiLgVuRC7Aj+Ayk7hl4cXlIotTQNibiCXQuZVsjxgguqvGE0jA++ujtlpgy
         FdW7nFtFfHLgBICOtt2s1zubpYGy2HSaxhHW9wZ9SVFUpN8QukeNoqrhAfqqjncq4IB2
         228w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id 41si620879edr.20.2019.03.07.05.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 05:21:35 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 21C9620005;
	Thu,  7 Mar 2019 13:21:26 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
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
Subject: [PATCH v6 1/4] sh: Advertise gigantic page support
Date: Thu,  7 Mar 2019 08:20:12 -0500
Message-Id: <20190307132015.26970-2-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307132015.26970-1-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr>
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

