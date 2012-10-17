Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id CAE906B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 16:28:07 -0400 (EDT)
Message-ID: <507F160A.7090302@am.sony.com>
Date: Wed, 17 Oct 2012 13:33:14 -0700
From: Tim Bird <tim.bird@am.sony.com>
MIME-Version: 1.0
Subject: Re: [Q] Default SLAB allocator
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org> <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com> <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com> <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com> <alpine.DEB.2.00.1210151745400.31712@chino.kir.corp.google.com> <CALF0-+WgfnNOOZwj+WLB397cgGX7YhNuoPXAK5E0DZ5v_BxxEA@mail.gmail.com> <1350392160.3954.986.camel@edumazet-glaptop> <507DA245.9050709@am.sony.com> <CALF0-+VLVqy_uE63_jL83qh8MqBQAE3vYLRX1mRQURZ4a1M20g@mail.gmail.com> <1350414968.3954.1427.camel@edumazet-glaptop> <507EFCC3.1050304@am.sony.com> <1350501217.26103.852.camel@edumazet-glaptop> <CAGDaZ_qKg3x_ChdZck25P_XF78cJNeB_DJLg=ZtL3eZWSz3yXA@mail.gmail.com>
In-Reply-To: <CAGDaZ_qKg3x_ChdZck25P_XF78cJNeB_DJLg=ZtL3eZWSz3yXA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shentino <shentino@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ezequiel Garcia <elezegarcia@gmail.com>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "celinux-dev@lists.celinuxforum.org" <celinux-dev@lists.celinuxforum.org>

On 10/17/2012 12:20 PM, Shentino wrote:
> Potentially stupid question
> 
> But is SLAB the one where all objects per cache have a fixed size and
> thus you don't have any bookkeeping overhead for the actual
> allocations?
> 
> I remember something about one of the allocation mechanisms being
> designed for caches of fixed sized objects to minimize the need for
> bookkeeping.

I wouldn't say "don't have _any_ bookkeeping", but minimizing the
bookkeeping is indeed part of the SLAB goals.

However, that is for objects that are allocated at fixed size.
kmalloc is (currently) a thin wrapper over the slab system,
and it maps non-power-of-two allocations onto slabs that are
power-of-two sized.  So, for example a string that is 18 bytes long
will be allocated out of a slab with 32-byte objects.  This
is the wastage that we're talking about here.  "Overhead" may
have been the wrong word on my part, as that may imply overhead
in the actual slab mechanisms, rather than just slop in the
data area.

As an aside...

Is there a canonical glossary for memory-related terms?  What
is the correct term for the difference between what is requested
and what is actually returned by the allocator?  I've been
calling it alternately "wastage" or "overhead", but maybe there's
a more official term?

I looked here: http://www.memorymanagement.org/glossary/
but didn't find exactly what I was looking for.  The closest
things I found were "internal fragmentation" and
"padding", but those didn't seem to exactly describe
the situation here.
 -- Tim

=============================
Tim Bird
Architecture Group Chair, CE Workgroup of the Linux Foundation
Senior Staff Engineer, Sony Network Entertainment
=============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
