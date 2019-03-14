Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCA44C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 02:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B4AC217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 02:53:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B4AC217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6E088E0003; Wed, 13 Mar 2019 22:53:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD0048E0001; Wed, 13 Mar 2019 22:53:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C981C8E0003; Wed, 13 Mar 2019 22:53:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 812378E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:53:32 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 73so4546134pga.18
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:53:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=0xB4e1lfqpstrykhi2eHtig57G+/kVYcEgrsv936XPA=;
        b=EUC5HlgIjNKX8EgOpaSvXDUgbRWPUrO2XFZelnWZENxgnwdDBT64oWmd+/Z3RpqPXi
         NNX5uCPKLD9y3ZcnvVmHxmppiq4AUpfVfAqVhy4FnN+9TPRgcKGfVjWXCkokO1CL7Gcv
         5epDYRVyoGL0kL/V5XqZtB1SUDEZveWLwAqQOhq2E/S0yACBUEAPajM5vs+M9BtWVwaq
         Mps6QnX83qPEyjVPFdKMyCtv4Kt6rzfq70VdjacgEMcWyLWEQS1EjSNDrE0+rGQkWKBn
         /fSS2EfCiCWrdRrnNHJqA8XaFbzrmIu2X74hOtdspGui9W/R7+1t35+kMEd3hDzPuC1T
         MnPw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAVKEW4ScXyr4rczZC3fBudDPPJEpngUp1pa3qmXi+a5CuXfW0RM
	ZbQtfEvDXp7BVhZoWJeiWbKzzyUfaJqYeDwiRBe6OeP/hSB499m2b+yLSma15v0O/70u98xs4WF
	ZXVzN9+fyRzUJKpR88J9n4qK18Ja0BekuD+MShcbWWoKUR9zxOUxFS1PGrM8Y6HM=
X-Received: by 2002:a63:544f:: with SMTP id e15mr3363789pgm.344.1552532012091;
        Wed, 13 Mar 2019 19:53:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjGNHMmbAGA4+OE0wGm1KsbDXv1tmW+bIBANINuNIDRdYkYssxjd+ga2ksXTS9XnjdqKDT
X-Received: by 2002:a63:544f:: with SMTP id e15mr3363746pgm.344.1552532010947;
        Wed, 13 Mar 2019 19:53:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552532010; cv=none;
        d=google.com; s=arc-20160816;
        b=yoo5bXlNgwFbDsztkkUTnVUD2mfO0BfXBweG5VV7XrYmq14aiR32QkJ5/eL1jIC5M4
         bZ2Twh02Zd/fTS2yuASxmihvUQgKSqhs6/jeaWBHx3cJvRNtqTngYUFpZKiaXUi9nosg
         mQDmjnum04RJ2QAtRE8pyKOttJ2NTBsR1jMyJORg+R/WWwvY30ycwwIhgMpZ1IaNMWeV
         Ksbk4nfTeFWuKGphW7tCtx+du+cXAze2Thb/fh/DwAb57GQG4w0oGyfzbR4dSuLjspvE
         x20hOO9r8nhPGorPVHl7PVQWWenWuHWtpPgQgNNnJOUNWVPpJGxjTiK84URqvF+sZl2d
         U3hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=0xB4e1lfqpstrykhi2eHtig57G+/kVYcEgrsv936XPA=;
        b=lHaePM5nHZj1U+Weusc9SlW8ZRug16Tx/Ia8GWhPqWtrDJQr+2p4J6PkMDwLTnukoQ
         eKxSLwKfRFO2ngKs/51IGsyfRidich6T9nPdu4FbNfLDH+Q4DHGwTAuMLJe04dO5bI4B
         QPRUB3CQWiHmwFG0id08nbG7+XTIOaS4sRhmIZFPPPaTCRO7bCgA7poKzF4TDWe4CVdR
         B01Fc8oPorjQ9it0HjZRsjRgLNkCO2kqms2V2RN+ZGzOhoW10IgyzymnC32xAi3EfjuB
         ob+SEU5rDro4tm+ok3/xpy9VQXpz1YW6FHBrerzOQ8RTCm+CQybP4DOWN8kuM4sSN4Ev
         seYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id ck9si13396559plb.196.2019.03.13.19.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 19:53:30 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44KYDf4Y26z9s70;
	Thu, 14 Mar 2019 13:53:21 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Alexandre Ghiti <alex@ghiti.fr>, Andrew Morton
 <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Catalin
 Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko
 Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S .
 Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter
 Anvin" <hpa@zytor.com>, x86@kernel.org, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
In-Reply-To: <20190307132015.26970-5-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr> <20190307132015.26970-5-alex@ghiti.fr>
Date: Thu, 14 Mar 2019 13:53:21 +1100
Message-ID: <87va0m9nfi.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Cc += Aneesh ]

Alexandre Ghiti <alex@ghiti.fr> writes:
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 5b0177733994..d04a0bcc2f1c 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -32,13 +32,6 @@ static inline int hstate_get_psize(struct hstate *hstate)
>  	}
>  }
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void)
> -{
> -	return true;
> -}
> -#endif

This is going to clash with:

  https://patchwork.ozlabs.org/patch/1047003/

Which does:

@@ -35,6 +35,13 @@  static inline int hstate_get_psize(struct hstate *hstate)
 #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
 static inline bool gigantic_page_supported(void)
 {
+	/*
+	 * We used gigantic page reservation with hypervisor assist in some case.
+	 * We cannot use runtime allocation of gigantic pages in those platforms
+	 * This is hash translation mode LPARs.
+	 */
+	if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
+		return false;
 	return true;
 }
 #endif


Not sure how to resolve it.

cheers

