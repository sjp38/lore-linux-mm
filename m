Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 41D696B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 13:34:39 -0400 (EDT)
Received: by igcau2 with SMTP id au2so36936576igc.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 10:34:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d15si1352016ioe.23.2015.03.23.10.34.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 10:34:38 -0700 (PDT)
Message-ID: <55104EAA.4060607@oracle.com>
Date: Mon, 23 Mar 2015 11:34:34 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550F5852.5020405@oracle.com>	<20150322.220024.1171832215344978787.davem@davemloft.net>	<20150322.221906.1670737065885267482.davem@davemloft.net> <20150323.122530.812870422534676208.davem@davemloft.net>
In-Reply-To: <20150323.122530.812870422534676208.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

On 3/23/15 10:25 AM, David Miller wrote:
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
>       load   src + 0x00
>       load   src + 0x08
>       load   src + 0x10
>       load   src + 0x18
>       load   src + 0x20
>       store  dst + 0x00
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

seems like a formality at this point, but this resolves the panic on the 
M7-based ldom and baremetal. The T5-8 failed to boot, but it could be a 
different problem.

Thanks for the fast turnaround,
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
