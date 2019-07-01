Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D384C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:57:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DC3220881
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:57:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC3220881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F9B8E0002; Mon,  1 Jul 2019 05:57:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB7866B0008; Mon,  1 Jul 2019 05:57:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A62E08E0002; Mon,  1 Jul 2019 05:57:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4526B0007
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:57:17 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id c27so16515470edn.8
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1iauxxUfIEGvJQUGVUPb5P6hHu4AmvRVZSXROty2v8A=;
        b=iec9c4WBO3Dadc6Iix2kYYKXK6eSGg9YtFTsqwXK2kiGljIglwyxRO3bbtayDay7M/
         yG/QXcPuGjNkoJK394CPltQcQRm8MGbS1hSVLk3KDNBjUJUVAYF8s6ImryCH7gl8nu9e
         2djWza7bAXEl88qPBYS6M7s63655xv6LiC6U/tI+OfllFy5a+hQeTQaVdzxVOpd5IYDg
         l8M4XFBRJKITEE85bUpbKDfHPtPT/GQL55mOn6nf2+OOE2nSFPo2gU5igJU7hJUowUlT
         MJXLbc5hKSBEDx1EVsSypjv7GTByyMFfq29HG6J/68Dvf6ZsfvrXerMq+OQTlZ2S6ylS
         PC+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUlgsKOl7AlAHAVApydLBkfsGNd5c0BgRlojpKE9C/Y40PvEOYS
	sH+7p2QxrYHpquZQc7seIlqraxzZVYUCYghUlZZVwlvRaSZFXyEeYYByhrNoGrthccYwk2amJcq
	OeISujyAKXkp7/PidwoCcK3ezEaIlfyXox3Q31ROp/JlvHRj7YwJIdsuI23ZV7/Za3Q==
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr22180476ejb.267.1561975036942;
        Mon, 01 Jul 2019 02:57:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztDQANrrWTWnYedM6Bf7HQNhEci6aY8afpLvodIXu1uJimSMlT9tuv7jTaTOUGVg3qzVAT
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr22180406ejb.267.1561975035831;
        Mon, 01 Jul 2019 02:57:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561975035; cv=none;
        d=google.com; s=arc-20160816;
        b=imvwHr0Jmh4GSxVWClDLFi+q3ooFz4xeymSXEdnwV7pT18JNZHjSluYMywltD6USO7
         5HR4Ue5xl1LfzITcN42orKGhoxlxk+38HcPxmg7BrJ/uGGfokNPW2HQfA7L3poZ8d6qI
         Hq5/DYw8sQvzW0+N8De1fJWtHFlsJjzltM7XoGVxQIRidJCCE0hAsWe36dBHXUUx48Cq
         ypiIOdx4+FGB/u+rMhCIwIqzRTLuaZZl0sIWcyws9FjHFSg2jXTj5dCxoc7lgszP4hy/
         QITMtQtCcQaUWuIbVmZ7HsXMdcqlddoqXESicWcz0MNZXV77GI+5rJeNAC73ahci0GIM
         nAsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1iauxxUfIEGvJQUGVUPb5P6hHu4AmvRVZSXROty2v8A=;
        b=Jjg7bUfyRU7KMqeHMJfKu1JxA5kWYIOjdqdLqD2ubk6YBPSYjzYDtsayif28I8JV3G
         fBEfWLf9D00jWMLRq4OYXxlGaBJEmBWNEXvVyYZpBufy/lAvm9KLOk2jNXHxpcYgcQIe
         naY1IN1A75hX/pwNaiUGmdHyCUfh/Nrc7IdRhwG6imBiRKr14qDIuJcr4bjmP+bEw4GB
         ZE2wIaCNzAm8W8w3FrG9oXw5MfCAbnGIGn6KItBB6ybZarV33vmAt4+x2dB7ly6oUCmY
         EBSDj8G7BL65qYn6msTZPZuxhGXLcQCYzwaGX3+unVAy/luXMYrrbRU9HJCRk1SbGm/s
         +yAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b14si6608539ejb.289.2019.07.01.02.57.15
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 02:57:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CCCC92B;
	Mon,  1 Jul 2019 02:57:14 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8156A3F718;
	Mon,  1 Jul 2019 02:57:10 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] arm64: mm: Add p?d_large() definitions
To: Nicholas Piggin <npiggin@gmail.com>,
 "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>,
 Mark Rutland <mark.rutland@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon
 <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 "linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
 "linux-arm-kernel @ lists . infradead . org"
 <linux-arm-kernel@lists.infradead.org>
References: <20190701064026.970-1-npiggin@gmail.com>
 <20190701064026.970-2-npiggin@gmail.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <0a3e0833-908d-b7eb-e6e7-6413b2e37094@arm.com>
Date: Mon, 1 Jul 2019 10:57:09 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701064026.970-2-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/07/2019 07:40, Nicholas Piggin wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information will be provided by the
> p?d_large() functions/macros.
> 
> For arm64, we already have p?d_sect() macros which we can reuse for
> p?d_large().
> 
> pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
> or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
> configured this way then architecturally it isn't allowed to have a
> large page that this level, and any code using these page walking macros
> is implicitly relying on the page size/number of levels being the same as
> the kernel. So it is safe to reuse this for p?d_large() as it is an
> architectural restriction.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>

Hi Nicolas,

This appears to my patch which I originally posted as part of converting
x86/arm64 to use a generic page walk code[1]. I'm not sure that this
patch makes much sense on its own, in particular it was working up to
having a generic macro[2] which means the _large() macros could be used
across all architectures.

Also as a matter of courtesy please can you ensure the authorship
information is preserved when posting other people's patches (there
should be a From: line with my name on). You should also include your
own Signed-off-by: line (see submitting-patches[3]) after mine.

Apologies to anyone that has been following my patch series, I've been
on holiday so not actively working on it. My aim is to combine the
series with a generic ptdump implementation[4] which should improve the
diff state. I should be able to post that in the next few weeks.

Thanks,

Steve

[1] Series: https://patchwork.kernel.org/cover/10883885/
    Last posting of this patch:
	https://patchwork.kernel.org/patch/10883899/

[2] https://patchwork.kernel.org/patch/10883965/

[3]
https://www.kernel.org/doc/html/latest/process/submitting-patches.html#developer-s-certificate-of-origin-1-1

[4] RFC version here:
https://lore.kernel.org/lkml/20190417143423.26665-1-steven.price@arm.com/

> ---
>  arch/arm64/include/asm/pgtable.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index fca26759081a..0e973201bc16 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -417,6 +417,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  				 PMD_TYPE_TABLE)
>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>  				 PMD_TYPE_SECT)
> +#define pmd_large(pmd)		pmd_sect(pmd)
>  
>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>  #define pud_sect(pud)		(0)
> @@ -499,6 +500,7 @@ static inline void pte_unmap(pte_t *pte) { }
>  #define pud_none(pud)		(!pud_val(pud))
>  #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
>  #define pud_present(pud)	pte_present(pud_pte(pud))
> +#define pud_large(pud)		pud_sect(pud)
>  #define pud_valid(pud)		pte_valid(pud_pte(pud))
>  
>  static inline void set_pud(pud_t *pudp, pud_t pud)
> 

