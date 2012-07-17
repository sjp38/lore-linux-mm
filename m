Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D134B6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:25:07 -0400 (EDT)
Received: by eekc50 with SMTP id c50so185125eek.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:25:06 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/4 v2] mm: fix return value in
 __alloc_contig_migrate_range()
References: <Yes> <1342528415-2291-1-git-send-email-js1304@gmail.com>
 <1342528415-2291-3-git-send-email-js1304@gmail.com>
Date: Tue, 17 Jul 2012 15:25:03 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.whld71os3l0zgt@mpn-glaptop>
In-Reply-To: <1342528415-2291-3-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Christoph
 Lameter <cl@linux.com>

On Tue, 17 Jul 2012 14:33:34 +0200, Joonsoo Kim <js1304@gmail.com> wrote=
:
> migrate_pages() would return positive value in some failure case,
> so 'ret > 0 ? 0 : ret' may be wrong.
> This fix it and remove one dead statement.

How about the following message:

------------------- >8 -------------------------------------------------=
--
migrate_pages() can return positive value while at the same time emptyin=
g
the list of pages it was called with.  Such situation means that it went=

through all the pages on the list some of which failed to be migrated.

If that happens, __alloc_contig_migrate_range()'s loop may finish withou=
t
"++tries =3D=3D 5" never being checked.  This in turn means that at the =
end
of the function, ret may have a positive value, which should be treated
as an error.

This patch changes __alloc_contig_migrate_range() so that the return
statement converts positive ret value into -EBUSY error.
------------------- >8 -------------------------------------------------=
--

> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>
> Acked-by: Christoph Lameter <cl@linux.com>

In fact, now that I look at it, I think that __alloc_contig_migrate_rang=
e()
should be changed even further.  I'll take a closer look at it and send
a patch (possibly through Marek ;) ).

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..02d4519 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5673,7 +5673,6 @@ static int __alloc_contig_migrate_range(unsigned=
 long start, unsigned long end)
>  			}
>  			tries =3D 0;
>  		} else if (++tries =3D=3D 5) {
> -			ret =3D ret < 0 ? ret : -EBUSY;
>  			break;
>  		}
>@@ -5683,7 +5682,7 @@ static int __alloc_contig_migrate_range(unsigned =
long start, unsigned long end)
>  	}
> 	putback_lru_pages(&cc.migratepages);
> -	return ret > 0 ? 0 : ret;
> +	return ret <=3D 0 ? ret : -EBUSY;
>  }
> /*


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
