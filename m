Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 425286B006E
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:19:10 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so175845930pad.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 19:19:10 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id tu4si19385732pab.237.2015.03.22.19.19.09
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 19:19:09 -0700 (PDT)
Date: Sun, 22 Mar 2015 22:19:06 -0400 (EDT)
Message-Id: <20150322.221906.1670737065885267482.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <20150322.220024.1171832215344978787.davem@davemloft.net>
References: <20150322.195403.1653355516554747742.davem@davemloft.net>
	<550F5852.5020405@oracle.com>
	<20150322.220024.1171832215344978787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.ahern@oracle.com
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net


Nevermind I think I figured out the problem.

It's the cache initializing stores, we can't do overlapping
copies where dst <= src in all cases because of them.

A store to a address modulo the cache line size (which for
these instructions is 64 bytes), clears that whole line.

But when we're doing these memmove() calls in SLAB/SLUB, we
can clear some bytes at the end of the line before they've
been read in.

And reading over NG4memcpy, this _can_ happen, the main unrolled
loop begins like this:

	load	src + 0x00
	load	src + 0x08
	load	src + 0x10
	load	src + 0x18
	load	src + 0x20
	store	dst + 0x00

Assume dst is 64 byte aligned and let's say that dst is src - 8 for
this memcpy() call, right?  That store at the end there is the one to
the first line in the cache line, thus clearing the whole line, which
thus clobbers "src + 0x28" before it even gets loaded.

I'm pretty sure this is what's happening.

And it's only going to trigger if the memcpy() is 128 bytes or larger.

I'll work on a fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
