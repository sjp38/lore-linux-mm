Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC5A3C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9570D216F4
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 14:28:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gU068bo8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9570D216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46F118E0013; Wed, 26 Jun 2019 10:28:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 420A08E0002; Wed, 26 Jun 2019 10:28:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6D98E0013; Wed, 26 Jun 2019 10:28:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09AA38E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:28:04 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id w76so525365vsw.10
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:28:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=TMu0A+3chvyUOctsH0BXGlUt9J7/DbmOlILtGATtQF/vym9hfVdUVidKGCWMm2ghTD
         HuUcwYf6YMKbY8KmsVHlAW24D3F6Wz0lHy8F9kgIjsHMjjYRm4VzP/fXvkDXQw0mmZCM
         xaNm/lJ3pprfXQU5yW5FOVZ3QJhQHRt5JmdtZuUXXkdCfzZ8bDvkaOyOFlHMxCg0wUMP
         EWN8UlfFdv8cJVYDU9kFY0+AO7n9TqnLlkU0a7jQm2pU1jr+zUj/z4TJgT+RYNf7E+MV
         PFJe2M6arj/lFsvrYJTkCFEdl8VQSYe8aL8csLSkona4L6J8+9iDQvXhvXhyout1FETn
         Dqsw==
X-Gm-Message-State: APjAAAX8PDZ5coVrmw5YfuFM+D9hqFdvHXtYdDU0Kfd5efGsSxBUFQGp
	AXdQb+edhQX6ae2yyWlGwyb49ogA17iqxqITXo4L2aqFwBQdAep2pp7JwirDgi6ilwIjxr1G1td
	7mTRUnmaVgAFBTyDCdMS3i+cJvSkdO92Pk1ZZlV95rhanDdV8u2m2RwP/vL7YFB/Pzw==
X-Received: by 2002:ab0:18a6:: with SMTP id t38mr2749447uag.83.1561559283662;
        Wed, 26 Jun 2019 07:28:03 -0700 (PDT)
X-Received: by 2002:ab0:18a6:: with SMTP id t38mr2749421uag.83.1561559283178;
        Wed, 26 Jun 2019 07:28:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561559283; cv=none;
        d=google.com; s=arc-20160816;
        b=CjYTrE31uZPQOxFhpdighbr272A1dw+Hpm+IYbRXP2GHTespqFQbGmds9XnFbVFuSm
         BwHcnX5ZyYTIMFkIOHkdIgrrvpLB/1yRA6WcfCihpZNihq/URL0tm1pRRHt7wWg0I4Hf
         aLsT5IeK4eRbqpZHuihfGzQVw67S3e0mkHSSsAqDZp4erveIJVqBzFNQx6KTx4Qtj3mB
         obxxb8gFquFlFTL7v43u+ocrkqIKaF+OxDzRFD4BmRUF2cGAvDY7MKJKOiIptv59RFLh
         ndzBK8Nze+qJuP5VJJP0hZbRRVvNOJieB2Wkp0YpNxH92iR7zOFR2tmrGFFN8nQvlBBZ
         n6/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=EI9kctSfYjk+2oDtwP0dR+gJy3NeQqPulx5wX4WGRitKZPILxqUa/nCdelICS8Oiqd
         RDlOP4EB94UkbyHrzTizmTgVn7f7opEodfJ6tJLGBISIv2A4QWF1M4dWl2gaNwNQvWDA
         Xdb63uBX4auJTlF5tn9VBkZlotR/Jq+uyEyS4hoNBeKmtpdlu+HXW69b2N+gqvexsGVO
         5MrdQl0GQ/9ZQtkofF4AKiWa6aWop+lHEBReCvvC7g63KZJuPXZYvJRXG/tyS5SslYvZ
         gED88c3ZsqvRxkyvWY0vWWsVZbJhNIImLqAJx0SPCw4jdL1b78FKlo7F75O16+SFIehs
         zLdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gU068bo8;
       spf=pass (google.com: domain of 38oatxqukcderyiretbbtyr.pbzyvahk-zzxinpx.bet@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38oATXQUKCDERYiReTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 4sor5401248vkh.64.2019.06.26.07.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 07:28:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 38oatxqukcderyiretbbtyr.pbzyvahk-zzxinpx.bet@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gU068bo8;
       spf=pass (google.com: domain of 38oatxqukcderyiretbbtyr.pbzyvahk-zzxinpx.bet@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=38oATXQUKCDERYiReTbbTYR.PbZYVahk-ZZXiNPX.beT@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=gU068bo8xI9L4oRs1xcqv6j6N8grLH+AVjMocfTmuM4/QLKQLZ9QIslBwFDqGkRaKR
         Nalu2EhT83YJzP8X3y3VqF99al81l3vbeMWMq6Vv8cV0pT2GHKQG6TiZyPyxGWJJH0+w
         uiXHRZi806sGyKzldGWmP+mv8uuH2IL46hSwD0xgwvmeXYFr1mZmXJNtmnOpcpCZ2TU9
         LlX+Hvk2kLpmjnlVLNn+CmX1fXrBN8qP38IAz7RxpAbrzukzszYTb5z7N1xNWI48iTPq
         KFLfb5HFylzoR1RIOZsvqdTxQbst5LNBijEISkOESca8sUNG/W0wbcjbhJs6XTeJjxqH
         +W8A==
X-Google-Smtp-Source: APXvYqyFzpguQlvg2yrB3GTEFA5hP/raLtejdwArbzB/ifkPk8m/SyboHpSof39lpBUIHCeFgRv34I646g==
X-Received: by 2002:ac5:c2d2:: with SMTP id i18mr1273686vkk.36.1561559282687;
 Wed, 26 Jun 2019 07:28:02 -0700 (PDT)
Date: Wed, 26 Jun 2019 16:20:12 +0200
In-Reply-To: <20190626142014.141844-1-elver@google.com>
Message-Id: <20190626142014.141844-4-elver@google.com>
Mime-Version: 1.0
References: <20190626142014.141844-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 3/5] lib/test_kasan: Add test for double-kzfree detection
From: Marco Elver <elver@google.com>
To: elver@google.com
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, 
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adds a simple test that checks if double-kzfree is being detected
correctly.

Signed-off-by: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 lib/test_kasan.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index e3c593c38eff..dda5da9f5bd4 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -619,6 +619,22 @@ static noinline void __init kasan_strings(void)
 	strnlen(ptr, 1);
 }
 
+static noinline void __init kmalloc_double_kzfree(void)
+{
+	char *ptr;
+	size_t size = 16;
+
+	pr_info("double-free (kzfree)\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kzfree(ptr);
+	kzfree(ptr);
+}
+
 static int __init kmalloc_tests_init(void)
 {
 	/*
@@ -660,6 +676,7 @@ static int __init kmalloc_tests_init(void)
 	kasan_memchr();
 	kasan_memcmp();
 	kasan_strings();
+	kmalloc_double_kzfree();
 
 	kasan_restore_multi_shot(multishot);
 
-- 
2.22.0.410.gd8fdbe21b5-goog

