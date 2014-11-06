Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3B717900015
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 07:31:18 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so1301455wib.17
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 04:31:17 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id ee10si9695254wib.21.2014.11.06.04.31.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 04:31:17 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id h11so1319429wiw.9
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 04:31:17 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: page_isolation: check pfn validity before access
In-Reply-To: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
References: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
Date: Thu, 06 Nov 2014 13:31:14 +0100
Message-ID: <xa1ta944ik8d.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, kamezawa.hiroyu@jp.fujitsu.com, 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Thu, Nov 06 2014, Weijie Yang <weijie.yang@samsung.com> wrote:
> In the undo path of start_isolate_page_range(), we need to check
> the pfn validity before access its page, or it will trigger an
> addressing exception if there is hole in the zone.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_isolation.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index d1473b2..3ddc8b3 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -137,8 +137,11 @@ int start_isolate_page_range(unsigned long start_pfn=
, unsigned long end_pfn,
>  undo:
>  	for (pfn =3D start_pfn;
>  	     pfn < undo_pfn;
> -	     pfn +=3D pageblock_nr_pages)
> -		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
> +	     pfn +=3D pageblock_nr_pages) {
> +		page =3D __first_valid_page(pfn, pageblock_nr_pages);
> +		if (page)
> +			unset_migratetype_isolate(page, migratetype);
> +	}
>=20=20
>  	return -EBUSY;
>  }
> --=20
> 1.7.0.4
>
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
