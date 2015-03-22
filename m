Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7061A6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 18:23:17 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so167320391pdb.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 15:23:17 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id rp11si19130037pab.75.2015.03.22.15.23.16
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 15:23:16 -0700 (PDT)
Date: Sun, 22 Mar 2015 18:23:11 -0400 (EDT)
Message-Id: <20150322.182311.109269221031797359.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>
References: <CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
	<20150322.133603.471287558426791155.davem@davemloft.net>
	<CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: david.ahern@oracle.com, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 22 Mar 2015 12:47:08 -0700

> Which was why I was asking how sure you are that memcpy *always*
> copies from low to high.

Yeah I'm pretty sure.

> I don't even know which version of memcpy ends up being used on M7.
> Some of them do things like use VIS. I can follow some regular sparc
> asm, there's no way I'm even *looking* at that. Is it really ok to use
> VIS registers in random contexts?

Yes, using VIS how we do is alright, and in fact I did an audit of
this about 1 year ago.  This is another one of those "if this is
wrong, so much stuff would break"

The only thing funny some of these routines do is fetch 2 64-byte
blocks of data ahead in the inner loops, but that should be fine
right?

On the M7 we'll use the Niagara-4 memcpy.

Hmmm... I'll run this silly sparc kernel memmove through the glibc
testsuite and see if it barfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
