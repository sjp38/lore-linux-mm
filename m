Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC8C6B0031
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 06:58:33 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so6450766pbb.0
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 03:58:32 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id ph10si15380106pbb.19.2013.12.24.03.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Dec 2013 03:58:32 -0800 (PST)
Date: Tue, 24 Dec 2013 23:00:12 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v3 03/14] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
Message-ID: <20131224120012.GH12407@voom.fritz.box>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-4-git-send-email-iamjoonsoo.kim@lge.com>
 <20131221135819.GB12407@voom.fritz.box>
 <20131223010517.GB19388@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FUaywKC54iCcLzqT"
Content-Disposition: inline
In-Reply-To: <20131223010517.GB19388@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--FUaywKC54iCcLzqT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 23, 2013 at 10:05:17AM +0900, Joonsoo Kim wrote:
> On Sun, Dec 22, 2013 at 12:58:19AM +1100, David Gibson wrote:
> > On Wed, Dec 18, 2013 at 03:53:49PM +0900, Joonsoo Kim wrote:
> > > There is a race condition if we map a same file on different processe=
s.
> > > Region tracking is protected by mmap_sem and hugetlb_instantiation_mu=
tex.
> > > When we do mmap, we don't grab a hugetlb_instantiation_mutex, but,
> > > grab a mmap_sem. This doesn't prevent other process to modify region
> > > structure, so it can be modified by two processes concurrently.
> > >=20
> > > To solve this, I introduce a lock to resv_map and make region manipul=
ation
> > > function grab a lock before they do actual work. This makes region
> > > tracking safe.
> >=20
> > It's not clear to me if you're saying there is a list corruption race
> > bug in the existing code, or only that there will be if the
> > instantiation mutex goes away.
>=20
> Hello,
>=20
> The race exists in current code.
> Currently, region tracking is protected by either down_write(&mm->mmap_se=
m) or
> down_read(&mm->mmap_sem) + instantiation mutex. But if we map this hugetl=
bfs
> file to two different processes, holding a mmap_sem doesn't have any impa=
ct on
> the other process and concurrent access to data structure is possible.

Ouch.  In that case:

Acked-by: David Gibson <david@gibson.dropbear.id.au>

It would be really nice to add a testcase for this race to the
libhugetlbfs testsuite.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--FUaywKC54iCcLzqT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJSuXdLAAoJEGw4ysog2bOS+jEQAIehZUe2TUacMZP+VdVrUnD/
cHIUzV9DvGBsyciQU1nHbzS2PV/LsglP8yMwNDgSHpygcCKvTj9yzLpbM6uKRsnl
wCXO6vfy+2bi3dd3znGiH+wRBPIMxuS9TlbUCLHcyCVNLb4jZ0vr3REzoe45OX7x
Piccug0+AD7D6gLolPr2RlYpt2xfYamwIAGwT1tgkzJeHSNo0Zm2rB8/apnyAbPr
WOJ7Hkk0yyM+1q02LP8tYrjVX9WxOane5e98i6y+PHImpiWW3T+icFX0knyedqE7
CDYwMlakgX3L8StpoXppu2nrcoXderrT1ruiQ2Dy8bKvZsMsbsgZ3PwWRRFKZMBF
Z1SLTe9D9PoJxT39rl02hxHfQuGLFbDC9g795jc/ug0Rww2YJzK75lvvGUyzZsNe
Ju5990bZywDhfOXdHSQElIuyosQPfEDOUENmx0pzfvOlyeJ/fXwOwQ9RaHxCPCAN
FsLUjMK8bogBq2C13O3qoqgeD19RVGK0tMEl7utPKGsTdZ6m19dCr11LjptFkcCf
qOgMOMYUZq3TD9DBFjzMRKoxgUx/hYsU7PCaHBUqsBGQCMlsepRCzNWqf9NtshRy
lbnKbhllSvIv+TbbDUw8lD0aka0GuJsLzKFEmtJa0GFA2Oqy17JNUlU0PJWMz3uB
IidLyCPdlxo4SswAxUJR
=A0Ha
-----END PGP SIGNATURE-----

--FUaywKC54iCcLzqT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
