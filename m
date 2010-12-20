Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8A1F86B00B8
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 23:41:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK4fHBk031518
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 13:41:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49F9345DE55
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 13:41:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 239C145DE68
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 13:41:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A70FE08002
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 13:41:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6358E18005
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 13:41:16 +0900 (JST)
Date: Mon, 20 Dec 2010 13:35:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
Message-Id: <20101220133526.e075feb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=UfmZNfKWCisrs6ezzoWqpcwUOT5bs8LGwN7Rv@mail.gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
	<20101220112227.E566.A69D9226@jp.fujitsu.com>
	<20101220112733.064f2fe3.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=UfmZNfKWCisrs6ezzoWqpcwUOT5bs8LGwN7Rv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Dec 2010 11:58:50 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, Dec 20, 2010 at 11:27 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 20 Dec 2010 11:21:52 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >
> >> > This patch series changes remove_from_page_cache's page ref counting
> >> > rule. page cache ref count is decreased in remove_from_page_cache.
> >> > So we don't need call again in caller context.
> >> >
> >> > Cc: Nick Piggin <npiggin@suse.de>
> >> > Cc: Al Viro <viro@zeniv.linux.org.uk>
> >> > Cc: linux-mm@kvack.org
> >> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >> > ---
> >> > A mm/truncate.c | A  A 1 -
> >> > A 1 files changed, 0 insertions(+), 1 deletions(-)
> >> >
> >> > diff --git a/mm/truncate.c b/mm/truncate.c
> >> > index 9ee5673..8decb93 100644
> >> > --- a/mm/truncate.c
> >> > +++ b/mm/truncate.c
> >> > @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
> >> > A  A  A * calls cleancache_put_page (and note page->mapping is now NULL)
> >> > A  A  A */
> >> > A  A  cleancache_flush_page(mapping, page);
> >> > - A  page_cache_release(page); A  A  A  /* pagecache ref */
> >> > A  A  return 0;
> >>
> >> Do we _always_ have stable page reference here? IOW, I can assume
> >> cleancache_flush_page() doesn't cause NULL deref?
> >>
> > Hmm, my review was bad.
> >
> > I think cleancache_flush_page() here should eat (mapping, index) as argument
> > rather than "page".
> >
> > BTW, A I can't understand
> > ==
> > void __cleancache_flush_page(struct address_space *mapping, struct page *page)
> > {
> > A  A  A  A /* careful... page->mapping is NULL sometimes when this is called */
> > A  A  A  A int pool_id = mapping->host->i_sb->cleancache_poolid;
> > A  A  A  A struct cleancache_filekey key = { .u.key = { 0 } };
> > ==
> >
> > Why above is safe...
> > I think (mapping,index) should be passed instead of page.
> 
> I don't think current code isn't safe.
> 
> void __cleancache_flush_page(struct address_space *mapping, struct page *page)
> {
>         /* careful... page->mapping is NULL sometimes when this is called */
>         int pool_id = mapping->host->i_sb->cleancache_poolid;
>         struct cleancache_filekey key = { .u.key = { 0 } };
> 
>         if (pool_id >= 0) {
>                 VM_BUG_ON(!PageLocked(page));
> 
> it does check PageLocked. So caller should hold a page reference to
> prevent freeing ramined PG_locked
> If the caller doesn't hold a ref of page, I think it's BUG of caller.
> 
> In our case, caller calls truncate_complete_page have to make sure it, I think.
> 

Ah, my point is that this function trust page->index even if page->mapping is
reset to NULL. And I'm not sure that there are any race that an other thread
add a replacement page for (mapping, index) while a thread call this function.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
