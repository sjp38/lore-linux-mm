Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CE1AC6B00A2
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 08:08:25 -0400 (EDT)
Date: Mon, 16 Sep 2013 22:09:09 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20130916120909.GA2706@voom.fritz.box>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
 <20130905011553.GA10158@voom.redhat.com>
 <20130905054357.GA23597@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
Content-Disposition: inline
In-Reply-To: <20130905054357.GA23597@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 05, 2013 at 02:43:57PM +0900, Joonsoo Kim wrote:
> Hello, David.
>=20
> First of all, thanks for review!
>=20
> On Thu, Sep 05, 2013 at 11:15:53AM +1000, David Gibson wrote:
> > On Fri, Aug 09, 2013 at 06:26:37PM +0900, Joonsoo Kim wrote:
> > > If parallel fault occur, we can fail to allocate a hugepage,
> > > because many threads dequeue a hugepage to handle a fault of same add=
ress.
> > > This makes reserved pool shortage just for a little while and this ca=
use
> > > faulting thread who can get hugepages to get a SIGBUS signal.
> > >=20
> > > To solve this problem, we already have a nice solution, that is,
> > > a hugetlb_instantiation_mutex. This blocks other threads to dive into
> > > a fault handler. This solve the problem clearly, but it introduce
> > > performance degradation, because it serialize all fault handling.
> > >=20
> > > Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> > > performance degradation. For achieving it, at first, we should ensure=
 that
