Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC9E76B0268
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:32:17 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e12so11935348oib.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:32:17 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id c58si2055933ote.227.2016.10.26.09.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 09:32:16 -0700 (PDT)
Received: by mail-oi0-x22c.google.com with SMTP id n202so24890281oig.3
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:32:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 09:32:16 -0700
Message-ID: <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 8:51 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> I get the following BUG with 4.9-rc2, CONFIG_VMAP_STACK and
>> CONFIG_DEBUG_VIRTUAL turned on:
>>
>>   kernel BUG at arch/x86/mm/physaddr.c:26!
>
> const struct zone *zone = page_zone(virt_to_page(word));
>
> If the stack is vmalloced, then you can't find the page's zone like
> that.  We could look it up the slow way (ick!), but maybe another
> solution would be to do:

Christ. It's that damn bit-wait craziness again with the idiotic zone lookup.

I complained about it a couple of weeks ago for entirely unrelated
reasons: it absolutely sucks donkey ass through a straw from a cache
standpoint too. It makes the page_waitqueue() thing very expensive, to
the point where it shows up as taking up 3% of CPU time on a real
load.,

PeterZ had a patch that fixed most of the performance trouble because
the page_waitqueue is actually never realistically contested, and by
making the bit-waiting use *two* bits you can avoid the slow-path cost
entirely.

But here we have a totally different issue, namely that we want to
wait on a virtual address.

Quite frankly, I think the solution is to just rip out all the insane
zone crap. The most important use (by far) for the bit-waitqueue is
for the page locking, and with the "use a second bit to show
contention", there is absolutely no reason to try to do some crazy
per-zone thing. It's a slow-path that never matters, and rather than
make things scale well, the only thing it does is to pretty much
guarantee at least one extra cache miss.

Adding MelG and the mm list to the cc (PeterZ was already there) here
just for the heads up.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
