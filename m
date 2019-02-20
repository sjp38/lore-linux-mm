Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A77C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37D52075B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 15:55:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UYFX0F0O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37D52075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F5768E0022; Wed, 20 Feb 2019 10:55:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77D158E0002; Wed, 20 Feb 2019 10:55:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61E9E8E0022; Wed, 20 Feb 2019 10:55:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04F608E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 10:55:25 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id o9so10739973wra.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:55:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=WYT38OLrPVg9S6X2MhbH3YDUija7usseRIKSRWILMjE=;
        b=FU3yRKzYNIbaA4RQ63daGQAjWWLCVVEjeft/xp5GgyWsIg9lzazDonbPNZ4S9l7VfW
         c61ZQCzLtNdxGBJU61FbUWK+vMfBKHEIk8J370Vb0+YitC/UEaMU3NbwfXU6f8al7rbh
         9RfPxZ4NyZC2dmxI5OOW4BujWwatEsikAtYXrLYHrNTQontEuJbMFd6j8uaeQP8BefMr
         ZscS97kkoKneouBBlnc/6BCQIq/4w+HfnrhPtOIt7SNgItc7WX0k+SNFcbrblgeSOYTj
         HO1vStSVlr3eMxcI3AafceNyd/CLn2sjoTxnq1+5sjfc7et8/3Mpb846mrYIlI+nAygz
         KL0A==
X-Gm-Message-State: AHQUAubCbwGO1XjU0ioUeBsJw/v27QnvDb2ZUkU05fslcf0rDmmZfB+3
	f59MNaZTG0T2ORypvrk/MPnKQ0xvWqgTHRXPyFV40eKmWxxxXHTr/1iL4A/XSdovQETru3j1cE/
	WPivQwtrvTOZeBYy5K3yJmJlPlRAWq404WhF/P62jq7SJvGMal2OYcZ5XYsw6+UrY8TMKlEqruL
	E9tetIzOiB+CmFTQ2wZS7aUh1ZADRpWCSE+jD8gKGdlkc2DIhZ/7MdmJz40X/dfVg2xP3yTSHuj
	RHr6QjwTFK9e2uW2ZSxmXT2mzbxPUhhOH7UzvcCd8+SZCVmyx5q0UVqoF/OfnsHGHWaK0G25m2J
	aaaVGHthNpPgTUcBpmTo5gWg4sunYKN9JOgzvftGzrsphoMz1QhjpXKfodRunYpd6C8iBs43C96
	9
X-Received: by 2002:a1c:4c1a:: with SMTP id z26mr7286111wmf.139.1550678124398;
        Wed, 20 Feb 2019 07:55:24 -0800 (PST)
X-Received: by 2002:a1c:4c1a:: with SMTP id z26mr7286064wmf.139.1550678123369;
        Wed, 20 Feb 2019 07:55:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550678123; cv=none;
        d=google.com; s=arc-20160816;
        b=ukzIWfEDmVR1hGJKDw+hUfB9PNkSZ7GY91S+A/0mSvZE5cxTbMQHliQMLI52zeDY4x
         TiD9pRZNmhNgWUfuW1mvd1wwM+ygNzX86mY6q0w+FAC2I/82L/F3OYzZyNVmzUx0YQ+J
         s1pbIH0CuUh+p+IwZn+kXq+ekoO89xSiZFRY0/AEyxzsRpaWDAmx/L1m5GBoBiMwdKo+
         PvI1N03OhfK79tfuhLbwG3Vr55Mrwq//vP8+TpfeIWtJYGrtEtbm9I0OMKsiK+VVsAPy
         9YUL7/BWfKAuL52zh7StDSvrKqiFV+847CMkanjnZn95GfTFUJRmw695qkWItU/JCykG
         UXaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=WYT38OLrPVg9S6X2MhbH3YDUija7usseRIKSRWILMjE=;
        b=IyIppnbocaN7ufkeR/GY2N2mkDArB4LRnIf+TzzwEXKzEa4B110sb9DCqG+dhCxR3p
         McAAxNiN+7SMf9LQcTV9IQ95W4a1S0vMl9TJbax8cjVI8zw7MaHg71KFgRjRxq57IPWT
         UzOiAIoPQzHlIzXOSqf8EWSN1pM/p4PyrYX4f+0zyyEO8oDtLGtcZOEd6HXuWESRfA/f
         gLKewtURoEqqrlBn0uLVEmLJtJQBgkK0EnMorBD9z+Ql3qzNjZiYFrIq6snAfpCaHMa5
         tzWeu7OiyWIOkcyw2HBUiQl7P6p2btqqnvzjRqdfUzeL5h63yrI5A6DdZnyQQQoJL0Lj
         2IBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UYFX0F0O;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor5971165wrq.2.2019.02.20.07.55.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 07:55:23 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UYFX0F0O;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=WYT38OLrPVg9S6X2MhbH3YDUija7usseRIKSRWILMjE=;
        b=UYFX0F0OThw7N0PyeqCyt0irylizzHeD9kLgxsa8k+zjiaCPAzarRJ/HkE6XJ9KCjk
         lKxBE5kvHvbEjQZUTewsDE0gcg0U9ddWJ11dhS2mUWkEsSaQGYh9dcJVnMXk1rRhWx0V
         796niuhMXoifCIGOX3KHMZgkigOQIoQgBXD3LklyqToxv8aMxOKMXHU6JbnZlgDE59Qf
         Edc8+Mb4a7tCtVUcPONrdth2cPdbDKf5K/toe5YIpkMrrLA6RYiiAYUnxD0QsLWlBQOW
         Xv5cvVvJaUiSehf0vBMlnbvASYBXSUc+rxERYW7IF4up0ZjC2UtZM5FqtQzE2a2zGrph
         EKqA==
X-Google-Smtp-Source: AHgI3Ib7iotiEeNe3DMKzry1okFfh8qa+obGm4GtHqr2CY6I9l57NhS0zMjAvSlHCbguN8qtlDB2wQ==
X-Received: by 2002:adf:f305:: with SMTP id i5mr19396335wro.161.1550678122707;
        Wed, 20 Feb 2019 07:55:22 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id r15sm23730158wrt.37.2019.02.20.07.55.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 07:55:21 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Miles Chen <miles.chen@mediatek.com>,
	James Morse <james.morse@arm.com>,
	Andrew Murray <andrew.murray@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>
Subject: [PATCH] kasan: fix random seed generation for tag-based mode
Date: Wed, 20 Feb 2019 16:55:18 +0100
Message-Id: <1f815cc914b61f3516ed4cc9bfd9eeca9bd5d9de.1550677973.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are two issues with assigning random percpu seeds right now:

1. We use for_each_possible_cpu() to iterate over cpus, but cpumask is
   not set up yet at the moment of kasan_init(), and thus we only set
   the seed for cpu #0.

2. A call to get_random_u32() always returns the same number and produces
   a message in dmesg, since the random subsystem is not yet initialized.

Fix 1 by calling kasan_init_tags() after cpumask is set up.

Fix 2 by using get_cycles() instead of get_random_u32(). This gives us
lower quality random numbers, but it's good enough, as KASAN is meant to
be used as a debugging tool and not a mitigation.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/kernel/setup.c  | 3 +++
 arch/arm64/mm/kasan_init.c | 2 --
 mm/kasan/tags.c            | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index d09ec76f08cf..009849328289 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -339,6 +339,9 @@ void __init setup_arch(char **cmdline_p)
 	smp_init_cpus();
 	smp_build_mpidr_hash();
 
+	/* Init percpu seeds for random tags after cpus are set up. */
+	kasan_init_tags();
+
 #ifdef CONFIG_ARM64_SW_TTBR0_PAN
 	/*
 	 * Make sure init_thread_info.ttbr0 always generates translation
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 4b55b15707a3..f37a86d2a69d 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -252,8 +252,6 @@ void __init kasan_init(void)
 	memset(kasan_early_shadow_page, KASAN_SHADOW_INIT, PAGE_SIZE);
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
-	kasan_init_tags();
-
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 0777649e07c4..63fca3172659 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -46,7 +46,7 @@ void kasan_init_tags(void)
 	int cpu;
 
 	for_each_possible_cpu(cpu)
-		per_cpu(prng_state, cpu) = get_random_u32();
+		per_cpu(prng_state, cpu) = (u32)get_cycles();
 }
 
 /*
-- 
2.21.0.rc0.258.g878e2cd30e-goog

