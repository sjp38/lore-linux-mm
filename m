Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4346B021C
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 10:43:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c2744f69-5974-4017-ae33-4244ce0960e2@default>
Date: Thu, 29 Apr 2010 07:42:44 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>
 <4BD3377E.6010303@redhat.com>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>
 <ce808441-fae6-4a33-8335-f7702740097a@default 20100428055538.GA1730@ucw.cz>
In-Reply-To: <20100428055538.GA1730@ucw.cz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Pavel --

The whole concept of RAM that _might_ be available to the
kernel and is _not_ directly addressable by the kernel takes
some thinking to wrap your mind around, but I assure you
there are very good use cases for it.  RAM owned and managed
by a hypervisor (using controls unknowable to the kernel)
is one example; this is Transcendent Memory.  RAM which
has been compressed is another example; Nitin is working
on this using the frontswap approach because of some
issues that arise with ramzswap (see elsewhere on this
thread).  There are likely more use cases.

So in that context, let me answer your questions, combined
into a single reply.

> > That's a reasonable analogy.  Frontswap serves nicely as an
> > emergency safety valve when a guest has given up (too) much of
> > its memory via ballooning but unexpectedly has an urgent need
> > that can't be serviced quickly enough by the balloon driver.
>=20
> wtf? So lets fix the ballooning driver instead?
>=20
> There's no reason it could not be as fast as frontswap, right?
> Actually I'd expect it to be faster -- it can deal with big chunks.

If this was possible by fixing the balloon driver, VMware would
have done it years ago.  The problem is that the balloon driver
is acting on very limited information, namely ONLY what THIS
kernel wants; every kernel is selfish and (eventually) uses every
bit of RAM it can get.  This is especially true when swapping
is required (under memory pressure).

So, in general, ballooning is NOT faster because a balloon
request to "get" RAM must wait for some other balloon driver
in some other kernel to "give" RAM.  OR some other entity
must periodically scan every kernels memory and guess at which
kernels are using memory inefficiently and steal it away before
a "needy" kernel asks for it.

While this does indeed "work" today in VMware, if you talk to
VMware customers that use it, many are very unhappy with the
anomalous performance problems that occur.

> > The existing swap API as it stands is inadequate for an efficient
> > synchronous interface (e.g. for swapping to RAM).  Both Nitin
> > and I independently have found this to be true.  But swap-to-RAM
>=20
> So... how much slower is swapping to RAM over current interface when
> compared to proposed interface, and how much is that slower than just
> using the memory directly?

Simply copying RAM from one page owned by the kernel to another
page owned by the kernel is pretty pointless as far as swapping
is concerned because it does nothing to reduce memory pressure,
so the comparison is a bit irrelevant.  But...

In my measurements, the overhead of managing "pseudo-RAM" pages
is in the same ballpark as copying the page.  Compression or
deduplication of course has additional costs.  See the
performance results at the end of the following two presentations
for some performance information when "pseudo-RAM" is Transcendent
Memory.

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/Transc=
endentMemoryLinuxConfAu2010.pdf=20

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/Transc=
endentMemoryXenSummit2010.pdf=20

(the latter will be presented later today)

> > I'm a bit confused: What do you mean by 'existing swap API'?
> > Frontswap simply hooks in swap_readpage() and swap_writepage() to
> > call frontswap_{get,put}_page() respectively. Now to avoid a
> hardcoded
> > implementation of these function, it introduces struct frontswap_ops
> > so that custom implementations fronswap get/put/etc. functions can be
> > provided. This allows easy implementation of swap-to-hypervisor,
> > in-memory-compressed-swapping etc. with common set of hooks.
>=20
> Yes, and that set of hooks is new API, right?

Well, no, if you define API as "application programming interface"
this is NOT exposed to userland.  If you define API as a new
in-kernel function call, yes, these hooks are a new API, but that
is true of virtually any new code in the kernel.  If you define
API as some new interface between the kernel and a hypervisor,
yes, this is a new API, but it is "optional" at several levels
so that any hypervisor (e.g. KVM) can completely ignore it.

So please let's not argue about whether the code is a "new API"
or not, but instead consider whether the concept is useful or not
and if useful, if there is or is not a cleaner way to implement it.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
