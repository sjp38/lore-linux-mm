Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 342086B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:08:38 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so196270642pdb.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:08:37 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fj8si2229428pad.135.2015.03.23.12.08.37
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 12:08:37 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:08:33 -0400 (EDT)
Message-Id: <20150323.150833.1435862810481480096.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <CA+55aFzepCj56MPVgYmMem+yfYpSOX7tBRtPHeOQxXp31Tghhg@mail.gmail.com>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<CA+55aFzepCj56MPVgYmMem+yfYpSOX7tBRtPHeOQxXp31Tghhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: david.ahern@oracle.com, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 Mar 2015 10:00:02 -0700

> Maybe the code could be something like
> 
>     void *memmove(void *dst, const void *src, size_t n);
>     {
>         // non-overlapping cases
>         if (src + n <= dst)
>             return memcpy(dst, src, n);
>         if (dst + n <= src)
>             return memcpy(dst, src, n);
> 
>         // overlapping, but we know we
>         //  (a) copy upwards
>         //  (b) initialize the result in at most chunks of 64
>         if (dst+64 <= src)
>             return memcpy(dst, src, n);
> 
>         .. do the backwards thing ..
>     }
> 
> (ok, maybe I got it wrong, but you get the idea).
> 
> I *think* gcc should do ok on the above kind of code, and not generate
> wildly different code from your handcoded version.

Sure you could do that in C, but I really want to avoid using memcpy()
if dst and src overlap in any way at all.

Said another way, I don't want to codify that "64" thing.  The next
chip could do 128 byte initializing stores.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
