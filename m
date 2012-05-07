Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8F8526B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 15:17:05 -0400 (EDT)
Received: by dadm1 with SMTP id m1so3194489dad.8
        for <linux-mm@kvack.org>; Mon, 07 May 2012 12:17:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336390672-14421-8-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
	<1336390672-14421-8-git-send-email-hannes@cmpxchg.org>
Date: Mon, 7 May 2012 12:17:04 -0700
Message-ID: <CAE9FiQVVvppc0iuxFEoqU+Pxq0A2c=uoByDGvYEccMU2kahJbQ@mail.gmail.com>
Subject: Re: [patch 07/10] mm: nobootmem: panic on node-specific allocation failure
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 7, 2012 at 4:37 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> __alloc_bootmem_node and __alloc_bootmem_low_node documentation claims
> the functions panic on allocation failure. =A0Do it.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0mm/nobootmem.c | =A0 20 ++++++++++++++++----
> =A01 file changed, 16 insertions(+), 4 deletions(-)
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index e53bb8a..b078ff8 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -306,11 +306,17 @@ again:
>
> =A0 =A0 =A0 =A0ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, alig=
n,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0goal, -1ULL);
> - =A0 =A0 =A0 if (!ptr && goal) {
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 if (goal) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goal =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto again;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> + =A0 =A0 =A0 panic("Out of memory");
> + =A0 =A0 =A0 return NULL;
> =A0}
>
> =A0void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned lon=
g size,
> @@ -408,6 +414,12 @@ void * __init __alloc_bootmem_low_node(pg_data_t *pg=
dat, unsigned long size,
> =A0 =A0 =A0 =A0if (ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ptr;
>
> - =A0 =A0 =A0 return =A0__alloc_memory_core_early(MAX_NUMNODES, size, ali=
gn,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goal, ARCH_=
LOW_ADDRESS_LIMIT);
> + =A0 =A0 =A0 ptr =3D __alloc_memory_core_early(MAX_NUMNODES, size, align=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goal, ARCH_LOW_ADDRESS_LIMIT);
> + =A0 =A0 =A0 if (ptr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ptr;
> +
> + =A0 =A0 =A0 printk(KERN_ALERT "bootmem alloc of %lu bytes failed!\n", s=
ize);
> + =A0 =A0 =A0 panic("Out of memory");
> + =A0 =A0 =A0 return NULL;
> =A0}

Acked-by: Yinghai Lu <yinghai@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
