Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97230C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4642C213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Yb6UzHtN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4642C213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCFCD8E0013; Tue, 12 Mar 2019 18:16:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDDFF8E0011; Tue, 12 Mar 2019 18:16:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A365E8E0013; Tue, 12 Mar 2019 18:16:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 430108E0011
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:25 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p3so1595627wrs.7
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=D8w+m6PVWbWnbVuhF9ZKnJbxwUjNhp1FDRV4ywUWxfs=;
        b=Zil/mr8RZMIQprpPFwhHeiot9mViNg9v5wGSihOtMbBnMNlY/ly91gyGQYbxmF+3os
         9YKqcMGMyI81tFYHZGv4+phQ2klMb9/2r1dTBI9gIo0gNj7E6oeszSpAtXMClkpdp6WG
         pfFDJE9l0HaL5nFzxRA+BAXqRiqF5AYAFQkJ/zvXBLBgdwo+Vp6ccf2Uq1VhMYo9BHzI
         uThKMu73/tKnDEQgSNqD1/Sc6KZOSWAYB+QMYvX4v9DRYvgaqm2l/mQ3EjAJZDQt278M
         jTV7NZA9w5avGoqiXWtN9PHmGotjpfxHiqdcSg1n97nPN/1gooqWrpNz8IhD9sFW1w73
         x77Q==
X-Gm-Message-State: APjAAAXZTPb36Lo18aPkL5HxhKTBnndjFZdVaExOPfP2kCT1LpPa5DuD
	7t0V9o+rnfxwQn5//t6gFXOhichhylhydmepVCNRuuNFIpKadYyf4eOiH9o0E9ljDCqHDKQ1XRa
	SLE0IpAq9V1Ob2J4ujAKutAGhNWqn7b6dorzaVTr/tsSaFr5tynQoAUBSd8KIDfBUnQ==
X-Received: by 2002:adf:b64d:: with SMTP id i13mr20247175wre.292.1552428984487;
        Tue, 12 Mar 2019 15:16:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhyDjwcq0RhxKrISq+LHph/nfA7IPmV1cNS91yVn3/dIIsFQSbZXdDFzonTQKW6xiTeoH9
X-Received: by 2002:adf:b64d:: with SMTP id i13mr20247139wre.292.1552428983225;
        Tue, 12 Mar 2019 15:16:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428983; cv=none;
        d=google.com; s=arc-20160816;
        b=WGW+hwI+RzXqkFInjMbLBFCExbenF3lEZt/XjHYsjzCz54hV69e4/KC9hkdVjnC2T1
         nmKCePv3cnC9VgiJkEjLv9v222zNZkk8XvbQbqBeq+m8p/upZ7StljbC9BHKzPLudEfR
         bpECgUZRY/o3XjvTYoFf5pXrHaqkP9p8FzwDkyJSB2XQRk1PuBy63ppztkyaZJfbG9tX
         uqVWkfTnF4TEscs6KOa/cBAgoXELSqQMHiLpV5DfVGkt/BWr+MiQw9usOxn08S6rXo9H
         KqKdQE+3F1h6AFD3xipzD22e7b35VYh5XqH9EIl0zPQwpci7rLYph523DGQehLqxbXX1
         OtIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=D8w+m6PVWbWnbVuhF9ZKnJbxwUjNhp1FDRV4ywUWxfs=;
        b=S1TqLQFZpDH+PoqoTbFganQPNIBcrQYqiG6Ngw2kQxq+xuvD7o3F6d/SQhHoUNu/9P
         SNoPG23YVqM4DjP6JBMzraC832+7c+HENNG+kAeXw2ZUpzIsJRs+aL2g/qUui47s6yDt
         1R5KWO9mapk3ol5tu5rEQDZGRiHS/4POAgfwEpW39qWa0XBrVo1PIxJZCpr7RWu9qgXD
         bOCpcIK9WrBM8qIhtPoQbclVc9GMKxyIKfowUhMX3Yv1xwtf69/jvg48H1QKfJetzWE+
         jGU8iv7deJ8TC1sbjW1CoQLTQ9Guza1Gifwnq7tCF+OpCSmmNge8ckLvrKc0ByFt/Nc3
         sMxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Yb6UzHtN;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l13si6127724wrr.124.2019.03.12.15.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Yb6UzHtN;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7V4K2Fz9tylq;
	Tue, 12 Mar 2019 23:16:22 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Yb6UzHtN; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id vwXcDA_2HKgG; Tue, 12 Mar 2019 23:16:22 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7V36Fvz9tyll;
	Tue, 12 Mar 2019 23:16:22 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428982; bh=D8w+m6PVWbWnbVuhF9ZKnJbxwUjNhp1FDRV4ywUWxfs=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Yb6UzHtNwFgb6Hxq13PPwFfbyi7aIHatfH6zZ/4zN3oa6InMCvqGTYwCJ5RIvCDrM
	 icUKoYFtxRiWabE0zKzjt7lbjVgWsHYbAuY/f0FlOCqzI6v+I04QJRK+Zi6H3b1vfF
	 Y3zXlOS/T2ylFG+3vXLJVZRwZDB0EgvWHQ73oqrU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A0E3B8B8B1;
	Tue, 12 Mar 2019 23:16:22 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id seg9g2DF1DLM; Tue, 12 Mar 2019 23:16:22 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5F43A8B8A7;
	Tue, 12 Mar 2019 23:16:22 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 214836FA15; Tue, 12 Mar 2019 22:16:22 +0000 (UTC)
