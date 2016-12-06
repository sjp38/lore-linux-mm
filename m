Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2BC6B0069
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 19:50:38 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so527501158pfg.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 16:50:38 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id y1si16705446pfd.3.2016.12.05.16.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 16:50:37 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id x23so17988806pgx.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 16:50:37 -0800 (PST)
Subject: Re: [PATCHv4 05/10] arm64: Use __pa_symbol for kernel symbols
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-6-git-send-email-labbott@redhat.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <72eb08c8-4f2c-6cb9-1e23-0860fd153a2e@gmail.com>
Date: Mon, 5 Dec 2016 16:50:33 -0800
MIME-Version: 1.0
In-Reply-To: <1480445729-27130-6-git-send-email-labbott@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 11/29/2016 10:55 AM, Laura Abbott wrote:
> __pa_symbol is technically the marco that should be used for kernel
> symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
> will do bounds checking. As part of this, introduce lm_alias, a
> macro which wraps the __va(__pa(...)) idiom used a few places to
> get the alias.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> v4: Stop calling __va early, conversion of a few more sites. I decided against
> wrapping the __p*d_populate calls into new functions since the call sites
> should be limited.
> ---


> -	pud_populate(&init_mm, pud, bm_pmd);
> +	if (pud_none(*pud))
> +		__pud_populate(pud, __pa_symbol(bm_pmd), PMD_TYPE_TABLE);
>  	pmd = fixmap_pmd(addr);
> -	pmd_populate_kernel(&init_mm, pmd, bm_pte);
> +	__pmd_populate(pmd, __pa_symbol(bm_pte), PMD_TYPE_TABLE);

Is there a particular reason why pmd_populate_kernel() is not changed to
use __pa_symbol() instead of using __pa()? The other users in the arm64
kernel is arch/arm64/kernel/hibernate.c which seems to call this against
kernel symbols as well?
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
