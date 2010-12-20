Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 850856B00B6
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 22:03:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK33ccV024087
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Dec 2010 12:03:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FE3245DE61
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 12:03:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AECE45DE63
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 12:03:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33ACDE08001
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 12:03:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E68E51DB8037
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 12:03:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
In-Reply-To: <AANLkTikOu6xUs3e_gEubidwSc_kQVuTKask+1WcCjzFs@mail.gmail.com>
References: <20101220113239.E56C.A69D9226@jp.fujitsu.com> <AANLkTikOu6xUs3e_gEubidwSc_kQVuTKask+1WcCjzFs@mail.gmail.com>
Message-Id: <20101220120218.E56F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 20 Dec 2010 12:03:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

> On Mon, Dec 20, 2010 at 11:32 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Mon, Dec 20, 2010 at 11:21 AM, KOSAKI Motohiro
> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >> This patch series changes remove_from_page_cache's page ref countin=
g
> >> >> rule. page cache ref count is decreased in remove_from_page_cache.
> >> >> So we don't need call again in caller context.
> >> >>
> >> >> Cc: Nick Piggin <npiggin@suse.de>
> >> >> Cc: Al Viro <viro@zeniv.linux.org.uk>
> >> >> Cc: linux-mm@kvack.org
> >> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> >> ---
> >> >> =A0mm/truncate.c | =A0 =A01 -
> >> >> =A01 files changed, 0 insertions(+), 1 deletions(-)
> >> >>
> >> >> diff --git a/mm/truncate.c b/mm/truncate.c
> >> >> index 9ee5673..8decb93 100644
> >> >> --- a/mm/truncate.c
> >> >> +++ b/mm/truncate.c
> >> >> @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *ma=
pping, struct page *page)
> >> >> =A0 =A0 =A0 =A0* calls cleancache_put_page (and note page->mapping =
is now NULL)
> >> >> =A0 =A0 =A0 =A0*/
> >> >> =A0 =A0 =A0 cleancache_flush_page(mapping, page);
> >> >> - =A0 =A0 page_cache_release(page); =A0 =A0 =A0 /* pagecache ref */
> >> >> =A0 =A0 =A0 return 0;
> >> >
> >> > Do we _always_ have stable page reference here? IOW, I can assume
> >>
> >> I think so.
> >> Because the page is locked so caller have to hold a ref to unlock it.
> >
> > Hmm...
> >
> > Perhaps, I'm missing something. But I think =A0__memory_failure() only =
lock
> > compaund_head page. not all. example.
>=20
> The page passed truncate_complete_page is only head page?
> Is it possible to pass the page which isn't head of compound in
> truncate_complete_page?

I dunno, really. My five miniture grep found following logic. therefore I a=
sked you.



__memory_failure()
{
        p =3D pfn_to_page(pfn);
        hpage =3D compound_head(p);
(snip)
        res =3D -EBUSY;
        for (ps =3D error_states;; ps++) {
                if ((p->flags & ps->mask) =3D=3D ps->res) {
                        res =3D page_action(ps, p, pfn);  // call truncate =
here
                        break;
                }
        }
out:
        unlock_page(hpage);
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
