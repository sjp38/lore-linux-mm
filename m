Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AAC8C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E62E62086D
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 09:45:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="J0Ci+Hl2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E62E62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8368E8E0007; Thu, 27 Jun 2019 05:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EB5D8E0002; Thu, 27 Jun 2019 05:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF928E0007; Thu, 27 Jun 2019 05:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4398E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:45:14 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id v83so3242046ybv.17
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:45:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=Nak00YJk+AEgPvXyyfa6aOMnYdoSdmwezqKF16kthRLX16cb4GMg398kM+468jXuEa
         ur1I8BjIF50xYCNdV5OdXwDcgM6hn4pwxeMAqZ4SnUcKW2CWlg/o3eTN5MDUhwuZ052T
         13Nf2SGFgDbxQgeF9wk0GDbjhY9HfLDdK1hG+M0MJjhSqnvNpoEWH2OFP7u8oAilQbfE
         VvqAoWpb7A9lp3m2cwRV7a3wu7tKUVWTOoL3vGLpv3Wvzzfi2HdjVevNHHjVWEXqBmml
         Ra5TlL/Ehu0YO6OtMrkbRcC1V87AJMWpya8CJaFSykYRs7J3U6cRYpuRtzxXzOzYNWx6
         dTyA==
X-Gm-Message-State: APjAAAWf6K4PPmzEK7DYYtuRmSTFbifh133UjYAV1bFbbXu5nEC6pw5d
	Ox81ku3H+t1otrLQ6wWE3ul8qdMgC0HbLBdziPFqcZzG4AicidduecqzhIyBnsfk6mGgkW2qp4e
	++w+gucaUsvrn2eGmcCOu49N2DauqORfeiG5feShX89vK95n2QFYG8qRqWb++Y4CsaQ==
X-Received: by 2002:a25:d493:: with SMTP id m141mr576681ybf.230.1561628713997;
        Thu, 27 Jun 2019 02:45:13 -0700 (PDT)
X-Received: by 2002:a25:d493:: with SMTP id m141mr576661ybf.230.1561628713583;
        Thu, 27 Jun 2019 02:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561628713; cv=none;
        d=google.com; s=arc-20160816;
        b=HRt/E/HQJja5z/eGt0N0Xez1jbw9JN+oRyVtiyto7Xoog4ZxJmNFsSjIkY6mlypRzs
         VcpHjB/CpEH7T4zkx7ldruGNWQQ7sytHXAHy3yGtWRWfQyRM48YwFaxxxeWHCMkksKLA
         PPP4J/7XPA1d4mJuZf21TdynLsg4ftTH8kR/el5CZZTzIgpR2M0dVN0XnBjPtxDRoLBD
         kdD3H199+3bjjBYBrop060/RMNn2j2njNlyHGnjJ7gPfCU55qEVytNNtUDoJYYNlkEhm
         8vyi6xizFtW2CaqQicKW8nz0aPbaK3QrLprgw9QvUR5BcYqwmT+O8j3rgJYa03I4ASXO
         qQDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=OZR+q14u9dDxuUjgAM2kxiqJ/h7MIAHmwtzV4xcYIFOOpORS0Xs2jb0s6a394RKGdk
         1buvOjjzSGOsIRWtIn3CQ2I4zDVIQ/xxMCv+CBye5r7tFskBADvdarYcmTL8CSTkQTzA
         oBIm9jH1ymWKetEXmSliiRLn3Jpdh2zTCJHLegKjCHvr9eGyAMaSY0Q6G2FgnvKlTwS/
         W6SfrCyldBX4Rv7SbP5/BskXInyOoGY9JPBVgLEwEvqcCvlL4nvm+Jd6kjSGxrKrnF/K
         Q1HSD1RkbPX5IbOTAofJzGP4vrgWwq2yxQ5wCx+Q/+CCHcC8M01wjpW6cmR+qbTenfxH
         vL2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=J0Ci+Hl2;
       spf=pass (google.com: domain of 3kzauxqukciosz9s5u22uzs.q20zw18b-00y9oqy.25u@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KZAUXQUKCIosz9s5u22uzs.q20zw18B-00y9oqy.25u@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z204sor868199ybb.96.2019.06.27.02.45.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 02:45:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3kzauxqukciosz9s5u22uzs.q20zw18b-00y9oqy.25u@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=J0Ci+Hl2;
       spf=pass (google.com: domain of 3kzauxqukciosz9s5u22uzs.q20zw18b-00y9oqy.25u@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3KZAUXQUKCIosz9s5u22uzs.q20zw18B-00y9oqy.25u@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=/Bjb3ErsQTLw+YrlSLkjBcr6K+fvu3f9fORDBwR/vbU=;
        b=J0Ci+Hl2dklL61XlDu+L7c3zA5n+Cr6/DaQOIbrhOtnPcC74yySQ+I5nkFakrDmsxW
         4bi1Q4JaIWXmIUOCc4DIdh/ds39jpfRXGtDW6mU0xdjNAlM9Jda9tH6hbUAdTGAZEeX8
         49vYKspcn666nQb3sq8SwovKzlb21N9T7d8GljQX+tyOtgPUiOjtZI/gKE936+eoqNHx
         rxxaGWQaPKCugOiKAzguIJfywBy0nNvgisRy5RigGtGBtBdfJH3TJYPgtpjGV0zoyJTK
         ZjYB1aD0xLPDgs/tqbM7lVH6PjLItziSxZ1iovnz/Tq5P9P4Rc8eKOb7vfjUUS6OEaiR
         c5iQ==
X-Google-Smtp-Source: APXvYqzrzpOQbBKJXfxXILWs07ouSrOOgu0C1a7VRkp0utCzl0DRrXpztivBKMFnbS0DUZY3rM1cYhRiLQ==
X-Received: by 2002:a25:9a44:: with SMTP id r4mr1814342ybo.393.1561628713265;
 Thu, 27 Jun 2019 02:45:13 -0700 (PDT)
Date: Thu, 27 Jun 2019 11:44:43 +0200
In-Reply-To: <20190627094445.216365-1-elver@google.com>
Message-Id: <20190627094445.216365-4-elver@google.com>
Mime-Version: 1.0
References: <20190627094445.216365-1-elver@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v4 3/5] lib/test_kasan: Add test for double-kzfree detection
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

