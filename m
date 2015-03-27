Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF8436B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:51:44 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so96491033pab.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 06:51:44 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id l9si2966094pdp.89.2015.03.27.06.51.43
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 06:51:43 -0700 (PDT)
Date: Fri, 27 Mar 2015 09:51:39 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
Message-ID: <20150327135139.GA10747@akamai.com>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3>
 <alpine.LSU.2.11.1503251708530.5592@eggly.anvils>
 <alpine.DEB.2.10.1503251754320.26501@davide-lnx3>
 <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503260431290.2755@mbplnx>
 <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
 <alpine.DEB.2.10.1503261250430.9410@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UlVJffcvxoiEqYs2"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503261250430.9410@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Davide Libenzi <davidel@xmailserver.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 26 Mar 2015, David Rientjes wrote:

> On Thu, 26 Mar 2015, Davide Libenzi wrote:
>=20
> > > Yes, this munmap() behavior of lengths <=3D hugepage_size - PAGE_SIZE=
 for a=20
> > > hugetlb vma is long standing and there may be applications that break=
 as a=20
> > > result of changing the behavior: a database that reserves all allocat=
ed=20
> > > hugetlb memory with mmap() so that it always has exclusive access to =
those=20
> > > hugepages, whether they are faulted or not, and maintains its own hug=
epage=20
> > > pool (which is common), may test the return value of munmap() and dep=
end=20
> > > on it returning -EINVAL to determine if it is freeing memory that was=
=20
> > > either dynamically allocated or mapped from the hugetlb reserved pool.
> >=20
> > You went a long way to create such a case.
> > But, in your case, that application will erroneously considering hugepa=
ge=20
> > mmaped memory, as dynamically allocated, since it will always get EINVA=
L,=20
> > unless it passes an aligned size. Aligned size, which a fix like the on=
e=20
> > posted in the patch will still leave as success.
>=20
> There was a patch proposed last week to add reserved pools to the=20
> hugetlbfs mount option specifically for the case where a large database=
=20
> wants sole reserved access to the hugepage pool.  This is why hugetlbfs=
=20
> pages become reserved on mmap().  In that case, the database never wants=
=20
> to do munmap() and instead maintains its own hugepage pool.
>=20
> That makes the usual database case, mmap() all necessary hugetlb pages to=
=20
> reserve them, even easier since they have historically had to maintain=20
> this pool amongst various processes.
>=20
> Is there a process out there that tests for munmap(ptr) =3D=3D EINVAL and=
, if=20
> true, returns ptr to its hugepage pool?  I can't say for certain that non=
e=20
> exist, that's why the potential for breakage exists.

Such an application can use /proc/pid/smaps to determine the page size
of a mapping.  IMO, this is relying on broken behavior but I see where
you are coming from that this behavior has been present for a long time.

As I stated before, I think we should fix this bug and make munmap()
behavior match what is described in the man page.

>=20
> > OTOH, an application, which might be more common than the one you poste=
d,
> > which calls munmap() to release a pointer which it validly got from a=
=20
> > previous mmap(), will leak huge pages as all the issued munmaps will fa=
il.
> >=20
>=20
> That application would have to be ignoring an EINVAL return value.
>=20
> > > If we were to go back in time and decide this when the munmap() behav=
ior=20
> > > for hugetlb vmas was originally introduced, that would be valid.  The=
=20
> > > problem is that it could lead to userspace breakage and that's a=20
> > > non-starter.
> > >=20
> > > What we can do is improve the documentation and man-page to clearly=
=20
> > > specify the long-standing behavior so that nobody encounters unexpect=
ed=20
> > > results in the future.
> >=20
> > This way you will leave the mmap API with broken semantics.
> > In any case, I am done arguing.
> > I will leave to Andrew to sort it out, and to Michael Kerrisk to update=
=20
> > the mmap man pages with the new funny behaviour.
> >=20
>=20
> The behavior is certainly not new, it has always been the case for=20
> munmap() on hugetlb vmas.
>=20
> In a strict POSIX interpretation, it refers only to pages in the sense of
> what is returned by sysconf(_SC_PAGESIZE).  Such vmas are not backed by=
=20
> any pages of size sysconf(_SC_PAGESIZE), so this behavior is undefined. =
=20
> It would be best to modify the man page to explicitly state this for=20
> MAP_HUGETLB.

--UlVJffcvxoiEqYs2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVFWBrAAoJELbVsDOpoOa9TtMP/2gT2wQyu3g82TFSUrAX+s+k
Nykf1bbb862qU0IkXmueum+Go4tx60G3P+D82eStdyHo0xDTinHvHX3Eiwm40SFY
WzmyiAWSSGTqy4jKEMXLIa7faPOLxG0Mplnn/jF47UcyN4BshYqNDOUgPuXsZnsI
6+qWn4ewwf+PRRhoSCx8msQ0GgdlIjV+Czvew8AzCI8zbjaEAM77tO5ibaNa6Vnz
c8OLGO1lZ5nZ8Awo+rMh1MVd/61RuKrMrXvrxOBbP+8nxumTxADLZMxZt12tP7iy
JBZI9RfatMJf2FalHreRMb2N5HL6fankJslEoJEXKklq7HPTHm3a9cpI0xSFibc1
+NSVsJo98VtZ07NelFKoBi1PGT/1Llp2mLXLG9kfOZqe5z2U0UDY1r3Bx5kHp7DF
k0475sDqQrmymG3sxkJTK2aQjIELgZvy+z5k1J8n5hO5EpYbcfjytBQXEkSnx4Wt
xsoVFeA3unRQetblVcflu88qlF7OPZUOMI73C3vZdHtb3ZDJt0zIPnhXZy9+WsOk
04kkQwaOV+wKdFm1SKRIbxIjkMOIQmDKSfZc2fzTCkbjrVCDO15Wxo+aFlbE+VuI
+FYfxqGNdmtFCYEC7+MwpADSRsLi2Snnw6FSj4W8UeM5l52I70ifFpGNu9uIsRYB
7pwDEL0sas71zH+B04Ji
=RpSK
-----END PGP SIGNATURE-----

--UlVJffcvxoiEqYs2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
