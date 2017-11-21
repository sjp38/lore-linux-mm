Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A04AD6B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 09:20:14 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id v137so6992007qkb.3
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 06:20:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d20sor9911437qte.56.2017.11.21.06.20.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 06:20:13 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential leak
In-Reply-To: <20171120193930.23428-2-mike.kravetz@oracle.com>
References: <20171120193930.23428-1-mike.kravetz@oracle.com> <20171120193930.23428-2-mike.kravetz@oracle.com>
Date: Tue, 21 Nov 2017 15:20:09 +0100
Message-ID: <xa1tlgizk92e.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Mon, Nov 20 2017, Mike Kravetz wrote:
> If the call __alloc_contig_migrate_range() in alloc_contig_range
> returns -EBUSY, processing continues so that test_pages_isolated()
> is called where there is a tracepoint to identify the busy pages.
> However, it is possible for busy pages to become available between
> the calls to these two routines.  In this case, the range of pages
> may be allocated.   Unfortunately, the original return code (ret
> =3D=3D -EBUSY) is still set and returned to the caller.  Therefore,
> the caller believes the pages were not allocated and they are leaked.
>
> Update the return code with the value from test_pages_isolated().
>
> Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation f=
ailure")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77e4d3c5c57b..3605ca82fd29 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7632,10 +7632,10 @@ int alloc_contig_range(unsigned long start, unsig=
ned long end,
>  	}
>=20=20
>  	/* Make sure the range is really isolated. */
> -	if (test_pages_isolated(outer_start, end, false)) {
> +	ret =3D test_pages_isolated(outer_start, end, false);
> +	if (ret) {
>  		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>  			__func__, outer_start, end);
> -		ret =3D -EBUSY;
>  		goto done;
>  	}

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
