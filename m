Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id A81B58E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 15:53:21 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id o5so1549527wmf.9
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:53:21 -0800 (PST)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60079.outbound.protection.outlook.com. [40.107.6.79])
        by mx.google.com with ESMTPS id f8si54071993wro.330.2019.01.15.12.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Jan 2019 12:53:20 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Tue, 15 Jan 2019 20:53:16 +0000
Message-ID: <20190115205311.GD22031@mellanox.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
In-Reply-To: <20190115181300.27547-7-dave@stgolabs.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C5B84038AA26984BBCB1A409893CDF97@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Tue, Jan 15, 2019 at 10:13:00AM -0800, Davidlohr Bueso wrote:
> ib_umem_get() uses gup_longterm() and relies on the lock to
> stabilze the vma_list, so we cannot really get rid of mmap_sem
> altogether, but now that the counter is atomic, we can get of
> some complexity that mmap_sem brings with only pinned_vm.
>=20
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>  drivers/infiniband/core/umem.c | 41 ++----------------------------------=
-----
>  1 file changed, 2 insertions(+), 39 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/ume=
m.c
> index bf556215aa7e..baa2412bf6fb 100644
> +++ b/drivers/infiniband/core/umem.c
> @@ -160,15 +160,12 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *con=
text, unsigned long addr,
> =20
>  	lock_limit =3D rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> =20
> -	down_write(&mm->mmap_sem);
> -	new_pinned =3D atomic_long_read(&mm->pinned_vm) + npages;
> +	new_pinned =3D atomic_long_add_return(npages, &mm->pinned_vm);
>  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {

I thought a patch had been made for this to use check_overflow...

npages is controlled by userspace, so can we protect pinned_vm from
overflow in some way that still allows it to be atomic?

Jason
