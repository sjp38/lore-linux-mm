Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63C5E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:23:18 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so4504728ply.4
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:23:18 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 62si1783925pgi.314.2018.12.21.09.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 09:23:17 -0800 (PST)
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 69BAF2195D
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:23:16 +0000 (UTC)
Received: by mail-wr1-f46.google.com with SMTP id c14so6057102wrr.0
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:23:16 -0800 (PST)
MIME-Version: 1.0
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-5-igor.stoppa@huawei.com> <20181220184917.GY10600@bombadil.infradead.org>
 <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
In-Reply-To: <d5e8523a-3afd-d992-1af3-b329985c5ed5@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 21 Dec 2018 09:23:03 -0800
Message-ID: <CALCETrU8GZbF2oWYeKUVKBURuh1zeMqcHM5RMTchiDsdrSSVPA@mail.gmail.com>
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 20, 2018 at 11:19 AM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>
>
>
> On 20/12/2018 20:49, Matthew Wilcox wrote:
>
> > I think you're causing yourself more headaches by implementing this "op"
> > function.
>
> I probably misinterpreted the initial criticism on my first patchset,
> about duplication. Somehow, I'm still thinking to the endgame of having
> higher-level functions, like list management.
>
> > Here's some generic code:
>
> thank you, I have one question, below
>
> > void *wr_memcpy(void *dst, void *src, unsigned int len)
> > {
> >       wr_state_t wr_state;
> >       void *wr_poking_addr = __wr_addr(dst);
> >
> >       local_irq_disable();
> >       wr_enable(&wr_state);
> >       __wr_memcpy(wr_poking_addr, src, len);
>
> Is __wraddr() invoked inside wm_memcpy() instead of being invoked
> privately within __wr_memcpy() because the code is generic, or is there
> some other reason?
>
> >       wr_disable(&wr_state);
> >       local_irq_enable();
> >
> >       return dst;
> > }
> >
> > Now, x86 can define appropriate macros and functions to use the temporary_mm
> > functionality, and other architectures can do what makes sense to them.
> >

I suspect that most architectures will want to do this exactly like
x86, though, but sure, it could be restructured like this.

On x86, I *think* that __wr_memcpy() will want to special-case len ==
1, 2, 4, and (on 64-bit) 8 byte writes to keep them atomic. i'm
guessing this is the same on most or all architectures.

>
> --
> igor
