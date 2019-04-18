Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F18E5C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 983CA217F9
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hNSJWi7d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 983CA217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 362506B0005; Thu, 18 Apr 2019 01:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310D16B0006; Thu, 18 Apr 2019 01:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 203276B0007; Thu, 18 Apr 2019 01:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED4196B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:28:08 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id b16so181785vsp.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ohjMtnRuoMZoK8NFCIw9UXTAaT8mCgqZCZ9c725i5mE=;
        b=JUAJAiG80lkY4fc8PhpsGpOL7ZdUaNdqHrjZeb8IptKWZqnoXqROXzR5tIX+0b9h3P
         uPPt+gIbrSjgmPIT0JzGEEdLHRNmgefLrmxZmnhcZEYKUfodk3ZhH9GINdU2lgDmB3ia
         oyR3GtkxnNVogN1fMShBrHDJPfyWDzOgQf/4IjITBBe4+AarZ2+OBVAOy7AsY/BUq4Jr
         o1W2BwhVPvDZ4VkqfJt8NZoH0OJIB1V57ORXLL5WCJAbeVtae5GHr7+k70grZxgAW4rm
         WZsXRzxZem9ZaCL/MUiMIq3olsbsmnHyo85dy6NpqzjiMY4FQQujl+QIMheDhODcB3uC
         OROw==
X-Gm-Message-State: APjAAAVhccLO9IxS9z4yKGMS55k4l7MZYU50lqLgNBhsBT7uclW9vZh4
	wa0f65k9Xh+wMu7PVMNQM/spN+prfemXjIT5ksz60JmHxl97E7/hbgQ3TktZQX+LZ6TxkmS34pf
	VBA7hqj1WzQKzf4cy0iizYK6yAg+acIqWThDVnhYegtiNqXhJZIbeFtksguwUMsyS3w==
X-Received: by 2002:a67:99c3:: with SMTP id b186mr33184069vse.50.1555565288667;
        Wed, 17 Apr 2019 22:28:08 -0700 (PDT)
X-Received: by 2002:a67:99c3:: with SMTP id b186mr33184054vse.50.1555565288007;
        Wed, 17 Apr 2019 22:28:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565288; cv=none;
        d=google.com; s=arc-20160816;
        b=vBQ9M8oeGWUSIUMjgYL1m3PghY72aYi0P/i9YJvv8gYKlDK1xbNnZAxcyR+eSSHXOU
         3V/Ei5Y1Q1BMBgBIEGNgJX5EOCtbcG46N2SRiwyrjiXvtZQK4QWBQHFVy2WVtkZ+u7Qt
         Qf/Us0Mc2gUvKN9qdLkCVGILpuHlwfQHHmzan9BQGCQfEhii1eKnLz1Mm/0+E2mCqLdE
         YwO4OktH2NhD+wCL9LMXi4c4zkoM16rH4Mx6liG6/7DUecvuTsN5bUz+6Pf3hGvr7OTx
         RIbJJb4pM4XN4MBcsfqIeUvAqFS+Ax5vdvim7vtb5DlGsW2a8WRjOvAJz9G7SMePOvyJ
         U+8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ohjMtnRuoMZoK8NFCIw9UXTAaT8mCgqZCZ9c725i5mE=;
        b=uP5rLLZV2hncR9z6ezoeqqthS9MAtnErv9mfltzi1TEnco1SE60d2oxHKBjh6Xxixp
         VU2d2hgBL37bgYxpB0Eo10SoyaDu8MZJQcaaK3FWlIGkp5uvExtb8/L+v+Uxjkx4bHkx
         D4WEmra5NQKysW8Yh/CxjoqkYjWApFzDU9cRowyk73evc2ZrXwC5P+PafKOsKErQxTsn
         azpi/0guMCeJxHLHRhg5ys62+E1ELyEczQS5pUQPy8DaFUcUZA2XAsaRtnAGI5R1e2k2
         lmTc+AKu/HQZPolQ6EK7PbRqtq2JPAq7OITT5MAZJhjR2DPhIgnZV4etUaH+jKVKfP5V
         UW4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hNSJWi7d;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor362979vsn.114.2019.04.17.22.28.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:28:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hNSJWi7d;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ohjMtnRuoMZoK8NFCIw9UXTAaT8mCgqZCZ9c725i5mE=;
        b=hNSJWi7dfZS6icOBYs4kZRM3P2+rnM98qjGabtZHa2binvsfr93Ocxkw+IwxUASlD/
         pQX01+gyN8BW8yJYMgeqgS/eAzOZQEpQCg6E3xJ+hbrCPgvJPgJJi4wI0J+FiIbsUSP6
         0k+cQm02mdD+oM5hLDG6hhfyjMKa1vlN3OhUw=
X-Google-Smtp-Source: APXvYqyIlUw+cIPLxwx8PU4Wic4h/C7/huLiqIy6JZeIm/vPCHtud3xYwgJR/lpvXIy3WD2NOTgq6w==
X-Received: by 2002:a67:82c8:: with SMTP id e191mr50839838vsd.24.1555565287061;
        Wed, 17 Apr 2019 22:28:07 -0700 (PDT)
Received: from mail-vk1-f182.google.com (mail-vk1-f182.google.com. [209.85.221.182])
        by smtp.gmail.com with ESMTPSA id t207sm385796vkb.21.2019.04.17.22.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:28:05 -0700 (PDT)
Received: by mail-vk1-f182.google.com with SMTP id x2so202769vkx.13
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:05 -0700 (PDT)
X-Received: by 2002:a1f:2e07:: with SMTP id u7mr49260276vku.44.1555565284857;
 Wed, 17 Apr 2019 22:28:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-7-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-7-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:27:53 -0500
X-Gmail-Original-Message-ID: <CAGXu5jLFtaiRqvd_Lw2B688bzUyti2O8o_iZVmQhb7rmnEKzBQ@mail.gmail.com>
Message-ID: <CAGXu5jLFtaiRqvd_Lw2B688bzUyti2O8o_iZVmQhb7rmnEKzBQ@mail.gmail.com>
Subject: Re: [PATCH v3 06/11] arm: Use STACK_TOP when computing mmap base address
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

On Wed, Apr 17, 2019 at 12:29 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> mmap base address must be computed wrt stack top address, using TASK_SIZE
> is wrong since STACK_TOP and TASK_SIZE are not equivalent.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
>  arch/arm/mm/mmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index bff3d00bda5b..0b94b674aa91 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -19,7 +19,7 @@
>
>  /* gap between mmap and stack */
>  #define MIN_GAP                (128*1024*1024UL)
> -#define MAX_GAP                ((TASK_SIZE)/6*5)
> +#define MAX_GAP                ((STACK_TOP)/6*5)

Parens around STACK_TOP aren't needed, but you'll be removing it
entirely, so I can't complain. ;)

>  #define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>
>  static int mmap_is_legacy(struct rlimit *rlim_stack)
> @@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>         else if (gap > MAX_GAP)
>                 gap = MAX_GAP;
>
> -       return PAGE_ALIGN(TASK_SIZE - gap - rnd);
> +       return PAGE_ALIGN(STACK_TOP - gap - rnd);
>  }
>
>  /*
> --
> 2.20.1
>

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook

