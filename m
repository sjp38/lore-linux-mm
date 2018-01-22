Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8636800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 16:25:19 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id z39so12590520ita.1
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:25:19 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id q129si13870757ioe.313.2018.01.22.13.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 13:25:18 -0800 (PST)
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
 <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
 <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
 <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
 <143DE376-A8A4-4A91-B4FF-E258D578242D@zytor.com>
 <CA+55aFxg5H38Ef4DUgMQ7KrsUtWdaKYKCRFZ8rangUrZ=OgCEw@mail.gmail.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <aedcd5b4-f054-0579-d9e2-8439b982a5dd@zytor.com>
Date: Mon, 22 Jan 2018 13:10:19 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFxg5H38Ef4DUgMQ7KrsUtWdaKYKCRFZ8rangUrZ=OgCEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On 01/22/18 12:14, Linus Torvalds wrote:
> On Sun, Jan 21, 2018 at 6:20 PM,  <hpa@zytor.com> wrote:
>>
>> No idea about Intel, but at least on Transmeta CPUs the limit check was asynchronous with the access.
> 
> Yes, but TMTA had a really odd uarch and didn't check segment limits natively.
> 

Only on TM3000 ("Wilma") and TM5000 ("Fred"), not on TM8000 ("Astro").
Astro might in fact have been more synchronous than most modern machines
(see below.)

> When you do it in hardware. the limit check is actually fairly natural
> to do early rather than late (since it acts on the linear address
> _before_ base add and TLB lookup).
> 
> So it's not like it can't be done late, but there are reasons why a
> traditional microarchitecture might always end up doing the limit
> check early and so segmentation might be a good defense against
> meltdown on 32-bit Intel.

I will try to investigate, but as you can imagine the amount of
bandwidth I might be able to get on this is definitely going to be limited.

All of the below is generic discussion that almost certainly can be
found in some form in Hennesey & Patterson, and so I don't have to worry
about giving away Intel secrets:

It isn't really true that it is natural to check this early.  One of the
most fundamental frequency limiters in a modern CPU architecture
(meaning anything from the last 20 years or so) has been the
data-dependent AGU-D$-AGU loop.  Note that this doesn't even include the
TLB: the TLB is looked up in parallel with the D$, and if the result was
*either* a cache-TLB mismatch or a TLB miss the result is prevented from
committing.

In the case of the x86, the AGU receives up to three sources plus the
segment base, and if possible given the target process and gates
available might be designed to have a unified 4-input adder, with the
3-input case for limit checks being done separately.

Misses and even more so exceptions (which are far less frequent than
misses) are demoted to a slower where the goal is to prevent commit
rather than trying to race to be in the data path.  So although it is
natural to *issue* the load and the limit check at the same time, the
limit check is still going to be deferred.  Whether or not it is
permitted to be fully asynchronous with the load is probably a tradeoff
of timing requirements vs complexity.  At least theoretically one could
imagine a machine which would take the trap after the speculative
machine had already chased the pointer loop several levels down; this
would most likely mean separate uops to allow for the existing
out-of-order machine to do the bookkeeping.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
