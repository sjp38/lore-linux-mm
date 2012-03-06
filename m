Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id EF92C6B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 09:06:18 -0500 (EST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 6 Mar 2012 19:36:15 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q26E68Mr4526216
	for <linux-mm@kvack.org>; Tue, 6 Mar 2012 19:36:08 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q26E67fo028584
	for <linux-mm@kvack.org>; Wed, 7 Mar 2012 01:06:08 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2 0/9] memcg: add HugeTLB resource tracking
In-Reply-To: <CAJd=RBAJxVs0Jz+=PNO222oDvF0n6+hh7FNuFpSYTS3EJL8fpw@mail.gmail.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120301144029.545a5589.akpm@linux-foundation.org> <878vjgdvo4.fsf@linux.vnet.ibm.com> <CAJd=RBAJxVs0Jz+=PNO222oDvF0n6+hh7FNuFpSYTS3EJL8fpw@mail.gmail.com>
Date: Tue, 06 Mar 2012 19:35:56 +0530
Message-ID: <87hay1akor.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>

On Mon, 5 Mar 2012 21:56:50 +0800, Hillf Danton <dhillf@gmail.com> wrote:
> On Mon, Mar 5, 2012 at 3:15 AM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > On Thu, 1 Mar 2012 14:40:29 -0800, Andrew Morton <akpm@linux-foundation=
.org> wrote:
> >> I haven't begin to get my head around this yet, but I'd like to draw
> >> your attention to https://lkml.org/lkml/2012/2/15/548.
> >
> > Hmm that's really serious bug.
> >
> >> =C2=A0That fix has
> >> been hanging around for a while, but I haven't done anything with it
> >> yet because I don't like its additional blurring of the separation
> >> between hugetlb core code and hugetlbfs. =C2=A0I want to find time to =
sit
> >> down and see if the fix can be better architected but haven't got
> >> around to that yet.
> >>
> >> I expect that your patches will conflict at least mechanically with
> >> David's, which is not a big issue. =C2=A0But I wonder whether your pat=
ches
> >> will copy the same bug into other places, and whether you can think of
> >> a tidier way of addressing the bug which David is seeing?
> >>
> >
> > I will go through the implementation again and make sure the problem
> > explained by David doesn't happen in the new code path added by the
> > patch series.
> >
> Hi Aneesh
>=20
> When you tackle that problem, please take the following approach also
> into account, though it is a draft, in which quota handback is simply
> eliminated when huge page is freed, if that problem is caused by extra
> reference count.
> And get_quota is carefully paired with put_quota for newly allocated
> page. That is all, and feel free to correct me.

But we should not do put quota until the page is added back to the free pool
right ? otherwise quota subsystem (the actual hugetlb pool) will
indicate availability where as the file system won't have any free
pages.=20

-aneesh

