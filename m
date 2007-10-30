Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0710301232220.9601@blonde.wat.veritas.com>
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
	 <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
	 <1193738177.27652.69.camel@twins> <1193741356.13775.2.camel@matrix>
	 <Pine.LNX.4.64.0710301232220.9601@blonde.wat.veritas.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-O8n8cSmG90ndQbmamybl"
Date: Tue, 30 Oct 2007 14:12:38 +0100
Message-Id: <1193749958.27652.77.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Stefani Seibold <stefani@seibold.net>, Jaya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-O8n8cSmG90ndQbmamybl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-30 at 12:39 +0000, Hugh Dickins wrote:
> On Tue, 30 Oct 2007, Stefani Seibold wrote:
> >=20
> > the question is how can i get all pte's from a vmalloc'ed memory. Due t=
o
> > the zeroed mapping pointer i dont see how to do this?
>=20
> The mapping pointer is zeroed because you've done nothing to set it.
> Below is how I answered you a week ago.  But this is new territory
> (extending page_mkclean to work on more than just pagecache pages),
> I'm still unsure what would be the safest way to do it.

Quite, I think manual usage of page_mkclean_one() on the vma gotten from
mmap() along with properly setting page->index is the simplest solution
to make work.

Making page_mkclean(struct page *) work for remap_pfn/vmalloc_range()
style mmaps would require extending rmap to work with those, which
includes setting page->mapping to point to a anon_vma like object.

But that sounds like a lot of work, and I'm not sure its worth the
overhead, because so far all users of remap_pfn/vmalloc_range() have
survived without.



--=-O8n8cSmG90ndQbmamybl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHJy3GXA2jU0ANEf4RAk2sAJ0ed/uAPzbet9n0PA4BQrLhFMcfWwCeMlwM
osCzd8nCgUeKIwqzb3RE4QA=
=j0B/
-----END PGP SIGNATURE-----

--=-O8n8cSmG90ndQbmamybl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
