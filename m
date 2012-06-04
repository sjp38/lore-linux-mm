Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 8D2CD6B0069
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 21:27:00 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6799403pbb.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 18:26:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FCC0DB4.30106@kernel.org>
References: <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils>
 <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
 <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <20120603181548.GA306@redhat.com>
 <CA+55aFwZ5PsBLqM7K8vDQdbS3sf+vi3yeoWx6XKV=nF8k2r7DQ@mail.gmail.com>
 <20120603183139.GA1061@redhat.com> <20120603205332.GA5412@redhat.com>
 <alpine.LSU.2.00.1206031459450.15427@eggly.anvils> <CA+55aFz--XDSOConDoM2SO0Jpd78Dg4GsGP+Z0F+__JWz+6JoQ@mail.gmail.com>
 <4FCC0DB4.30106@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 3 Jun 2012 21:26:39 -0400
Message-ID: <CAHGf_=qVsqdsrfZw5xHOBboM5_eNFqWcBKjUyNXmAxNDNuuV_A@mail.gmail.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> Right. I missed that. I think we can use the page passed to rescue_unmova=
ble_pageblock.
> We make sure it's valid in isolate_freepages. So how about this?
>
> barrios@bbox:~/linux-2.6$ git diff
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4ac338a..7459ab5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -368,11 +368,11 @@ isolate_migratepages_range(struct zone *zone, struc=
t compact_control *cc,
> =A0static bool rescue_unmovable_pageblock(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0unsigned long pfn, start_pfn, end_pfn;
> - =A0 =A0 =A0 struct page *start_page, *end_page;
> + =A0 =A0 =A0 struct page *start_page, *end_page, *cursor_page;
>
> =A0 =A0 =A0 =A0pfn =3D page_to_pfn(page);
> =A0 =A0 =A0 =A0start_pfn =3D pfn & ~(pageblock_nr_pages - 1);
> - =A0 =A0 =A0 end_pfn =3D start_pfn + pageblock_nr_pages;
> + =A0 =A0 =A0 end_pfn =3D start_pfn + pageblock_nr_pages - 1;
>
> =A0 =A0 =A0 =A0start_page =3D pfn_to_page(start_pfn);
> =A0 =A0 =A0 =A0end_page =3D pfn_to_page(end_pfn);
> @@ -381,19 +381,19 @@ static bool rescue_unmovable_pageblock(struct page =
*page)
> =A0 =A0 =A0 =A0if (page_zone(start_page) !=3D page_zone(end_page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> - =A0 =A0 =A0 for (page =3D start_page, pfn =3D start_pfn; page < end_pag=
e; pfn++,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page++) {
> + =A0 =A0 =A0 for (cursor_page =3D start_page, pfn =3D start_pfn; cursor_=
page <=3D end_page; pfn++,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cursor_page++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!pfn_valid_within(pfn))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;

I guess  page_zone() should be used after pfn_valid_within(). Why can
we assume invalid
pfn return correct zone?


> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageBuddy(page)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order =3D page_order(pa=
ge);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageBuddy(cursor_page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order =3D page_order(cu=
rsor_page);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pfn +=3D (1 << order) - 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page +=3D (1 << order) - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cursor_page +=3D (1 << orde=
r) - 1;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (page_count(page) =3D=3D 0 || Pag=
eLRU(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (page_count(cursor_page) =3D=3D 0=
 || PageLRU(cursor_page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
