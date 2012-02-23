Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9330C6B0092
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 09:44:31 -0500 (EST)
Received: by dadv6 with SMTP id v6so1615071dad.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 06:44:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120223135328.12988.87152.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135328.12988.87152.stgit@zurg>
Date: Thu, 23 Feb 2012 22:44:30 +0800
Message-ID: <CAJd=RBB8b_zpESue8_=A=oL1E6P8HDCyVYEPASH=1vq20nXLxA@mail.gmail.com>
Subject: Re: [PATCH v3 21/21] mm: zone lru vectors interleaving
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>

On Thu, Feb 23, 2012 at 9:53 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> @@ -4312,7 +4312,7 @@ void init_zone_lruvec(struct zone *zone, struct lru=
vec *lruvec)
> =C2=A0static void __paginginit free_area_init_core(struct pglist_data *pg=
dat,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long *zon=
es_size, unsigned long *zholes_size)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 enum zone_type j;
> + =C2=A0 =C2=A0 =C2=A0 enum zone_type j, lruvec_id;

Like other cases in the patch,

          int lruvec_id;

looks clearer

> =C2=A0 =C2=A0 =C2=A0 =C2=A0int nid =3D pgdat->node_id;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long zone_start_pfn =3D pgdat->node_s=
tart_pfn;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
> @@ -4374,7 +4374,8 @@ static void __paginginit free_area_init_core(struct=
 pglist_data *pgdat,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->zone_pgdat =
=3D pgdat;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_pcp_init(zone=
);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 init_zone_lruvec(zone,=
 &zone->lruvec);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_lruvec_id(lru=
vec_id)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 init_zone_lruvec(zone, &zone->lruvec[lruvec_id]);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zap_zone_vm_stats(=
zone);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone->flags =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
