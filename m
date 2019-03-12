Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85340C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:17:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26234213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:17:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="c8XcioCi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26234213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8124C8E0014; Tue, 12 Mar 2019 18:16:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799D58E0011; Tue, 12 Mar 2019 18:16:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EACB8E0014; Tue, 12 Mar 2019 18:16:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 006A08E0011
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:26 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g7so1248900wrp.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=dEzxTiGln0bue6uZbHj/H20SjQwnB1JvnNPVgqIMv3k=;
        b=p8lDuO6lGPrc4pyr9lmHA37yoH+V5cGcNTCviUbXEWt9Q1v4scFsp1Nm/1omfMJLVa
         uzmQbMehrHtFzQoUgvO0kYhKeefHjGOgP5gXhUHwBjzEz2W2lAdHDUtk//c3FnSSVZ6w
         Rf8eTFzafUeiMXNvw90hJ5EeATdcQUVQ8OEqZgSZDxMWcfz535A8ckTfkVg2yrOnd3w8
         dRAaxiVLZ7S9J47Y/IVzwSJuhKfWYpLeZzkHEWeVnkSDjQZX2o6brldGkpNVrK7rnhDU
         PLagCVXE1KOSviuV+ziggUbRkThegqScg/NNA0yrrVv65X5NUiKzsdz09dm8ubpOXJ9t
         uGOQ==
X-Gm-Message-State: APjAAAWh/OObRXiar483Sx6uIAp+rXkyShX/xEOa4qxFmd+B9WvFEhB1
	NzLpwr/aoGvyW1j4LxOcxbhXFFU5Myn2iMQKSkc+Uktbu1NGZBs6PeIpeP918/WGi5UvZNL+rCt
	MMChUTPI6Te3AzMDAiBtwCjGLnlkgB2wJ4QncQl2uhrEOVjcWSJ+I24o0uouWSclrIQ==
X-Received: by 2002:a1c:4e19:: with SMTP id g25mr34109wmh.106.1552428985386;
        Tue, 12 Mar 2019 15:16:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws4PHFZyXCflfBoe/TqKHOXIKROVeXodi9PO4JzGNCIOb75WbO+yUFrHK/Xmi7RLaQQsSm
X-Received: by 2002:a1c:4e19:: with SMTP id g25mr34071wmh.106.1552428984274;
        Tue, 12 Mar 2019 15:16:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428984; cv=none;
        d=google.com; s=arc-20160816;
        b=vjBeuOmjEIKoD5+Oi0Gq46zF3i0M8evqCW5kZkaZ8zi+TX8qseUR2CZYqPo7NLPt8y
         rPM4MCp954QTfaHp2EbSk55Qy6Ue9eTlNWoYBF5+jbHuYeLaP5XGiGv/S0IORb1gM/xh
         1YgLEh7tJf6WSTK5bWhYmiFOaNAFIE+bZWNlsS8Sv5bCyIp2TBd6DuzjIf/41XfNCJef
         HpK15MVGmbeiQ0r3wnuexpiOAti21/DRgoflF0/62dwH0eijIRDdYa6wjscC9rn865lB
         DTPhdCprCfCb/pHJKRM0g0nQUDxV+2qph8C+WyMoNCBkVia02cxMgkWgdG+hKTm4pqVC
         EYXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=dEzxTiGln0bue6uZbHj/H20SjQwnB1JvnNPVgqIMv3k=;
        b=QH03AppgWUGl5vjtHxnsAn8dqezychTy5Cmh8FBPIw7U5fqAbHR8o9LXRXz086ZIWa
         GaRK1B7iKR2AM3FmQO8mZ1SfD6ImoBZYgYgeaK4Lw3Yej5dm+aklD714VNsv+Au9kB3E
         6TJQCIAQnuF1hKl78JHk/9bjLrZES1GyHMcn4N1lOAzaRWPkTWJJk7ru83MbYNBktgRb
         pKSFjvrA2nCSyDNz8ga357Hzh5KCEyPbq5D+jcgCrjmX550kw6U/ZgSUKOnvlfubDqLu
         JKvCCaFKwqDntQggRfcwv6Ytv1YqqadKTdvH8s/6PrN2YyW9dhvn/KXXA6ZW3ioXlQ6e
         ELaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=c8XcioCi;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id o13si6109394wrm.409.2019.03.12.15.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=c8XcioCi;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7W4RDwz9tylr;
	Tue, 12 Mar 2019 23:16:23 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=c8XcioCi; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 62bjLAJtcdl6; Tue, 12 Mar 2019 23:16:23 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7W3BJcz9tyll;
	Tue, 12 Mar 2019 23:16:23 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428983; bh=dEzxTiGln0bue6uZbHj/H20SjQwnB1JvnNPVgqIMv3k=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=c8XcioCi6Zr8+Kp6xAb9yUXdneRo3pqOMJ1PRDU2sB9qOiRQg1QeN8NxmdI0sw8Zi
	 C1Hyab7dVkRqTDrI0m6wwDXP5xTu+FzqpvWQydoQuxGAXk1AC2w+qsOVSGPtLZUlcg
	 N8mWkzbGl8dgqo6eb6MhZBVpDFB1J5EiU1vvSFjk=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A4D518B8B1;
	Tue, 12 Mar 2019 23:16:23 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id rsP8JgWWL1Z7; Tue, 12 Mar 2019 23:16:23 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6C0338B8A7;
	Tue, 12 Mar 2019 23:16:23 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 2B12E6FA15; Tue, 12 Mar 2019 22:16:23 +0000 (UTC)
Message-Id: <4f888b49a3c72105ef8e74997fcb2ab20ad2252d.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH RFC v3 17/18] kasan: allow architectures to provide an outline
 readiness check
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Axtens <dja@axtens.net>

In powerpc (as I understand it), we spend a lot of time in boot
running in real mode before MMU paging is initialised. During
this time we call a lot of generic code, including printk(). If
we try to access the shadow region during this time, things fail.

My attempts to move early init before the first printk have not
been successful. (Both previous RFCs for ppc64 - by 2 different
people - have needed this trick too!)

So, allow architectures to define a kasan_arch_is_ready()
hook that bails out of check_memory_region_inline() unless the
arch has done all of the init.

Link: https://lore.kernel.org/patchwork/patch/592820/ # ppc64 hash series
Link: https://patchwork.ozlabs.org/patch/795211/      # ppc radix series
Originally-by: Balbir Singh <bsingharora@gmail.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
[check_return_arch_not_ready() ==> static inline kasan_arch_is_ready()]
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 include/linux/kasan.h | 4 ++++
 mm/kasan/generic.c    | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index f6261840f94c..a630d53f1a36 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -14,6 +14,10 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+#ifndef kasan_arch_is_ready
+static inline bool kasan_arch_is_ready(void)	{ return true; }
+#endif
+
 extern unsigned char kasan_early_shadow_page[PAGE_SIZE];
 extern pte_t kasan_early_shadow_pte[PTRS_PER_PTE];
 extern pmd_t kasan_early_shadow_pmd[PTRS_PER_PMD];
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index a5b28e3ceacb..0336f31bbae3 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -170,6 +170,9 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 						size_t size, bool write,
 						unsigned long ret_ip)
 {
+	if (!kasan_arch_is_ready())
+		return;
+
 	if (unlikely(size == 0))
 		return;
 
-- 
2.13.3

