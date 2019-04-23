Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C04C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:14:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0AEA217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:14:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ib64WJia"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0AEA217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 650206B026D; Tue, 23 Apr 2019 13:14:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600486B026E; Tue, 23 Apr 2019 13:14:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EF186B026F; Tue, 23 Apr 2019 13:14:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C03266B026D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:14:52 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 140so2491820ljj.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:14:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DN41PzKZOmTQMbeHkdOhlUuj8ZVoq/HWKOihKOAiUlk=;
        b=HLvQqWiJqc8GZVn5z0Wrum/wPX1AlzGo9dTDsk4x2tnTOUVZIaG7XfMrO1pGBh4vwr
         Cs8cvuzLb+0fpq0VSDnwCFEuVFJ570Cj7VQIxfF1y2dqXsBRZIzog5xUegwNhOb3+iWh
         e+FJotuhR2fJw4ygZz7JVXoIOMdMK/N0IQzh/mVhSxUrffZ8mrmWW44Bc0A5CQVmN0Me
         67wz8KnlZBk0/AQxPlWY1DyzEFrHvXFDm9Hekc47/VbDAGDSX/S8z5xU53c9D+Pf4Yf7
         SyvKCcVgkincM9QIzT+Oh/D2taLawWQrZzoY3ReM4ZLqRGoHa5RdW0tgyR95UPG9jSJw
         cSvw==
X-Gm-Message-State: APjAAAUBW2cQ37Yp44BuAbzyZcVXF1Lo0p9PQceaHLgqjG5Y8ZtfTajB
	VjAjzIki6Bv6XmpUuYZ7PDAH/Axiiyxvhuseg2sVCp+dfuQ1xXjtrovz2cyDCLRba+IKLsXBFJd
	6DsSPjWPJkW6QutlaPMSECZ/dXEsooLjq5iTBvMFUtfGEk2Hwh4ikx8ChErsIQtGW9w==
X-Received: by 2002:a2e:4555:: with SMTP id s82mr14305972lja.15.1556039691941;
        Tue, 23 Apr 2019 10:14:51 -0700 (PDT)
X-Received: by 2002:a2e:4555:: with SMTP id s82mr14305899lja.15.1556039690217;
        Tue, 23 Apr 2019 10:14:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556039690; cv=none;
        d=google.com; s=arc-20160816;
        b=ZPu+5ztDCJrL3YMP7LfpcFQkClEx+KV9up9iHJCNoTI1atn6PBBxo5E5ZcR96eLtJZ
         u9glxN0P+6NNwFWH4O9aaV1Wk8+zYZzIMfOpRHcr0qf9Pybh6WJxbyOKhfr3MKUCSB28
         hi9QUbtcI58xO4Y3M1WpqgK9lg+xlkqTfpD2EHU/8RxH/3SaWiVLbyKxPYHWT/RRqezV
         QU/NSimf0qSECR+u5RAcQnjiFsQM1p+zbcie9AcDIPmnbdDabYytb2kMcX2w4wS7TX5X
         0yzDVwY79mMha2GnJpJkQMMwfUbx8dv8OAKe3vmNC2iJs/5DmW+QLiqDDB22bxBy5snW
         kUTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DN41PzKZOmTQMbeHkdOhlUuj8ZVoq/HWKOihKOAiUlk=;
        b=zuUv6bok/9XE7yfS8fFig1+Kp8OYwmjOGtu/7d70APynbkFTK2+jzHNyTEuEihn1Oh
         1Gp+ToqzBbq/ltdU27gSmdugm3dPNadVD7yBIdrbIuqMAHDAB7Ndvkqtvcxp+Li1pxgt
         7R5+CjRKNTE1ZrVRiHAF0VpP3XIHjuhpYO3Kn/iahYqMfTqEdoG4CgLNKYV5ovvXrCeQ
         LPsy6qnnZBh/2XivqvQTU9vIxjCGnTjuCc1keU+5AtBJ7K5XzfTLiNbyaUvJHv49+BSo
         psfhqYDbeLwTIrqdY5JihK2QORdDz6HAcdpoV36GK6YptDbm+upBajnRG/nnhJaZBWk2
         Y3Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ib64WJia;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor4167054lfe.27.2019.04.23.10.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:14:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ib64WJia;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DN41PzKZOmTQMbeHkdOhlUuj8ZVoq/HWKOihKOAiUlk=;
        b=Ib64WJia/BAkPDxbS+Kc7wXnZyKBjMnMMHhd+sIbXK68gAgLelqjEQTJbsLzKLenkP
         fsUI/qmA7RWw9sKX+1LXEyJ0JjpobuIYaE5y5iZEQVfDbXFKv4nQF6ctLwx8VbQ6iq6r
         L8FlHR7/6h1HX4TJHJE1+HMqNNdLQcm4yYvuPAXpcUjpad3YIqqt8g3+z+zn2kwra6kZ
         G1rCsDybwHQAbtp4pxJ3U92I640/D33dXYjVYVnxI9aMnifAV+u9MbkNi//0UfKQdnhb
         ClzR7A2g2WZ+YQ9QVvteaAwicRGRCxFUBTuGbc5d4esRIQE/NvlpKDd7UFrwF4J9FaZ5
         Nfrw==
