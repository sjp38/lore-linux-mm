Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B67D6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:01:01 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so223898378pdb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:01:01 -0700 (PDT)
Received: from homiemail-a72.g.dreamhost.com (sub4.mail.dreamhost.com. [69.163.253.135])
        by mx.google.com with ESMTP id ns9si5883549pbc.151.2015.03.24.08.00.59
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 08:01:00 -0700 (PDT)
Date: Tue, 24 Mar 2015 10:57:53 -0400
From: Bob Picco <bpicco@meloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
Message-ID: <20150324145753.GC10685@zareason>
References: <550F5852.5020405@oracle.com>
 <20150322.220024.1171832215344978787.davem@davemloft.net>
 <20150322.221906.1670737065885267482.davem@davemloft.net>
 <20150323.122530.812870422534676208.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150323.122530.812870422534676208.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: david.ahern@oracle.com, torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

David Miller wrote:	[Mon Mar 23 2015, 12:25:30PM EDT]
> From: David Miller <davem@davemloft.net>
> Date: Sun, 22 Mar 2015 22:19:06 -0400 (EDT)
> 
> > I'll work on a fix.
> 
> Ok, here is what I committed.   David et al., let me know if you still
> see the crashes with this applied.
> 
> Of course, I'll queue this up for -stable as well.
> 
> Thanks!
> 
> ====================
> [PATCH] sparc64: Fix several bugs in memmove().
> 
> Firstly, handle zero length calls properly.  Believe it or not there
> are a few of these happening during early boot.
> 
> Next, we can't just drop to a memcpy() call in the forward copy case
> where dst <= src.  The reason is that the cache initializing stores
> used in the Niagara memcpy() implementations can end up clearing out
> cache lines before we've sourced their original contents completely.
> 
> For example, considering NG4memcpy, the main unrolled loop begins like
> this:
> 
>      load   src + 0x00
>      load   src + 0x08
>      load   src + 0x10
>      load   src + 0x18
>      load   src + 0x20
>      store  dst + 0x00
> 
> Assume dst is 64 byte aligned and let's say that dst is src - 8 for
> this memcpy() call.  That store at the end there is the one to the
> first line in the cache line, thus clearing the whole line, which thus
> clobbers "src + 0x28" before it even gets loaded.
> 
> To avoid this, just fall through to a simple copy only mildly
> optimized for the case where src and dst are 8 byte aligned and the
> length is a multiple of 8 as well.  We could get fancy and call
> GENmemcpy() but this is good enough for how this thing is actually
> used.
> 
> Reported-by: David Ahern <david.ahern@oracle.com>
> Reported-by: Bob Picco <bpicco@meloft.net>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
Seems solid with 2.6.39 on M7-4. Jalap?no is happy with current sparc.git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
