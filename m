Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E06186B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 20:17:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b1so706955730pgc.5
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 17:17:14 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id a96si41511517pli.200.2016.12.25.17.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 17:17:14 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 127so6202524pfg.0
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 17:17:13 -0800 (PST)
Date: Mon, 26 Dec 2016 11:16:54 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting
 for a page bit
Message-ID: <20161226111654.76ab0957@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com>
	<20161225030030.23219-3-npiggin@gmail.com>
	<CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Sun, 25 Dec 2016 13:51:17 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, Dec 24, 2016 at 7:00 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> > Add a new page flag, PageWaiters, to indicate the page waitqueue has
> > tasks waiting. This can be tested rather than testing waitqueue_active
> > which requires another cacheline load.  
> 
> Ok, I applied this one too. I think there's room for improvement, but
> I don't think it's going to help to just wait another release cycle
> and hope something happens.
> 
> Example room for improvement from a profile of unlock_page():
> 
>    46.44 a??      lock   andb $0xfe,(%rdi)
>    34.22 a??      mov    (%rdi),%rax
> 
> this has the old "do atomic op on a byte, then load the whole word"
> issue that we used to have with the nasty zone lookup code too. And it
> causes a horrible pipeline hickup because the load will not forward
> the data from the (partial) store.
> 
>  Its' really a misfeature of our asm optimizations of the atomic bit
> ops. Using "andb" is slightly smaller, but in this case in particular,
> an "andq" would be a ton faster, and the mask still fits in an imm8,
> so it's not even hugely larger.

I did actually play around with that. I could not get my skylake
to forward the result from a lock op to a subsequent load (the
latency was the same whether you use lock ; andb or lock ; andl
(32 cycles for my test loop) whereas with non-atomic versions I
was getting about 15 cycles for andb vs 2 for andl.

I guess the lock op drains the store queue to coherency and does
not allow forwarding so as to provide the memory ordering
semantics.

> But it might also be a good idea to simply use a "cmpxchg" loop here.
> That also gives atomicity guarantees that we don't have with the
> "clear bit and then load the value".

cmpxchg ends up at 19 cycles including the initial load, so it
may be worthwhile. Powerpc has a similar problem with doing a
clear_bit; test_bit (not the size mismatch, but forwarding from
atomic ops being less capable).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
