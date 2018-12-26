Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5CC7C43612
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 12:02:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6629721720
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 12:02:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="jqpnXoNu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6629721720
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF938E0002; Wed, 26 Dec 2018 07:02:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B98FF8E0001; Wed, 26 Dec 2018 07:02:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A583C8E0002; Wed, 26 Dec 2018 07:02:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFD08E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:02:51 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id c73so18454982itd.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 04:02:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JVjRXbgxFYGFk9y6ELrr8A6OdFVvdGFRoOhZs8VKPx8=;
        b=CGCLwntZ/unJAq07ZhhSzD5xdJZLu2gjS5hRMsh3GOMrs5xdL755b7tR/MAKpvo06U
         6cSkc6zS3bf9G3svQQUIU85FYSs/1Kdyk9+RGprM6O+tjbvT+sMu/YqwILZJaWaog5oa
         q8R2IOmvwC6vHJU122ayUhK3rMp6uwCO1w4lWrtXSdwLeCnigfoRDfGSAtocf+lfLIq/
         aZsMDwYauk2PMkWlW3I0u2kZ0QdyTIWAnaRn0Mt/N8eJh+H+k0bjt5CXn+mxpFyOi0x4
         zO0gS9vN6fsMSONSz/Z4ggeBjwCEIJ9dSbABgRRjabawufRRMOZk48UsgVkG1LR9LpMO
         HPuw==
X-Gm-Message-State: AJcUukfWl9mIJ/i6f58VRRLb9a7xuq+dZKV2u8jyVfLcfQBC3DmN/vTK
	2x3rdQRCbDtioAvMoU+9j8+P9f/dNkK0hhJltkLK3ILoOqmIDyd2Acs7tL+YSOPOPVOu7SWCQ1x
	HM0M9aIjNewrpbBVNd1ofJgdx1QzPcFJIrGHZgYFAwYMOLMdCh0HOJcP8HK/UW3jf7dqk+uYeLu
	qtOtv1pkltczvO+kcfzeVxPBUPBCUSj9r1OMD/Rq5+12dr8pPq3+FjW4pubdyYUsF3ZjXKO6m7q
	fuQA5sYfvPqVMrfWCVvVCLic4VvN0JzSTMA0ye9VyMdB/UvrOXB4NMq7Xdm4Atzcum1QobaXnrK
	C7KZPd1o5qE2zyoMzWJbjmCUg7GI8i6TLCKnGXJSxLPMGfTPYpJEH8aeozzMKaUCe4vEOWD0xuO
	4
X-Received: by 2002:a6b:5012:: with SMTP id e18mr14223139iob.73.1545825771242;
        Wed, 26 Dec 2018 04:02:51 -0800 (PST)
X-Received: by 2002:a6b:5012:: with SMTP id e18mr14223095iob.73.1545825770459;
        Wed, 26 Dec 2018 04:02:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545825770; cv=none;
        d=google.com; s=arc-20160816;
        b=ehKK1Bus33URyAjLHBIllOgYbvUlZdy0HEWn2ao618NAWMn7uMCbtRNmq33hYxpQ3p
         5wxguBep6mO13CRdDBIr9HwvnhvRAJimrXOozyBYYJ7lyQeF5FwQyP0jM/nwzRtmFzeA
         uAh3UScdLm+mGUDs9r7wxgx5YW0e+lTi9qP4NTRq8M7u2M33WME2UamtmeL3wy/hd5dU
         SPtro3goh0X+h1P22svUsU8w8vvrE9cge+tTchEx74f6ETW6K+2CTymYbp/ciJMb72wZ
         ZloYpFyfYg6ZS0lUwR7iq0i+FiWHUvWf0r8b3BXlB+WcTgpwMuCrPlV6FouP/fvqcE+J
         pjcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JVjRXbgxFYGFk9y6ELrr8A6OdFVvdGFRoOhZs8VKPx8=;
        b=SX50Te1upeMp1lHVhtuhl1XtHcZ9APqsM0Rdfq321Wh66vrQG02SWy9mwAq0HQuChb
         JfqHA0RlbDPOqQAsnDWzfZokkdgP+K72amKqnR51HAbW6iLVydP2mq4zh0ceEUg6kUFT
         TNWo0OsPsu/bnjLG4052B9gsMyVCJ1V08x6dY0sEFB5pbUHkOflP3om6Ar2PPX7GNEWS
         hy0UL1DZdlO9G4mtW2XWb9blGjIHMdFbvdDy6ndj13SG9eFArs3v389dy6Bi9I9OQeS5
         DkJiltVDvujS4C/o0IVGj/RlO0RVEWV2tWXAixBeaV9s+wpVyUClcWXI0IkyK1xckfO+
         hBCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=jqpnXoNu;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t134sor15959657ita.12.2018.12.26.04.02.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 04:02:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=jqpnXoNu;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JVjRXbgxFYGFk9y6ELrr8A6OdFVvdGFRoOhZs8VKPx8=;
        b=jqpnXoNuQH4Y6npYm3Y2uFXpd55m5SqzzyO6HphWz08wfUy/4IgmJP2r1s4+bvxJ/x
         s2wgXo6W4YwVrVx3bgJCH34vyuVLurXj32RtgKEQb4HiADWuz/6Ifu8HnvY+9BAM1exs
         xFkjyd5FCR5s4hhcvNLE85A55c+emVzKGD3mo=
X-Google-Smtp-Source: AFSGD/UACFsUr9ithLjnKHB92iRq6d/4awgjLXCysK99G3+FhGWesdRdkf89Pq2E7DiJOn2IJegyRCmr7cRZK+om/30=
X-Received: by 2002:a24:710:: with SMTP id f16mr10914024itf.121.1545825769997;
 Wed, 26 Dec 2018 04:02:49 -0800 (PST)
MIME-Version: 1.0
References: <20181226023534.64048-1-cai@lca.pw>
In-Reply-To: <20181226023534.64048-1-cai@lca.pw>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 26 Dec 2018 13:02:38 +0100
Message-ID:
 <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
To: Qian Cai <cai@lca.pw>, Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Linux-MM <linux-mm@kvack.org>, linux-efi <linux-efi@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226120238.xc3Vl4chASVtBcg4OjeKy30G1p9R0ayfKZZP7IdZeqA@z>

On Wed, 26 Dec 2018 at 03:35, Qian Cai <cai@lca.pw> wrote:
>
> a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
> needed due to efi_mem_reserve_persistent() uses __get_free_page()
> instead where kmemelak is not able to track regardless. Otherwise,
> kernel reported "kmemleak: Trying to color unknown object at
> 0xffff801060ef0000 as Black"
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Why are you sending this to -mmotm?

Andrew, please disregard this patch. This is EFI/tip material.

> ---
>  drivers/firmware/efi/efi.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index 7ac09dd8f268..4c46ff6f2242 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -31,7 +31,6 @@
>  #include <linux/acpi.h>
>  #include <linux/ucs2_string.h>
>  #include <linux/memblock.h>
> -#include <linux/kmemleak.h>
>
>  #include <asm/early_ioremap.h>
>
> @@ -1027,8 +1026,6 @@ int __ref efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
>         if (!rsv)
>                 return -ENOMEM;
>
> -       kmemleak_ignore(rsv);
> -
>         rsv->size = EFI_MEMRESERVE_COUNT(PAGE_SIZE);
>         atomic_set(&rsv->count, 1);
>         rsv->entry[0].base = addr;

The patch that adds the kmemleak_ignore() call here is queued in
efi/urgent branch in the tip tree, but did not make it into v4.20.

efi/urgent does not apply cleanly to efi/core, since the kmalloc()
call [which requires the kmemleak_ignore() call] has been replaced
with alloc_pages() [which doesn't], necessitating this patch to remove
the kmemleak_ignore() call again.

So what I would like to suggest is that Ingo resolves this conflict by
simply dropping the call to kmemleak_ignore(). That way, we don't need
this patch, and we can still backport the efi/urgent change to
v4.20-stable.

