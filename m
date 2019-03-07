Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F9CDC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473272063F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 07:51:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473272063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB19B8E0003; Thu,  7 Mar 2019 02:51:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D631A8E0002; Thu,  7 Mar 2019 02:51:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C784D8E0003; Thu,  7 Mar 2019 02:51:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7570A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 02:51:29 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id n12so3052466wmc.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 23:51:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=doVSihVtvnS6CkNQalvfCsjdYDgV4LO3GBdowmBNjww=;
        b=cu9sG6KfsKkYTSm5wzwvSaH4H7qzgd+8lV+CjFUsrVgEYW5vjHtD9TvUp5q8fJOw3c
         fG3fLLb/8KaaohgXCh061YpOX3txRzRjg37+bAbLi2qPLNwZLB75rijnWAUju89QpqqV
         Ix6EU88b0l+tfGscD09JoiFx5bQgRu8QvHAVBG3YLrQa6K9MMe0AEDs1T87sRD8sEbvu
         hjyC7o2Finl1TFbJvKjxr6/v9e71kb0wr+F0EvRMfUa93gQRGpxRS8aaLZ3xH0799DVR
         2W/XemtyJD6bt9jUIPq0Y9f57Bm0ufaB1OrX/M5zeSpB0dXi6Gkf4RLMHVWWzs5+cz+S
         GGGA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAW7OwJf2Gs1Z+p7YLvV4uFtEyuxONtil/Jl6DphXwiJBRMz7yWg
	axD5fd8iCK17/ceAwG4jHhFc/Nz0ovF4u2edux0dfU6qHBnkkJYurNIfkwkcjcSfkeLRCqfvpqN
	4KqfwjahnfXFvYP9tE2fAaL9XhHLcepog2KTQBlAQ0e7R3FmNktajXgoP3fVV0a0=
X-Received: by 2002:a1c:63d4:: with SMTP id x203mr4905619wmb.128.1551945088696;
        Wed, 06 Mar 2019 23:51:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqy3tJpucucNbfrv9C80ACjE2tbGn+Ffh40X4t0bcgvbKWZL9i/HcHAmPyKyEDVmVUj5ub5m
X-Received: by 2002:a1c:63d4:: with SMTP id x203mr4905570wmb.128.1551945087407;
        Wed, 06 Mar 2019 23:51:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551945087; cv=none;
        d=google.com; s=arc-20160816;
        b=Yw23NJ3t57QyjxeDMtZr9ZvMKVnjYJvv61UMpGPGjk3Xx9Ptxw7aFe7RE+w4j1VJdr
         lgOd/CrIJKSRSy68uMmKVEAMnKUiBLuP31HTcQiedZSqTkhfCxlYC4N/YgufahVtCY3X
         kvxBj1/nju8Bd4On0cxjDQrSnhc7QQKtawRAqgWMvVLruaQoift6dJgsJpM2kPJzSAZe
         s4x4pS+eJdH3JRZibOy/sOYiLGu1Xl0yA1UCU4oZbL70zJ4hxYJHyqA+pATXIHl3Zhp3
         c726EV9rX9amMZpjGGdIxvdgBabYNjoqywcYaOnsObCZEeHcqo6hnCJLSTvqlsIOq/y1
         jQcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=doVSihVtvnS6CkNQalvfCsjdYDgV4LO3GBdowmBNjww=;
        b=E38et0tSODnkfSc+hkVHeywm+PL4XKqfdfJppXlE/8LcdR24klu2WdS1f/9Rf6w9gH
         5Gs5eemdPyxvPxjR6uKy/YkEnL0J/WnVIzr3lwE3B6x2JKgaKdS4swv+rvJ8YOCPPPBz
         KoKt+QgpiZv8w2s1Vi5EWrIlBwW7942yGHT40+AVp5Aq6WZoSmuyICMYbG/zB0ot2uFm
         Hv07iFNMPrZ+2YuiZHZ3HitZLAlt9P0+fqBe1pGRLBBwfyqus2osgEQ0VTsi/YFxNITR
         lBfEL1anVDhILP8qfdqteSwSGz57/NrjCrUYsbAJ9p2zC4NwF+4ZgctDXFoyGzF02CSM
         jpAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id b14si2494830wrw.257.2019.03.06.23.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 23:51:27 -0800 (PST)
Received-SPF: neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.17.13;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.13 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from wuerfel.lan ([109.192.41.194]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.145]) with ESMTPA (Nemesis) id
 1McYTD-1gW1pI21dd-00cwuj; Thu, 07 Mar 2019 08:51:25 +0100
