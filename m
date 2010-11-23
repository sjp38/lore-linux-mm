Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E7FF46B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:01:18 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN81GFd009190
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 17:01:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F2F645DE55
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:01:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF02045DD75
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:01:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0D271DB803C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:01:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 750141DB803B
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:01:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <AANLkTinZmv540r+EkjwUu6cd9c1u7qG9iR+pvp3YqZC1@mail.gmail.com>
References: <20101122143817.E242.A69D9226@jp.fujitsu.com> <AANLkTinZmv540r+EkjwUu6cd9c1u7qG9iR+pvp3YqZC1@mail.gmail.com>
Message-Id: <20101123165240.7BC2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 23 Nov 2010 17:01:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> Hi KOSAKI,
>=20
> 2010/11/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> >> By Other approach, app developer uses POSIX_FADV_DONTNEED.
> >> But it has a problem. If kernel meets page is writing
> >> during invalidate_mapping_pages, it can't work.
> >> It is very hard for application programmer to use it.
> >> Because they always have to sync data before calling
> >> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> >> be discardable. At last, they can't use deferred write of kernel
> >> so that they could see performance loss.
> >> (http://insights.oetiker.ch/linux/fadvise.html)
> >
> > If rsync use the above url patch, we don't need your patch.
> > fdatasync() + POSIX_FADV_DONTNEED should work fine.
>=20
> It works well. But it needs always fdatasync before calling fadvise.
> For small file, it hurt performance since we can't use the deferred write.

I doubt rsync need to call fdatasync. Why?

If rsync continue to do following loop, some POSIX_FADV_DONTNEED
may not drop some dirty pages. But they can be dropped at next loop's
POSIX_FADV_DONTNEED. Then, It doesn't make serious issue.

1) read
2) write
3) POSIX_FADV_DONTNEED
4) goto 1


Am I missing anything?


> > So, I think the core worth of previous PeterZ's patch is in readahead
> > based heuristics. I'm curious why you drop it.
> >
>=20
> In previous peter's patch, it couldn't move active page into inactive lis=
t.
> So it's not what i want and I think invalidation is stronger hint than
> the readahead heuristic.
> But if we need it, I will add it in my series. It can help reclaiming
> unnecessary inactive page asap.
> but before that, I hope we make sure fadvise works well enough.

I've got it.Yeah, 1) implement manual  oepration 2) add automatic heuristic=
=20
is right order. I think. we can easily test your one.



> >> In fact, invalidate is very big hint to reclaimer.
> >> It means we don't use the page any more. So let's move
> >> the writing page into inactive list's head.
> >
> > But, I agree this.
>=20
> Thank you.
>
> >> +static void __pagevec_lru_deactive(struct pagevec *pvec)
> >> +{
> >> + =A0 =A0 int i, lru, file;
> >> +
> >> + =A0 =A0 struct zone *zone =3D NULL;
> >> +
> >> + =A0 =A0 for (i =3D 0; i < pagevec_count(pvec); i++) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D pvec->pages[i];
> >> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *pagezone =3D page_zone(page);
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (pagezone !=3D zone) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_=
irq(&zone->lru_lock);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone =3D pagezone;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_loc=
k);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 }
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageLRU(page)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageActive(page)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 file =3D pag=
e_is_file_cache(page);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru =3D page=
_lru_base_type(page);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_page_fro=
m_lru_list(zone, page,
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 lru + LRU_ACTIVE);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageAct=
ive(page);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageRef=
erenced(page);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_page_to_=
lru_list(zone, page, lru);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_e=
vent(PGDEACTIVATE);
> >> +
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 update_page_=
reclaim_stat(zone, page, file, 0);
> >
> > When PageActive is unset, we need to change cgroup lru too.
>=20
> Doesn't add_page_to_lru_list/del_page_from_lru_list do it?

Grr, my fault. I've forgot to we changed add_page_to_lru_list.=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
