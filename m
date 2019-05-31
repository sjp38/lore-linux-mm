Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EB1EC28CC4
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33F4E26595
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:16:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="FW/qqnwd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33F4E26595
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3A7A6B0272; Fri, 31 May 2019 04:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EA656B0274; Fri, 31 May 2019 04:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D84A6B0276; Fri, 31 May 2019 04:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFA46B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:16:56 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id o126so7511901itc.5
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:16:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TyU1z8yaq1bO5gAC7lJ3UvtvJG+4a0ROhgbK2ALXN8o=;
        b=Umuoc4xKaeyk4BzbH4d9NLwydht+QXkgVJwiRnkCETpKP1vsAWIcL3RJeM/ejkd4do
         4mBnlfHjAtj1R677Tyl74sEo2X1K6NEU5N24j3MhnAWahCI6LPrQ9d0wH1xkVw0GsEZ4
         CjhRUA0EsX3sTalJdSOJlOOzQjmBELNpD3EJRVoeG6nov/gJycqS0FaqOIq/UhAbLupQ
         h/Ly6+NbELDQZrrGJec6+UtR9MgF/LKaUyX8dvb3OgsQFotkmJwifF1Avj9KskX1RVfg
         yYn5VtoY5xtp7ppICxS3w1EI2+ENhhZEO7G+GD2onoZ/Zdl7yy4ZE52EGQyTnnmHNBSo
         kvYA==
X-Gm-Message-State: APjAAAVvSXsfsoB/H9LjB1t/Wy1kvVE0Seee66RbFMmB9Mnv+oV4RtDU
	IwV8/T6RiBoXw1sNKMPY/kEbkGvsIBsiYWAhPtLOwWiucOTPz8TBqGeYzkGjgOITF/AZt6Ti5PS
	hhiSfTszGZku1eYcBuNHW5bQE6Ytc4cOm0dBvRltoJxUzMZQqZMVUr2sfQqticdCeAw==
X-Received: by 2002:a24:1c8f:: with SMTP id c137mr6705250itc.165.1559290616104;
        Fri, 31 May 2019 01:16:56 -0700 (PDT)
X-Received: by 2002:a24:1c8f:: with SMTP id c137mr6705197itc.165.1559290615068;
        Fri, 31 May 2019 01:16:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559290615; cv=none;
        d=google.com; s=arc-20160816;
        b=tlAFSygIs+DDx+EUhgXytCYanpTzqP87ZPid1VNYcRrEMZjekEsnRVV9L2ohsgXT2N
         Klj/vy+8kDapt3eYBVz+mUS5keSoZODFPS8wXa8FPgBdHzDchMvtXgVorTOPxTQ1YXjY
         1eJO6bkHMxSrAwl57m3iMiYEEcFg+dU1Hcb/hu/4AkzTnovF6r2S1QdS89K2aCk+0lRw
         mz/o+VTOeuKsHS1PuLzJjDy5lCdwUYaXVsf+jGO4qsFrLwSKfTQ6DeiyprPczMQqtEtF
         CyXosCmJ4HtIDzhd/sVZySzQXbWILOAi878QpUl72qmAosRzzLN88SPo2bAfJLYBNINs
         /2dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TyU1z8yaq1bO5gAC7lJ3UvtvJG+4a0ROhgbK2ALXN8o=;
        b=o7sjc4njfFDnAnqLbNq/ILIghCuQLA/FpP0MWKrJXWtPXwqA9mYX0WmLDjFXkmA2Be
         n05TNcBp+uWDkMua24JvGXlw4VEZVsxI0MXblKh/4OtoAdQYaYn9Q9eOU66abzF0o/d9
         0SSQnZigY3M6exi+n7bS0a9Hn3FDgzdMKZe4c2tEiH/dri5eIvsBwMFCL+KrroYT25Ag
         +EdSSkyPhUNnkeTiC4PIkukiCog6GGVUJPCUtoxd5BymvVOZG/hk51K9piSBKSbtf2DK
         BZmYfjzBl58L107AWVeWRY/B6gg7fudQPyyKF2sxqicVMKDVN0IUPO+ZApm6jr/+XU4I
         2W/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="FW/qqnwd";
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor2908637ioh.117.2019.05.31.01.16.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 01:16:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="FW/qqnwd";
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TyU1z8yaq1bO5gAC7lJ3UvtvJG+4a0ROhgbK2ALXN8o=;
        b=FW/qqnwdQpjp6KMKEf6nJ1JbhZZ1Gru4BFb3xt0G/ys9qonneCpXnHW4xCtmIehQln
         /9z4/prGn9WDiKxcPRdExWbHI5VnR8T4pWIVSXGdB+JRnoF6e5Clgo4Sy88kU5XuvvcD
         AA1Xx1sgEO7qrRZC+Iybk5fGtKo2XcDRC0DfL64MfExnBZRIFvAUgF+C6X5Hcn4VXwGs
         PX4Qb2CSJ3Ni0kRyNSsYM3+0i5zRhHQUIpCX+n+eSlaQiktsu8nRn1MmxaGxCT/hldwy
         YlMolgk+sjJiGyQkjMAVrhKdMAtRXo4y9+F/MsJyvRypwvlsbglOXfQUprlXbUaa3gcY
         NnfA==
