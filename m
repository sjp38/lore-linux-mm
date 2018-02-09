Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1036B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 20:47:59 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id e8so3817259qkm.18
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 17:47:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 46sor1056015qtx.147.2018.02.08.17.47.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 17:47:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208202100.GB3424@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
 <20180208185648.GB9524@bombadil.infradead.org> <CA+DvKQLHcFc3+kW_SnD6hs53yyD5Zi+uAeSgDMm1tRzxqy-Opg@mail.gmail.com>
 <20180208194235.GA3424@bombadil.infradead.org> <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
 <20180208202100.GB3424@bombadil.infradead.org>
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 8 Feb 2018 20:47:57 -0500
Message-ID: <CA+DvKQK_JAmy9AyJgX6wp=nMatYiAb5882JTzDuoD4Bcuzo2Cw@mail.gmail.com>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kees Cook <keescook@chromium.org>

I think there are likely legitimate programs mapping something a bunch of times.

Falling back to a global object -> count mapping (an rbtree / radix
trie or whatever) with a lock once it hits saturation wouldn't risk
breaking something. It would permanently leave the inline count
saturated and just use the address of the inline counter as the key
for the map to find the 64-bit counter. Once it gets to 0 in the map,
it can delete it from the map and do the standard freeing process,
avoiding leaks. It would really just make it a 64-bit reference count
heavily size optimized for the common case. It would work elsewhere
too, not just this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
