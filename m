Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id D73976B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:45:59 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id 10so20310285lbg.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:45:59 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id ca7si998732lad.74.2015.01.12.12.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 12:45:58 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id b6so19595693lbj.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:45:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Date: Mon, 12 Jan 2015 21:45:58 +0100
Message-ID: <CAMuHMdV74n3v81xaLRDN_Mn_QGg14yUkXNn6JYaGH4MGgLRM2A@mail.gmail.com>
Subject: Re: [PATCH 0/5] kstrdup optimization
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: Linux MM <linux-mm@kvack.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Andreas Mohr <andi@lisas.de>, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 12, 2015 at 10:18 AM, Andrzej Hajda <a.hajda@samsung.com> wrote:
> kstrdup if often used to duplicate strings where neither source neither
> destination will be ever modified. In such case we can just reuse the source
> instead of duplicating it. The problem is that we must be sure that
> the source is non-modifiable and its life-time is long enough.
>
> I suspect the good candidates for such strings are strings located in kernel
> .rodata section, they cannot be modifed because the section is read-only and
> their life-time is equal to kernel life-time.
>
> This small patchset proposes alternative version of kstrdup - kstrdup_const,
> which returns source string if it is located in .rodata otherwise it fallbacks
> to kstrdup.

It also introduces kfree_const(const void *x).

As kfree_const() has the exact same signature as kfree(), the risk of
accidentally passing pointers returned from kstrdup_const() to kfree() seems
high, which may lead to memory corruption if the pointer doesn't point to
allocated memory.

> To verify if the source is in .rodata function checks if the address is between
> sentinels __start_rodata, __end_rodata. I guess it should work with all
> architectures.
>
> The main patch is accompanied by four patches constifying kstrdup for cases
> where situtation described above happens frequently.
>
> As I have tested the patchset on mobile platform (exynos4210-trats) it saves
> 3272 string allocations. Since minimal allocation is 32 or 64 bytes depending
> on Kconfig options the patchset saves respectively about 100KB or 200KB of memory.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
