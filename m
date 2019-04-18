Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03BAFC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A061B217F9
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:30:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="edeVbOaB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A061B217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55BF96B0005; Thu, 18 Apr 2019 01:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 533D76B0006; Thu, 18 Apr 2019 01:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4494D6B0007; Thu, 18 Apr 2019 01:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDDB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:30:47 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id p134so185615vsc.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:30:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bLtDzKXu09gPBmOTPhLlCKa/1j1gZ8w+6fLRYpgkXVc=;
        b=VP5ajjXpwf829cnlXUNGtUoV4hT+5FiVIlIFkmpkhFVasJ+p9s3yeN5jIAxxzzEE3j
         OJFjYQg42QDox4wIu0ly4NxMZWwcPLahvzFFRphHo3HfccR3lYW7Qjr0JBBAGR4IJfWs
         vfUlQjrx3s894TWvgiygkaJdBOR7tJw4NX3Aaz++BJiL0a4rLMc5t2z/mjv2tnCn7gPf
         wzCBFD6M1lIyqcUWNC9UQS3sW5YNwVXoSovlm3SkRPtzmFaPx731VoDZnq4wLq09qrGO
         olyKg3Y3Qh//oLsaw0Jf8NjUnp38UL+WnJjBOmCrkPMGnTgcnpDZD/0poUoWhBPMhz0u
         xu0A==
X-Gm-Message-State: APjAAAV8vgpb5OoDVpESj/PpowioTjpF+HscE9ua3eq3oZ9x+EUzO3Ie
	0eVx55uZWndLNRsKvrG2SU0M5qxmpQRhdS8G87Pu9eXEBYYukexAzOMchAsNU8M9BOry+24syE4
	gUQf5DmUAsUlpt16VHKXF6rjfWwFEWP+YBhEwifLY+lOUvcPZ6QChoNndrwslqHKiJQ==
X-Received: by 2002:a67:bc13:: with SMTP id t19mr2610608vsn.222.1555565446852;
        Wed, 17 Apr 2019 22:30:46 -0700 (PDT)
X-Received: by 2002:a67:bc13:: with SMTP id t19mr2610579vsn.222.1555565446100;
        Wed, 17 Apr 2019 22:30:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565446; cv=none;
        d=google.com; s=arc-20160816;
        b=YycveXxDLZOlZglebp/ZRgEblTVMIJqzACA52UL00l1acy7h3S0xIhGjiNgQTuCXV2
         1oH5AuLPtZNH2CyhxBr7Bj5XQZdnIZN6qmvv46F1I7uyccC5wmPEWQzCQysBjKjWn8pf
         +ZxlXsp6cVaZIqXCb2lKE4XIurdBozL53i2LMqDYFWeowWbw6cvpKg+XfZlcbp9Dexgn
         CYYqFwlWFY0o83EhKLOlK+tH2vYbo6B6VRVN3MBy3swgp91Xbs/93ZFA2UXbQ1P0TESS
         qPJCI7+fvPFiEfIwJUwlYseI6KFa0QIUh4ZRk65BOBTI+Zz9HRJIujqzIFHLjvz+KLtR
         hGxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bLtDzKXu09gPBmOTPhLlCKa/1j1gZ8w+6fLRYpgkXVc=;
        b=iTiXAsK6BM5l+U0i3d+6/FNGxZZmpB2vNnW9JMPajLN1SBrnoXMc+UomBWa3T0HkOM
         /+Y1t1vA31KfUocGQ4epVy99O5VIyCF3wY+3w6pXnl4frkO78LMsKcPff642i+bWAqw3
         Z+++mepX3gNYChY4Gtf1xIhsYJlWnKCDG3Q2T2yLb6NUfAJxledpQQWZd8nPWZuPF1KJ
         VcJSNpZzv9AEOGKYQmejU5FA0/nSiRDs57JEuweeO91Sy4P3h3D+WsRSvyNlv2PaUVbQ
         J9wCi09FvABpuC4Izi/4fn+DjPdcJCws3DB9M1wnFMBf7I1eH0ChvCZ296XZSCzPQLeH
         FkWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=edeVbOaB;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor515014uao.43.2019.04.17.22.30.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:30:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=edeVbOaB;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bLtDzKXu09gPBmOTPhLlCKa/1j1gZ8w+6fLRYpgkXVc=;
        b=edeVbOaBMLhN2dBQJXpv+D+6vAjewlRc9kM5lTmzsJMTYvnZuw8u8Y7DqZfh26UEgW
         OHIgnpHVLQHXols38+FJXscMQV6lYZx93+goYy0WamrsRBkh1x83txAmNxUkD0xqfkb/
         5V9w/CLbuOWB3OiL1UReRwHKvROTO3KbTfB1M=
X-Google-Smtp-Source: APXvYqy8idrwo1IybjTLXKjxX3T+Wx8cDqYrZPT3sCnZyVy+TQbXNojIpyUCT8wGz6kQG/3oTk4A2A==
X-Received: by 2002:ab0:6704:: with SMTP id q4mr2582684uam.132.1555565444651;
        Wed, 17 Apr 2019 22:30:44 -0700 (PDT)
Received: from mail-vs1-f51.google.com (mail-vs1-f51.google.com. [209.85.217.51])
        by smtp.gmail.com with ESMTPSA id l9sm222487uae.1.2019.04.17.22.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:30:43 -0700 (PDT)
Received: by mail-vs1-f51.google.com with SMTP id g127so509287vsd.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:30:43 -0700 (PDT)
X-Received: by 2002:a67:e881:: with SMTP id x1mr52185580vsn.48.1555565442783;
 Wed, 17 Apr 2019 22:30:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-9-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-9-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:30:31 -0500
X-Gmail-Original-Message-ID: <CAGXu5j+-M5VGsPqZ6JyqH6w=HP9NLK2KEAQqen99ssUg5mC89A@mail.gmail.com>
Message-ID: <CAGXu5j+-M5VGsPqZ6JyqH6w=HP9NLK2KEAQqen99ssUg5mC89A@mail.gmail.com>
Subject: Re: [PATCH v3 08/11] mips: Properly account for stack randomization
 and stack guard gap
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

On Wed, Apr 17, 2019 at 12:31 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> This commit takes care of stack randomization and stack guard gap when
> computing mmap base address and checks if the task asked for randomization.
> This fixes the problem uncovered and not fixed for mips here:
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

same URL change here please...

>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/mm/mmap.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index 2f616ebeb7e0..3ff82c6f7e24 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1; /* Sane caches */
>  EXPORT_SYMBOL(shm_align_mask);
>
>  /* gap between mmap and stack */
> -#define MIN_GAP (128*1024*1024UL)
> -#define MAX_GAP ((TASK_SIZE)/6*5)
> +#define MIN_GAP                (128*1024*1024UL)
> +#define MAX_GAP                ((TASK_SIZE)/6*5)
> +#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>
>  static int mmap_is_legacy(struct rlimit *rlim_stack)
>  {
> @@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
>  static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>  {
>         unsigned long gap = rlim_stack->rlim_cur;
> +       unsigned long pad = stack_guard_gap;
> +
> +       /* Account for stack randomization if necessary */
> +       if (current->flags & PF_RANDOMIZE)
> +               pad += (STACK_RND_MASK << PAGE_SHIFT);
> +
> +       /* Values close to RLIM_INFINITY can overflow. */
> +       if (gap + pad > gap)
> +               gap += pad;
>
>         if (gap < MIN_GAP)
>                 gap = MIN_GAP;
> --
> 2.20.1
>

-- 
Kees Cook