From: Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andrey Konovalov <andreyknvl@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] page flags: prioritize kasan bits over last-cpuid
Date: Thu,  7 Mar 2019 08:51:05 +0100
Message-Id: <20190307075124.3424302-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:veH9Knc6kktqy1oegAvldWvaMKGPY1paYlybq/Hp0sKWNk7FLma
 JKa79ay422Mv9MbcoOUDNPHaSLB7jZq+QX818+mOki0oF8NUOm7CgxX5lt/LtD+8jNI1ltM
 Ym6zcNiH3yMmouiTvVBkleWG+2W7c53iCCf4dPAJ/V9MRoJ5X4t6pW9suuKVK09LSjjPh5h
 +9kxEYL/z7zngiJq5sD9g==
X-UI-Out-Filterresults: notjunk:1;V03:K0:jfZPdugRt4A=:v5VK1smrr5w6HduxLQTC1P
 G/vBUms3YCvASNGSAg3DimYiX8isn4Ux5x4KLOE4F4I26fbfEpJ/tsyCkrHX2EMmyTRXHm1d4
 hkLZS4eJveZUwgohq3Hmn0yBYdgXCgduePN30/0oX52Hsy1vXHcUigfWo0WKk7SjH7AxpihOF
 DxuRw+yIdN9d6jrDUltAK3FxD1lqUMzi0XEDDos6YlrkgcT0ygp9dPUtYmzXgBidKxD5YHOVB
 q8xqOOD7eFodNVfl+EipnlNV9hdnwJq9BreYaMzOvmaEbyoRVNY4SiuSYERJKDfF4x1SyZ8l9
 0zyhnGFzfpRnHGx+PCq/UYfnG/0UqkGn+8UEprRiWgH5p+3uIEinBovAjy0TLQQAh1FwuLBdB
 BgzNgpEfSifeovZyKQ4roCyHxE65V0enmy8Q0wTTfZ86yewWNMt9KfdqKgwvbnr5/071zOLGE
 dWpv//RPTlRTSmO3+JAzKT3y6AEn2VpQQPO7bwT6Kpycv4+9tUCDgQTiQ7h60mw/I6sKltxK3
 +7t7HsOS2a9sz49XIbuCgCzzf/eIc8xH21yEl3URdr5fA6p3lYvLodu+RvallU3Iyf3Xv7iYG
 yEbWgmXQpYe4K6ZkPqLFg/5wf80oY8PNcdPUeyO5oguc54oidPa9isLS4dWoDJyrNKiCgBhtV
 o7uEBrcHSjdkffw2pJ61l4ORYpRchWLKWKviMgV/elZWTBQxhR+HHUuoeKrSDOo0xO6k8zq9Z
 GG43xegM+k4nvuXkDUievmvEZosehzGd1C6ofA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ARM64 randdconfig builds regularly run into a build error, especially
when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:

 #error "KASAN: not enough bits in page flags for tag"

The last-cpuid bits are already contitional on the available space,
so the result of the calculation is a bit random on whether they
were already left out or not.

Adding the kasan tag bits before last-cpuid makes it much more likely
to end up with a successful build here, and should be reliable for
randconfig at least, as long as that does not randomize NR_CPUS
or NODES_SHIFT but uses the defaults.

Fixes: 2813b9c02962 ("kasan, mm, arm64: tag non slab memory allocated via pagealloc")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/page-flags-layout.h | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 1dda31825ec4..9bc0751e68b2 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -76,21 +76,23 @@
 #define LAST_CPUPID_SHIFT 0
 #endif
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#ifdef CONFIG_KASAN_SW_TAGS
+#define KASAN_TAG_WIDTH 8
+#else
+#define KASAN_TAG_WIDTH 0
+#endif
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT+KASAN_TAG_WIDTH \
+	<= BITS_PER_LONG - NR_PAGEFLAGS
 #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
 #else
 #define LAST_CPUPID_WIDTH 0
 #endif
 
-#ifdef CONFIG_KASAN_SW_TAGS
-#define KASAN_TAG_WIDTH 8
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+LAST_CPUPID_WIDTH+KASAN_TAG_WIDTH \
 	> BITS_PER_LONG - NR_PAGEFLAGS
 #error "KASAN: not enough bits in page flags for tag"
 #endif
-#else
-#define KASAN_TAG_WIDTH 0
-#endif
 
 /*
  * We are going to use the flags for the page to node mapping if its in
-- 
2.20.0

