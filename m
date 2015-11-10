Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B81406B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 11:05:15 -0500 (EST)
Received: by wmdw130 with SMTP id w130so77442897wmd.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:05:15 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id ci12si5308390wjb.148.2015.11.10.08.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 08:05:14 -0800 (PST)
Received: by wmvv187 with SMTP id v187so15386446wmv.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:05:14 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/3] mm/page_isolation: return last tested pfn rather than failure indicator
In-Reply-To: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 10 Nov 2015 17:05:12 +0100
Message-ID: <xa1tbnb1g7rb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Nov 09 2015, Joonsoo Kim wrote:
> This is preparation step to report test failed pfn in new tracepoint
> to analyze cma allocation failure problem. There is no functional change
> in this patch.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_isolation.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
>
> @@ -266,10 +264,11 @@ int test_pages_isolated(unsigned long start_pfn, un=
signed long end_pfn,
>  	/* Check all pages are free or marked as ISOLATED */
>  	zone =3D page_zone(page);
>  	spin_lock_irqsave(&zone->lock, flags);
> -	ret =3D __test_page_isolated_in_pageblock(start_pfn, end_pfn,
> +	pfn =3D __test_page_isolated_in_pageblock(start_pfn, end_pfn,
>  						skip_hwpoisoned_pages);
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -	return ret ? 0 : -EBUSY;
> +
> +	return (pfn < end_pfn) ? -EBUSY : 0;

Parens aren=E2=80=99t necessary.  No strong feelings.

>  }
>=20=20
>  struct page *alloc_migrate_target(struct page *page, unsigned long priva=
te,

--=20
Best regards,                                            _     _
.o. | Liege of Serenely Enlightened Majesty of         o' \,=3D./ `o
..o | Computer Science,  =E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=
=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=84  (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
