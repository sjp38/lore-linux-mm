Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE680C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E2C72184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:37:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="OLkbJU7m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E2C72184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F20BD6B0007; Thu, 18 Apr 2019 00:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECFD56B0008; Thu, 18 Apr 2019 00:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBDF96B000A; Thu, 18 Apr 2019 00:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA4A46B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 00:37:16 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id l85so406504vke.15
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=92tRgfUMbeMv1ITsQnVX2nfQxbImxEmC6NtEESfsrL8=;
        b=bSp7T3INSiVUgvihaSHRxfC6/VRd5NghkgHAhcpTYQc+W+KkcJuPgLqJtx8KWMeDTf
         BxJ0wh2qljsQp0EJZD+PkRq5h3GvpctSyIKeRu1ZbbeHHfmFPBaWcCEcG5zQWtP21io+
         jpSHL/Pff5J0C3JRnkmREHdjIMWWRR1Fn3mfksAWDMs4fx9SBDCvtL/QTj6sOFOZU3UF
         p9++9j9AO+sdWp1+ZflR48vctZpyjFTkMWzbLM7Pu/E2rKmOWqSDeiZduQvKOODG6ODa
         NNECM0P4wrkatTbhHU9yZvCDy3HSe31kknVaKD8O7AQmRssYoRrbB5wL/gLE5RfCd72J
         kPmQ==
X-Gm-Message-State: APjAAAVKQwHljcBiSz3UQOBtqguQbELfCZVbdjwR2NC5nhh1n9YoKE8h
	SGJNe5sB4itV2W0/DYcBA/CG+9fNXwCPAT4LRf5ztt+JcAidruLqd6zy9Pt9Q2m8IcdYwFVxURu
	gbtxxDOugLvk/7uvd+rsQScuiaamgx7XObjmmI8vw5SOmphUiO5yJWqNr+tb7Q7+Jmw==
X-Received: by 2002:a67:fb18:: with SMTP id d24mr51597787vsr.44.1555562236535;
        Wed, 17 Apr 2019 21:37:16 -0700 (PDT)
X-Received: by 2002:a67:fb18:: with SMTP id d24mr51597772vsr.44.1555562235992;
        Wed, 17 Apr 2019 21:37:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555562235; cv=none;
        d=google.com; s=arc-20160816;
        b=U3e/Mk1uTya+v1aK/PjXfCB3YTQfyIbodCctURve/UWYY6ZFaC7A5eX4ThUAJuv4+n
         BgQ+smChDGGfbsrmWwHHXfZuTIxlaX5nUAopebbGw2cV/dlG3jBRA89FjzARzi0h1LdW
         3mqQN4Cj2t/9s1+faznQ/V+YHs/tEIBWKOb5j/ueCCcKN6V/U7wgEDDrm7Difgvtpqz5
         Yqp4l4dEjuNcF439tfNCy0cloM/dqG/uPRD/cZ+AdbBmIciC1IDcecOwtSukKBVCHUPF
         azKSGaMx6ZYdrepcu7kdQNisy0ycXV60rD4dHVddsp20YuU9UNtGhuEADnSK3TRovTEE
         krOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=92tRgfUMbeMv1ITsQnVX2nfQxbImxEmC6NtEESfsrL8=;
        b=hlRmyRqPmrvwg8ibOPWfR7ZCwqiQQxFNvjzH4sbHVUyySI1k9wpzRE0MYcdzh1/Ue4
         uVX6t3CKO2GRgddFIl3b1bbC4S55TF04YIOPnFmr488PqUz6tsXuMfG52976oIv2NVLs
         GHaaP2rMuvmrq+JE9lXf6LmYuNX9cH8fdPxKxQsoGPx6VrCJiLU9vRgk4JnbJVT8E95r
         Ac/GbOAI3u3Qj5u4rvfup7sm/U/JIRMwUt7PC1x0e9APw7dOlSmcb3wwmBWvzTHwZtwE
         tSLjMAUNh7F13VTiV3ZsArcLE/B2z7fApVbtC1IGXqPKl+R1rXCEHj7dG1PCxLhVtTa6
         vNoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OLkbJU7m;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6sor354771vsk.10.2019.04.17.21.37.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 21:37:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=OLkbJU7m;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=92tRgfUMbeMv1ITsQnVX2nfQxbImxEmC6NtEESfsrL8=;
        b=OLkbJU7m0JSpwXyWqa9ZSVBZbJJbsitwwGD9ZFTANpCONTXMGZ81AhxDTno9r38sEv
         Z0JotjuwKOUss922IFDFo/63cZ+UAJRNvTAAAwjPU190WnPbTuipbvAcYF0az0veXucS
         uACiUuIuiBILnxrE6ReQLiWsvSB24QasvXBQc=
X-Google-Smtp-Source: APXvYqy27SysP+0kFs9FLZ/wHDQf+6HOLF24OqsVRis+b5759t7lyxIwhZ1bA4cvM0CCM8s/sOcUfw==
X-Received: by 2002:a67:f358:: with SMTP id p24mr52076028vsm.3.1555562235299;
        Wed, 17 Apr 2019 21:37:15 -0700 (PDT)
Received: from mail-vs1-f51.google.com (mail-vs1-f51.google.com. [209.85.217.51])
        by smtp.gmail.com with ESMTPSA id w184sm880395vkd.0.2019.04.17.21.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 21:37:13 -0700 (PDT)
Received: by mail-vs1-f51.google.com with SMTP id t23so442417vso.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:37:12 -0700 (PDT)
X-Received: by 2002:a67:7c8a:: with SMTP id x132mr50675686vsc.172.1555562232106;
 Wed, 17 Apr 2019 21:37:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-4-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-4-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 17 Apr 2019 23:37:00 -0500
X-Gmail-Original-Message-ID: <CAGXu5jKo26zXw=jfKSzr_pnfx5Zux+fVbY7V9bJwEMApDcFi8w@mail.gmail.com>
Message-ID: <CAGXu5jKo26zXw=jfKSzr_pnfx5Zux+fVbY7V9bJwEMApDcFi8w@mail.gmail.com>
Subject: Re: [PATCH v3 03/11] arm64: Consider stack randomization for mmap
 base only when necessary
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, 
	Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, 
	linux-riscv@lists.infradead.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:26 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> Do not offset mmap base address because of stack randomization if
> current task does not want randomization.

Maybe mention that this makes this logic match the existing x86 behavior too?

> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/arm64/mm/mmap.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
> index ed4f9915f2b8..ac89686c4af8 100644
> --- a/arch/arm64/mm/mmap.c
> +++ b/arch/arm64/mm/mmap.c
> @@ -65,7 +65,11 @@ unsigned long arch_mmap_rnd(void)
>  static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>  {
>         unsigned long gap = rlim_stack->rlim_cur;
> -       unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
> +       unsigned long pad = stack_guard_gap;
> +
> +       /* Account for stack randomization if necessary */
> +       if (current->flags & PF_RANDOMIZE)
> +               pad += (STACK_RND_MASK << PAGE_SHIFT);
>
>         /* Values close to RLIM_INFINITY can overflow. */
>         if (gap + pad > gap)
> --
> 2.20.1
>


-- 
Kees Cook

