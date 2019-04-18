Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBC77C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D018217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:32:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="BwFdgFLF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D018217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A8816B0007; Thu, 18 Apr 2019 00:32:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02CBE6B0008; Thu, 18 Apr 2019 00:32:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E37CD6B000A; Thu, 18 Apr 2019 00:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3776B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 00:32:33 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id l11so401505vkl.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=emqG7/19kpW5wZ57vs/jCWwiZdoRZXGDohb1D974Avc=;
        b=iJr4DtMnELTYM8yltMMMHCiSU9YpSIa+gk+mJOjoJHI/gPnlpEjEbewlrIklhxWvLc
         f4ln1cu7XtF20TqAEx08o61sP9exHmu6R9emau1XCo7LBA6SN7oli25MSkdsEEvhhIfe
         xW5K+vYJMgEUWTeO5HwTNyhKPSuYwZiQu6iG1uWxEU5/khd50GN2bho+QDXiA6zQ7FLl
         XOHiwYGNGrjKxUxWjPq8iyTPHtqW9sQdVRQkrp52LkJr9dg2C7P/46kOW60x52LZ+HVW
         hgx1JV9Sll/EUyjHxoeUtN+01F+vH9f9lUAPCbDm9NVBvBoXmeqZMC5P4CNy4HSWHeMz
         wTOw==
X-Gm-Message-State: APjAAAWVZeWTzgctGqz6ZD3yjI4IxQfrnO1zgbdne5hpjvo/63pT+uLz
	ppByda7xmecqNjqax6pVChks2T6z0d3z6Fh/puXTdocTgliLFs2niQprkxt3w5wWPsjO0if0CVC
	jYHYhLu0Uv00e5HbNVW7wPyDvYxs/RdJxv0ZCFfIpT4XBLRUGUsn8z5QaqMYimW42bw==
X-Received: by 2002:a67:ed84:: with SMTP id d4mr27881000vsp.207.1555561953306;
        Wed, 17 Apr 2019 21:32:33 -0700 (PDT)
X-Received: by 2002:a67:ed84:: with SMTP id d4mr27880972vsp.207.1555561952653;
        Wed, 17 Apr 2019 21:32:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555561952; cv=none;
        d=google.com; s=arc-20160816;
        b=Pni3oFVBSGtqz3dcWo4ZWcibvw/u2YaDH8sdFnXu2NAsC/cZM2TreKO+4AiMYeneBW
         8NdBEu1G0cGEAjJ2RBDNY5Lr8PFM0FBUX5oodJ43E6jal1aitb1yTlLTswUoDIg+7RNO
         q1dGk2gREAIuEI3g4C9UHHPwi/GDcJGsWJi2DnWZRFDcriZX2DKIqnMQQhZ1M0O5I13O
         7aUk6gA4S17Zq5cghp17l03/xDQWyh4Bcn3u5hv216+kj09BujSSfD9JuLTUoDZXBijs
         cdthWLcB7hQxiFlmri1kBU8XYBc0qd4hroATCqnHDQdW9PBYjiLpPn2oM2EM1XESr1Ul
         dB/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=emqG7/19kpW5wZ57vs/jCWwiZdoRZXGDohb1D974Avc=;
        b=KabNSsk5YfUjG4c1fYXgXTsbndOfKtZPzUomLGEZGFbnoRxNhHUvF9xGJZ9Ma6w+Vl
         ICii09sNGP54Qt/EjKgTX/93OlNVzIiPJ2vNlLY0ZnZRDWIKqC4RB4ZQ9JiW1IKgCjjl
         0ySkkuAuyV7Ow9+y49dk6ozseKXlsJ9oF5MtXpE/h2Vn8CiRSEJkM4b/+RdWYH67rY+0
         eJPhmq9upVE3CTsqmbN9QjHyvbUNn/VaQzDuCu+7VkTxqlDIQIUm8xykO5K/ycWuWypw
         KHUkLOHD///3TNmXJJqIe029V+lUHoHsCyND6H+5XGzLmbPJ4DbLoYjN4rTRXUNvfG0z
         Qp3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=BwFdgFLF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor331576vso.124.2019.04.17.21.32.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 21:32:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=BwFdgFLF;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=emqG7/19kpW5wZ57vs/jCWwiZdoRZXGDohb1D974Avc=;
        b=BwFdgFLFNee7q4d/odil7gkB/UOuVM/QIlnvE7TGVcPxV0znLQ4z7fs87fH9FD/p2Q
         QIWn2YByOZWf2cz5EWUgLnTt8H1YHdlzqE3vWASVSstFIxPSA4Jhvnkwf4hkz5pNBDia
         3hMlCG7M0QDEQlArREt5/8jUB1Ed/r+jW9qXM=
X-Google-Smtp-Source: APXvYqxNfTQaquF8Iq7aLFSABAnJvOUtXNRWLXx6YAbhJNmOBsZ1onajyGWhhBeKXAAw5MA/Dm/OZg==
X-Received: by 2002:a67:f714:: with SMTP id m20mr52068543vso.211.1555561951773;
        Wed, 17 Apr 2019 21:32:31 -0700 (PDT)
Received: from mail-vs1-f53.google.com (mail-vs1-f53.google.com. [209.85.217.53])
        by smtp.gmail.com with ESMTPSA id 2sm1530612vke.27.2019.04.17.21.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 21:32:30 -0700 (PDT)
Received: by mail-vs1-f53.google.com with SMTP id j184so437704vsd.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:32:29 -0700 (PDT)
X-Received: by 2002:a67:bc13:: with SMTP id t19mr2517845vsn.222.1555561949440;
 Wed, 17 Apr 2019 21:32:29 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-3-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-3-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 17 Apr 2019 23:32:17 -0500
X-Gmail-Original-Message-ID: <CAGXu5jKVa2YgAkWH1e26kxd2j6C4WsJ38+Z3K1z7JRvr_jDX6Q@mail.gmail.com>
Message-ID: <CAGXu5jKVa2YgAkWH1e26kxd2j6C4WsJ38+Z3K1z7JRvr_jDX6Q@mail.gmail.com>
Subject: Re: [PATCH v3 02/11] arm64: Make use of is_compat_task instead of
 hardcoding this test
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

On Wed, Apr 17, 2019 at 12:25 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> Each architecture has its own way to determine if a task is a compat task,
> by using is_compat_task in arch_mmap_rnd, it allows more genericity and
> then it prepares its moving to mm/.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/arm64/mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
> index 842c8a5fcd53..ed4f9915f2b8 100644
> --- a/arch/arm64/mm/mmap.c
> +++ b/arch/arm64/mm/mmap.c
> @@ -54,7 +54,7 @@ unsigned long arch_mmap_rnd(void)
>         unsigned long rnd;
>
>  #ifdef CONFIG_COMPAT
> -       if (test_thread_flag(TIF_32BIT))
> +       if (is_compat_task())
>                 rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
>         else
>  #endif
> --
> 2.20.1
>


-- 
Kees Cook

