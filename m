Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E263FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A029221855
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:13:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BTT/af11"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A029221855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 355668E0006; Tue, 26 Feb 2019 07:13:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 305D28E0001; Tue, 26 Feb 2019 07:13:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F68F8E0006; Tue, 26 Feb 2019 07:13:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A59478E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:13:20 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id f11so1186907lfc.0
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:13:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DT0qlgg8yLGWJfZNXVHCGnHtRXa+0hWQ5l9kpD9jVV8=;
        b=N320a0RfeENzFnkWVliP7r5kb9p1nvX7NjouURt3Te4jsY353j19Df2BypsYWY14S5
         5d+DmEGiZRvpDH8FmXv3ARrYXjmFeVQ9Cn+lUifKtu/muGP1r+H3DBMYN+6uAqjcH7WQ
         lpf5Tz492/x5ubhBcGxHHSOTRfKpQLBCJqHNjwhrt4IBjAIpGI7LSwtgpnHjUZ2s9ozh
         9bCx9K6jQAM3v3nhEymvV7DURWpv5ilmOJ8OxuQwp+rVQ/zo3HRmaY29kK4onnWpFrAJ
         y4u23rFG1/ukAX2bHr5Nz9xgVveyiqaTTa8DppwsMR3Y5UTwAe7P8Xwu7ancuSNEqsad
         Ir3g==
X-Gm-Message-State: AHQUAuYJb3EVoqaiR0WSUF9nFIn70iYDtFuApx67WxnMjgqusEY+Spa2
	9BaR6U3gM+x6A0A8WyuXVsHSjrAIo9+Bwwi5SYiNGeE5AdWRACfzGi+/9teJOZ8Dp/zuygh7f+l
	766dyACsXLlFdgp/HB4QUnIujdpoSpJmWTVXdNy1QrVwPLqFfxreWHOwCiqYGPdGXMB8nGMRVgZ
	7yQfOmnmfvUvIccNUIPnSbNn/UBotiM4HatUcFnxpJ5/+EWwA66aHAR1sbpPKhTZnq72oDoEUmX
	CaEE3lYI3QfslXC+uqay2I/fLv8T9ZMDNUongfpMSWiRbpSEn8NkuQ3yrSgn5neUnaDezmg0QV1
	FQB/6ArPZYVrrYA1sAqXr0InSdOdTpCqoRRofOtfqf62zlfPT0HSEn5VNpEG3sRhk6QfuHH0ta/
	3
X-Received: by 2002:a2e:a28b:: with SMTP id k11mr12907258lja.176.1551183199869;
        Tue, 26 Feb 2019 04:13:19 -0800 (PST)
X-Received: by 2002:a2e:a28b:: with SMTP id k11mr12907210lja.176.1551183198821;
        Tue, 26 Feb 2019 04:13:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551183198; cv=none;
        d=google.com; s=arc-20160816;
        b=VcMlY72Q9HGWrsD1tY5oF6mOPXW61vb64rZCvDUAc34S82ol01fu8/uGh4dB70i1k6
         T0c8YDaQfckk5/jDA0SodLrJc92E2sSFggheHpclcFCtyhtH7fbl3zllcpc1Xm//HlYP
         koATJU43SZurNf6sfMB4ZlwGtho9iKqK/f6K7q6f3h8Cq2eyYpTK8A4Ri2S+b6C3Y084
         ilGPF8/xvbWWEHYSIDn4I8jlBgkzIfd1D/GDZ25/boKmvyy+XPlAyylAn1MwJ22KSEON
         n9Ne2b2EwZfSfayZxh0seRPV8cyTLo7CYbTZ1oduwFJyAWeI2gBmYirJbh3jdWI4+ol7
         ckcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DT0qlgg8yLGWJfZNXVHCGnHtRXa+0hWQ5l9kpD9jVV8=;
        b=YKZ3I+opAN+WwNi6oqk35qOBSaixTqLSB3BNh59GgZN0bJRnz0p0XQ2omS98XHxSsa
         XaG5TZHgmNUFvm7veqbsYHlBOotKmw+MVDp16Rp2UXXjZdq98zVDjPF9n/38eqo2C5Bd
         LJIPlFBUnt+FWSiv5YCvjkBz22/wK7ZDh+dddSCzCicdbYkQWcwDgGCZcoAJMmbktRyo
         2R2R2QIDTMWAw60xV3IRISgg7UEzuYMcGk0hpYzSFMNRiIuyMdynTKWwpfzxVjDXT2dJ
         KLWLStU7t3V6j/d/FmBs/r01mTTPfNJWBldQrpGVExNpXUTTB25IZXY/B9ynLbQ7A1R9
         oOQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BTT/af11";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor6883117ljf.40.2019.02.26.04.13.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 04:13:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BTT/af11";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DT0qlgg8yLGWJfZNXVHCGnHtRXa+0hWQ5l9kpD9jVV8=;
        b=BTT/af11Af4g7Z8+iUJtkrhRpsF18FwF+w/DZHgvAt3DMkp0DR3DZI5Xl4r06i9MiA
         yRnQaNrTgCz3u/9qEbJRf4Rx2S0rDLKR7sB4loDcv4vOOHEpJPBdduj3TNHoA0HlD76/
         8eau9Nwao+bFFEgDH+m0fkUaSdIi9Jzr2zz9WxUIxY9mSAUuojWBfkWXMh6cFJR7ctX4
         U0p3y02ujuSIqgyV6QthnsOFiMMQgzVEo4P7qNOSs0twzddPrSmfTbudjODRwAuIVbwl
         3Enu7havs7HWL3lMXY03THVCMsyGFlrnMdQ0FxTPU7HiSlWmly/P1p5byZd3t9Q6CpgZ
         T2wQ==
