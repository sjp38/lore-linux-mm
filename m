Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB273C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAF3121479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:49:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JlYc5LnY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAF3121479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 302E46B0005; Thu, 18 Apr 2019 01:49:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B5336B0006; Thu, 18 Apr 2019 01:49:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C8C66B0007; Thu, 18 Apr 2019 01:49:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id EABD36B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:49:36 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id z5so201725vsq.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QVoqbwyN443Uxffv4ADeYKBc3zmgcqP5SCaKkpPU0Ag=;
        b=RT2JRwwVqBSlnuUAAVs75Kt6kKyrcKBUUPBwyu26F7BKIlJCcpudB1eATXo6cbkfBZ
         mPRLAFsgPsvvpXado0QUKrNXVq+YJqYa2eEpMQ+XMB+52NyQa1RlYtn2hRpaKe7SC5lb
         3fidUcnhQuYXwxjG5D3NucSWlmSu5SxkbCUvyC4LlaW3TYN+Uj3Zt9TC6gqZWKL608BD
         JaXbhVd3G8R9mGFCGYsCB/NyARtXimBwK1lHy45iZBdHwYuSQ7d8l7mIIlN7/fXtrGEB
         Ze5tTAFIlcbMJE5MyqvZ2TXopEUBkFe9qGsbWdUiewKzMXJ9BLGbFubvmvrNixuJ4NAO
         zaHA==
X-Gm-Message-State: APjAAAV+3gwsKfCPvTnnzPgyocGr5GW5V4q7B2iRAK/ab8Gb8e+c+URO
	wEM6TzHLWXJlOtPT8T0TlDoO6PA9Wnjj6XSAdgJh3+U7tDk+fQq6G1ChAaJrR7jkc6sv0vrxgUa
	L9DigFVj1eUombkt5ACQKEDpaRoND8aJkduenbZ/m6hIVv3IRmG+nWawunG7a30ZZjg==
X-Received: by 2002:a67:fb45:: with SMTP id e5mr50191037vsr.72.1555566576689;
        Wed, 17 Apr 2019 22:49:36 -0700 (PDT)
X-Received: by 2002:a67:fb45:: with SMTP id e5mr50191014vsr.72.1555566576025;
        Wed, 17 Apr 2019 22:49:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555566576; cv=none;
        d=google.com; s=arc-20160816;
        b=L4TdJ+6y/EPRNW35SMfhV4NXeNtMYW6BiCStp5QOoSkjRkv+vqaapEXRt/HbeWHEQo
         bDao0/M2PPRMoG+Ct8J/ySTwkoCX6GgJX/w1JYrV6LpA5ohU+/r2UQFzIFrV6nzTf+oJ
         bEkaN9STFElAbFcPye9We7z/t43vvHpy1/OhiWKd62AQJkQHH3Ni1g/bix2mEApAuZdt
         fVFEHvkxhq5PAP1AEabbw6328/132wSkvBYbYdJA1XTfb0D8pego4G/ZtwGY4prgwAGp
         gAJbklMMyagz5QdLAApL6sEq7eKNhxQHQjFt/CDz7C1Z9yiWFfK/CqwystlAqUB8e9YW
         CWCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QVoqbwyN443Uxffv4ADeYKBc3zmgcqP5SCaKkpPU0Ag=;
        b=pSRPeNYVjZGd7sNxq4Nv8374wyZj/zo+DOaCGAYRiJHloo3RUnJZ/vIqYjjA3NZ8T1
         PKN9hPsIuptFDSl6XimlDi+/OIyAvUQXDIvyOziA0DmPQd1js5fNtfSlOxxVusguh3pZ
         I2d8xs0jl/mgkE2To4qci/Ij6VXjiiKsc5d7jgV7rQLY3NH8jq16o5uHQudJTOdNOu0j
         UOUV+oX2DlPTeNDinHukoGeoB/D1Mq/HuwLXR1n113EoyM7VdgUk0jrXH+Yg3sbC4spT
         I2OJI5fIpymkNG2aJsnu3GjybDvqbx93VXUmAvHh5czEuAiolRuJWfl1UyrZmN8Q8oPD
         kmOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JlYc5LnY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor380407vsk.106.2019.04.17.22.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:49:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JlYc5LnY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QVoqbwyN443Uxffv4ADeYKBc3zmgcqP5SCaKkpPU0Ag=;
        b=JlYc5LnYPCwWgX5oqj7ynsTkg9HwSCKe5lZ5zN605L7Uvo1glCbNDCtQfk8GyTRI13
         ROZ9wJjLihPw49RRrvvr1sPQAGB3Bk/uVz5KXlTfPr4zLd1Qk3TnxysN1P6IizUWSim9
         CZommiTKB0IOC+Nf2V/4WJTnJI7JYYMqf0DOY=
X-Google-Smtp-Source: APXvYqxpfH/cnpmm1xO5dd/Q6EVmimiODDlPkz7/8R5kulTt6B7vBMSg2vUhtK/dnO4dX5SNxb3Vfw==
X-Received: by 2002:a67:fb4b:: with SMTP id e11mr8843265vsr.148.1555566575453;
        Wed, 17 Apr 2019 22:49:35 -0700 (PDT)
Received: from mail-vs1-f52.google.com (mail-vs1-f52.google.com. [209.85.217.52])
        by smtp.gmail.com with ESMTPSA id x80sm312098vkd.22.2019.04.17.22.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:49:35 -0700 (PDT)
Received: by mail-vs1-f52.google.com with SMTP id w13so530878vsc.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:49:35 -0700 (PDT)
X-Received: by 2002:a67:eecb:: with SMTP id o11mr50384241vsp.66.1555565182826;
 Wed, 17 Apr 2019 22:26:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-6-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-6-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:26:11 -0500
X-Gmail-Original-Message-ID: <CAGXu5j+V_kJk-Lu=u82CrA291EPpgJtX951EKigprozXt7=ORA@mail.gmail.com>
Message-ID: <CAGXu5j+V_kJk-Lu=u82CrA291EPpgJtX951EKigprozXt7=ORA@mail.gmail.com>
Subject: Re: [PATCH v3 05/11] arm: Properly account for stack randomization
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

On Wed, Apr 17, 2019 at 12:28 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> This commit takes care of stack randomization and stack guard gap when
> computing mmap base address and checks if the task asked for randomization.
> This fixes the problem uncovered and not fixed for arm here:
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Please use the official archive instead. This includes headers, linked
patches, etc:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
>  arch/arm/mm/mmap.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index f866870db749..bff3d00bda5b 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -18,8 +18,9 @@
>          (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
>
>  /* gap between mmap and stack */
> -#define MIN_GAP (128*1024*1024UL)
> -#define MAX_GAP ((TASK_SIZE)/6*5)
> +#define MIN_GAP                (128*1024*1024UL)

Might as well fix this up as SIZE_128M

> +#define MAX_GAP                ((TASK_SIZE)/6*5)
> +#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))

STACK_RND_MASK is already defined so you don't need to add it here, yes?

>  static int mmap_is_legacy(struct rlimit *rlim_stack)
>  {
> @@ -35,6 +36,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
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

But otherwise, yes:

Acked-by: Kees Cook <keescook@chromium.org>

--
Kees Cook

