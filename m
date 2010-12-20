Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 752D16B00B0
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 21:33:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK2XL79029465
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 11:33:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3393445DE5E
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:33:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16C6445DE58
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:33:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF14EE38001
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:33:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB28FE08001
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 11:33:20 +0900 (JST)
Date: Mon, 20 Dec 2010 11:27:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/5] truncate: Remove unnecessary page release
Message-Id: <20101220112733.064f2fe3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101220112227.E566.A69D9226@jp.fujitsu.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<02ab98b3a1450f7a1c31edc48ccc57e887cee900.1292604746.git.minchan.kim@gmail.com>
	<20101220112227.E566.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Dec 2010 11:21:52 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > This patch series changes remove_from_page_cache's page ref counting
> > rule. page cache ref count is decreased in remove_from_page_cache.
> > So we don't need call again in caller context.
> > 
> > Cc: Nick Piggin <npiggin@suse.de>
> > Cc: Al Viro <viro@zeniv.linux.org.uk>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/truncate.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index 9ee5673..8decb93 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -114,7 +114,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
> >  	 * calls cleancache_put_page (and note page->mapping is now NULL)
> >  	 */
> >  	cleancache_flush_page(mapping, page);
> > -	page_cache_release(page);	/* pagecache ref */
> >  	return 0;
> 
> Do we _always_ have stable page reference here? IOW, I can assume 
> cleancache_flush_page() doesn't cause NULL deref?
> 
Hmm, my review was bad.

I think cleancache_flush_page() here should eat (mapping, index) as argument
rather than "page".

BTW,  I can't understand
==
void __cleancache_flush_page(struct address_space *mapping, struct page *page)
{
        /* careful... page->mapping is NULL sometimes when this is called */
        int pool_id = mapping->host->i_sb->cleancache_poolid;
        struct cleancache_filekey key = { .u.key = { 0 } };
==

Why above is safe...
I think (mapping,index) should be passed instead of page.


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
