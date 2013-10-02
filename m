Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC7B6B005A
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:55:03 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1166966pab.41
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:55:02 -0700 (PDT)
From: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Subject: RE: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Date: Wed, 2 Oct 2013 14:54:59 +0000
Message-ID: <32E1700B9017364D9B60AED9960492BC211AEF75@FMSMSX107.amr.corp.intel.com>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-24-git-send-email-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

Thanks!!

I would like to test these two patches and also do the stable work for the =
deadlock as well.  Do you have these patches in a repo somewhere to save me=
 a bit of work?

We had been working on an internal version of the deadlock portion of this =
patch that uses get_user_pages_fast() vs. the new get_user_pages_unlocked()=
.

The risk of GUP fast is the loss of the "force" arg on GUP fast, which I do=
n't see as significant give our use case.

Some nits on the subject and commit message:
1. use IB/qib, IB/ipath vs. ib
2. use the correct ipath vs. qib in the commit message text

Mike

> -----Original Message-----
> From: Jan Kara [mailto:jack@suse.cz]
> Sent: Wednesday, October 02, 2013 10:28 AM
> To: LKML
> Cc: linux-mm@kvack.org; Jan Kara; infinipath; Roland Dreier; linux-
> rdma@vger.kernel.org
> Subject: [PATCH 23/26] ib: Convert qib_get_user_pages() to
> get_user_pages_unlocked()
>=20
> Convert qib_get_user_pages() to use get_user_pages_unlocked().  This
> shortens the section where we hold mmap_sem for writing and also removes
> the knowledge about get_user_pages() locking from ipath driver. We also f=
ix
> a bug in testing pinned number of pages when changing the code.
>=20
> CC: Mike Marciniszyn <infinipath@intel.com>
> CC: Roland Dreier <roland@kernel.org>
> CC: linux-rdma@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  drivers/infiniband/hw/qib/qib_user_pages.c | 62 +++++++++++++-----------=
-----
> -
>  1 file changed, 26 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c
> b/drivers/infiniband/hw/qib/qib_user_pages.c
> index 2bc1d2b96298..57ce83c2d1d9 100644
> --- a/drivers/infiniband/hw/qib/qib_user_pages.c
> +++ b/drivers/infiniband/hw/qib/qib_user_pages.c
> @@ -48,39 +48,55 @@ static void __qib_release_user_pages(struct page
> **p, size_t num_pages,
>  	}
>  }
>=20
> -/*
> - * Call with current->mm->mmap_sem held.
> +/**
> + * qib_get_user_pages - lock user pages into memory
> + * @start_page: the start page
> + * @num_pages: the number of pages
> + * @p: the output page structures
> + *
> + * This function takes a given start page (page aligned user virtual
> + * address) and pins it and the following specified number of pages.
> +For
> + * now, num_pages is always 1, but that will probably change at some
> +point
> + * (because caller is doing expected sends on a single virtually
> +contiguous
> + * buffer, so we can do all pages at once).
>   */
> -static int __qib_get_user_pages(unsigned long start_page, size_t
> num_pages,
> -				struct page **p, struct vm_area_struct
> **vma)
> +int qib_get_user_pages(unsigned long start_page, size_t num_pages,
> +		       struct page **p)
>  {
>  	unsigned long lock_limit;
>  	size_t got;
>  	int ret;
> +	struct mm_struct *mm =3D current->mm;
>=20
> +	down_write(&mm->mmap_sem);
>  	lock_limit =3D rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>=20
> -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> +	if (mm->pinned_vm + num_pages > lock_limit &&
> !capable(CAP_IPC_LOCK)) {
> +		up_write(&mm->mmap_sem);
>  		ret =3D -ENOMEM;
>  		goto bail;
>  	}
> +	mm->pinned_vm +=3D num_pages;
> +	up_write(&mm->mmap_sem);
>=20
>  	for (got =3D 0; got < num_pages; got +=3D ret) {
> -		ret =3D get_user_pages(current, current->mm,
> -				     start_page + got * PAGE_SIZE,
> -				     num_pages - got, 1, 1,
> -				     p + got, vma);
> +		ret =3D get_user_pages_unlocked(current, mm,
> +					      start_page + got * PAGE_SIZE,
> +					      num_pages - got, 1, 1,
> +					      p + got);
>  		if (ret < 0)
>  			goto bail_release;
>  	}
>=20
> -	current->mm->pinned_vm +=3D num_pages;
>=20
>  	ret =3D 0;
>  	goto bail;
>=20
>  bail_release:
>  	__qib_release_user_pages(p, got, 0);
> +	down_write(&mm->mmap_sem);
> +	mm->pinned_vm -=3D num_pages;
> +	up_write(&mm->mmap_sem);
>  bail:
>  	return ret;
>  }
> @@ -117,32 +133,6 @@ dma_addr_t qib_map_page(struct pci_dev *hwdev,
> struct page *page,
>  	return phys;
>  }
>=20
> -/**
> - * qib_get_user_pages - lock user pages into memory
> - * @start_page: the start page
> - * @num_pages: the number of pages
> - * @p: the output page structures
> - *
> - * This function takes a given start page (page aligned user virtual
> - * address) and pins it and the following specified number of pages.  Fo=
r
> - * now, num_pages is always 1, but that will probably change at some poi=
nt
> - * (because caller is doing expected sends on a single virtually contigu=
ous
> - * buffer, so we can do all pages at once).
> - */
> -int qib_get_user_pages(unsigned long start_page, size_t num_pages,
> -		       struct page **p)
> -{
> -	int ret;
> -
> -	down_write(&current->mm->mmap_sem);
> -
> -	ret =3D __qib_get_user_pages(start_page, num_pages, p, NULL);
> -
> -	up_write(&current->mm->mmap_sem);
> -
> -	return ret;
> -}
> -
>  void qib_release_user_pages(struct page **p, size_t num_pages)  {
>  	if (current->mm) /* during close after signal, mm can be NULL */
> --
> 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
