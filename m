Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 35C346B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 20:46:57 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so15908231ied.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:46:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507F160A.7090302@am.sony.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
 <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
 <m2391ktxjj.fsf@firstfloor.org> <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
 <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
 <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
 <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com>
 <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com>
 <1350392160.3954.986.camel@edumazet-glaptop> <507DA245.9050709@am.sony.com>
 <CALF0-+VLVqy_uE63_jL83qh8MqBQAE3vYLRX1mRQURZ4a1M20g@mail.gmail.com>
 <1350414968.3954.1427.camel@edumazet-glaptop> <507EFCC3.1050304@am.sony.com>
 <1350501217.26103.852.camel@edumazet-glaptop> <CAGDaZ_qKg3x_ChdZck25P_XF78cJNeB_DJLg=ZtL3eZWSz3yXA@mail.gmail.com>
 <507F160A.7090302@am.sony.com>
From: Shentino <shentino@gmail.com>
Date: Wed, 17 Oct 2012 17:46:16 -0700
Message-ID: <CAGDaZ_qQ6L38EVkwmSakWF4xGFcESY-cr_XbjwG1pELTr1XGQw@mail.gmail.com>
Subject: Re: [Q] Default SLAB allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Bird <tim.bird@am.sony.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ezequiel Garcia <elezegarcia@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On Wed, Oct 17, 2012 at 1:33 PM, Tim Bird <tim.bird@am.sony.com> wrote:
> On 10/17/2012 12:20 PM, Shentino wrote:
>> Potentially stupid question
>>
>> But is SLAB the one where all objects per cache have a fixed size and
>> thus you don't have any bookkeeping overhead for the actual
>> allocations?
>>
>> I remember something about one of the allocation mechanisms being
>> designed for caches of fixed sized objects to minimize the need for
>> bookkeeping.
>
> I wouldn't say "don't have _any_ bookkeeping", but minimizing the
> bookkeeping is indeed part of the SLAB goals.
>
> However, that is for objects that are allocated at fixed size.
> kmalloc is (currently) a thin wrapper over the slab system,
> and it maps non-power-of-two allocations onto slabs that are
> power-of-two sized.

...yuck?

> So, for example a string that is 18 bytes long
> will be allocated out of a slab with 32-byte objects.  This
> is the wastage that we're talking about here.  "Overhead" may
> have been the wrong word on my part, as that may imply overhead
> in the actual slab mechanisms, rather than just slop in the
> data area.

Data slop (both for alignment as well as for making room for
per-allocation bookkeeping overhead as is often done with userspace
malloc arenas) is precisely what I was referring to here.

Thanks for the answers I was curious.

> As an aside...
>
> Is there a canonical glossary for memory-related terms?  What
> is the correct term for the difference between what is requested
> and what is actually returned by the allocator?  I've been
> calling it alternately "wastage" or "overhead", but maybe there's
> a more official term?
>
> I looked here: http://www.memorymanagement.org/glossary/
> but didn't find exactly what I was looking for.  The closest
> things I found were "internal fragmentation" and
> "padding", but those didn't seem to exactly describe
> the situation here.

Another stupid question.

Is it possible to have both SLAB for fixed sized objects and something
like SLOB or SLUB standing aside with a different pool for variable
sized allocations ala kmalloc?

My hunch is that handling the two cases with separate methods may get
the best of both worlds.  Or layering kmalloc through something that
gets huge blocks from slab and slices them up in ways more amenable to
avoiding power-of-2 slopping.

No memory geek, so my two cents.

>  -- Tim
>
> =============================
> Tim Bird
> Architecture Group Chair, CE Workgroup of the Linux Foundation
> Senior Staff Engineer, Sony Network Entertainment
> =============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
