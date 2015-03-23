Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 218FC6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 13:00:03 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so40698153iec.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 10:00:03 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id 89si1276738iod.8.2015.03.23.10.00.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 10:00:02 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so40697912iec.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 10:00:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150323.122530.812870422534676208.davem@davemloft.net>
References: <550F5852.5020405@oracle.com>
	<20150322.220024.1171832215344978787.davem@davemloft.net>
	<20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
Date: Mon, 23 Mar 2015 10:00:02 -0700
Message-ID: <CA+55aFzepCj56MPVgYmMem+yfYpSOX7tBRtPHeOQxXp31Tghhg@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: David Ahern <david.ahern@oracle.com>, sparclinux@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bpicco@meloft.net

On Mon, Mar 23, 2015 at 9:25 AM, David Miller <davem@davemloft.net> wrote:
>
> Ok, here is what I committed.

So I wonder - looking at that assembly, I get the feeling that it
isn't any better code than gcc could generate from simple C code.

Would it perhaps be better to turn memmove() into C?

That's particularly true because if I read this code right, it now
seems to seriously pessimise non-overlapping memmove's, in that it now
*always* uses that slow downward copy if the destination is below the
source.

Now, admittedly, the kernel doesn't use a lot of memmov's, but this
still falls back on the "byte at a time" model for a lot of cases (all
non-64-bit-aligned ones). I could imagine those existing. And some
people (reasonably) hate memcpy because they've been burnt by the
overlapping case and end up using memmove as a "safe alternative", so
it's not necessarily just the overlapping case that might trigger
this.

Maybe the code could be something like

    void *memmove(void *dst, const void *src, size_t n);
    {
        // non-overlapping cases
        if (src + n <= dst)
            return memcpy(dst, src, n);
        if (dst + n <= src)
            return memcpy(dst, src, n);

        // overlapping, but we know we
        //  (a) copy upwards
        //  (b) initialize the result in at most chunks of 64
        if (dst+64 <= src)
            return memcpy(dst, src, n);

        .. do the backwards thing ..
    }

(ok, maybe I got it wrong, but you get the idea).

I *think* gcc should do ok on the above kind of code, and not generate
wildly different code from your handcoded version.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
