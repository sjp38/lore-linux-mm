Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73617C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:12:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37FCF21904
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:12:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="n2m5ud1r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37FCF21904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32F68E000C; Fri, 19 Jul 2019 00:12:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE3268E0001; Fri, 19 Jul 2019 00:12:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAAE58E000C; Fri, 19 Jul 2019 00:12:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 786CB8E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:12:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so15132582pls.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:12:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2kWERNzyv4FhVFUd89sSSSvRu/IL6GMa1w84yONmA7I=;
        b=siFNy1WVK8+QgUWmo6hkBxaQHbc70RtSIzdx79WakUeTLWFnR53hLtvPKWLw1PoFV9
         wvU47JpC+8Ysa7/irVj6LLM8cOCnxD/DqDNnjIkGShUPkmTJUaPWwPENydicFX3o7efh
         zs0ARABAKDBmU0iy5zpedkowDnxLwoAzz4bb8VxmVPi1UNUhKk2SFIuJ6r+qjS5VUQA9
         C34EPmaEsgaAmJXV45kcRqYwKoU/CKUw48DMGwqsv8oB8t+reVYoUS62EaZg9WbBBoc8
         YEMa2sJz/tT93Pkxs/jxTnQSjHCZiseFyzW6IFR6JY9bMbICp/P746aHqiOH/+uNjwAs
         30uQ==
X-Gm-Message-State: APjAAAVjJo4yIIkbdPCEuUkba1BIdEUClKIKNAiVwTIMUBFLCpltm74X
	unHNWuI7PrcLRYohBd0+13mCs+5VQvLVyafK3AGGKrA0UR/l+CSRidqJgTZaJaRpM4wVGgAceJV
	PgG4KWY0VWi2JSRbS8KNop0/WkibVijjDV3A28Pei5Reo0jEs5cnF9r+ypwFcG9JLjg==
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr51646824plb.187.1563509577184;
        Thu, 18 Jul 2019 21:12:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7VpuYo4ci2/XzT4AH55zHOYqRepGvw1RSE2Kyh4mcab9QEGMVZrgg4Vj2MDwU+l5nZfhB
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr51646783plb.187.1563509576610;
        Thu, 18 Jul 2019 21:12:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509576; cv=none;
        d=google.com; s=arc-20160816;
        b=H+Cbhypm/7c6llFjVt8qV9546PxNZvhaPktbYrr2SkLE1J9PdUiDp+LSHuBhzc672N
         x0VwnoTc5re2IFFFemCFwo1coEyKOkFqiASWGn2Te2Q78/SjTQz+DAMI8icZU4CLm9gY
         gfQMBnoe+nheXk8OMA5FH+p23kl2faTBD+8Z1mZX1+kJSO6TtQxOH1/erJJ/wZaVUpDE
         pHUW37dh2jrH3g5zGsQcTRzWyvAhD+lm0ukr0FNe3r7rr3ZKx/7Iy2IbU0k7ksSEQAZb
         7IAszHXQ4hlAn6BkTqc9ag8RWsHSt0QKxS+R/shLXAHLe/9X2vgZirO6Q8lp4uEIA7n1
         X+tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2kWERNzyv4FhVFUd89sSSSvRu/IL6GMa1w84yONmA7I=;
        b=uW2Q3XZpiwX6ejGQQWrnmFTdvX5T+Xvmsv4ar17FDnjhW3dLBMzeGV0dZc9qJRzdbO
         MI39YMwk9zdioWhqWuD5oESKDLohxrHFeR4SkzXaMoh0iisZ33+2MLS4A+dALolhkYf+
         m4dwmpIAmk8/g+dB5IqWoYOBPlq50BxyJEeNEfzaJjJQtX8mNGh8WQ3k3Y3RZpRm5q7P
         W3HNcQ2Pye5XVIC8h1mYlfHR5vgiqzyRoYwzMWuAjt0uqtIsILsZa3/t5BlhtWFt05kP
         WHs70WPyDnncCc0IuPJlKwydMv9xKHYTyqxChqY5GiyYNOEe2l6KAwvd3VGafhjSDZeb
         H7bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=n2m5ud1r;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v9si734954plp.4.2019.07.18.21.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:12:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=n2m5ud1r;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 43831218C3;
	Fri, 19 Jul 2019 04:12:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509576;
	bh=o2CmxtnO3fr6rs0CJpzZuz1kwev2BrwHqvGqigfTsNc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=n2m5ud1rRGw/B01/Jxmb91tPTdEeJUBwfYd0ae3btN2dY4TA6rG/WVdudRv9mfrwy
	 itj3E7Vl4FTC5r0d46UwsSbBkS8lRZnbHIlOby2N0j0mpc/PtE/VGxY54C7wCaK6bc
	 pKERvNs+VBerZIlwU+5zpcKbdxdAainAR4bwBz7Q=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Guenter Roeck <linux@roeck-us.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Robin Murphy <robin.murphy@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 57/60] mm/gup.c: mark undo_dev_pagemap as __maybe_unused
Date: Fri, 19 Jul 2019 00:11:06 -0400
Message-Id: <20190719041109.18262-57-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719041109.18262-1-sashal@kernel.org>
References: <20190719041109.18262-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Guenter Roeck <linux@roeck-us.net>

[ Upstream commit 790c73690c2bbecb3f6f8becbdb11ddc9bcff8cc ]

Several mips builds generate the following build warning.

  mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used

The function is declared unconditionally but only called from behind
various ifdefs. Mark it __maybe_unused.

Link: http://lkml.kernel.org/r/1562072523-22311-1-git-send-email-linux@roeck-us.net
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index babcbd6d99c3..cee599d1692c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1364,7 +1364,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif
 
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
+					    struct page **pages)
 {
 	while ((*nr) - nr_start) {
 		struct page *page = pages[--(*nr)];
-- 
2.20.1