Message-Id: <6350da5e480a2006b8990124d74cdbfa70704d98.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH RFC v3 16/18] kasan: allow architectures to manage the
 memory-to-shadow mapping
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Axtens <dja@axtens.net>

Currently, shadow addresses are always addr >> shift + offset.
However, for powerpc, the virtual address space is fragmented in
ways that make this simple scheme impractical.

Allow architectures to override:
 - kasan_shadow_to_mem
 - kasan_mem_to_shadow
 - addr_has_shadow

Rename addr_has_shadow to kasan_addr_has_shadow as if it is
overridden it will be available in more places, increasing the
risk of collisions.

If architectures do not #define their own versions, the generic
code will continue to run as usual.

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 include/linux/kasan.h     | 2 ++
 mm/kasan/generic.c        | 2 +-
 mm/kasan/generic_report.c | 2 +-
 mm/kasan/kasan.h          | 6 +++++-
 mm/kasan/report.c         | 6 +++---
 mm/kasan/tags.c           | 2 +-
 6 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b40ea104dd36..f6261840f94c 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -23,11 +23,13 @@ extern p4d_t kasan_early_shadow_p4d[MAX_PTRS_PER_P4D];
 int kasan_populate_early_shadow(const void *shadow_start,
 				const void *shadow_end);
 
+#ifndef kasan_mem_to_shadow
 static inline void *kasan_mem_to_shadow(const void *addr)
 {
 	return (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
 		+ KASAN_SHADOW_OFFSET;
 }
+#endif
 
 /* Enable reporting bugs after kasan_disable_current() */
 extern void kasan_enable_current(void);
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index 9e5c989dab8c..a5b28e3ceacb 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -173,7 +173,7 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (unlikely(size == 0))
 		return;
 
-	if (unlikely(!addr_has_shadow((void *)addr))) {
+	if (unlikely(!kasan_addr_has_shadow((void *)addr))) {
 		kasan_report(addr, size, write, ret_ip);
 		return;
 	}
diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
index 36c645939bc9..6caafd61fc3a 100644
--- a/mm/kasan/generic_report.c
+++ b/mm/kasan/generic_report.c
@@ -107,7 +107,7 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
 
 const char *get_bug_type(struct kasan_access_info *info)
 {
-	if (addr_has_shadow(info->access_addr))
+	if (kasan_addr_has_shadow(info->access_addr))
 		return get_shadow_bug_type(info);
 	return get_wild_bug_type(info);
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 3e0c11f7d7a1..958e984d4544 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -110,16 +110,20 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 					const void *object);
 
+#ifndef kasan_shadow_to_mem
 static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 {
 	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
+#endif
 
-static inline bool addr_has_shadow(const void *addr)
+#ifndef kasan_addr_has_shadow
+static inline bool kasan_addr_has_shadow(const void *addr)
 {
 	return (addr >= kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
 }
+#endif
 
 void kasan_poison_shadow(const void *address, size_t size, u8 value);
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index ca9418fe9232..bc3355ee2dd0 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -298,7 +298,7 @@ void kasan_report(unsigned long addr, size_t size,
 	untagged_addr = reset_tag(tagged_addr);
 
 	info.access_addr = tagged_addr;
-	if (addr_has_shadow(untagged_addr))
+	if (kasan_addr_has_shadow(untagged_addr))
 		info.first_bad_addr = find_first_bad_addr(tagged_addr, size);
 	else
 		info.first_bad_addr = untagged_addr;
@@ -309,11 +309,11 @@ void kasan_report(unsigned long addr, size_t size,
 	start_report(&flags);
 
 	print_error_description(&info);
-	if (addr_has_shadow(untagged_addr))
+	if (kasan_addr_has_shadow(untagged_addr))
 		print_tags(get_tag(tagged_addr), info.first_bad_addr);
 	pr_err("\n");
 
-	if (addr_has_shadow(untagged_addr)) {
+	if (kasan_addr_has_shadow(untagged_addr)) {
 		print_address_description(untagged_addr);
 		pr_err("\n");
 		print_shadow_for_address(info.first_bad_addr);
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 87ebee0a6aea..661c23dd5340 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -109,7 +109,7 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 		return;
 
 	untagged_addr = reset_tag((const void *)addr);
-	if (unlikely(!addr_has_shadow(untagged_addr))) {
+	if (unlikely(!kasan_addr_has_shadow(untagged_addr))) {
 		kasan_report(addr, size, write, ret_ip);
 		return;
 	}
-- 
2.13.3

