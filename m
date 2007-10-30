Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45a44e480710300616p34b0a159m87de78d0a4d43028@mail.gmail.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins>
	 <45a44e480710300616p34b0a159m87de78d0a4d43028@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pHqx6XxmjBvEmf05Optt"
Date: Tue, 30 Oct 2007 14:25:51 +0100
Message-Id: <1193750751.27652.86.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

--=-pHqx6XxmjBvEmf05Optt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-30 at 09:16 -0400, Jaya Kumar wrote:
> On 10/30/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > So page->index does what you want it to, identify which part of the
> > framebuffer this particular page belongs to.
>=20
> Ok. I'm attempting to walk the code sequence. Here's what I think:
>=20
> - driver loads
> - driver vmalloc()s its fb
> - this creates the necessary pte entries

well, one set thereof, the kernel mappings, which for this purpose are
the least interesting.

> then...
> - app mmap(/dev/fb0)
> - vma is created
> - defio mmap adds this vma to private list (equivalent of
> address_space or anon_vma)

> - app touches base + pixel(128,128) =3D base + 16k
> - page fault
> - defio nopage gets called
> - defio nopage does vmalloc_to_page(base+16k)

this installs a user space page table entry for your page; this is the
interesting one as it carries the user-dirty state.

> - that finds the correct struct page corresponding to that vaddr.
> page->index has not been set by anyone so far, right?
> * ah... i see, you are suggesting that this is where I could set the
> index since i know the offset i want it to represent. right?

Not quite, you would set that right after vmallocing, just set an
increasing page->index starting with 0 for the first page.

Then ensure your vma->vm_pgoff is 0 (which should be the case since
userspace will most likely mmap the whole thing, and if not it still
gets what it expects).

> - defio mkwrite get called. defio adds page to its list. schedules delaye=
d work
> - app keeps writing the page
> - delayed work occurs
> - foreach vma { foreach page { page_mkclean_one(page, vma) }

Yeah, page_mkclean_one(page, vma) will use vma_address() to obtain an
user-space address for the page in this vma using page->index and the
formula from the last email, this address is then used to walk the page
tables and obtain a pte.

This will be the user-space pte installed by your nopfn handler. Not the
kernel vmap pte resulting from the vmalloc() call.

> - cycle repeats...



--=-pHqx6XxmjBvEmf05Optt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJzDfXA2jU0ANEf4RAh18AJwOekOCk1QihR4h6+12dUbIVA+t/gCcCNUE
z8ot0/SsHvSCn+2e6nBGgFs=
=LaJp
-----END PGP SIGNATURE-----

--=-pHqx6XxmjBvEmf05Optt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