> > > no one get a SIGBUS if there are enough hugepages.
> > >=20
> > > For this purpose, if we fail to allocate a new hugepage when there is
> > > concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With t=
his,
> > > these threads defer to get a SIGBUS signal until there is no
> > > concurrent user, and so, we can ensure that no one get a SIGBUS if th=
ere
> > > are enough hugepages.
> > >=20
> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > >=20
> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > > index e29e28f..981c539 100644
> > > --- a/include/linux/hugetlb.h
> > > +++ b/include/linux/hugetlb.h
> > > @@ -242,6 +242,7 @@ struct hstate {
> > >  	int next_nid_to_free;
> > >  	unsigned int order;
> > >  	unsigned long mask;
> > > +	unsigned long nr_dequeue_users;
> > >  	unsigned long max_huge_pages;
> > >  	unsigned long nr_huge_pages;
> > >  	unsigned long free_huge_pages;
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 8743e5c..0501fe5 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -561,6 +561,7 @@ retry_cpuset:
> > >  		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
> > >  			page =3D dequeue_huge_page_node(h, zone_to_nid(zone));
> > >  			if (page) {
> > > +				h->nr_dequeue_users++;
> >=20
> > So, nr_dequeue_users doesn't seem to be incremented in the
> > alloc_huge_page_node() path.  I'm not sure exactly where that's used,
> > so I'm not sure if it's a problem.
> >=20
>=20
> Hmm.. I think that it isn't a problem. The point is that we want to avoid
> the race which kill the legitimate users of hugepages by out of resources.
> This allocation doesn't harm to the legitimate users.

Well, my point is just that since whatever callers there are to this
function are external, they need to be checked to see if they can
participate in this race.

>=20
> > >  				if (!use_reserve)
> > >  					break;
> > > =20
> > > @@ -577,6 +578,16 @@ retry_cpuset:
> > >  	return page;
> > >  }
> > > =20
> > > +static void commit_dequeued_huge_page(struct hstate *h, bool do_dequ=
eue)
> > > +{
> > > +	if (!do_dequeue)
> > > +		return;
> >=20
> > Seems like it would be easier to do this test in the callers, but I
> > doubt it matters much.
>=20
> Yes, I will fix it.
>=20
> >=20
> > > +	spin_lock(&hugetlb_lock);
> > > +	h->nr_dequeue_users--;
> > > +	spin_unlock(&hugetlb_lock);
> > > +}
> > > +
> > >  static void update_and_free_page(struct hstate *h, struct page *page)
> > >  {
> > >  	int i;
> > > @@ -1110,7 +1121,9 @@ static void vma_commit_reservation(struct hstat=
e *h,
> > >  }
> > > =20
> > >  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> > > -				    unsigned long addr, int use_reserve)
> > > +				    unsigned long addr, int use_reserve,
> > > +				    unsigned long *nr_dequeue_users,
> > > +				    bool *do_dequeue)
> > >  {
> > >  	struct hugepage_subpool *spool =3D subpool_vma(vma);
> > >  	struct hstate *h =3D hstate_vma(vma);
> > > @@ -1138,8 +1151,11 @@ static struct page *alloc_huge_page(struct vm_=
area_struct *vma,
> > >  		return ERR_PTR(-ENOSPC);
> > >  	}
> > >  	spin_lock(&hugetlb_lock);
> > > +	*do_dequeue =3D true;
> > >  	page =3D dequeue_huge_page_vma(h, vma, addr, use_reserve);
> > >  	if (!page) {
> > > +		*nr_dequeue_users =3D h->nr_dequeue_users;
> >=20
> > So, the nr_dequeue_users parameter is only initialized if !page here.
> > It's not obvious to me that the callers only use it in hat case.
>=20
> Okay. I will fix it.
>=20
> >=20
> > > +		*do_dequeue =3D false;
> > >  		spin_unlock(&hugetlb_lock);
> > >  		page =3D alloc_buddy_huge_page(h, NUMA_NO_NODE);
> > >  		if (!page) {
> >=20
> > I think the counter also needs to be incremented in the case where we
> > call alloc_buddy_huge_page() from alloc_huge_page().  Even though it's
> > new, it gets added to the hugepage pool at this point and could still
> > be a contended page for the last allocation, unless I'm missing
> > something.
>=20
> Your comment has reasonable point to me, but I have a different opinion.
>=20
> As I already mentioned, the point is that we want to avoid the race
> which kill the legitimate users of hugepages by out of resources.
> I increase 'h->nr_dequeue_users' when the hugepage allocated by
> administrator is dequeued. It is because what the hugepage I want to
> protect from the race is the one allocated by administrator via
> kernel param or /proc interface. Administrator may already know how many
> hugepages are needed for their application so that he may set nr_hugepage
> to reasonable value. I want to guarantee that these hugepages can be used
> for his application without any race, since he assume that the application
> would work fine with these hugepages.
>=20
> To protect hugepages returned from alloc_buddy_huge_page() from the race
> is different for me. Although it will be added to the hugepage pool, this
> doesn't guarantee certain application's success more. If certain
> application's success depends on the race of this new hugepage, it's death
> by the race doesn't matter, since nobody assume that it works fine.

Hrm.  I still think this path should be included.  Although I'll agree
that failing in this case is less bad.

However, it can still lead to a situation where with two processes or
threads, faulting on exactly the same shared page we have one succeed
and the other fail.  That's a strange behaviour and I think we want to
avoid it in this case too.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSNvTlAAoJEGw4ysog2bOSo9AQAMWe90W5ba7DZnrpnhcYtaCv
QjS7+pvssY/lXlbzp3IwwaGndc+AAMLvMOvXpWqx6gshurJpad2EnO0ETk+RiKXZ
QGDyEz0iXktGnaY5c/ed/lQM1dCoMMzLwyfi85UbNa4NJnCWNyBlvsxB9JjQUxaA
/TiXaFpoxK+ADSPEzfJl/Xb2nYplu3z4iP8R7pd0WTVBld7goU1JSxhhJKFXMTq8
S7pqMc1I3c9ExQzgobTQgqxMS0AzP5RhUpb0TXyiv8rujyuJ09VntKtED2w5WkZ+
Ei8Sf6a5ZlbUzFjaOf0pXieIx9aLazg/mxkMwo10TDhR7W5YxmK/Px9rVPp3QWh/
Je35R3aF54Igjw99fqIZcCRnCi6/hLLtTVykPswagZFa384hBgkdELafYVM7kT8n
iKVhrEo4X7aF8clDVMcS15e95T2DgaxtOasFYlsLaBEuCdHBikeRyZZqadA6vsHJ
UB7SbaiJh6jSuW//9S6negc1zZPHmABCuvof4PHU2YaKjC8SMDGQeYq2v+LC1KmY
uCKbUw4XKx56JRpG4yKWtQZGYXpovqxOSnR0FN94mcjHcxaFy+6YeoMsJOQvVQ4o
lQx87OcM19jG63d824M9ecoNkP27eCXYADyVNiT0EF2mThpteUJYLlm2f4lQd9a2
AM30xrUCAxw9S6JeL93K
=pM7j
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