>=20
> Best Regards
> -hd
>=20
> --- a/mm/hugetlb.c	Mon Mar  5 20:20:34 2012
> +++ b/mm/hugetlb.c	Mon Mar  5 21:20:14 2012
> @@ -533,9 +533,7 @@ static void free_huge_page(struct page *
>  	 */
>  	struct hstate *h =3D page_hstate(page);
>  	int nid =3D page_to_nid(page);
> -	struct address_space *mapping;
>=20
> -	mapping =3D (struct address_space *) page_private(page);
>  	set_page_private(page, 0);
>  	page->mapping =3D NULL;
>  	BUG_ON(page_count(page));
> @@ -551,8 +549,6 @@ static void free_huge_page(struct page *
>  		enqueue_huge_page(h, page);
>  	}
>  	spin_unlock(&hugetlb_lock);
> -	if (mapping)
> -		hugetlb_put_quota(mapping, 1);
>  }
>=20
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int =
nid)
> @@ -1021,7 +1017,8 @@ static void vma_commit_reservation(struc
>  }
>=20
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> -				    unsigned long addr, int avoid_reserve)
> +				    unsigned long addr, int avoid_reserve,
> +				    long *quota)
>  {
>  	struct hstate *h =3D hstate_vma(vma);
>  	struct page *page;
> @@ -1050,7 +1047,8 @@ static struct page *alloc_huge_page(stru
>  	if (!page) {
>  		page =3D alloc_buddy_huge_page(h, NUMA_NO_NODE);
>  		if (!page) {
> -			hugetlb_put_quota(inode->i_mapping, chg);
> +			if (chg)
> +				hugetlb_put_quota(inode->i_mapping, chg);
>  			return ERR_PTR(-VM_FAULT_SIGBUS);
>  		}
>  	}
> @@ -1058,6 +1056,8 @@ static struct page *alloc_huge_page(stru
>  	set_page_private(page, (unsigned long) mapping);
>=20
>  	vma_commit_reservation(h, vma, addr);
> +	if (quota)
> +		*quota =3D chg;
>=20
>  	return page;
>  }
> @@ -2365,6 +2365,7 @@ static int hugetlb_cow(struct mm_struct
>  	struct page *old_page, *new_page;
>  	int avoidcopy;
>  	int outside_reserve =3D 0;
> +	long quota =3D 0;
>=20
>  	old_page =3D pte_page(pte);
>=20
> @@ -2397,7 +2398,8 @@ retry_avoidcopy:
>=20
>  	/* Drop page_table_lock as buddy allocator may be called */
>  	spin_unlock(&mm->page_table_lock);
> -	new_page =3D alloc_huge_page(vma, address, outside_reserve);
> +	quota =3D 0;
> +	new_page =3D alloc_huge_page(vma, address, outside_reserve, &quota);
>=20
>  	if (IS_ERR(new_page)) {
>  		page_cache_release(old_page);
> @@ -2439,6 +2441,8 @@ retry_avoidcopy:
>  	if (unlikely(anon_vma_prepare(vma))) {
>  		page_cache_release(new_page);
>  		page_cache_release(old_page);
> +		if (quota)
> +			hugetlb_put_quota(vma->vm_file->f_mapping, quota);
>  		/* Caller expects lock to be held */
>  		spin_lock(&mm->page_table_lock);
>  		return VM_FAULT_OOM;
> @@ -2470,6 +2474,8 @@ retry_avoidcopy:
>  			address & huge_page_mask(h),
>  			(address & huge_page_mask(h)) + huge_page_size(h));
>  	}
> +	else if (quota)
> +		hugetlb_put_quota(vma->vm_file->f_mapping, quota);
>  	page_cache_release(new_page);
>  	page_cache_release(old_page);
>  	return 0;
> @@ -2519,6 +2525,7 @@ static int hugetlb_no_page(struct mm_str
>  	struct page *page;
>  	struct address_space *mapping;
>  	pte_t new_pte;
> +	long quota =3D 0;
>=20
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -2540,12 +2547,13 @@ static int hugetlb_no_page(struct mm_str
>  	 * before we get page_table_lock.
>  	 */
>  retry:
> +	quota =3D 0;
>  	page =3D find_lock_page(mapping, idx);
>  	if (!page) {
>  		size =3D i_size_read(mapping->host) >> huge_page_shift(h);
>  		if (idx >=3D size)
>  			goto out;
> -		page =3D alloc_huge_page(vma, address, 0);
> +		page =3D alloc_huge_page(vma, address, 0, &quota);
>  		if (IS_ERR(page)) {
>  			ret =3D -PTR_ERR(page);
>  			goto out;
> @@ -2560,6 +2568,8 @@ retry:
>  			err =3D add_to_page_cache(page, mapping, idx, GFP_KERNEL);
>  			if (err) {
>  				put_page(page);
> +				if (quota)
> +					hugetlb_put_quota(mapping, quota);
>  				if (err =3D=3D -EEXIST)
>  					goto retry;
>  				goto out;
> @@ -2633,6 +2643,8 @@ backout:
>  backout_unlocked:
>  	unlock_page(page);
>  	put_page(page);
> +	if (quota)
> +		hugetlb_put_quota(mapping, quota);
>  	goto out;
>  }
>=20
> --
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
