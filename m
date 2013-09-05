Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 70F1D6B0033
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 21:15:51 -0400 (EDT)
Date: Thu, 5 Sep 2013 11:15:53 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20130905011553.GA10158@voom.redhat.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
In-Reply-To: <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 09, 2013 at 06:26:37PM +0900, Joonsoo Kim wrote:
> If parallel fault occur, we can fail to allocate a hugepage,
> because many threads dequeue a hugepage to handle a fault of same address.
> This makes reserved pool shortage just for a little while and this cause
> faulting thread who can get hugepages to get a SIGBUS signal.
>=20
> To solve this problem, we already have a nice solution, that is,
> a hugetlb_instantiation_mutex. This blocks other threads to dive into
> a fault handler. This solve the problem clearly, but it introduce
> performance degradation, because it serialize all fault handling.
>=20
> Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> performance degradation. For achieving it, at first, we should ensure that
> no one get a SIGBUS if there are enough hugepages.
>=20
> For this purpose, if we fail to allocate a new hugepage when there is
> concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With this,
> these threads defer to get a SIGBUS signal until there is no
> concurrent user, and so, we can ensure that no one get a SIGBUS if there
> are enough hugepages.
>=20
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index e29e28f..981c539 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -242,6 +242,7 @@ struct hstate {
>  	int next_nid_to_free;
>  	unsigned int order;
>  	unsigned long mask;
> +	unsigned long nr_dequeue_users;
>  	unsigned long max_huge_pages;
>  	unsigned long nr_huge_pages;
>  	unsigned long free_huge_pages;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8743e5c..0501fe5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -561,6 +561,7 @@ retry_cpuset:
>  		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
>  			page =3D dequeue_huge_page_node(h, zone_to_nid(zone));
>  			if (page) {
> +				h->nr_dequeue_users++;

So, nr_dequeue_users doesn't seem to be incremented in the
alloc_huge_page_node() path.  I'm not sure exactly where that's used,
so I'm not sure if it's a problem.

>  				if (!use_reserve)
>  					break;
> =20
> @@ -577,6 +578,16 @@ retry_cpuset:
>  	return page;
>  }
> =20
> +static void commit_dequeued_huge_page(struct hstate *h, bool do_dequeue)
> +{
> +	if (!do_dequeue)
> +		return;

Seems like it would be easier to do this test in the callers, but I
doubt it matters much.

> +	spin_lock(&hugetlb_lock);
> +	h->nr_dequeue_users--;
> +	spin_unlock(&hugetlb_lock);
> +}
> +
>  static void update_and_free_page(struct hstate *h, struct page *page)
>  {
>  	int i;
> @@ -1110,7 +1121,9 @@ static void vma_commit_reservation(struct hstate *h,
>  }
> =20
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> -				    unsigned long addr, int use_reserve)
> +				    unsigned long addr, int use_reserve,
> +				    unsigned long *nr_dequeue_users,
> +				    bool *do_dequeue)
>  {
>  	struct hugepage_subpool *spool =3D subpool_vma(vma);
>  	struct hstate *h =3D hstate_vma(vma);
> @@ -1138,8 +1151,11 @@ static struct page *alloc_huge_page(struct vm_area=
_struct *vma,
>  		return ERR_PTR(-ENOSPC);
>  	}
>  	spin_lock(&hugetlb_lock);
> +	*do_dequeue =3D true;
>  	page =3D dequeue_huge_page_vma(h, vma, addr, use_reserve);
>  	if (!page) {
> +		*nr_dequeue_users =3D h->nr_dequeue_users;

So, the nr_dequeue_users parameter is only initialized if !page here.
It's not obvious to me that the callers only use it in hat case.

> +		*do_dequeue =3D false;
>  		spin_unlock(&hugetlb_lock);
>  		page =3D alloc_buddy_huge_page(h, NUMA_NO_NODE);
>  		if (!page) {

I think the counter also needs to be incremented in the case where we
call alloc_buddy_huge_page() from alloc_huge_page().  Even though it's
new, it gets added to the hugepage pool at this point and could still
be a contended page for the last allocation, unless I'm missing
something.

> @@ -1894,6 +1910,7 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->mask =3D ~((1ULL << (order + PAGE_SHIFT)) - 1);
>  	h->nr_huge_pages =3D 0;
>  	h->free_huge_pages =3D 0;
> +	h->nr_dequeue_users =3D 0;
>  	for (i =3D 0; i < MAX_NUMNODES; ++i)
>  		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
>  	INIT_LIST_HEAD(&h->hugepage_activelist);
> @@ -2500,6 +2517,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct=
 vm_area_struct *vma,
>  	int outside_reserve =3D 0;
>  	long chg;
>  	bool use_reserve =3D false;
> +	unsigned long nr_dequeue_users =3D 0;
> +	bool do_dequeue =3D false;
>  	int ret =3D 0;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> @@ -2551,11 +2570,17 @@ retry_avoidcopy:
>  		use_reserve =3D !chg;
>  	}
> =20
> -	new_page =3D alloc_huge_page(vma, address, use_reserve);
> +	new_page =3D alloc_huge_page(vma, address, use_reserve,
> +						&nr_dequeue_users, &do_dequeue);
> =20
>  	if (IS_ERR(new_page)) {
>  		page_cache_release(old_page);
> =20
> +		if (nr_dequeue_users) {
> +			ret =3D 0;
> +			goto out_lock;
> +		}
> +
>  		/*
>  		 * If a process owning a MAP_PRIVATE mapping fails to COW,
>  		 * it is due to references held by a child and an insufficient
> @@ -2580,6 +2605,9 @@ retry_avoidcopy:
>  			WARN_ON_ONCE(1);
>  		}
> =20
> +		if (use_reserve)
> +			WARN_ON_ONCE(1);
> +
>  		ret =3D VM_FAULT_SIGBUS;
>  		goto out_lock;
>  	}
> @@ -2614,6 +2642,7 @@ retry_avoidcopy:
>  	page_cache_release(new_page);
>  out_old_page:
>  	page_cache_release(old_page);
> +	commit_dequeued_huge_page(h, do_dequeue);
>  out_lock:
>  	/* Caller expects lock to be held */
>  	spin_lock(&mm->page_table_lock);
> @@ -2666,6 +2695,8 @@ static int hugetlb_no_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
>  	pte_t new_pte;
>  	long chg;
>  	bool use_reserve;
> +	unsigned long nr_dequeue_users =3D 0;
> +	bool do_dequeue =3D false;
> =20
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -2699,9 +2730,17 @@ retry:
>  		}
>  		use_reserve =3D !chg;
> =20
> -		page =3D alloc_huge_page(vma, address, use_reserve);
> +		page =3D alloc_huge_page(vma, address, use_reserve,
> +					&nr_dequeue_users, &do_dequeue);
>  		if (IS_ERR(page)) {
> -			ret =3D VM_FAULT_SIGBUS;
> +			if (nr_dequeue_users)
> +				ret =3D 0;
> +			else {
> +				if (use_reserve)
> +					WARN_ON_ONCE(1);
> +
> +				ret =3D VM_FAULT_SIGBUS;
> +			}
>  			goto out;
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));
> @@ -2714,22 +2753,24 @@ retry:
>  			err =3D add_to_page_cache(page, mapping, idx, GFP_KERNEL);
>  			if (err) {
>  				put_page(page);
> +				commit_dequeued_huge_page(h, do_dequeue);
>  				if (err =3D=3D -EEXIST)
>  					goto retry;
>  				goto out;
>  			}
>  			ClearPagePrivate(page);
> +			commit_dequeued_huge_page(h, do_dequeue);
> =20
>  			spin_lock(&inode->i_lock);
>  			inode->i_blocks +=3D blocks_per_huge_page(h);
>  			spin_unlock(&inode->i_lock);
>  		} else {
>  			lock_page(page);
> +			anon_rmap =3D 1;
>  			if (unlikely(anon_vma_prepare(vma))) {
>  				ret =3D VM_FAULT_OOM;
>  				goto backout_unlocked;
>  			}
> -			anon_rmap =3D 1;
>  		}
>  	} else {
>  		/*
> @@ -2783,6 +2824,8 @@ retry:
>  	spin_unlock(&mm->page_table_lock);
>  	unlock_page(page);
>  out:
> +	if (anon_rmap)
> +		commit_dequeued_huge_page(h, do_dequeue);
>  	return ret;
> =20
>  backout:

Otherwise I think it looks good.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSJ9tIAAoJEGw4ysog2bOS5AoP/1prkMVHp6kfFIhoKqALM0kP
hl78eo0ngO0UaZ80It3LfFJPJe0SqRTsgkKoMFsU8XcHQ6JntL4YfNDiIkKa3LUf
zNiH8UHZAP0jAsopAIuMGz3RoFPDLZEsSI5tYigeO17M1aSxCOb+t9T1ITBaqgM6
HW5ojH+isDpTMc+DjaQ3S2IxutjxOwuHJdniPRhpd8arzDcQb4vS59NjzGHv3iGK
M67LVelqcPGgZcNgLYX7wJA6WnpoGwpO64DShJieYiZkVWwO+4X6uDf4PdV94aC1
5bbrM9LAd6h3/hP7wAof+YvTCrQZsxhcH8nSqg7AlZQ7gRLr7QVDWhZ3u/b83qd8
ghg9+IyThMBzTJGj9oUK5O9DSbkACkA1vvEiraKSrEMabaaX0ov7l/Oqv+qbk6ox
V+M7ToscIqq7KDFybAnj+MVn2EV0xhmaTOUDWZ2WXl5iyeBq4Zg8nbNNmIX3+LXA
1Xi0zdE5xTMMv+N8mZGYdYAboiiYI72sBX61tZC/cLgM/2GTdWevb02/WdOVDgtm
ahsn7dS8uDF1kKXGmqOw68wDVYTeYwyVecVKKVTvsp17CrmHp8Xs3pLhQEm9RWvC
APtqD3C6kRxRgJe3J7CZRf+1CNiEFTS/Nhw/9aaucIrA1XQdmBeNfqql/PDMrjT6
iv8+BjvL1mnlgwOAz5a/
=h4zC
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
