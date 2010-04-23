Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5079C6B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 09:48:09 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
Date: Fri, 23 Apr 2010 06:47:18 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default
 4BD16D09.2030803@redhat.com>
In-Reply-To: <4BD16D09.2030803@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> >> Much easier to simulate an asynchronous API with a synchronous
> backend.
> >>
> > Indeed.  But an asynchronous API is not appropriate for frontswap
> > (or cleancache).  The reason the hooks are so simple is because they
> > are assumed to be synchronous so that the page can be immediately
> > freed/reused.
> >
>=20
> Swapping is inherently asynchronous, so we'll have to wait for that to
> complete anyway (as frontswap does not guarantee swap-in will succeed).
> I don't doubt it makes things simpler, but also less flexible and
> useful.
>=20
> Something else that bothers me is the double swapping.  Sure we're
> making swapin faster, but we we're still loading the io subsystem with
> writes.  Much better to make swap-to-ram authoritative (and have the
> hypervisor swap it to disk if it needs the memory).

Hmmm.... I now realize you are thinking of applying frontswap to
a hosted hypervisor (e.g. KVM). Using frontswap with a bare-metal
hypervisor (e.g. Xen) works fully synchronously, guarantees swap-in
will succeed, never double-swaps, and doesn't load the io subsystem
with writes.  This all works very nicely today with a fully
synchronous "backend" (e.g. with tmem in Xen 4.0).

So, I agree, hiding a truly asynchronous interface behind
frontswap's synchronous interface may have some thorny issues.
I wasn't recommending that it should be done, just speculating
how it might be done.  This doesn't make frontswap any less
useful with a fully synchronous "backend".

> >> Well, copying memory so you can use a zero-copy dma engine is
> >> counterproductive.
> >>
> > Yes, but for something like an SSD where copying can be used to
> > build up a full 64K write, the cost of copying memory may not be
> > counterproductive.
>=20
> I don't understand.  Please clarify.

If I understand correctly, SSDs work much more efficiently when
writing 64KB blocks.  So much more efficiently in fact that waiting
to collect 16 4KB pages (by first copying them to fill a 64KB buffer)
will be faster than page-at-a-time DMA'ing them.  If so, the
frontswap interface, backed by an asynchronous "buffering layer"
which collects 16 pages before writing to the SSD, may work
very nicely.  Again this is still just speculation... I was
only pointing out that zero-copy DMA may not always be the best
solution.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
