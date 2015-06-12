Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A7A876B0089
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 06:18:11 -0400 (EDT)
Received: by wiga1 with SMTP id a1so12625077wig.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:18:11 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id h18si2541470wiw.84.2015.06.12.03.18.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 03:18:10 -0700 (PDT)
Received: by wgez8 with SMTP id z8so21401567wge.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 03:18:09 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 5/6] mm, compaction: skip compound pages by order in free scanner
In-Reply-To: <1433928754-966-6-git-send-email-vbabka@suse.cz>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-6-git-send-email-vbabka@suse.cz>
Date: Fri, 12 Jun 2015 12:18:07 +0200
Message-ID: <xa1tk2v9p6w0.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10 2015, Vlastimil Babka wrote:
> The compaction free scanner is looking for PageBuddy() pages and skipping=
 all
> others.  For large compound pages such as THP or hugetlbfs, we can save a=
 lot
> of iterations if we skip them at once using their compound_order(). This =
is
> generally unsafe and we can read a bogus value of order due to a race, bu=
t if
> we are careful, the only danger is skipping too much.
>
> When tested with stress-highalloc from mmtests on 4GB system with 1GB hug=
etlbfs
> pages, the vmstat compact_free_scanned count decreased by at least 15%.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e37d361..4a14084 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -437,6 +437,24 @@ static unsigned long isolate_freepages_block(struct =
compact_control *cc,
>=20=20
>  		if (!valid_page)
>  			valid_page =3D page;
> +
> +		/*
> +		 * For compound pages such as THP and hugetlbfs, we can save
> +		 * potentially a lot of iterations if we skip them at once.
> +		 * The check is racy, but we can consider only valid values
> +		 * and the only danger is skipping too much.
> +		 */
> +		if (PageCompound(page)) {
> +			unsigned int comp_order =3D compound_order(page);
> +
> +			if (comp_order > 0 && comp_order < MAX_ORDER) {

+			if (comp_order < MAX_ORDER) {

Might produce shorter/faster code.  Dunno.  Maybe.  So much
micro-optimisations.  Applies to the previous patch as well.

> +				blockpfn +=3D (1UL << comp_order) - 1;
> +				cursor +=3D (1UL << comp_order) - 1;
> +			}
> +
> +			goto isolate_fail;
> +		}
> +
>  		if (!PageBuddy(page))
>  			goto isolate_fail;
>=20=20
> @@ -496,6 +514,13 @@ isolate_fail:
>=20=20
>  	}
>=20=20
> +	/*
> +	 * There is a tiny chance that we have read bogus compound_order(),
> +	 * so be careful to not go outside of the pageblock.
> +	 */
> +	if (unlikely(blockpfn > end_pfn))
> +		blockpfn =3D end_pfn;
> +
>  	trace_mm_compaction_isolate_freepages(*start_pfn, blockpfn,
>  					nr_scanned, total_isolated);
>=20=20
> --=20
> 2.1.4
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
