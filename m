Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A749C6B0034
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 20:27:27 -0400 (EDT)
Date: Fri, 9 Aug 2013 10:02:31 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
Message-ID: <20130809000231.GB2904@voom.fritz.box>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
 <20130729072823.GD29970@voom.fritz.box>
 <20130731053753.GM2548@lge.com>
 <20130803104302.GC19115@voom.redhat.com>
 <20130805073647.GD27240@lge.com>
 <1375834724.2134.49.camel@buesod1.americas.hpqcorp.net>
 <20130807010312.GA17110@voom.redhat.com>
 <1375839529.2134.50.camel@buesod1.americas.hpqcorp.net>
 <20130807091832.GD32449@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2B/JsCI69OhZNC5r"
Content-Disposition: inline
In-Reply-To: <20130807091832.GD32449@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--2B/JsCI69OhZNC5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 07, 2013 at 06:18:32PM +0900, Joonsoo Kim wrote:
> On Tue, Aug 06, 2013 at 06:38:49PM -0700, Davidlohr Bueso wrote:
> > On Wed, 2013-08-07 at 11:03 +1000, David Gibson wrote:
> > > On Tue, Aug 06, 2013 at 05:18:44PM -0700, Davidlohr Bueso wrote:
> > > > On Mon, 2013-08-05 at 16:36 +0900, Joonsoo Kim wrote:
> > > > > > Any mapping that doesn't use the reserved pool, not just
> > > > > > MAP_NORESERVE.  For example, if a process makes a MAP_PRIVATE m=
apping,
> > > > > > then fork()s then the mapping is instantiated in the child, tha=
t will
> > > > > > not draw from the reserved pool.
> > > > > >=20
> > > > > > > Should we ensure them to allocate the last hugepage?
> > > > > > > They map a region with MAP_NORESERVE, so don't assume that th=
eir requests
> > > > > > > always succeed.
> > > > > >=20
> > > > > > If the pages are available, people get cranky if it fails for no
> > > > > > apparent reason, MAP_NORESERVE or not.  They get especially cra=
nky if
> > > > > > it sometimes fails and sometimes doesn't due to a race conditio=
n.
> > > > >=20
> > > > > Hello,
> > > > >=20
> > > > > Hmm... Okay. I will try to implement another way to protect race =
condition.
> > > > > Maybe it is the best to use a table mutex :)
> > > > > Anyway, please give me a time, guys.
> > > >=20
> > > > So another option is to take the mutex table patchset for now as it
> > > > *does* improve things a great deal, then, when ready, get rid of the
> > > > instantiation lock all together.
> > >=20
> > > We still don't have a solid proposal for doing that. Joonsoo Kim's
> > > patchset misses cases (non reserved mappings).  I'm also not certain
> > > there aren't a few edge cases which can lead to even reserved mappings
> > > failing, and if that happens the patches will lead to livelock.
> > >=20
> >=20
> > Exactly, which is why I suggest minimizing the lock contention until we
> > do have such a proposal.
>=20
> Okay. my proposal is not complete and maybe much time is needed.
> And I'm not sure that my *retry* approach can eventually cover all
> the race situations, currently.

Yes.  The difficulty with retrying is knowing when its safe to to
so.  If you don't retry enough, you get SIGBUS when you should be able
to allocate, if you retry too much, you freeze up trying to find a
page that isn't there.

I once attempted an approach involving an atomic counter of the number
of "in flight" hugepages, only retrying when it's non zero.  Working
out a safe ordering for all the updates to get all the cases right
made my brain melt though, and I never got it working.

> If you have to hurry, I don't have strong objection to your patches,
> but, IMHO, we should go slow, because it is not just trivial change.
> Hugetlb code is too subtle, so it is hard to confirm it's solidness.
> Following is the race problem what I found with those patches.
>=20
> I assume that nr_free_hugepage is 2.
>=20
> 1. parent process map an 1 hugepage sizeid region with MAP_PRIVATE
> 2. parent process write something to this region, so fault occur.
> 3. fault handling.
> 4. fork
> 5. parent process write something to this hugepage, so cow-fault occur.
> 6. while parent allocate a new page and do copy_user_huge_page()
> 	in fault handler, child process write something to this hugepage,
> 	so cow-fault occur. This access is not protected by table mutex,
> 	because mm is different.
> 7. child process die, because there is no free hugepage.
>=20
> If we have no race, child process would not die,
> because all we needed is only 2 hugepages, one for parent,
> and the other for child.

Ouch, good catch.  Unlike the existing form of the race, I doubt this
one has been encountered in the wild, but it shows how subtle this is.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--2B/JsCI69OhZNC5r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlIEMZcACgkQaILKxv3ab8Zl6QCdHWT++yDiK36KaozYPIKlVo4H
tQwAn34XTW3rQ79/qHD2KTojPxd2o3Ba
=aaoT
-----END PGP SIGNATURE-----

--2B/JsCI69OhZNC5r--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
