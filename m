Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5YvOV9vyBU21zrnG5jly"
Date: Tue, 30 Oct 2007 10:56:17 +0100
Message-Id: <1193738177.27652.69.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

--=-5YvOV9vyBU21zrnG5jly
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-10-29 at 21:22 -0400, Jaya Kumar wrote:
> On 10/29/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >
> > [ also, remap_vmalloc_range() suffers similar issues, only file and ano=
n
> >   have proper rmap ]
> >
> > I'm not sure we want full rmap for remap_pfn/vmalloc_range, but perhaps
> > we could assist drivers in maintaining and using vma lists.
> >
> > I think page_mkclean_one() would work if you'd manually set page->index
> > and iterate the vmas yourself. Although atm I'm not sure of anything so
> > don't pin me on it.
>=20
> :-) If it's anybody's fault, it's mine for not testing properly. My bad.
>=20
> In the case of defio, I think it's no trouble to build a list of vmas
> at mmap time and then to iterate through them when it's ready for
> mkclean time as you suggested. I don't fully understand page->index
> yet. I had thought it was only used by swap cache or file map.
>=20
> On an unrelated note, I was looking for somewhere to stuff a 16 bit
> offset (so that I have a cheap way to know which struct page
> corresponds to which framebuffer block or offset) for another driver.
> I had thought page->index was it but I think I am wrong now.

Yeah, page->index is used along with vma->vmpgoff and vma->vm_start to
determine the address of the page in the given vma:

  address =3D vma->vm_start + ((page->index - vma->vm_pgoff) << PAGE_SHIFT)=
;

and from that address the pte can be found by walking the vma->vm_mm
page tables.

So page->index does what you want it to, identify which part of the
framebuffer this particular page belongs to.

--=-5YvOV9vyBU21zrnG5jly
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJv/BXA2jU0ANEf4RAp7OAJ9EboaIxJ0TUEi/2KBa20ikku3vJwCZAa9Y
5KdrwGsKaO5Qz0NFxOdF7ls=
=19lL
-----END PGP SIGNATURE-----

--=-5YvOV9vyBU21zrnG5jly--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