X-Google-Smtp-Source: APXvYqz/hN6UwWr6nRTmMXR2GagmRGWOtCDKVVMFHwAq+NEsAjy94UHcnM8rxvZyuHgPDHHoWZI2R7Mo5DoWGs7U42Y=
X-Received: by 2002:a05:6512:20e:: with SMTP id a14mr254692lfo.14.1556039689580;
 Tue, 23 Apr 2019 10:14:49 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1555427418.git.nishadkamdar@gmail.com> <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
In-Reply-To: <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 23 Apr 2019 22:44:38 +0530
Message-ID: <CAFqt6za6CgpL--0eNSC28FheRYLxwfCeGVgiZS9xhkNovtyPPA@mail.gmail.com>
Subject: Re: [PATCH v3 2/5] nds32: Use the correct style for SPDX License Identifier
To: Nishad Kamdar <nishadkamdar@gmail.com>
Cc: Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Will Deacon <will.deacon@arm.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Nick Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joe Perches <joe@perches.com>, 
	=?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, 
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 8:54 PM Nishad Kamdar <nishadkamdar@gmail.com> wrote:
>
> This patch corrects the SPDX License Identifier style
> in the nds32 Hardware Architecture related files.
>
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Nishad Kamdar <nishadkamdar@gmail.com>
> ---
>  arch/nds32/include/asm/assembler.h       | 2 +-
>  arch/nds32/include/asm/barrier.h         | 2 +-
>  arch/nds32/include/asm/bitfield.h        | 2 +-
>  arch/nds32/include/asm/cache.h           | 2 +-
>  arch/nds32/include/asm/cache_info.h      | 2 +-
>  arch/nds32/include/asm/cacheflush.h      | 2 +-
>  arch/nds32/include/asm/current.h         | 2 +-
>  arch/nds32/include/asm/delay.h           | 2 +-
>  arch/nds32/include/asm/elf.h             | 2 +-
>  arch/nds32/include/asm/fixmap.h          | 2 +-
>  arch/nds32/include/asm/futex.h           | 2 +-
>  arch/nds32/include/asm/highmem.h         | 2 +-
>  arch/nds32/include/asm/io.h              | 2 +-
>  arch/nds32/include/asm/irqflags.h        | 2 +-
>  arch/nds32/include/asm/l2_cache.h        | 2 +-
>  arch/nds32/include/asm/linkage.h         | 2 +-
>  arch/nds32/include/asm/memory.h          | 2 +-
>  arch/nds32/include/asm/mmu.h             | 2 +-
>  arch/nds32/include/asm/mmu_context.h     | 2 +-
>  arch/nds32/include/asm/module.h          | 2 +-
>  arch/nds32/include/asm/nds32.h           | 2 +-
>  arch/nds32/include/asm/page.h            | 2 +-
>  arch/nds32/include/asm/pgalloc.h         | 2 +-
>  arch/nds32/include/asm/pgtable.h         | 2 +-
>  arch/nds32/include/asm/proc-fns.h        | 2 +-
>  arch/nds32/include/asm/processor.h       | 2 +-
>  arch/nds32/include/asm/ptrace.h          | 2 +-
>  arch/nds32/include/asm/shmparam.h        | 2 +-
>  arch/nds32/include/asm/string.h          | 2 +-
>  arch/nds32/include/asm/swab.h            | 2 +-
>  arch/nds32/include/asm/syscall.h         | 2 +-
>  arch/nds32/include/asm/syscalls.h        | 2 +-
>  arch/nds32/include/asm/thread_info.h     | 2 +-
>  arch/nds32/include/asm/tlb.h             | 2 +-
>  arch/nds32/include/asm/tlbflush.h        | 2 +-
>  arch/nds32/include/asm/uaccess.h         | 2 +-
>  arch/nds32/include/asm/unistd.h          | 2 +-
>  arch/nds32/include/asm/vdso.h            | 2 +-
>  arch/nds32/include/asm/vdso_datapage.h   | 2 +-
>  arch/nds32/include/asm/vdso_timer_info.h | 2 +-
>  arch/nds32/include/uapi/asm/auxvec.h     | 2 +-
>  arch/nds32/include/uapi/asm/byteorder.h  | 2 +-
>  arch/nds32/include/uapi/asm/cachectl.h   | 2 +-
>  arch/nds32/include/uapi/asm/param.h      | 2 +-
>  arch/nds32/include/uapi/asm/ptrace.h     | 2 +-
>  arch/nds32/include/uapi/asm/sigcontext.h | 2 +-
>  arch/nds32/include/uapi/asm/unistd.h     | 2 +-
>  47 files changed, 47 insertions(+), 47 deletions(-)
>
> diff --git a/arch/nds32/include/asm/assembler.h b/arch/nds32/include/asm/assembler.h
> index c3855782a541..5e7c56926049 100644
> --- a/arch/nds32/include/asm/assembler.h
> +++ b/arch/nds32/include/asm/assembler.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation

