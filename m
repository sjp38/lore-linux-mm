Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 17B4C6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 03:26:57 -0500 (EST)
Date: Mon, 29 Nov 2010 16:26:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2 2/3] move ClearPageReclaim
Message-ID: <20101129082651.GA26715@localhost>
References: <7b50614882592047dfd96f6ca2bb2d0baa8f5367.1290956059.git.minchan.kim@gmail.com>
 <c3b1c78f0e2eba5dfebda7c363c4274e649ab36a.1290956059.git.minchan.kim@gmail.com>
 <20101129072951.GA22803@localhost>
 <AANLkTikuriwJr-UZg9=WXXwLt-u3sywkzkpZFBV1C4Db@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikuriwJr-UZg9=WXXwLt-u3sywkzkpZFBV1C4Db@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 04:16:01PM +0800, Minchan Kim wrote:
> On Mon, Nov 29, 2010 at 4:29 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Sun, Nov 28, 2010 at 11:02:56PM +0800, Minchan Kim wrote:
> >> fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
> >> preventing fast reclaiming readahead marker page.
> >>
> >> In this series, PG_reclaim is used by invalidated page, too.
> >> If VM find the page is invalidated and it's dirty, it sets PG_reclaim
> >> to reclaim asap. Then, when the dirty page will be writeback,
> >> clear_page_dirty_for_io will clear PG_reclaim unconditionally.
> >> It disturbs this serie's goal.
> >>
> >> I think it's okay to clear PG_readahead when the page is dirty, not
> >> writeback time. So this patch moves ClearPageReadahead.
> >> This patch needs Wu's opinion.
> >
> > It's a safe change. The possibility and consequence of races are both
> > small enough. However the patch could be simplified as follows?
> 
> If all of file systems use it, I don't mind it.
> Do all of filesystems use it when the page is dirtied?
> I was not sure it.(It's why I added Cc. :)
> If it doesn't have a problem, I hope so.

Please double check, but here is my findings:

__set_page_dirty_buffers() is called by several fs' ->set_page_dirty()
which are all called by set_page_dirty().

set_page_dirty_lock() will call set_page_dirty().

__set_page_dirty_no_writeback(): it have no connection to
end_page_writeback(), so no need to set PG_reclaim.

Thanks,
Fengguang


> > --- linux-next.orig/mm/page-writeback.c 2010-11-29 15:14:54.000000000 +0800
> > +++ linux-next/mm/page-writeback.c A  A  A 2010-11-29 15:15:02.000000000 +0800
> > @@ -1330,6 +1330,7 @@ int set_page_dirty(struct page *page)
> > A {
> > A  A  A  A struct address_space *mapping = page_mapping(page);
> >
> > + A  A  A  ClearPageReclaim(page);
> > A  A  A  A if (likely(mapping)) {
> > A  A  A  A  A  A  A  A int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
> > A #ifdef CONFIG_BLOCK
> > @@ -1387,7 +1388,6 @@ int clear_page_dirty_for_io(struct page
> >
> > A  A  A  A BUG_ON(!PageLocked(page));
> >
> > - A  A  A  ClearPageReclaim(page);
> > A  A  A  A if (mapping && mapping_cap_account_dirty(mapping)) {
> > A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  * Yes, Virginia, this is indeed insane.
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
