Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53D96C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EE0820B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:14:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE0820B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADC8B6B0003; Wed, 19 Jun 2019 01:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A65AC8E0002; Wed, 19 Jun 2019 01:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 907368E0001; Wed, 19 Jun 2019 01:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9C96B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:14:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d13so24456437edo.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:14:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SHkC1mZg2rp08rzAypemwkUbAlcN9ysauQkDyXk9YVg=;
        b=DdSJzvXzun4oadw/n3dE3Z5WHQUZWQ58B06SDcJ8DXWVUmts+lIPSrk6bCinqxx5s7
         zgWy2Gxsz14tgioQgNI9YAcm9t/w722LqVY6dJ95bDoS50Ey+TVBPO9zLW0Ujdmu1Dcx
         Ej3VOdJL3kFO1uplbNZU7Ba0gQRGwKgqeT/WpeesbAsKZbBVdnCjsy9ODqg7AnS5N8PX
         tAyN0434Bwo4gUm/F6AQitEeDN1gjjocY1j2CcAXYTgSq1+5D7QEdtYFz8zYpF9yyhix
         p2bbOcpwo9JjSRDO2AUqvHUhkyQK2McWTqL9F9P9KxnCb5A9B35x5dg0MvSqvpBSD6ek
         8jog==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWzKXz8ByvYn7n19JuJKelvzH9QfDE+rlC2LJi7s5V9yldWJwuL
	1aOyPCy41e4MKexMbn2KE3eHVkd5tIXVeIDTmDOJApJziKccdy07lC2T637V66HOlmAEXaKwtYb
	h78qRK5L9qpQ4MQ6HvQbrT6rXRnghY1mi8YwbS7cfC7O1p9xowyHi9xQEiED0MsQ=
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr71178341edm.199.1560921239781;
        Tue, 18 Jun 2019 22:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaEa91jAhPYehtN0x6YiBn9tMK2qorIhKfkuGLC4qJi/zTpFdjqk1cDX+Arf9kW8Q77KGL
X-Received: by 2002:a50:8ba6:: with SMTP id m35mr71178269edm.199.1560921238752;
        Tue, 18 Jun 2019 22:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560921238; cv=none;
        d=google.com; s=arc-20160816;
        b=CnNVSx3h0RCJloZDcCAM5DNyoc2fYhYHhwcKFm3DHbEYEkKcjvSdAu9wvZs+DciCh0
         9GWXES+haT7LkVTBsYNCNh7TlWg+/xxwuFCr2JHPYgknnJax9RZ5GdOQSJtge9SmlfZU
         Y8Zd0KYJ4Q95/Fx532uAAhAOAGsT/Vr4z7sm/xW9m8btK1KbWElWhR5/JXHrF+bsYY3h
         9tbVKJd4ZVlWC6vlZZrXojozpXWdXsifzQY+UOghEu8Db5Ew+6nC1lY6febqXf1ZRF5y
         g9Vd6/hVyS5ODXZm/vGVt5wHbte7ffWnMvW32r0j4/FO3Ls96LTOUChysRaGvjrUO3V6
         9NpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SHkC1mZg2rp08rzAypemwkUbAlcN9ysauQkDyXk9YVg=;
        b=eqgC5thJf+gxu9GBI7/2XSXSdMu9ezvhJx8r7HNN/awLVjS+KybcnxHGyzpaINlFCX
         7eeivMYSNz93CIi02FChmi7Up9ueP+YkGgoOyZqIP2iKSD0gXJBxNXsraU4/xlOqpdfm
         OIDSSRWJzFWO3SrADAjNg1C/YEYmDtswCEy7uG44P/ZpaML3XCeEcR83jwXNyGkyWp/j
         6Uciay6BNMfT/KcE9EjMslTGOZjUb73bc/ZnljSZpiC6wzENBnRDmL1K/zTBnR2oFxKO
         chb1Oo9KK+58DJhg2Bl6u4Dw/3+meUouJObrGR5yJOipqDVvYLmKjkedvk7VV3HrVAVY
         bGEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id f58si12948135edf.135.2019.06.18.22.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:13:58 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 46F1560005;
	Wed, 19 Jun 2019 05:13:54 +0000 (UTC)
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
Subject: [PATCH 4/8] x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
Date: Wed, 19 Jun 2019 01:08:40 -0400
Message-Id: <20190619050844.5294-5-alex@ghiti.fr>
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
 arch/x86/mm/hugetlbpage.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index fab095362c50..4b90339aef50 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -106,11 +106,12 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 {
 	struct hstate *h = hstate_file(file);
 	struct vm_unmapped_area_info info;
+	unsigned long mmap_base = get_mmap_base(0);
 
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = PAGE_SIZE;
-	info.high_limit = get_mmap_base(0);
+	info.high_limit = mmap_base;
 
 	/*
 	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
@@ -132,7 +133,7 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	if (addr & ~PAGE_MASK) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
-		info.low_limit = TASK_UNMAPPED_BASE;
+		info.low_limit = mmap_base;
 		info.high_limit = TASK_SIZE_LOW;
 		addr = vm_unmapped_area(&info);
 	}
-- 
2.20.1

