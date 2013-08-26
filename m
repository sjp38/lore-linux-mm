Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id EB0926B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 16:16:00 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id pb11so2548993veb.11
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 13:16:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130826190757.GB27768@redhat.com>
References: <20130807153030.GA25515@redhat.com>
	<CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
	<20130819231836.GD14369@redhat.com>
	<CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
	<20130821204901.GA19802@redhat.com>
	<CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
	<20130823032127.GA5098@redhat.com>
	<CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
	<20130823035344.GB5098@redhat.com>
	<CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
	<20130826190757.GB27768@redhat.com>
Date: Mon, 26 Aug 2013 13:15:59 -0700
Message-ID: <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Mon, Aug 26, 2013 at 12:08 PM, Dave Jones <davej@redhat.com> wrote:
>
> [ 4588.541886] swap_free: Unused swap offset entry 00002d15
> [ 4588.541952] BUG: Bad page map in process trinity-kid12  pte:005a2a80 pmd:22c01f067
>
> I can reproduce this pretty quickly by driving the system into swapping using
> a few instances of 'trinity -C64' (this creates 64 threads)
>
> I'm not sure how far back this bug goes, so I'll try some older kernels
> and see if I can bisect it, because we don't seem to be getting closer
> to figuring out what's actually happening..

Bisecting would indeed be good. But I get the feeling that you'll need
to go back a *long* time, because the swap_map[] code hasn't changed
in ages.

I'm adding Hugh Dickins to the cc just in case he hasn't seen this on
linux-mm, because the swap_map[] code is complex as hell, and Hugh did
touch some of it last. The whole swap_map[] thing is complicated by:

 - it's a single byte per swap entry
 - it's not even a *structured* byte, but a single counter that has
several "fields" by hand
 - it has a count in the low 6 bits, with a magic "bad" value (which
is also a magic "continuation" value if one of the high bits are set)
 - it has two magic bits: HAS_CACHE and CONTINUED
 - it has a _third_ magic value (SWAP_MAP_SHMEM) which is "CONTINUED+BAD"
 - we increment this nasty pseudo-counter wildly hackily, and and have
magic special case checks for the odd cases

and if we get any of the special cases wrong, we'll
increment/decrement it wrong, and we're screwed.

The *locking* looks pretty simple, though. It's a simple spinlock. We
do some optimistic tests outside the spinlock, but the actual
allocation and modification seem to all be inside the lock and
re-check any optimistic values afaik.

So I'm almost likely to think that we are more likely to have
something wrong in the messy magical special cases. I'm wondering if
we should get rid of the continuation crap, for example, and expand
the "one byte per swap page" to two bytes instead.

Hugh, I think you know this code best, because you added the last
special case (that SWAP_MAP_SHMEM value). Comments?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
