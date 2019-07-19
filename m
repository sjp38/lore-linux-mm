Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE753C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 762ED2189F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1EtMe0iD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 762ED2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2ED108E0003; Fri, 19 Jul 2019 00:02:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4748E0001; Fri, 19 Jul 2019 00:02:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16B768E0003; Fri, 19 Jul 2019 00:02:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBC858E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:02:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 65so15115753plf.16
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:02:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rLHZ2q6G+M0PNJ8XkTQl0L0QLO6MMei3QSLq64PJAmU=;
        b=LYEn4zQXoS5wdK++IZUDOaOpzqwhOgutmOinlmluXEkG1j8cI6hUbDVraXflNRadeJ
         7GD1O3szdA5DzmPEtcYWhPKOHa5i1+fNKObAudyy6Dghzh0T5N/vy/4XxxlkBCyBKNjf
         fpnQY2g24Iw7KGSu0NSTnRxR7OyJaC+VkRycPje4AJNRJ0mI71Qijo0saMxfLRHOgfPY
         RaSEZocm3IC4YVusUryMY8r3PAz0FFG5/5HN389wNW8Egq1WFqkF924lauPn/jt8neBo
         5tRKaXrJ0KRxdFGHKWTd9gdqYHgX+TC5lu37xjUd+Ad/Jbkfi/kMY78TSCieM3vQrVb8
         wxsQ==
X-Gm-Message-State: APjAAAU3YKKykulOFyHRgw592i07ZEoRIJ8rdx5mAm89orIbhIUXsCXm
	+a/8volntQTOgYu9drgtn5I8yQtSvlquKB+XHoTwl2ep1RDIpjWv+MUQoFtK2naD2wmSdLMnqa6
	Y0o7n18T5CWabkFeQ+bNyYd9ZFSYrQpqLY1oZoR3J+HAajpBCgYmBhjntAXCZ98PjRA==
X-Received: by 2002:a17:90a:ca0f:: with SMTP id x15mr10578983pjt.82.1563508925519;
        Thu, 18 Jul 2019 21:02:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztKf/Y4kXnDEEUlfdmxjrliFN2rVT4wJilgGyJMCrwVLxLCaIt3KKFkvFdVxqNzJ/aoBOY
X-Received: by 2002:a17:90a:ca0f:: with SMTP id x15mr10578930pjt.82.1563508924833;
        Thu, 18 Jul 2019 21:02:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508924; cv=none;
        d=google.com; s=arc-20160816;
        b=DT6U9VTtdUEJflNqLdvYop29cu6JZylzOWfrm5gi5832QT83oJ60YoZJ6qWIE3sHsP
         9bbLTNboqEJAGU2QrGs6CbLePTlgR0uWuT7PZC0I68dStJSV+K5T/xgmDqa8ztig9CRW
         z6pS+MLwB7EltJUHxAQDcp5Y05DUhTEvlys9Y9Au8ehUQx+lgrtG7DvLTOy5hj5wCpxI
         PjCMDVgHKGU0lXBYoldPwBiXir3huwIP+a+gMyHMFl+5Kh6WLjRBk0jAS8XVOsqfEbx8
         tAw/tzo2XsJKeNjbdzoF2Rjico6LroEUdilmkPh5cwo/H19m+LGsGhB2wNolPGKVYA4Q
         JGhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rLHZ2q6G+M0PNJ8XkTQl0L0QLO6MMei3QSLq64PJAmU=;
        b=e2dd3+vopSBp/fiPsOKpcOxtKYYUk6qnpfuOXnVMCDW0enqMM0hwcx8oAfM0DM9D2a
         wrzQIR1hxvcYH+nRwJjc7QWvKzffUJlG+UnlRE3i30xLg2571UlJedOVJZhPVa8DAiv6
         dpO7er4QJsZUCu7pciLaKGmvwxhJRFtMpxqtjTFemShf2S+mdCxrcZUrRX8UgHhSCqDW
         KhFX+dENnRFGcwj92b4JyznJjORCqVt8XahjfOriqxFtl4tyNKDfR7VzYt2DyKrlOioy
         QuV5PwigW6o1uEFQw/xzbVJX/8ZDyebti1+GpbR3EY2ZP+Dl23xUXvqs70NwzMZfGUAJ
         mFbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1EtMe0iD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u38si559354pgn.79.2019.07.18.21.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:02:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1EtMe0iD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 83F8421851;
	Fri, 19 Jul 2019 04:02:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508924;
	bh=3tGUSyKZat/dmcqO896qO06Msf2f2s+baD14991fs+I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=1EtMe0iDCnhov9z/InapjWhmveObQ7da/HREOfT9aH/YhHWUwEOkUr8Y+QRoMXlI9
	 UP27kvLZxcMCpZNnDbqPn0Crz4AivOImyhxbzy+jnh7qohPaMx+A35fdP86GLO5jJ3
	 8rTReANSCS7HlgGZE3l5WeseJpTLF7qZC8c8zVzk=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Florian Weimer <fweimer@redhat.com>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 160/171] mm/gup.c: remove some BUG_ONs from get_gate_page()
Date: Thu, 18 Jul 2019 23:56:31 -0400
Message-Id: <20190719035643.14300-160-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

[ Upstream commit b5d1c39f34d1c9bca0c4b9ae2e339fbbe264a9c7 ]

If we end up without a PGD or PUD entry backing the gate area, don't BUG
-- just fail gracefully.

It's not entirely implausible that this could happen some day on x86.  It
doesn't right now even with an execute-only emulated vsyscall page because
the fixmap shares the PUD, but the core mm code shouldn't rely on that
particular detail to avoid OOPSing.

Link: http://lkml.kernel.org/r/a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Florian Weimer <fweimer@redhat.com>
Cc: Jann Horn <jannh@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 22855ff0b448..d2c14fc4b5d4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -585,11 +585,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
 		pgd = pgd_offset_k(address);
 	else
 		pgd = pgd_offset_gate(mm, address);
-	BUG_ON(pgd_none(*pgd));
+	if (pgd_none(*pgd))
+		return -EFAULT;
 	p4d = p4d_offset(pgd, address);
-	BUG_ON(p4d_none(*p4d));
+	if (p4d_none(*p4d))
+		return -EFAULT;
 	pud = pud_offset(p4d, address);
-	BUG_ON(pud_none(*pud));
+	if (pud_none(*pud))
+		return -EFAULT;
 	pmd = pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
 		return -EFAULT;
-- 
2.20.1

