Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E74426B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 15:28:58 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so164535384pdb.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 12:28:58 -0700 (PDT)
Received: from homiemail-a24.g.dreamhost.com (sub4.mail.dreamhost.com. [69.163.253.135])
        by mx.google.com with ESMTP id pk5si18873850pdb.11.2015.03.22.12.28.57
        for <linux-mm@kvack.org>;
        Sun, 22 Mar 2015 12:28:57 -0700 (PDT)
Date: Sun, 22 Mar 2015 15:25:57 -0400
From: Bob Picco <bpicco@meloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
Message-ID: <20150322192557.GA2929@zareason>
References: <CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
 <550DAE23.7030000@oracle.com>
 <CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
 <20150322.133603.471287558426791155.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150322.133603.471287558426791155.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, david.ahern@oracle.com, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Miller wrote:	[Sun Mar 22 2015, 01:36:03PM EDT]
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 21 Mar 2015 11:49:12 -0700
> 
> > Davem? I don't read sparc assembly, so I'm *really* not going to try
> > to verify that (a) all the memcpy implementations always copy
> > low-to-high and (b) that I even read the address comparisons in
> > memmove.S right.
> 
> All of the sparc memcpy implementations copy from low to high.
> I'll eat my hat if they don't. :-)
> 
> The guard tests at the beginning of memmove() are saying:
> 
> 	if (dst <= src)
> 		memcpy(...);
> 	if (src + len <= dst)
> 		memcpy(...);
> 
> And then the reverse copy loop (and we do have to copy in reverse for
> correctness) is basically:
> 
> 	src = (src + len - 1);
> 	dst = (dst + len - 1);
> 
> 1:	tmp = *(u8 *)src;
> 	len -= 1;
> 	src -= 1;
> 	*(u8 *)dst = tmp;
> 	dst -= 1;
> 	if (len != 0)
> 		goto 1b;
> 
> And then we return the original 'dst' pointer.
> 
> So at first glance it looks at least correct.
> 
> memmove() is a good idea to look into though, as SLAB and SLUB are the
> only really heavy users of it, and they do so with overlapping
> contents.
> 
> And they end up using that byte-at-a-time code, since SLAB and SLUB
> do mmemove() calls of the form:
> 
> 	memmove(X + N, X, LEN);
> 
> In which case neither of the memcpy() guard tests will pass.
> 
> Maybe there is some subtle bug in there I just don't see right now.
My original pursuit of this issue focused on transfers to and from the shared
array. Basically substituting memcpy-s with a primitive unsigned long memory
mover. This might have been incorrect.

There were substantial doubts because of large modifications to 2.6.39 too.
Unstabile hardware cause(d|s) issue too.

Eliminating the shared array functions correctly. Though this removal changes
performance and timing dramatically.

This afternoon I included modification of two memmove-s and no issue thus far.
The issue APPEARS to come from memmove-s within cache_flusharray() and/or
drain_array(). Now we are covering moves within an array_cache.

The above was done on 2.6.39.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