X-Google-Smtp-Source: AHgI3IbqBHCDYCt00RIdjo12W+Ik6ICDGxRWE+n+JCPu9cfQgZ/db+khrZWu0PfllbqgyVIo+DTu4bpAmvZ+uT1UBs4=
X-Received: by 2002:a2e:240a:: with SMTP id k10mr13038482ljk.31.1551183198318;
 Tue, 26 Feb 2019 04:13:18 -0800 (PST)
MIME-Version: 1.0
References: <20190225191710.48131-1-cai@lca.pw>
In-Reply-To: <20190225191710.48131-1-cai@lca.pw>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 26 Feb 2019 17:43:06 +0530
Message-ID: <CAFqt6zYjf=KnXhkmbr78RR3ZkzRmTaERJMNOn7CXrrYYxrV-Pg@mail.gmail.com>
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 12:47 AM Qian Cai <cai@lca.pw> wrote:
>
> When onlining memory pages, it calls kernel_unmap_linear_page(),
> However, it does not call kernel_map_linear_page() while offlining
> memory pages. As the result, it triggers a panic below while onlining on
> ppc64le as it checks if the pages are mapped before unmapping,
> Therefore, let it call kernel_map_linear_page() when setting all pages
> as reserved.
>
> kernel BUG at arch/powerpc/mm/hash_utils_64.c:1815!
> Oops: Exception in kernel mode, sig: 5 [#1]
> LE SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
> CPU: 2 PID: 4298 Comm: bash Not tainted 5.0.0-rc7+ #15
> NIP:  c000000000062670 LR: c00000000006265c CTR: 0000000000000000
> REGS: c0000005bf8a75b0 TRAP: 0700   Not tainted  (5.0.0-rc7+)
> MSR:  800000000282b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE>  CR: 28422842  XER: 00000000
> CFAR: c000000000804f44 IRQMASK: 1
> GPR00: c00000000006265c c0000005bf8a7840 c000000001518200 c0000000013cbcc8
> GPR04: 0000000000080004 0000000000000000 00000000ccc457e0 c0000005c4e341d8
> GPR08: 0000000000000000 0000000000000001 c000000007f4f800 0000000000000001
> GPR12: 0000000000002200 c000000007f4e100 0000000000000000 0000000139c29710
> GPR16: 0000000139c29714 0000000139c29788 c0000000013cbcc8 0000000000000000
> GPR20: 0000000000034000 c0000000016e05e8 0000000000000000 0000000000000001
> GPR24: 0000000000bf50d9 800000000000018e 0000000000000000 c0000000016e04b8
> GPR28: f000000000d00040 0000006420a2f217 f000000000d00000 00ea1b2170340000
> NIP [c000000000062670] __kernel_map_pages+0x2e0/0x4f0
> LR [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0
> Call Trace:
> [c0000005bf8a7840] [c00000000006265c] __kernel_map_pages+0x2cc/0x4f0 (unreliable)
> [c0000005bf8a78d0] [c00000000028c4a0] free_unref_page_prepare+0x2f0/0x4d0
> [c0000005bf8a7930] [c000000000293144] free_unref_page+0x44/0x90
> [c0000005bf8a7970] [c00000000037af24] __online_page_free+0x84/0x110
> [c0000005bf8a79a0] [c00000000037b6e0] online_pages_range+0xc0/0x150
> [c0000005bf8a7a00] [c00000000005aaa8] walk_system_ram_range+0xc8/0x120
> [c0000005bf8a7a50] [c00000000037e710] online_pages+0x280/0x5a0
> [c0000005bf8a7b40] [c0000000006419e4] memory_subsys_online+0x1b4/0x270
> [c0000005bf8a7bb0] [c000000000616720] device_online+0xc0/0xf0
> [c0000005bf8a7bf0] [c000000000642570] state_store+0xc0/0x180
> [c0000005bf8a7c30] [c000000000610b2c] dev_attr_store+0x3c/0x60
> [c0000005bf8a7c50] [c0000000004c0a50] sysfs_kf_write+0x70/0xb0
> [c0000005bf8a7c90] [c0000000004bf40c] kernfs_fop_write+0x10c/0x250
> [c0000005bf8a7ce0] [c0000000003e4b18] __vfs_write+0x48/0x240
> [c0000005bf8a7d80] [c0000000003e4f68] vfs_write+0xd8/0x210
> [c0000005bf8a7dd0] [c0000000003e52f0] ksys_write+0x70/0x120
> [c0000005bf8a7e20] [c00000000000b000] system_call+0x5c/0x70
> Instruction dump:
> 7fbd5278 7fbd4a78 3e42ffeb 7bbd0640 3a523ac8 7e439378 487a2881 60000000
> e95505f0 7e6aa0ae 6a690080 7929c9c2 <0b090000> 7f4aa1ae 7e439378 487a28dd
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/page_alloc.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 10d0f2ed9f69..025fc93d1518 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8349,6 +8349,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>                 for (i = 0; i < (1 << order); i++)
>                         SetPageReserved((page+i));
>                 pfn += (1 << order);
> +               kernel_map_pages(page, 1 << order, 1);

Doubt , Not sure, but does this change will have any impact on
drivers/base/memory.c#L249
memory_block_action() ->  offline_pages() ?

>         }
>         spin_unlock_irqrestore(&zone->lock, flags);
>  }
> --
> 2.17.2 (Apple Git-113)
>