I think, better to include next *Copyright* line in multi line comment.
Applicable in all below places.

>
>  #ifndef __NDS32_ASSEMBLER_H__
> diff --git a/arch/nds32/include/asm/barrier.h b/arch/nds32/include/asm/barrier.h
> index faafc373ea6c..16413172fd50 100644
> --- a/arch/nds32/include/asm/barrier.h
> +++ b/arch/nds32/include/asm/barrier.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_ASM_BARRIER_H
> diff --git a/arch/nds32/include/asm/bitfield.h b/arch/nds32/include/asm/bitfield.h
> index 7414fcbbab4e..e75212c76b20 100644
> --- a/arch/nds32/include/asm/bitfield.h
> +++ b/arch/nds32/include/asm/bitfield.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_BITFIELD_H__
> diff --git a/arch/nds32/include/asm/cache.h b/arch/nds32/include/asm/cache.h
> index 347db4881c5f..fc3c41b59169 100644
> --- a/arch/nds32/include/asm/cache.h
> +++ b/arch/nds32/include/asm/cache.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_CACHE_H__
> diff --git a/arch/nds32/include/asm/cache_info.h b/arch/nds32/include/asm/cache_info.h
> index 38ec458ba543..e89d8078f3a6 100644
> --- a/arch/nds32/include/asm/cache_info.h
> +++ b/arch/nds32/include/asm/cache_info.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  struct cache_info {
> diff --git a/arch/nds32/include/asm/cacheflush.h b/arch/nds32/include/asm/cacheflush.h
> index 8b26198d51bb..d9ac7e6408ef 100644
> --- a/arch/nds32/include/asm/cacheflush.h
> +++ b/arch/nds32/include/asm/cacheflush.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_CACHEFLUSH_H__
> diff --git a/arch/nds32/include/asm/current.h b/arch/nds32/include/asm/current.h
> index b4dcd22b7bcb..65d30096142b 100644
> --- a/arch/nds32/include/asm/current.h
> +++ b/arch/nds32/include/asm/current.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASM_NDS32_CURRENT_H
> diff --git a/arch/nds32/include/asm/delay.h b/arch/nds32/include/asm/delay.h
> index 519ba97acb6e..56ea3894f8f8 100644
> --- a/arch/nds32/include/asm/delay.h
> +++ b/arch/nds32/include/asm/delay.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_DELAY_H__
> diff --git a/arch/nds32/include/asm/elf.h b/arch/nds32/include/asm/elf.h
> index 02250626b9f0..1c8e56d7013d 100644
> --- a/arch/nds32/include/asm/elf.h
> +++ b/arch/nds32/include/asm/elf.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASMNDS32_ELF_H
> diff --git a/arch/nds32/include/asm/fixmap.h b/arch/nds32/include/asm/fixmap.h
> index 0e60e153a71a..5a4bf11e5800 100644
> --- a/arch/nds32/include/asm/fixmap.h
> +++ b/arch/nds32/include/asm/fixmap.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_FIXMAP_H
> diff --git a/arch/nds32/include/asm/futex.h b/arch/nds32/include/asm/futex.h
> index baf178bf1d0b..5213c65c2e0b 100644
> --- a/arch/nds32/include/asm/futex.h
> +++ b/arch/nds32/include/asm/futex.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_FUTEX_H__
> diff --git a/arch/nds32/include/asm/highmem.h b/arch/nds32/include/asm/highmem.h
> index 425d546cb059..b3a82c97ded3 100644
> --- a/arch/nds32/include/asm/highmem.h
> +++ b/arch/nds32/include/asm/highmem.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASM_HIGHMEM_H
> diff --git a/arch/nds32/include/asm/io.h b/arch/nds32/include/asm/io.h
> index 5ef8ae5ba833..16f262322b8f 100644
> --- a/arch/nds32/include/asm/io.h
> +++ b/arch/nds32/include/asm/io.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_IO_H
> diff --git a/arch/nds32/include/asm/irqflags.h b/arch/nds32/include/asm/irqflags.h
> index 2bfd00f8bc48..fb45ec46bb1b 100644
> --- a/arch/nds32/include/asm/irqflags.h
> +++ b/arch/nds32/include/asm/irqflags.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #include <asm/nds32.h>
> diff --git a/arch/nds32/include/asm/l2_cache.h b/arch/nds32/include/asm/l2_cache.h
> index 37dd5ef61de8..3ea48e19e6de 100644
> --- a/arch/nds32/include/asm/l2_cache.h
> +++ b/arch/nds32/include/asm/l2_cache.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef L2_CACHE_H
> diff --git a/arch/nds32/include/asm/linkage.h b/arch/nds32/include/asm/linkage.h
> index e708c8bdb926..a696469abb70 100644
> --- a/arch/nds32/include/asm/linkage.h
> +++ b/arch/nds32/include/asm/linkage.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_LINKAGE_H
> diff --git a/arch/nds32/include/asm/memory.h b/arch/nds32/include/asm/memory.h
> index 60efc726b56e..3f4b5eeb5be2 100644
> --- a/arch/nds32/include/asm/memory.h
> +++ b/arch/nds32/include/asm/memory.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_MEMORY_H
> diff --git a/arch/nds32/include/asm/mmu.h b/arch/nds32/include/asm/mmu.h
> index 88b9ee8c1064..89d63afee455 100644
> --- a/arch/nds32/include/asm/mmu.h
> +++ b/arch/nds32/include/asm/mmu.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_MMU_H
> diff --git a/arch/nds32/include/asm/mmu_context.h b/arch/nds32/include/asm/mmu_context.h
> index fd7d13cefccc..b8fd3d189fdc 100644
> --- a/arch/nds32/include/asm/mmu_context.h
> +++ b/arch/nds32/include/asm/mmu_context.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_MMU_CONTEXT_H
> diff --git a/arch/nds32/include/asm/module.h b/arch/nds32/include/asm/module.h
> index 16cf9c7237ad..a3a08e993c65 100644
> --- a/arch/nds32/include/asm/module.h
> +++ b/arch/nds32/include/asm/module.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASM_NDS32_MODULE_H
> diff --git a/arch/nds32/include/asm/nds32.h b/arch/nds32/include/asm/nds32.h
> index 68c38151c3e4..4994f6a9e0a0 100644
> --- a/arch/nds32/include/asm/nds32.h
> +++ b/arch/nds32/include/asm/nds32.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASM_NDS32_NDS32_H_
> diff --git a/arch/nds32/include/asm/page.h b/arch/nds32/include/asm/page.h
> index 947f0491c9a7..8feb1fa12f01 100644
> --- a/arch/nds32/include/asm/page.h
> +++ b/arch/nds32/include/asm/page.h
> @@ -1,5 +1,5 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
>  /*
> - * SPDX-License-Identifier: GPL-2.0
>   * Copyright (C) 2005-2017 Andes Technology Corporation
>   */
>
> diff --git a/arch/nds32/include/asm/pgalloc.h b/arch/nds32/include/asm/pgalloc.h
> index 3c5fee5b5759..3cbc749c79aa 100644
> --- a/arch/nds32/include/asm/pgalloc.h
> +++ b/arch/nds32/include/asm/pgalloc.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMNDS32_PGALLOC_H
> diff --git a/arch/nds32/include/asm/pgtable.h b/arch/nds32/include/asm/pgtable.h
> index ee59c1f9e4fc..c70cc56bec09 100644
> --- a/arch/nds32/include/asm/pgtable.h
> +++ b/arch/nds32/include/asm/pgtable.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMNDS32_PGTABLE_H
> diff --git a/arch/nds32/include/asm/proc-fns.h b/arch/nds32/include/asm/proc-fns.h
> index bedc4f59e064..27c617fa77af 100644
> --- a/arch/nds32/include/asm/proc-fns.h
> +++ b/arch/nds32/include/asm/proc-fns.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_PROCFNS_H__
> diff --git a/arch/nds32/include/asm/processor.h b/arch/nds32/include/asm/processor.h
> index 72024f8bc129..b82369c7659d 100644
> --- a/arch/nds32/include/asm/processor.h
> +++ b/arch/nds32/include/asm/processor.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_PROCESSOR_H
> diff --git a/arch/nds32/include/asm/ptrace.h b/arch/nds32/include/asm/ptrace.h
> index c4538839055c..919ee223620c 100644
> --- a/arch/nds32/include/asm/ptrace.h
> +++ b/arch/nds32/include/asm/ptrace.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_PTRACE_H
> diff --git a/arch/nds32/include/asm/shmparam.h b/arch/nds32/include/asm/shmparam.h
> index fd1cff64b68e..3aeee946973d 100644
> --- a/arch/nds32/include/asm/shmparam.h
> +++ b/arch/nds32/include/asm/shmparam.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMNDS32_SHMPARAM_H
> diff --git a/arch/nds32/include/asm/string.h b/arch/nds32/include/asm/string.h
> index 179272caa540..cae8fe16de98 100644
> --- a/arch/nds32/include/asm/string.h
> +++ b/arch/nds32/include/asm/string.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_STRING_H
> diff --git a/arch/nds32/include/asm/swab.h b/arch/nds32/include/asm/swab.h
> index e01a755a37d2..362a466f2976 100644
> --- a/arch/nds32/include/asm/swab.h
> +++ b/arch/nds32/include/asm/swab.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_SWAB_H__
> diff --git a/arch/nds32/include/asm/syscall.h b/arch/nds32/include/asm/syscall.h
> index 174b8571d362..899b2fb4b52f 100644
> --- a/arch/nds32/include/asm/syscall.h
> +++ b/arch/nds32/include/asm/syscall.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2008-2009 Red Hat, Inc.  All rights reserved.
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
> diff --git a/arch/nds32/include/asm/syscalls.h b/arch/nds32/include/asm/syscalls.h
> index da32101b455d..f3b16f602cb5 100644
> --- a/arch/nds32/include/asm/syscalls.h
> +++ b/arch/nds32/include/asm/syscalls.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_SYSCALLS_H
> diff --git a/arch/nds32/include/asm/thread_info.h b/arch/nds32/include/asm/thread_info.h
> index bff741ff337b..3734b1c1cf82 100644
> --- a/arch/nds32/include/asm/thread_info.h
> +++ b/arch/nds32/include/asm/thread_info.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_THREAD_INFO_H
> diff --git a/arch/nds32/include/asm/tlb.h b/arch/nds32/include/asm/tlb.h
> index d5ae571c8d30..a8aff1c8b4f4 100644
> --- a/arch/nds32/include/asm/tlb.h
> +++ b/arch/nds32/include/asm/tlb.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASMNDS32_TLB_H
> diff --git a/arch/nds32/include/asm/tlbflush.h b/arch/nds32/include/asm/tlbflush.h
> index 38ee769b18d8..97155366ea01 100644
> --- a/arch/nds32/include/asm/tlbflush.h
> +++ b/arch/nds32/include/asm/tlbflush.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMNDS32_TLBFLUSH_H
> diff --git a/arch/nds32/include/asm/uaccess.h b/arch/nds32/include/asm/uaccess.h
> index 116598b47c4d..8916ad9f9f13 100644
> --- a/arch/nds32/include/asm/uaccess.h
> +++ b/arch/nds32/include/asm/uaccess.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMANDES_UACCESS_H
> diff --git a/arch/nds32/include/asm/unistd.h b/arch/nds32/include/asm/unistd.h
> index b586a2862beb..bf5e2d440913 100644
> --- a/arch/nds32/include/asm/unistd.h
> +++ b/arch/nds32/include/asm/unistd.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #define __ARCH_WANT_SYS_CLONE
> diff --git a/arch/nds32/include/asm/vdso.h b/arch/nds32/include/asm/vdso.h
> index af2c6afc2469..89b113ffc3dc 100644
> --- a/arch/nds32/include/asm/vdso.h
> +++ b/arch/nds32/include/asm/vdso.h
> @@ -1,5 +1,5 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
>  /*
> - * SPDX-License-Identifier: GPL-2.0
>   * Copyright (C) 2005-2017 Andes Technology Corporation
>   */
>
> diff --git a/arch/nds32/include/asm/vdso_datapage.h b/arch/nds32/include/asm/vdso_datapage.h
> index 79db5a12ca5e..cd1dda3da0f9 100644
> --- a/arch/nds32/include/asm/vdso_datapage.h
> +++ b/arch/nds32/include/asm/vdso_datapage.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2012 ARM Limited
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>  #ifndef __ASM_VDSO_DATAPAGE_H
> diff --git a/arch/nds32/include/asm/vdso_timer_info.h b/arch/nds32/include/asm/vdso_timer_info.h
> index 50ba117cff12..328439ce37db 100644
> --- a/arch/nds32/include/asm/vdso_timer_info.h
> +++ b/arch/nds32/include/asm/vdso_timer_info.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  extern struct timer_info_t timer_info;
> diff --git a/arch/nds32/include/uapi/asm/auxvec.h b/arch/nds32/include/uapi/asm/auxvec.h
> index 2d3213f5e595..b5d58ea8decb 100644
> --- a/arch/nds32/include/uapi/asm/auxvec.h
> +++ b/arch/nds32/include/uapi/asm/auxvec.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_AUXVEC_H
> diff --git a/arch/nds32/include/uapi/asm/byteorder.h b/arch/nds32/include/uapi/asm/byteorder.h
> index a23f6f3a2468..511e653c709d 100644
> --- a/arch/nds32/include/uapi/asm/byteorder.h
> +++ b/arch/nds32/include/uapi/asm/byteorder.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __NDS32_BYTEORDER_H__
> diff --git a/arch/nds32/include/uapi/asm/cachectl.h b/arch/nds32/include/uapi/asm/cachectl.h
> index 4cdca9b23974..73793662815c 100644
> --- a/arch/nds32/include/uapi/asm/cachectl.h
> +++ b/arch/nds32/include/uapi/asm/cachectl.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 1994, 1995, 1996 by Ralf Baechle
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>  #ifndef        _ASM_CACHECTL
> diff --git a/arch/nds32/include/uapi/asm/param.h b/arch/nds32/include/uapi/asm/param.h
> index e3fb723ee362..2977534a6bd3 100644
> --- a/arch/nds32/include/uapi/asm/param.h
> +++ b/arch/nds32/include/uapi/asm/param.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __ASM_NDS32_PARAM_H
> diff --git a/arch/nds32/include/uapi/asm/ptrace.h b/arch/nds32/include/uapi/asm/ptrace.h
> index 358c99e399d0..1a6e01c00e6f 100644
> --- a/arch/nds32/include/uapi/asm/ptrace.h
> +++ b/arch/nds32/include/uapi/asm/ptrace.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef __UAPI_ASM_NDS32_PTRACE_H
> diff --git a/arch/nds32/include/uapi/asm/sigcontext.h b/arch/nds32/include/uapi/asm/sigcontext.h
> index 58afc416473e..628ff6b75825 100644
> --- a/arch/nds32/include/uapi/asm/sigcontext.h
> +++ b/arch/nds32/include/uapi/asm/sigcontext.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #ifndef _ASMNDS32_SIGCONTEXT_H
> diff --git a/arch/nds32/include/uapi/asm/unistd.h b/arch/nds32/include/uapi/asm/unistd.h
> index 4ec8f543103f..c691735017ed 100644
> --- a/arch/nds32/include/uapi/asm/unistd.h
> +++ b/arch/nds32/include/uapi/asm/unistd.h
> @@ -1,4 +1,4 @@
> -// SPDX-License-Identifier: GPL-2.0
> +/* SPDX-License-Identifier: GPL-2.0 */
>  // Copyright (C) 2005-2017 Andes Technology Corporation
>
>  #define __ARCH_WANT_STAT64
> --
> 2.17.1
>

