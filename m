Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 264B76B0083
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 03:05:33 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 17 Feb 2012 08:00:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1H85LBd917730
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:05:21 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1H85K5n019654
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:05:20 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 5/6] hugetlbfs: Add controller support for private mapping
In-Reply-To: <4F3DE424.3010301@gmail.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1328909806-15236-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F3DE424.3010301@gmail.com>
Date: Fri, 17 Feb 2012 13:35:06 +0530
Message-ID: <87aa4hevgt.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bill4carson <bill4carson@gmail.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com

On Fri, 17 Feb 2012 13:22:44 +0800, bill4carson <bill4carson@gmail.com> wro=
te:
>=20
>=20
> On 2012=E5=B9=B402=E6=9C=8811=E6=97=A5 05:36, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> >
> > HugeTLB controller is different from a memory controller in that we cha=
rge
> > controller during mmap() time and not fault time. This make sure usersp=
ace
> > can fallback to non-hugepage allocation when mmap fails due to controll=
er
> > limit.
> >
> > For private mapping we always charge/uncharge from the current task cgr=
oup.
> > Charging happens during mmap(2) and uncharge happens during the
> > vm_operations->close when resv_map refcount reaches zero. The uncharge =
count
> > is stored in struct resv_map. For child task after fork the charging ha=
ppens
> > during fault time in alloc_huge_page. We also need to make sure for pri=
vate
> > mapping each vma for hugeTLB mapping have struct resv_map allocated so =
that we
> > can store the uncharge count in resv_map.
> >
> > Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >   fs/hugetlbfs/hugetlb_cgroup.c  |   50 ++++++++++++++++++++++++++++++++
> >   include/linux/hugetlb.h        |    7 ++++
> >   include/linux/hugetlb_cgroup.h |   16 ++++++++++
> >   mm/hugetlb.c                   |   62 +++++++++++++++++++++++++++++++=
+--------
> >   4 files changed, 123 insertions(+), 12 deletions(-)
> >
> > diff --git a/fs/hugetlbfs/hugetlb_cgroup.c b/fs/hugetlbfs/hugetlb_cgrou=
p.c
> > index c478fb0..f828fb2 100644
> > --- a/fs/hugetlbfs/hugetlb_cgroup.c
> > +++ b/fs/hugetlbfs/hugetlb_cgroup.c
> > @@ -458,3 +458,53 @@ long  hugetlb_truncate_cgroup_charge(struct hstate=
 *h,
> >   	}
> >   	return chg;
> >   }
> > +
> > +int hugetlb_priv_page_charge(struct resv_map *map, struct hstate *h, l=
ong chg)
> > +{
> > +	long csize;
> > +	int idx, ret;
> > +	struct hugetlb_cgroup *h_cg;
> > +	struct res_counter *fail_res;
> > +
> > +	/*
> > +	 * Get the task cgroup within rcu_readlock and also
> > +	 * get cgroup reference to make sure cgroup destroy won't
> > +	 * race with page_charge. We don't allow a cgroup destroy
> > +	 * when the cgroup have some charge against it
> > +	 */
> > +	rcu_read_lock();
> > +	h_cg =3D task_hugetlbcgroup(current);
> > +	css_get(&h_cg->css);
> > +	rcu_read_unlock();
> > +
> > +	if (hugetlb_cgroup_is_root(h_cg)) {
> > +		ret =3D chg;
> > +		goto err_out;
> > +	}
> > +
> > +	csize =3D chg * huge_page_size(h);
> > +	idx =3D h - hstates;
> > +	ret =3D res_counter_charge(&h_cg->memhuge[idx], csize,&fail_res);
> > +	if (!ret) {
> > +		map->nr_pages[idx] +=3D chg<<  huge_page_order(h);
> > +		ret =3D chg;
> > +	}
> > +err_out:
> > +	css_put(&h_cg->css);
> > +	return ret;
> > +}
> > +
> > +void hugetlb_priv_page_uncharge(struct resv_map *map, int idx, int nr_=
pages)
> > +{
> > +	struct hugetlb_cgroup *h_cg;
> > +	unsigned long csize =3D nr_pages * PAGE_SIZE;
> > +
> > +	rcu_read_lock();
> > +	h_cg =3D task_hugetlbcgroup(current);
> > +	if (!hugetlb_cgroup_is_root(h_cg)) {
> > +		res_counter_uncharge(&h_cg->memhuge[idx], csize);
> > +		map->nr_pages[idx] -=3D nr_pages;
> > +	}
> > +	rcu_read_unlock();
> > +	return;
> > +}
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 4392b6a..e2ba381 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -233,6 +233,12 @@ struct hstate {
> >   	char name[HSTATE_NAME_LEN];
> >   };
> >
> > +struct resv_map {
> > +	struct kref refs;
> > +	int nr_pages[HUGE_MAX_HSTATE];
> > +	struct list_head regions;
> > +};
> > +
>=20
> Please put resv_map after HUGE_MAX_HSTATE definition,
> otherwise it will break on non-x86 arches, which has no
> HUGE_MAX_HSTATE definition.
>=20
>=20
> #ifndef HUGE_MAX_HSTATE
> #define HUGE_MAX_HSTATE 1
> #endif
>=20
> +struct resv_map {
> +	struct kref refs;
> +	int nr_pages[HUGE_MAX_HSTATE];
> +	struct list_head regions;
> +};
>=20
>=20
>=20
>=20

Will do in the next iteration.

Thanks for the review
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
