Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54EE7C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2013E20C01
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:31:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2013E20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE7166B0007; Thu,  2 May 2019 11:31:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A98F96B0008; Thu,  2 May 2019 11:31:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95FD56B000A; Thu,  2 May 2019 11:31:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 621866B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:31:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j1so1406839pll.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:31:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=WPvixB2cusW++fm3QJW6ASW7ik4SbH/kTd2Di7wczUA=;
        b=Ir3WohTfpEEYDKR7rj7OAYNq1QZ4GElDU2RmORa02tiKTvyDi2+ZXThx+bXYKwK7km
         6ZfKREzGXonmi1Mb7AUfrWzE5sDP/TPXdR4UaZQjrVjxfKOLC1NtuhcTiE42bHNSptlx
         WciQ5RgzErVLWE/G6htFd4omwHMw40xueEbNJEfTvaSI+b1YUfJybv+Xu79K7m05H67r
         Ty8nVH/vGzKY5urR578IUJ6r10lvtsQqHVrg6/ws2qcK8+3U9HTeLzThXTO+ttG25mI4
         HAO5BzKYAPuREC1CFeAGbVzfcdsCBvDFgqX7u3BItWbj3rQegti3fetdY+K4gtXQ+c9N
         cabQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUHw/Ogx8ox9k9i1EKR7KAeck+KR4Vl17EE0h+MIZCDe7ghXiV1
	QTKRVJ3anyt38kVLzkiZAVXOk0kTZs0Tt2EGeTfdZxeLkxlJlD/FtwOp9uuDDxKol7rRVZJM2jk
	9tHDQsg0v54iuEM6KFUML/ZOHFkBpiHXmIA3FutF7WarYjKA4yBojQA7jTiRQ2T8=
X-Received: by 2002:a63:10c:: with SMTP id 12mr4760983pgb.276.1556811081912;
        Thu, 02 May 2019 08:31:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb63tQiDFYwMKlS32KzY/bT/t4OnxwyvBiT0JeLTGuhDFP6FXETYXWSk7yVUkBuJphS/si
X-Received: by 2002:a63:10c:: with SMTP id 12mr4760896pgb.276.1556811080957;
        Thu, 02 May 2019 08:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556811080; cv=none;
        d=google.com; s=arc-20160816;
        b=nPDYx3KDl4rqS93h9WYDro5qfAI7+zf9a4R520uXQAxRoK0BmzX3w3hmLbuRWKkIQy
         zejxMJxNp1YsZvwT0lV90/ki8TLZRZ8PdJjdE5SMUCTGEovod9jX5B2NZfkyi8vD2tHu
         eBQzl2Wo8Q3G8XB7QywmMrhekM1FaW77gXR/uUHN+Wa74gyxRSQmzYdD7qTqs7UXorzB
         g8qD9Z/insEghwG2T7dZWmAoPRLnrq6N5bwRpmwJn0+FBjmFsHOBpXemMj6/tAD0gBH0
         L+U75wiOsh1tyFJWLjA4a93aUnavhha7h+9M13J+T4hadeLTMcH/XYtOpZa7ffpCaBSQ
         KG2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=WPvixB2cusW++fm3QJW6ASW7ik4SbH/kTd2Di7wczUA=;
        b=b0GVTMdH2rfMSIDFYdVGQuPAM+flpbIjVaTM4Eg5jocE+M1EcaNZMZFlO68PjzO7Nr
         04jyd2b8b0grlooCIXVg+YCMrGmYWNlSBPcdFfa6C+RIez0uu2UiPzv5l7ic5QT2nodo
         VdL0+ZY3O7nEZ0qCGgKfSb6qpDe+xOB859ZdpkGiKChZTru++n1Y+uP7i5DYYFvMZZTv
         r9WQfxgsKRZjnXuoP7zzUwGAGAt7SafXx1NixrlwhoG/bygFFAR+DhuNLyaJs94B/QFS
         uAGnrSKcSG15JdnUeJX7AahqcDH+WfKVOBdD0Kcf0mFqNyIcUtF3WvaPwU83C4Y3nR17
         UFmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (bilbo.ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id w2si17048554plk.274.2019.05.02.08.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 May 2019 08:31:20 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44vzkR0Xvsz9sPk;
	Fri,  3 May 2019 01:31:11 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas
 <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo
 <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf
 Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, James
 Hogan <jhogan@kernel.org>, Ley Foon Tan <lftan@altera.com>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
 <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko
 Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav
 Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
 Eric Biederman <ebiederm@xmission.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org,
 kexec@lists.infradead.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] memblock: make keeping memblock memory opt-in rather than opt-out
In-Reply-To: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
References: <1556102150-32517-1-git-send-email-rppt@linux.ibm.com>
Date: Fri, 03 May 2019 01:31:10 +1000
Message-ID: <87h8acyitd.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 2d0be82..39877b9 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -143,6 +143,7 @@ config PPC
>  	select ARCH_HAS_UBSAN_SANITIZE_ALL
>  	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
> +	select ARCH_KEEP_MEMBLOCK

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

