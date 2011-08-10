Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6E73990013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 11:09:14 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2f1abd2b-4c58-46b4-83bd-18c5338de28e@default>
Date: Wed, 10 Aug 2011 08:08:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default>
 <4E429407.8000209@linux.vnet.ibm.com 4E429945.1020008@linux.vnet.ibm.com>
In-Reply-To: <4E429945.1020008@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Brian King <brking@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH v2] staging: zcache: support multiple clients, prep f=
or KVM and RAMster
>=20
> > This crash is hit every time a high memory page is swapped out.
> >
> > I have no solution right now other that to revert this patch and
> > restore the original signatures.

Hi Seth --

Thanks for your testing.  I haven't done much testing on 32-bit.

> Sorry for the noise, but I noticed right after I sent this that
> the tmem layer doesn't DO anything with the data parameter. So
> a possible solution is to just pass the page pointer instead of
> the virtual address.  After all, pointers are pointers.

Yes, this looks like a good patch.

> --- a/drivers/staging/zcache/zcache.c
> +++ b/drivers/staging/zcache/zcache.c
> @@ -1153,7 +1153,7 @@ static void *zcache_pampd_create(char *data, size_t=
 size,
>         size_t clen;
>         int ret;
>         unsigned long count;
> -       struct page *page =3D virt_to_page(data);
> +       struct page *page =3D (struct page *)(data);
>         struct zcache_client *cli =3D pool->client;
>         uint16_t client_id =3D get_client_id_from_client(cli);
>         unsigned long zv_mean_zsize;
> @@ -1220,7 +1220,7 @@ static int zcache_pampd_get_data(char *data, size_t=
 *bufsi
>         int ret =3D 0;
>=20
>         BUG_ON(is_ephemeral(pool));
> -       zv_decompress(virt_to_page(data), pampd);
> +       zv_decompress((struct page *)(data), pampd);
>         return ret;
>  }
>=20
> @@ -1532,7 +1532,7 @@ static int zcache_put_page(int cli_id, int pool_id,=
 struct
>                 goto out;
>         if (!zcache_freeze && zcache_do_preload(pool) =3D=3D 0) {
>                 /* preload does preempt_disable on success */
> -               ret =3D tmem_put(pool, oidp, index, page_address(page),
> +               ret =3D tmem_put(pool, oidp, index, (char *)(page),
>                                 PAGE_SIZE, 0, is_ephemeral(pool));
>                 if (ret < 0) {
>                         if (is_ephemeral(pool))
> @@ -1565,7 +1565,7 @@ static int zcache_get_page(int cli_id, int pool_id,=
 struct
>         pool =3D zcache_get_pool_by_id(cli_id, pool_id);
>         if (likely(pool !=3D NULL)) {
>                 if (atomic_read(&pool->obj_count) > 0)
> -                       ret =3D tmem_get(pool, oidp, index, page_address(=
page),
> +                       ret =3D tmem_get(pool, oidp, index, (char *)(page=
),
>                                         &size, 0, is_ephemeral(pool));
>                 zcache_put_pool(pool);
>         }
>=20
> I tested this and it works.
>=20
> Dan, does this mess anything else up?

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> > What was the rationale for the signature changes?
> > Seth

The change on the tmem side allows tmem to handle pre-compressed pages,
which is useful to RAMster and possibly for KVM.  The new "raw"
parameter identifies that case, but for zcache "raw" is always zero so
your solution looks fine.

Seth, could you submit an "official" patch (i.e. proper subject field,
signed-off-by) and I will ack that and ask GregKH to queue it up for
a 3.1-rc?

Subject something like: staging: zcache: fix highmem crash on 32-bit

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
