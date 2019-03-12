Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C19D3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66FE3213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="NqvnAjUO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66FE3213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD0078E0012; Tue, 12 Mar 2019 18:16:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5D458E0011; Tue, 12 Mar 2019 18:16:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 883C48E0012; Tue, 12 Mar 2019 18:16:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDA88E0011
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:24 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l1so1604737wrn.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=Rsr2lGusV3I5iCGIZKB5JSsUmE7r8qg3qRn745C2fwM=;
        b=p9ILBvQWE9meeXVQVP5rYfu9iCMLbOjKoLDRB1I1aegbiSSaPHwBHSUD4ElRZ13s/C
         n5smTjvjQ/FQa1TeYa6KmLhgbTbEE6P/NjH0tEycf7jS0YP2FiZoYcqOHKn+uOqHxpTi
         SPSSO+f8TYlcMFPh9iYfiyButF9FHNzmac28ZJnw0sNICdPqjWXfnDQy6ekPCrdwCIIx
         9tMAPVIOtokXUl6j9722Y1hYT7JY0tx4Xm/F8Wu2VpXaw8ECuBd1ZaHGx0RP11sJAWxS
         0UeLFa2rR1PVR/qQaJitLyT8/i8gx1rNT2djRZxV42EB1DfBUjUXCJfyINvlfUjW7ktD
         3qow==
X-Gm-Message-State: APjAAAV7GWyKJ6edUPumiM1o5GZfvo+kxROkb2Gg0t66qiJuXAY5VXLg
	Dj0lQi8m8UIRNsi34+cgMY2Vuehzis/11lfWa2ToRy47bJaBUFxMk+fcP0MevdXcYZ3GW1MqWLO
	fPYOrd3M6Ria7lE2ELIy5G1X/79ytwvuNF4//jFQzWM4PAd0AJMs4mbZDA/6YwGiX0g==
X-Received: by 2002:a1c:c6c2:: with SMTP id w185mr31503wmf.62.1552428983453;
        Tue, 12 Mar 2019 15:16:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysm8LW5oCcqxK3Gleu/pgq/odvsH1t4BmfXCKV27AQG7bfnB6m3YrWIUk7UDo2l9K1Tg7Y
X-Received: by 2002:a1c:c6c2:: with SMTP id w185mr31472wmf.62.1552428982308;
        Tue, 12 Mar 2019 15:16:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428982; cv=none;
        d=google.com; s=arc-20160816;
        b=GDnI0jLj47yGhfcMXtqMfAZ9cQtiTM3CYApUT9aHHR2AVu229XUvfUcGFwucOkNwPs
         tF+uMtYEJYVpTC5vl9SQkEnKQdunCXRuHJW647sf7gmH/n5Z8/biXaeteBf7r3lBxeOm
         EamqRSO3F3AQnNUvlngtWdqERubr/Gt+m4xkNu2UclE2psFxLgp1LXxajaPFToAGS+sX
         b62mmo0ATr5UD9FQzm1IhdFjD8PieMqgs8F8AuVZZipUZwyH3dwqQUm6S+4IIXYmsrc3
         o7QAJ29RH8zlLO3Hdec2CvTrbdIqqB4VCScq7ef03I+iqvSe/PxfNippnJAMKXvkcMpk
         xldw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=Rsr2lGusV3I5iCGIZKB5JSsUmE7r8qg3qRn745C2fwM=;
        b=XTDsLFvgdpizHHe74c8oSRwBYGp3KKiD7oWeFit2ScFnuPSDE04PoFK7jfjB1a7gRH
         wmtvQbbGPeFT0FyXiAJoEEWO29sotDIMfefU948HnG2UvOlgN5lqDckILqYML2D10Oj1
         cNLuwGVy9UKIrawfQgZ2MzggldrEdAxa2rkdO5wy6adM4KnEg4FKWuQhTiACucambcEO
         p6mtbf4P5r19Nc7Rm+XBxpO+icFxpbKWU4+0YVxckGmzj6d+UEweSwGprmLMY9QJ5n40
         kbzD9iqdIwLZuLwUj0eSz4mT6ypUv99gLwrFKHBj1OZjDPTxHgG/AW7uvlZrU4OJ3UDb
         dhqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=NqvnAjUO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id g11si6276290wru.294.2019.03.12.15.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=NqvnAjUO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7T3sfnz9tylp;
	Tue, 12 Mar 2019 23:16:21 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=NqvnAjUO; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id VZRbI8VkA4s5; Tue, 12 Mar 2019 23:16:21 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7T2X9Tz9tyll;
	Tue, 12 Mar 2019 23:16:21 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428981; bh=Rsr2lGusV3I5iCGIZKB5JSsUmE7r8qg3qRn745C2fwM=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=NqvnAjUOFSVvFxO2pXU9N1Nqp3/2q+fi7ncFIqF+WexHrOA1Vj6q2m6o00HAEg89U
	 mTTF22reS1UkjcOnRwuShhAcPyR6/uPgUTz3LeSDD/XeNulvINZMcgh2jESGGJmljC
	 qIUE+qGt1/aRsvlsBE6XhGw1IPP83QjcnuBkNwDU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 8ED148B8A7;
	Tue, 12 Mar 2019 23:16:21 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id dcCw_wLbl2XJ; Tue, 12 Mar 2019 23:16:21 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5E8AF8B8B2;
	Tue, 12 Mar 2019 23:16:21 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 1ABE76FA15; Tue, 12 Mar 2019 22:16:21 +0000 (UTC)
Message-Id: <40b9062b8bf49322ea4d9f91ca734eb6d93754b3.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH RFC v3 15/18] kasan: do not open-code addr_has_shadow
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Axtens <dja@axtens.net>

We have a couple of places checking for the existence of a shadow
mapping for an address by open-coding the inverse of the check in
addr_has_shadow.

Replace the open-coded versions with the helper. This will be
needed in future to allow architectures to override the layout
of the shadow mapping.

Reviewed-by: Andrew Donnellan <andrew.donnellan@au1.ibm.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 mm/kasan/generic.c | 3 +--
 mm/kasan/tags.c    | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index 504c79363a34..9e5c989dab8c 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -173,8 +173,7 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (unlikely(size == 0))
 		return;
 
-	if (unlikely((void *)addr <
-		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
+	if (unlikely(!addr_has_shadow((void *)addr))) {
 		kasan_report(addr, size, write, ret_ip);
 		return;
 	}
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
index 63fca3172659..87ebee0a6aea 100644
--- a/mm/kasan/tags.c
+++ b/mm/kasan/tags.c
@@ -109,8 +109,7 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
 		return;
 
 	untagged_addr = reset_tag((const void *)addr);
-	if (unlikely(untagged_addr <
-			kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
+	if (unlikely(!addr_has_shadow(untagged_addr))) {
 		kasan_report(addr, size, write, ret_ip);
 		return;
 	}
-- 
2.13.3

