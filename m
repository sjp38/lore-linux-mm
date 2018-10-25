Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1EB46B0291
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 08:38:35 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id g2so5811715otb.5
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:38:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c9sor4473849otb.160.2018.10.25.05.38.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 05:38:34 -0700 (PDT)
Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com. [209.85.167.178])
        by smtp.gmail.com with ESMTPSA id d7-v6sm2288865oia.18.2018.10.25.05.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 05:38:31 -0700 (PDT)
Received: by mail-oi1-f178.google.com with SMTP id p125-v6so6493925oic.3
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:38:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181025120006.GY30658@n2100.armlinux.org.uk>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org> <20181025120006.GY30658@n2100.armlinux.org.uk>
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Date: Thu, 25 Oct 2018 09:37:59 -0300
Message-ID: <CABdQkv_cC4ixEFr91zyg-S21O5_7U8FV7=g7ZMRqGcQyhrwzaQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow
 for PAE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Rafael David Tinoco <rafael.tinoco@linaro.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

> MAX_PHYSMEM_BITS is a definition for sparsemem, and is only visible
> when sparsemem is enabled.  When sparsemem is disabled, asm/sparsemem.h
> is not included (and should not be included) which means there is no
> MAX_PHYSMEM_BITS definition.

Missed that part :\, tks.

> I don't think zsmalloc.c should be (ab)using MAX_PHYSMEM_BITS, and
> your description above makes it sound like you expect it to always be
> defined.
>
> If we want to have a definition for this, we shouldn't be playing
> fragile games like:
>
> #ifndef MAX_POSSIBLE_PHYSMEM_BITS
> #ifdef MAX_PHYSMEM_BITS
> #define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
> #else
> /*
>  * If this definition of MAX_PHYSMEM_BITS is used, OBJ_INDEX_BITS will just
>  * be PAGE_SHIFT
>  */
> #define MAX_POSSIBLE_PHYSMEM_BITS BITS_PER_LONG
> #endif
> #endif
>
> but instead insist that MAX_PHYSMEM_BITS is defined _everywhere_.

Is it okay to propose using only MAX_PHYSMEM_BITS for zsmalloc (like
it was before commit 02390b87) instead, and make sure *at least* ARM
32/64 and x86/x64, for now, have it defined outside sparsemem headers
as well ? This way I can WARN_ONCE(), instead of BUG(), when specific
arch does not define it - enforcing behavior - showing BITS_PER_LONG
is being used instead of MAX_PHYSMEM_BITS (warning, at least once, for
the possibility of an overflow, like the issue showed in here).
