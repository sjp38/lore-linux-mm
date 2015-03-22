Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8F26B6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 15:47:09 -0400 (EDT)
Received: by iedm5 with SMTP id m5so22422909ied.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 12:47:09 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id k4si4183893igu.6.2015.03.22.12.47.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 12:47:09 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so26266437ied.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 12:47:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150322.133603.471287558426791155.davem@davemloft.net>
References: <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
	<550DAE23.7030000@oracle.com>
	<CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
	<20150322.133603.471287558426791155.davem@davemloft.net>
Date: Sun, 22 Mar 2015 12:47:08 -0700
Message-ID: <CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: David Ahern <david.ahern@oracle.com>, sparclinux@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Mar 22, 2015 at 10:36 AM, David Miller <davem@davemloft.net> wrote:
>
> And they end up using that byte-at-a-time code, since SLAB and SLUB
> do mmemove() calls of the form:
>
>         memmove(X + N, X, LEN);

Actually, the common case in slab is overlapping but of the form

     memmove(p, p+x, len);

which goes to memcpy. It's basically re-compacting the array at the beginning.

Which was why I was asking how sure you are that memcpy *always*
copies from low to high.

I don't even know which version of memcpy ends up being used on M7.
Some of them do things like use VIS. I can follow some regular sparc
asm, there's no way I'm even *looking* at that. Is it really ok to use
VIS registers in random contexts?

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
