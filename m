Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0130AC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDB86218BC
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cwI8doY6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDB86218BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DF858E000C; Fri, 19 Jul 2019 00:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66A438E0001; Fri, 19 Jul 2019 00:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BCB98E000C; Fri, 19 Jul 2019 00:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 158B58E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:06:55 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so15139457plo.6
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:06:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=l56U+y59UrI7uVB7BZM7a37lArLln3sNYHbeFd6WER8=;
        b=pUIdWGGAL7PtQvrgyMwgvOQh3rqys3eCJE/x4xpneMymXHlQ2Qm8s7z6WzVQPYmIMc
         xRl+VBT8sms+B0PqYEV8dCQvTVx+Y3BAqmpoJGxQGCX/3BTCchUoStVssQ8jVPUmzJFO
         aPyUGSa28VG3tLiNsZXE8AGf/fJAKnJItzz1rMQgD0ITqwCoHwe4mxmcktyOmSZnrCOC
         aGfkEXF9Dfj+Wn7Ca7PDeL54SO995zT/Z2lRvfdbVtDw7bQvtOe0CSdbXVjZ8Ir9HfbX
         k9JcpStF8TU5rIpeBWbEaFfO+UAbk2KETceHxTauGBwVYkZ2NhsALz1cTJMvNy6BIU8r
         FVYg==
X-Gm-Message-State: APjAAAXn+hqcGl0wP3Mz4xd6DL3HKk8jD7KgbVEcP6OmNtAlLXX5XCKk
	Mk0zYBR7wUanFhNEZmLO+yu8vmi8FUbn+jB7GgZbAyJ71ZqPV83dKQSwAxoS2NjuwckFmAZweNR
	JIGTyyUZYCZF6S+ye5BdcOJ2G21YiTCT16SXqw8Gd86eXRPb4KvHdAGYKmQUFYr/brA==
X-Received: by 2002:a17:902:e383:: with SMTP id ch3mr54025275plb.23.1563509214767;
        Thu, 18 Jul 2019 21:06:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1C4JIA4qsZLRbF8YA7FnaPkXCQDZ+U0EQbAXB5udfaoNoZgsullrFprC3ilDB3SvOqnEy
X-Received: by 2002:a17:902:e383:: with SMTP id ch3mr54025222plb.23.1563509214088;
        Thu, 18 Jul 2019 21:06:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509214; cv=none;
        d=google.com; s=arc-20160816;
        b=DXYi8bpQvizj/7t8Y9HmkhWMZ7vdKyNGnigabAiCFmb66fFLsU3L58/eVWAu3yK+OQ
         k2rd2ZUKMBYkFt+El8zGAkRn1FdIyzD0SkrG/i3SdyivREHlp6IzfAM+QoBCEmjy2zS9
         zdS7kaVYN35lo+o8FpBVJbOrAxt15FLLnMoHaVOrcLUc3oKQtpblo2Wn3tYAcljLzqQl
         1uEi7MYBXt5y1WdVumxJPcFXog79qO7JwFda6yI5evZY7B6+91ZVMETGBTJwqGvJvjXl
         Is9wRAd1i9Mz9NoRlhFRRTYL4WI1mYG0Zn3P9vwN5nicGD12tTsWoxEh0eX+PyNpyeBe
         wmtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=l56U+y59UrI7uVB7BZM7a37lArLln3sNYHbeFd6WER8=;
        b=pKSwOvag3/FPVNhi23qPpFbeWqpGJautXyURpmd5ENZSY8sSHfwn3epK/mM5L82V2/
         9I/iqpBU+Je/vBC6AH9fT8o3kp7bDq8j3Ax6tEe9oMqwqn40Jve+gAmRyAfnRodizCcb
         m3yl7A4Ng5X+baeGj6JwYRYxnGFp8Ndxyb4iQxanxbfdZPxAPpCSKu2nPmWbEP7OAaMJ
         MPEqeZ9O7HnoEK4HtcmRmgxGZDUI+hWmkPaxvKSlv4O6FXkQSp6DOQa0UZBxoTo9cmT5
         X+2Td0k4HuOim2bMHfi4BPzZngfliA4icYmDowxwvKQV3ZIHnPN31OL0p0O/uRjh+jJs
         Ma/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cwI8doY6;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q42si3716491pjc.103.2019.07.18.21.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:06:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cwI8doY6;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BC53721873;
	Fri, 19 Jul 2019 04:06:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509213;
	bh=CHUtUjcoZCmdIpRrpFG+/0VQUcEan2l3QkxxlFRqon0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=cwI8doY6BUeacgHioVlGSNw5ZLKGRjmfT3rwprqv11m70iCRU9N7Lb1kbkDMdfH7N
	 EkqHrjrAF4Kicy+A9LxAMsrYrlyBaEq2aVceABwUFJyMuLoTzoXY9hQaFQGG2mqw68
	 QRiTR54s/VuWMW2xIKkttJbRNM4mkBw4orDzXXak=
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
Subject: [PATCH AUTOSEL 5.1 130/141] mm/gup.c: remove some BUG_ONs from get_gate_page()
Date: Fri, 19 Jul 2019 00:02:35 -0400
Message-Id: <20190719040246.15945-130-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
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
index 60d759f4e4b5..de2e506d4aae 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -479,11 +479,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
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

