Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9958B6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:47:50 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so51006687ied.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:47:50 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id ys7si3050414igb.3.2015.03.23.12.47.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 12:47:50 -0700 (PDT)
Received: by ignm3 with SMTP id m3so39130426ign.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:47:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150323.150833.1435862810481480096.davem@davemloft.net>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<CA+55aFzepCj56MPVgYmMem+yfYpSOX7tBRtPHeOQxXp31Tghhg@mail.gmail.com>
	<20150323.150833.1435862810481480096.davem@davemloft.net>
Date: Mon, 23 Mar 2015 12:47:49 -0700
Message-ID: <CA+55aFwfAxOME7v=EUZd7j0AoHinXgs6TDwU-TZKiGy3Rs5Lbg@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: David Ahern <david.ahern@oracle.com>, sparclinux@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bpicco@meloft.net

On Mon, Mar 23, 2015 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
>
> Sure you could do that in C, but I really want to avoid using memcpy()
> if dst and src overlap in any way at all.
>
> Said another way, I don't want to codify that "64" thing.  The next
> chip could do 128 byte initializing stores.

But David, THAT IS NOT WHAT YOUR BROKEN ASM DOES ANYWAY!

Read it again. Your asm code does not check for overlap. Look at this:

        cmp             %o0, %o1
        bleu,pt         %xcc, 2f

and ponder. It's wrong.

So even if you don't want to take that "allow overlap more than 64
bytes apart" thing, my C version actually is *better* than the broken
asm version you have.

The new asm version is better than the old one, because the new
breakage is about really bad performance rather than actively
breaking, but still..

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
