Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DD4EB6B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 13:36:08 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so153476604pab.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 10:36:08 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id cg3si6849950pbc.36.2015.03.22.10.36.06
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 10:36:07 -0700 (PDT)
Date: Sun, 22 Mar 2015 13:36:03 -0400 (EDT)
Message-Id: <20150322.133603.471287558426791155.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
References: <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
	<550DAE23.7030000@oracle.com>
	<CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: david.ahern@oracle.com, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 21 Mar 2015 11:49:12 -0700

> Davem? I don't read sparc assembly, so I'm *really* not going to try
> to verify that (a) all the memcpy implementations always copy
> low-to-high and (b) that I even read the address comparisons in
> memmove.S right.

All of the sparc memcpy implementations copy from low to high.
I'll eat my hat if they don't. :-)

The guard tests at the beginning of memmove() are saying:

	if (dst <= src)
		memcpy(...);
	if (src + len <= dst)
		memcpy(...);

And then the reverse copy loop (and we do have to copy in reverse for
correctness) is basically:

	src = (src + len - 1);
	dst = (dst + len - 1);

1:	tmp = *(u8 *)src;
	len -= 1;
	src -= 1;
	*(u8 *)dst = tmp;
	dst -= 1;
	if (len != 0)
		goto 1b;

And then we return the original 'dst' pointer.

So at first glance it looks at least correct.

memmove() is a good idea to look into though, as SLAB and SLUB are the
only really heavy users of it, and they do so with overlapping
contents.

And they end up using that byte-at-a-time code, since SLAB and SLUB
do mmemove() calls of the form:

	memmove(X + N, X, LEN);

In which case neither of the memcpy() guard tests will pass.

Maybe there is some subtle bug in there I just don't see right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
