Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3A3116B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 21:15:51 -0400 (EDT)
Date: Thu, 5 Sep 2013 11:16:11 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20130905011611.GB10158@voom.redhat.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
 <20130904084430.GD16355@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qlTNgmc+xy1dBmNv"
Content-Disposition: inline
In-Reply-To: <20130904084430.GD16355@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--qlTNgmc+xy1dBmNv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 04, 2013 at 05:44:30PM +0900, Joonsoo Kim wrote:
> On Fri, Aug 09, 2013 at 06:26:37PM +0900, Joonsoo Kim wrote:
> > If parallel fault occur, we can fail to allocate a hugepage,
> > because many threads dequeue a hugepage to handle a fault of same addre=
ss.
> > This makes reserved pool shortage just for a little while and this cause
> > faulting thread who can get hugepages to get a SIGBUS signal.
> >=20
> > To solve this problem, we already have a nice solution, that is,
> > a hugetlb_instantiation_mutex. This blocks other threads to dive into
> > a fault handler. This solve the problem clearly, but it introduce
> > performance degradation, because it serialize all fault handling.
> >=20
> > Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> > performance degradation. For achieving it, at first, we should ensure t=
hat
> > no one get a SIGBUS if there are enough hugepages.
> >=20
> > For this purpose, if we fail to allocate a new hugepage when there is
> > concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With thi=
s,
> > these threads defer to get a SIGBUS signal until there is no
> > concurrent user, and so, we can ensure that no one get a SIGBUS if there
> > are enough hugepages.
> >=20
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >=20
>=20
> Hello, David.
> May I ask to you to review this one?
> I guess that you already thought about the various race condition,
> so I think that you are the most appropriate reviewer to this patch. :)

Yeah, sorry, I meant to get to it but kept forgetting.  I've sent a
review now.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--qlTNgmc+xy1dBmNv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSJ9tbAAoJEGw4ysog2bOSzC8QAJZuk/ClHpJkcLnTazrwtPr0
2DtE1dKuYH1WJR7QhaFV7S5kO/317Xtxam2C0XQXHi3jeFnWakkz0W83Y/ouRCc9
X0l9ruPGO1xqAKxFVHfNfMMK/zA2aWvKOPvFb7SpOxEx4iDb4EzcLEwNFZeoZzzf
CyXOWoFbsUHfsA6jOMGmVhve4UIt/SzaCM+oU6W7+Cy/jg7XZXynAaHX5nryfirt
Bz65LfETlmQ8TP1OR1WIOAd095xRLBlIGz1sDHBiDqdGRKTKGw/eQGAGztkqf8kU
D7YjPnggPtqAsPZ6ckV7FRBqpbct7WIzy288VvFb+bnphkJ12j+2+VkGC2U5+EHG
R0009D4m+w6a/OzPQWYtyWZOc4XEiQWQ2KiL+qPdbqfPVveNJx8yRprxba07LnNQ
5rtvGkxJqVLhj8AwrTTdvSAbUqIpflDjSf1jmJMNY6wxa3XaV9Unaef2aPV+fS5w
lnohaMtcvPYHqkO3gUCj9G+rTN0U+uXctzpcLR2hjvSvkG/2qORPNbeMWtVs7qO0
DJamjJjgOhMm1qJI2y2dSnYY73sS5ngOg3eMPbn7XGXdUEmgNF6CvjMtPwZ7KdAY
CsPFSHsS+rX5UtYHGXLo4vEML+xP2aLMdQj8E7L12Ocd5Jsal5UbJL6BLtWQyVBw
EziElBn1rnuzvo628cn8
=eMoZ
-----END PGP SIGNATURE-----

--qlTNgmc+xy1dBmNv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
