Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MISSING_HEADERS,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD9AEC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:17:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A305522BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:17:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Akqpe6Ca"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A305522BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D4978E006F; Thu, 25 Jul 2019 08:17:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68C8E8E0059; Thu, 25 Jul 2019 08:17:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59BDA8E006F; Thu, 25 Jul 2019 08:17:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 201458E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:17:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so30752052pfy.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:17:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:cc;
        bh=ljHSm6Zzu7WQyG9Dr0/JwBFIPwkJWPZ7lmDnCVtXIlE=;
        b=r/ALFBbwHZW2xtyMmmDx/qp9+HxZ84Ir6f+z99jvMwAr4anq1aRtV629Za7W4vTPkY
         i692Udz1SoYVOn+xJcVvU2bdeFWA9nRbeaCFbemNoPJ1R1hpWv9UtanokiXrsncEEYb0
         +OfnnuOGKEBVeq/af6dASUrFIdeF36HnIZw6aykzEOD+LyY1/yasHddNBclGnaouUC/L
         6Y9NNAK5kf/c6pTM7wSnybKqK/RM8jWO6C7xoYyJFW0SHvHFTvsg5xQPpto92agB5ag5
         IG1KquzTAENqUR91IaUseMKsfHGv6KQwmlclsgUp3m4Kekz1OW8iYa0/wz8QCCcwWJLV
         zdIg==
X-Gm-Message-State: APjAAAX5HyCmdaJI3Jvl67lgsr9AFYFUYmyWII9zhJY3veNI9wUCUbj1
	MoTPbM2E+pBNW6prii9VXmJmRCKXQtQ96w8oLHdtqpiaxxo6xS4a5jv6cuYRqTFVSKUWIJoK8Us
	wWBKxNc2D4Oj0oUMi+iP/OyQHy479oFRo3gaWBE4Uq9sKq1mSbShjQ58Wg50o6/uqmw==
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr86218318plb.187.1564057028745;
        Thu, 25 Jul 2019 05:17:08 -0700 (PDT)
X-Received: by 2002:a17:902:12d:: with SMTP id 42mr86218266plb.187.1564057028084;
        Thu, 25 Jul 2019 05:17:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564057028; cv=none;
        d=google.com; s=arc-20160816;
        b=qLSw/8ZKRuI3WZHPaqfXHPlWOaZa7JQTqJ732S25NFD1ZeBfjkzQKYB5n1kPExjC5B
         OeJlY/ngdmsszhR6o52jG3cBP4M5cB5wGDMLjdx69YKifDn/eTMaw1qhACsTQzBWIfEI
         YMKBb/Y1ca6hYCTb/OPuFxP1gt6j2l3BjyFE4Y+PiuDTU/SKyRkWL30mjpOly9llQQbD
         QbS42slOGDcELgLwr1A0kksfi7EZNJYxLZUyq+UUpUyQp+00Tt5fEUBwGKkpL06A/oes
         Cvo5EUoUGMzZNlsfDtWYiF7UHpwUpERJ4Wom4FMIGy/ywSDVoFuZimdA68S3FAjx0m2h
         KeEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:from:subject:mime-version:message-id:date:dkim-signature;
        bh=ljHSm6Zzu7WQyG9Dr0/JwBFIPwkJWPZ7lmDnCVtXIlE=;
        b=eqGrS+Z410goyeSUtv4SZJOPRs15WNtfH4TnknNJvjNRfbrOwemknxU7lf6Jlbi1IJ
         hyk0rfXQXxpaOb7gXEi67go3v9+mtEyRUFhXA3f8ZrvvT4SK8bYyF73pdxzkS2aLa28U
         XO2lZ9PcW+Yvz5TrsrgPsASzSIOnuGSv9Jc4C131Vx0C6WUrRSAJECSIeQIJBcH8Dga+
         G4s1W4Bsj9KdlUAYGRP/UUrcJjR7jWYdhhw7oS9WKmbT85MC24l6dB2DTWwA9ZNtPRcV
         dQy6lXmk2wlm3PzNmfiVyyD75AWlzGFmrN/0R/5lKEcO56KdLbNfpnWbQKMO+uS4s+jP
         Zu5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Akqpe6Ca;
       spf=pass (google.com: domain of 3w505xqykcnq6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w505XQYKCNQ6B834H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b3sor28525438pgc.45.2019.07.25.05.17.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 05:17:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3w505xqykcnq6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Akqpe6Ca;
       spf=pass (google.com: domain of 3w505xqykcnq6b834h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3w505XQYKCNQ6B834H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:cc;
        bh=ljHSm6Zzu7WQyG9Dr0/JwBFIPwkJWPZ7lmDnCVtXIlE=;
        b=Akqpe6Ca2kvfIFTvnoJ+c5OIYtAWTfjYFlxZ91JhehPR4MBfJm9ywhoCD3lGefBXW0
         n7SlpQFWfYgG4Aeujtxv2t7rdZa2kXKrO9hHdeloLRjBRpBGpMGC+IgBRq2hYlz74cwT
         010HpW9jL8W5gbrRGoEO3Y5fFruckvISszQcCXS5Fakkmmuet7C21J+u8swlLNVNjOq5
         Y1f7sdvOFzNM443uu1ysPbXSRudZDiBnFMX+WjpLHVbB5ENiuVLz2sPMw8Llub0ae2DF
         odjWLHT2fIwPD/mrVsCYEKgBnlnMvrlYvMqvBgUUd2lfogU6I9BnZ/kduh+R4OJE/trK
         0jzg==
X-Google-Smtp-Source: APXvYqz7yDmnI8s4vZuY1Ns1rw5n80XNvB05UiBPhLd8LH+m+RekLRU9SaXAoHp8e/m+hAePiBCX3thvsdg=
X-Received: by 2002:a63:cb4f:: with SMTP id m15mr10449746pgi.100.1564057027478;
 Thu, 25 Jul 2019 05:17:07 -0700 (PDT)
Date: Thu, 25 Jul 2019 14:17:03 +0200
Message-Id: <20190725121703.210874-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.657.g960e92d24f-goog
Subject: [PATCH] test_meminit: use GFP_ATOMIC in RCU critical section
From: Alexander Potapenko <glider@google.com>
Cc: Alexander Potapenko <glider@google.com>, Kees Cook <keescook@chromium.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc() shouldn't sleep while in RCU critical section, therefore
use GFP_ATOMIC instead of GFP_KERNEL.

The bug has been spotted by the 0day kernel testing robot.

Fixes: 7e659650cbda ("lib: introduce test_meminit module")
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
---
 lib/test_meminit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/test_meminit.c b/lib/test_meminit.c
index 62d19f270cad..9729f271d150 100644
--- a/lib/test_meminit.c
+++ b/lib/test_meminit.c
@@ -222,7 +222,7 @@ static int __init do_kmem_cache_size(size_t size, bool want_ctor,
 		 * Copy the buffer to check that it's not wiped on
 		 * free().
 		 */
-		buf_copy = kmalloc(size, GFP_KERNEL);
+		buf_copy = kmalloc(size, GFP_ATOMIC);
 		if (buf_copy)
 			memcpy(buf_copy, buf, size);
 
-- 
2.22.0.657.g960e92d24f-goog

