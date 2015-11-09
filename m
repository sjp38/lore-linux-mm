Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C4C5A6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:03:03 -0500 (EST)
Received: by pasz6 with SMTP id z6so195285895pas.2
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:03:03 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id rf7si20451233pab.149.2015.11.08.23.03.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 Nov 2015 23:03:02 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id tA97308O028174
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 9 Nov 2015 16:03:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas
 with holes
Date: Mon, 9 Nov 2015 06:57:05 +0000
Message-ID: <20151109065655.GA12428@hori1.linux.bs1.fc.nec.co.jp>
References: <1446247932-11348-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1446247932-11348-1-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E2F0A86B2C0BF04C984C8FCFA0B1A03F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>

On Fri, Oct 30, 2015 at 04:32:12PM -0700, Mike Kravetz wrote:
> Hugh Dickins pointed out problems with the new hugetlbfs fallocate
> hole punch code.  These problems are in the routine remove_inode_hugepage=
s
> and mostly occur in the case where there are holes in the range of
> pages to be removed.  These holes could be the result of a previous hole
> punch or simply sparse allocation.
>=20
> remove_inode_hugepages handles both hole punch and truncate operations.
> Page index handling was fixed/cleaned up so that holes are properly
> handled.  In addition, code was changed to ensure multiple passes of the
> address range only happens in the truncate case.  More comments were adde=
d
> to explain the different actions in each case.  A cond_resched() was adde=
d
> after removing up to PAGEVEC_SIZE pages.
>=20
> Some totally unnecessary code in hugetlbfs_fallocate() that remained from
> early development was also removed.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 44 +++++++++++++++++++++++++++++---------------
>  1 file changed, 29 insertions(+), 15 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 316adb9..30cf534 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -368,10 +368,25 @@ static void remove_inode_hugepages(struct inode *in=
ode, loff_t lstart,
>  			lookup_nr =3D end - next;
> =20
>  		/*
> -		 * This pagevec_lookup() may return pages past 'end',
> -		 * so we must check for page->index > end.
> +		 * When no more pages are found, take different action for
> +		 * hole punch and truncate.
> +		 *
> +		 * For hole punch, this indicates we have removed each page
> +		 * within the range and are done.  Note that pages may have
> +		 * been faulted in after being removed in the hole punch case.
> +		 * This is OK as long as each page in the range was removed
> +		 * once.
> +		 *
> +		 * For truncate, we need to make sure all pages within the
> +		 * range are removed when exiting this routine.  We could
> +		 * have raced with a fault that brought in a page after it
> +		 * was first removed.  Check the range again until no pages
> +		 * are found.
>  		 */
>  		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
> +			if (!truncate_op)
> +				break;
> +
>  			if (next =3D=3D start)
>  				break;
>  			next =3D start;
> @@ -382,19 +397,23 @@ static void remove_inode_hugepages(struct inode *in=
ode, loff_t lstart,
>  			struct page *page =3D pvec.pages[i];
>  			u32 hash;
> =20
> +			/*
> +			 * The page (index) could be beyond end.  This is
> +			 * only possible in the punch hole case as end is
> +			 * LLONG_MAX for truncate.
> +			 */
> +			if (page->index >=3D end) {
> +				next =3D end;	/* we are done */
> +				break;
> +			}
> +			next =3D page->index;
> +
>  			hash =3D hugetlb_fault_mutex_hash(h, current->mm,
>  							&pseudo_vma,
>  							mapping, next, 0);
>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
> =20
>  			lock_page(page);
> -			if (page->index >=3D end) {
> -				unlock_page(page);
> -				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> -				next =3D end;	/* we are done */
> -				break;
> -			}
> -
>  			/*
>  			 * If page is mapped, it was faulted in after being
>  			 * unmapped.  Do nothing in this race case.  In the
> @@ -423,15 +442,13 @@ static void remove_inode_hugepages(struct inode *in=
ode, loff_t lstart,
>  				}
>  			}
> =20
> -			if (page->index > next)
> -				next =3D page->index;
> -
>  			++next;

You set next =3D page->index above, so this increment takes effect only in
the final iteration. Can we put this outside (just after) this for-loop?

Thanks,
Naoya Horiguchi

>  			unlock_page(page);
> =20
>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>  		}
>  		huge_pagevec_release(&pvec);
> +		cond_resched();
>  	}
> =20
>  	if (truncate_op)
> @@ -647,9 +664,6 @@ static long hugetlbfs_fallocate(struct file *file, in=
t mode, loff_t offset,
>  	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
>  		i_size_write(inode, offset + len);
>  	inode->i_ctime =3D CURRENT_TIME;
> -	spin_lock(&inode->i_lock);
> -	inode->i_private =3D NULL;
> -	spin_unlock(&inode->i_lock);
>  out:
>  	mutex_unlock(&inode->i_mutex);
>  	return error;
> --=20
> 2.4.3
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
