Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A32C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A912420820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A912420820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 343E66B0266; Mon, 10 Jun 2019 01:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F5096B0269; Mon, 10 Jun 2019 01:47:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C186B026A; Mon, 10 Jun 2019 01:47:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6C8C6B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:47:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s5so13720570eda.10
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 22:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Kqmbs+76N5RhN0+0VSNihZMqx161fxdlNEVzx2FERXo=;
        b=b70UeZrIHLzPq/8nkKi1uKOieFvuIZq3at1GbcSMNXeW/E0skwXi6WtMZ+Lnly6erS
         ApxsKf8i6NxfMZb+f0V2OM5IbfUgzq9Or6eNr4CB/t2iF8PvSKh8PWNYdqqN4aBab1ia
         IzypMTFQyiiKQ7+ay7yFOylJchGzTCUdPT7KmBqiHGX392+suAWhMoPg4whc82p9LyDu
         pS+WHMaFjkuE+tPVZH6ubz5IrEEBsDdjAWonKougcb6q0CvUcKN1xonvUYJWmJ+af1Xs
         xDozLWB8MF5LXegAXhGi5TNXbQsPeiRXBMeXZrDu68OSPp6ykM6NSSfAiZuYGPKahldm
         GgDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWmdDHmzjL/HLCgP5MxpsVdbnea4KF1BnYsgWocd5fjYaoASrCc
	pLfkQvqXtTN1yyE3j5VqXnQXKKLgSqdQ7xZgdcZfoVxzcn+/p2fcPYsOmY1tu9dSytN59yu5qty
	GnInzOCQspTydYiBRo5hDfny0Qse0UHZIpBowiDoPtqg1OtlwPyBTRY1vJj7GmWZKmw==
X-Received: by 2002:a50:8ba8:: with SMTP id m37mr43575787edm.29.1560145635397;
        Sun, 09 Jun 2019 22:47:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKPGg4Z2RDfc3u3cAay6isq9oDga4xDvZVCTufk6wu4Q+HuZd7P2baFrIdxmQWaH2CHxmM
X-Received: by 2002:a50:8ba8:: with SMTP id m37mr43575758edm.29.1560145634785;
        Sun, 09 Jun 2019 22:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560145634; cv=none;
        d=google.com; s=arc-20160816;
        b=GDkoftVHrYuleihhUAg6UrWocm9JFhBgqJ2qlElPY8CDJmkdflzauCXsCeIyTHkAgX
         UGRKDoaHe9mOdqUcQujdEHR1fYvbvg4cMKXwnC0GYt8uZxi3Ke/vJ4h+IpufyioG3Hkt
         Ykro5o8YIKE22k+4sLKm6kzANYHbW8OrpoYsHM4KTFbfbEL+G16Th8XX6F9bMpt+bbA7
         N6h5J+gBZvLjz8TCzvKvIS5pabLCelJ6bzVGp7dNmQS2hjkX/aIih7IDsBMV43y3BrE+
         nQOOTrbFWxwa62QaeUxEA6HVnvdeP7ERfzmAxFNmieyhp/XhGhXqlX4DZcF9StODhCQ8
         CGWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Kqmbs+76N5RhN0+0VSNihZMqx161fxdlNEVzx2FERXo=;
        b=hDG779wqQRSiNgjHy8R7xPb01KrJ60b8bmUHWhDyDTcR2y0ujp2M9mVgvOjbopPabg
         KS3D2V43ibowneRFU0UEgKwoiJdGxJIYTXjT15dF4Qghny1Rf3Z4uZH9D8oSYBIFEOhm
         /w+rLRC+s8CdiwuX7/Pi7B74aoOL3QIxBl1gvDxxrOUiFRgPF/EHOwlIHyJkdxhLzeV8
         cuN9NUQlSFiYs96tbDnJmERYBGlBVOwYBkbDFWb9kFF7HmCY88OBddIdkAhhcWzc8V14
         6w9UiQ7+Qs7SSzu/AKe9qXQzIANU/X0ZluLIC8+3UzHi7QTSrZAyCB9y2fxVdUxGyrga
         FSKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k25si7158919ede.169.2019.06.09.22.47.13
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 22:47:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EABA0344;
	Sun,  9 Jun 2019 22:47:12 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7B91E3F557;
	Sun,  9 Jun 2019 22:47:11 -0700 (PDT)
Subject: Re: [PATCH 2/4] arm64: support huge vmap vmalloc
To: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
References: <20190610043838.27916-1-npiggin@gmail.com>
 <20190610043838.27916-2-npiggin@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c49a8fa7-c700-b45b-31b8-1d49afc42136@arm.com>
Date: Mon, 10 Jun 2019 11:17:29 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190610043838.27916-2-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
> Applying huge vmap to vmalloc requires vmalloc_to_page to walk huge
> pages. Define pud_large and pmd_large to support this.
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  arch/arm64/include/asm/pgtable.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 2c41b04708fe..30fe7b344bf7 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  				 PMD_TYPE_TABLE)
>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>  				 PMD_TYPE_SECT)
> +#define pmd_large(pmd)		pmd_sect(pmd)
>  
>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>  #define pud_sect(pud)		(0)
> @@ -438,6 +439,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>  				 PUD_TYPE_TABLE)
>  #endif
> +#define pud_large(pud)		pud_sect(pud)
>  
>  extern pgd_t init_pg_dir[PTRS_PER_PGD];
>  extern pgd_t init_pg_end[];

Another series (I guess not merged yet) is trying to add these wrappers
on arm64 (https://patchwork.kernel.org/patch/10883887/).

