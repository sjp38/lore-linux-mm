Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA6EC28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 11:19:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CFFB2075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 11:19:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CFFB2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66926B000E; Wed,  5 Jun 2019 07:19:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3FDF6B0010; Wed,  5 Jun 2019 07:19:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B53F86B0266; Wed,  5 Jun 2019 07:19:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 802D56B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 07:19:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so14569886pgo.14
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 04:19:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=Wqm76YMczlqB0UEhlA+7k1eDT0ZHfNZ4UD767P7sevQ=;
        b=h0y8PP87FSnaQAqeeTEFsXWIM59+c+Op7g+nOI5SmUeHNkjPEgotqWtr4nRm7QvU4+
         /93/X+JIBLLqdH3KG7Wf3Miw7duEmSyOCH3ks7wO921xWdilV2pEl0r92wdUhT0XfUjd
         V03hUg9/6XXbtL1MM/cS2fAXuD/BjU8lIEc8wMYxJFgDjKp4/WNjreIe+o+qpORsK3jN
         tC+sytpIyiUnvR76gH1qeYxdJPGCbgWUzwIQUkC6TFI4+sRTnPn4onFvNWYgARNAhq2A
         MyxgoRcUkprYp2/2gAdY2NeFWgIhb9F4ob4uMm6kxlPmBdFAwjpICWwRGRYZXz2uzNui
         6Wug==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUWGr4S35Qte+xSScg7P0N8JNs8hOadLj0X3MPiN5/MbdOVMH/G
	8NwWXRovEFOtncvD7yqjY/al5EsgidZ/2NdzCq8ozT+y0OzVVIzF9W7NNtafZWHeiwcbra/EXWs
	AJOjEoQ3cz3aarGy03qDn+cm8E9YuRbn26vPdO0BvQUYAAjEE+KmxS1EyjIVZJ5E=
X-Received: by 2002:a17:902:b944:: with SMTP id h4mr41103269pls.179.1559733571111;
        Wed, 05 Jun 2019 04:19:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyX8gfvx8G32+OuwBkWCsF2+GnSWLgs4imKh1o35oieMwkAx4Z0rxUXp8vTR2D8P0HIX1Vy
X-Received: by 2002:a17:902:b944:: with SMTP id h4mr41103218pls.179.1559733570207;
        Wed, 05 Jun 2019 04:19:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559733570; cv=none;
        d=google.com; s=arc-20160816;
        b=rckiygknYx1iQPbQUUhDVYaSaMoccUQTuGz6A6Ne8lssB8Dlou8rq4CUOJAGnq8Vvg
         AksN2s2OoKCWg7Exne7Xe+3CkUkwrDEvzVsrvFMu2BYdwn+lPaMYSA/M+gTzmB93SWA3
         9tgL5RSH1b48aS7Xw2syQmiA8AeefMk2XWplpWRB4RYime23s2PPvob1arlIXlRo4eGn
         SyQ9ny4PdnQB5ei3E9UVUKQXkKFGS5INeeOZGUkx1EPkKTvRF34NmV5On+K7RMYS1RNg
         iduGLjEP9fJ2tdGo87hJ2U4wYAy//Jdmy3xiMKiNXOuFIRi9rruECVxtXp1nXUGhuMrh
         STPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Wqm76YMczlqB0UEhlA+7k1eDT0ZHfNZ4UD767P7sevQ=;
        b=gLUcZY/t1beaIe5+I1/9JyveZvQMy3zeIXxBq6Lv82feVb7OZ9ed9s+JI64Mgfc1IL
         DjCj3RIA4oMCBLeCYVt5ZkvxLPByOF8T9oLYBvGmf7J38Rp2cq5Xs7S+QR9UMJGn9GTT
         BWp/Q3sKHofBKs1LbKl11ERbnPDqeOC74BgrMKDyJCNWihL1PgjTuqxxKk/+bTO/NnoP
         EddRcgu1eomVrc5dV6qgbI5GlWaOSkPrnRIVc2FuSzZLc528qhTU9VGYF8Z7z7uD8GT3
         NKB81ERCfM8sIxfQEv0p9rzc/cwfyFuNyPvn34QK56mY90G0FGG/iSxO2WJt9zFbNVIm
         pKQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id x1si27510806pfx.152.2019.06.05.04.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 04:19:29 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45JmXD0rHVz9sN6;
	Wed,  5 Jun 2019 21:19:23 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, Paul
 Mackerras <paulus@samba.org>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko
 Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, "David S. Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra
 <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski
 <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
In-Reply-To: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
Date: Wed, 05 Jun 2019 21:19:22 +1000
Message-ID: <87sgsomg91.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual <anshuman.khandual@arm.com> writes:
> Similar notify_page_fault() definitions are being used by architectures
> duplicating much of the same code. This attempts to unify them into a
> single implementation, generalize it and then move it to a common place.
> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
> now contain upto an 'unsigned int' accommodating all possible platforms.
...
> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> index 58f69fa..1bc3b18 100644
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -30,28 +30,6 @@
>  
>  #ifdef CONFIG_MMU
>  
> -#ifdef CONFIG_KPROBES
> -static inline int notify_page_fault(struct pt_regs *regs, unsigned int fsr)
> -{
> -	int ret = 0;
> -
> -	if (!user_mode(regs)) {
> -		/* kprobe_running() needs smp_processor_id() */
> -		preempt_disable();
> -		if (kprobe_running() && kprobe_fault_handler(regs, fsr))
> -			ret = 1;
> -		preempt_enable();
> -	}
> -
> -	return ret;
> -}
> -#else

You've changed several of the architectures from something like above,
where it disables preemption around the call into the below:

> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +	}
> +	return ret;
> +}

Which skips everything if we're preemptible. Is that an equivalent
change? If so can you please explain why in more detail.

Also why not have it return bool?

cheers

