Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 544DA6B00E3
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 13:23:00 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so937407yhj.8
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 10:22:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE2FCFB.4040808@jp.fujitsu.com>
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com>
 <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com>
 <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
 <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com>
 <4FE2A937.6040701@kernel.org> <4FE2FCFB.4040808@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 21 Jun 2012 13:22:37 -0400
Message-ID: <CAHGf_=rZm8JhyQg_Fuovw3STR=bZBUpUvAXH2yYtNn0phjOU5g@mail.gmail.com>
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>
> Hm. I'm sorry if I couldn't chase the disucussion...Can I make summary ?
>
> As you shown, it seems to be not difficult to counting free pages under
> MIGRATE_ISOLATE.
> And we can know the zone contains MIGRATE_ISOLATE area or not by simple
> check.
> for example.
> =3D=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_pageblock_migratetype(page, MIGRATE_IS=
OLATE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0move_freepages_block(zone, page, MIGRATE_I=
SOLATE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zone->nr_isolated_areas++;
> =3D
>
> Then, the solution will be adding a function like following
> =3D
> u64 zone_nr_free_pages(struct zone *zone) {
> =A0 =A0 =A0 =A0unsigned long free_pages;
>
> =A0 =A0 =A0 =A0free_pages =3D zone_page_state(NR_FREE_PAGES);
> =A0 =A0 =A0 =A0if (unlikely(z->nr_isolated_areas)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0isolated =3D count_migrate_isolated_pages(=
zone);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_pages -=3D isolated;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return free_pages;
> }
> =3D
>
> Right ?

This represent my intention exactly. :)

> and... zone->all_unreclaimable is a different problem ?

Yes, all_unreclaimable derived livelock don't depend on memory hotplug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
