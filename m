Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 9025D6B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:54:19 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <9a45f4be-a80c-434d-ae7f-f8faaea5e4d4@default>
Date: Wed, 13 Mar 2013 09:53:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/4] zcache: zero-filled pages awareness
References: <<1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>>
 <<1363158321-20790-3-git-send-email-liwanp@linux.vnet.ibm.com>>
In-Reply-To: <<1363158321-20790-3-git-send-email-liwanp@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Subject: [PATCH 2/4] zcache: zero-filled pages awareness
>=20
> Compression of zero-filled pages can unneccessarily cause internal
> fragmentation, and thus waste memory. This special case can be
> optimized.
>=20
> This patch captures zero-filled pages, and marks their corresponding
> zcache backing page entry as zero-filled. Whenever such zero-filled
> page is retrieved, we fill the page frame with zero.
>=20
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/tmem.c        |    4 +-
>  drivers/staging/zcache/tmem.h        |    5 ++
>  drivers/staging/zcache/zcache-main.c |   87 ++++++++++++++++++++++++++++=
++----
>  3 files changed, 85 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/staging/zcache/tmem.c b/drivers/staging/zcache/tmem.=
c
> index a2b7e03..62468ea 100644
> --- a/drivers/staging/zcache/tmem.c
> +++ b/drivers/staging/zcache/tmem.c
> @@ -597,7 +597,9 @@ int tmem_put(struct tmem_pool *pool, struct tmem_oid =
*oidp, uint32_t index,
>  =09if (unlikely(ret =3D=3D -ENOMEM))
>  =09=09/* may have partially built objnode tree ("stump") */
>  =09=09goto delete_and_free;
> -=09(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
> +=09if (pampd !=3D (void *)ZERO_FILLED)
> +=09=09(*tmem_pamops.create_finish)(pampd, is_ephemeral(pool));
> +
>  =09goto out;
>=20
>  delete_and_free:
> diff --git a/drivers/staging/zcache/tmem.h b/drivers/staging/zcache/tmem.=
h
> index adbe5a8..6719dbd 100644
> --- a/drivers/staging/zcache/tmem.h
> +++ b/drivers/staging/zcache/tmem.h
> @@ -204,6 +204,11 @@ struct tmem_handle {
>  =09uint16_t client_id;
>  };
>=20
> +/*
> + * mark pampd to special vaule in order that later
> + * retrieve will identify zero-filled pages
> + */
> +#define ZERO_FILLED 0x2

You can avoid changing tmem.[ch] entirely by moving this
definition into zcache-main.c and by moving the check
comparing pampd against ZERO_FILLED into zcache_pampd_create_finish()
I think that would be cleaner...

If you change this and make the pageframe counter fix for PATCH 4/4,
please add my ack for the next version:

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
