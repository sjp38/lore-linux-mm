Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 012266B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:49:52 -0400 (EDT)
Received: by igcau2 with SMTP id au2so28840876igc.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 16:49:51 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id x13si9900724ioi.93.2015.03.22.16.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 16:49:51 -0700 (PDT)
Received: by iecvj10 with SMTP id vj10so24588045iec.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 16:49:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150322.182311.109269221031797359.davem@davemloft.net>
References: <CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
	<20150322.133603.471287558426791155.davem@davemloft.net>
	<CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>
	<20150322.182311.109269221031797359.davem@davemloft.net>
Date: Sun, 22 Mar 2015 16:49:51 -0700
Message-ID: <CA+55aFwWJU+D_rFhZVf0JZ599XH-2APELyrpBYYuvDsynyoMUw@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: David Ahern <david.ahern@oracle.com>, sparclinux@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Mar 22, 2015 at 3:23 PM, David Miller <davem@davemloft.net> wrote:
>
> Yes, using VIS how we do is alright, and in fact I did an audit of
> this about 1 year ago.  This is another one of those "if this is
> wrong, so much stuff would break"

Maybe. But it does seem like Bob Picco has narrowed it down to memmove().

It also bothers me enormously - and perhaps unreasonably - how that
memcpy code has memory barriers in it. I can see _zero_ reason for a
memory barrier inside a memcpy, unless the memcpy does something that
isn't valid to begin with. Are the VIS operatiosn perhaps using some
kind of non-temporal form that doesn't follow the TSO rules? Kind of
like the "movnt" that Intel has?

That kind of stuff makes me worry. For example, the only reason I see for

        membar          #StoreLoad | #StoreStore

after that VIS loop is that the stxa doesn't honor normal memory store
ordering rules, but if that's true, then shouldn't we have a membar
*before* the loop too? How about "ldx"? Does that also do some
unordered loads?

So the memory barriers in there just make me nervous, because they are
either entirely bogus or superfluous, or they are not - and if they
aren't, then that implies that some of the code does something really
odd with memory ordering.

I dunno. I really can't read that code at all, so I'm going entirely
by gut instinct here.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