X-Google-Smtp-Source: APXvYqzLw5Kn1dmC2QWi7Vjf8M5tDzYUEjQgKCiGeLOt/yNhsIg2SGsHLvoWOmr0SYc+/Q0q/zBirv0DBGLcuXCQvYg=
X-Received: by 2002:a5d:9402:: with SMTP id v2mr5590698ion.128.1559290614556;
 Fri, 31 May 2019 01:16:54 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925717803.3775979.14412010256191901040.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925717803.3775979.14412010256191901040.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 31 May 2019 10:16:39 +0200
Message-ID: <CAKv+Gu8S8DaywCdEzQoZvSoE5by87+tBPPDeiVOVzr8naRstyA@mail.gmail.com>
Subject: Re: [PATCH v2 3/8] efi: Enumerate EFI_MEMORY_SP
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-efi <linux-efi@vger.kernel.org>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 May 2019 at 01:13, Dan Williams <dan.j.williams@intel.com> wrote:
>
> UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
> interpretation of the EFI Memory Types as "reserved for a specific
> purpose". The intent of this bit is to allow the OS to identify precious
> or scarce memory resources and optionally manage it separately from
> EfiConventionalMemory. As defined older OSes that do not know about this
> attribute are permitted to ignore it and the memory will be handled
> according to the OS default policy for the given memory type.
>
> In other words, this "specific purpose" hint is deliberately weaker than
> EfiReservedMemoryType in that the system continues to operate if the OS
> takes no action on the attribute. The risk of taking no action is
> potentially unwanted / unmovable kernel allocations from the designated
> resource that prevent the full realization of the "specific purpose".
> For example, consider a system with a high-bandwidth memory pool. Older
> kernels are permitted to boot and consume that memory as conventional
> "System-RAM" newer kernels may arrange for that memory to be set aside
> by the system administrator for a dedicated high-bandwidth memory aware
> application to consume.
>
> Specifically, this mechanism allows for the elimination of scenarios
> where platform firmware tries to game OS policy by lying about ACPI SLIT
> values, i.e. claiming that a precious memory resource has a high
> distance to trigger the OS to avoid it by default.
>
> Implement simple detection of the bit for EFI memory table dumps and
> save the kernel policy for a follow-on change.
>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  drivers/firmware/efi/efi.c |    5 +++--
>  include/linux/efi.h        |    1 +
>  2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index 55b77c576c42..81db09485881 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -848,15 +848,16 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
>         if (attr & ~(EFI_MEMORY_UC | EFI_MEMORY_WC | EFI_MEMORY_WT |
>                      EFI_MEMORY_WB | EFI_MEMORY_UCE | EFI_MEMORY_RO |
>                      EFI_MEMORY_WP | EFI_MEMORY_RP | EFI_MEMORY_XP |
> -                    EFI_MEMORY_NV |
> +                    EFI_MEMORY_NV | EFI_MEMORY_SP |
>                      EFI_MEMORY_RUNTIME | EFI_MEMORY_MORE_RELIABLE))
>                 snprintf(pos, size, "|attr=0x%016llx]",
>                          (unsigned long long)attr);
>         else
>                 snprintf(pos, size,
> -                        "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
> +                        "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
>                          attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
>                          attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
> +                        attr & EFI_MEMORY_SP      ? "SP"  : "",
>                          attr & EFI_MEMORY_NV      ? "NV"  : "",
>                          attr & EFI_MEMORY_XP      ? "XP"  : "",
>                          attr & EFI_MEMORY_RP      ? "RP"  : "",
> diff --git a/include/linux/efi.h b/include/linux/efi.h
> index 6ebc2098cfe1..91368f5ce114 100644
> --- a/include/linux/efi.h
> +++ b/include/linux/efi.h
> @@ -112,6 +112,7 @@ typedef     struct {
>  #define EFI_MEMORY_MORE_RELIABLE \
>                                 ((u64)0x0000000000010000ULL)    /* higher reliability */
>  #define EFI_MEMORY_RO          ((u64)0x0000000000020000ULL)    /* read-only */
> +#define EFI_MEMORY_SP          ((u64)0x0000000000040000ULL)    /* special purpose */
>  #define EFI_MEMORY_RUNTIME     ((u64)0x8000000000000000ULL)    /* range requires runtime mapping */
>  #define EFI_MEMORY_DESCRIPTOR_VERSION  1
>
>

