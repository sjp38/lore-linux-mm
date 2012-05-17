Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 57C7E6B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 16:23:36 -0400 (EDT)
Message-ID: <1337286204.4281.87.camel@twins>
Subject: Re: [PATCH] mm: Optimize put_mems_allowed() usage
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 17 May 2012 22:23:24 +0200
In-Reply-To: <20120517131610.d1b09fd8.akpm@linux-foundation.org>
References: <20120307180852.GE17697@suse.de>
	 <1332759384.16159.92.camel@twins> <20120326155027.GF16573@suse.de>
	 <1332778852.16159.138.camel@twins> <20120327124734.GH16573@suse.de>
	 <1332854070.16159.223.camel@twins>
	 <20120517131610.d1b09fd8.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 2012-05-17 at 13:16 -0700, Andrew Morton wrote:
> I do think it was a bad idea to remove that comment.  As it stands, the
> reader will be wondering why we did the read_mems_allowed_begin() at
> all, and whether failing to check for a change is a bug.
>=20
> --- a/mm/slub.c~mm-optimize-put_mems_allowed-usage-fix
> +++ a/mm/slub.c
> @@ -1624,8 +1624,16 @@ static struct page *get_any_partial(stru
>                         if (n && cpuset_zone_allowed_hardwall(zone, flags=
) &&
>                                         n->nr_partial > s->min_partial) {
>                                 object =3D get_partial_node(s, n, c);
> -                               if (object)
> +                               if (object) {
> +                                       /*
> +                                        * Don't check read_mems_allowed_=
retry()
> +                                        * here - if mems_allowed was upd=
ated in
> +                                        * parallel, that was a harmless =
race
> +                                        * between allocation and the cpu=
set
> +                                        * update
> +                                        */
>                                         return object;
> +                               }
>                         }
>                 }
>         } while (read_mems_allowed_retry(cpuset_mems_cookie));=20

OK, it seemed weird to have that comment in this one place whilst it is
the general pattern of this construct.

The whole read_mems_allowed_retry() should only ever be attempted in
case the allocation failed.

But sure..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
