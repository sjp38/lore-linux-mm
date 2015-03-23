Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B87E26B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:52:36 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so188642742pab.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:52:36 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id r3si2534105pdc.28.2015.03.23.12.52.35
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 12:52:35 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:52:32 -0400 (EDT)
Message-Id: <20150323.155232.650842650739774037.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <CA+55aFwfAxOME7v=EUZd7j0AoHinXgs6TDwU-TZKiGy3Rs5Lbg@mail.gmail.com>
References: <CA+55aFzepCj56MPVgYmMem+yfYpSOX7tBRtPHeOQxXp31Tghhg@mail.gmail.com>
	<20150323.150833.1435862810481480096.davem@davemloft.net>
	<CA+55aFwfAxOME7v=EUZd7j0AoHinXgs6TDwU-TZKiGy3Rs5Lbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: david.ahern@oracle.com, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 Mar 2015 12:47:49 -0700

> On Mon, Mar 23, 2015 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Sure you could do that in C, but I really want to avoid using memcpy()
>> if dst and src overlap in any way at all.
>>
>> Said another way, I don't want to codify that "64" thing.  The next
>> chip could do 128 byte initializing stores.
> 
> But David, THAT IS NOT WHAT YOUR BROKEN ASM DOES ANYWAY!
> 
> Read it again. Your asm code does not check for overlap. Look at this:
> 
>         cmp             %o0, %o1
>         bleu,pt         %xcc, 2f
> 
> and ponder. It's wrong.

Right, it's not checking for overlap.  It's checking for "does a
forward copy work?"

That's the standard test for this, and it's what glibc uses in it's
generic memmove() implementation FWIW.  (granted, I know glibc is not
generally a good source for "right way to do things :-)

> The new asm version is better than the old one, because the new
> breakage is about really bad performance rather than actively
> breaking, but still..

I accept that it's suboptimal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
