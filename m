Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A0F86B00AE
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 21:32:18 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK2WFJQ010620
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Dec 2010 11:32:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDDDB45DE5F
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:32:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A428F45DE56
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:32:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93BD1E38009
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:32:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 60DF9E08003
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:32:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
In-Reply-To: <AANLkTimaW7X6w2e=4SvynHQHO-Kv3wXGv4_NCKDsuYRR@mail.gmail.com>
References: <20101220112227.E566.A69D9226@jp.fujitsu.com> <AANLkTimaW7X6w2e=4SvynHQHO-Kv3wXGv4_NCKDsuYRR@mail.gmail.com>
Message-Id: <20101220113239.E56C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 20 Dec 2010 11:32:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

> On Mon, Dec 20, 2010 at 11:21 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> This patch series changes remove_from_page_cache's page ref counting
> >> rule. page cache ref count is decreased in remove_from_page_cache.
> >> So we don't need call again in caller context.
> >>
> >> Cc: Nick Piggin <npiggin@suse.de>
> >> Cc: Al Viro <viro@zeniv.linux.org.uk>
> >> Cc: linux-mm@kvack.org
> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> ---
> >> =A0mm/truncate.c | =A0 =A01 -
> >> =A01 files changed, 0 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/truncate.c b/mm/truncate.c
> >> index 9ee5673..8decb93 100644
> >> --- a/mm/truncate.c
> >> +++ b/mm/truncate.c
> >> @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mappi=
ng, struct page *page)
> >> =A0 =A0 =A0 =A0* calls cleancache_put_page (and note page->mapping is =
now NULL)
> >> =A0 =A0 =A0 =A0*/
> >> =A0 =A0 =A0 cleancache_flush_page(mapping, page);
> >> - =A0 =A0 page_cache_release(page); =A0 =A0 =A0 /* pagecache ref */
> >> =A0 =A0 =A0 return 0;
> >
> > Do we _always_ have stable page reference here? IOW, I can assume
>=20
> I think so.
> Because the page is locked so caller have to hold a ref to unlock it.

Hmm...

Perhaps, I'm missing something. But I think  __memory_failure() only lock=
=20
compaund_head page. not all. example.

>=20
> > cleancache_flush_page() doesn't cause NULL deref?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
