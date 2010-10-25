Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9751B8D000B
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:28:30 -0400 (EDT)
Date: Mon, 25 Oct 2010 11:28:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-ID: <20101025032827.GA15933@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
 <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025025703.GA13858@localhost>
 <20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025120550.45745c3d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 11:05:50AM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 25 Oct 2010 10:57:03 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Mon, Oct 25, 2010 at 10:40:17AM +0800, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 25 Oct 2010 10:47:31 +0800
> > > Bob Liu <lliubbo@gmail.com> wrote:
> > > 
> > > > It's normal for isolate_lru_page() to fail at times. The failures are
> > > > typically temporal and may well go away when offline_pages() retries
> > > > the call. So it seems more reasonable to migrate as much as possible
> > > > to increase the chance of complete success in next retry.
> > > > 
> > > > This patch remove page_count() check and remove putback_lru_pages() and
> > > > call migrate_pages() regardless of not_managed to reduce failure as much
> > > > as possible.
> > > > 
> > > > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > > 
> > > -EBUSY should be returned.
> > 
> > It does return -EBUSY when ALL pages cannot be isolated from LRU (or
> > is non-LRU pages at all). That means offline_pages() will repeat calls
> > to do_migrate_range() as fast as possible as long as it can make
> > progress.
> > 
> I read the patch wrong ? "ret = -EBUSY" is dropped and "ret" will be
> 0 or just a return code of migrate_page().

        for () {
                ret = isolate_lru_page(page);
        }

        if (list_empty(&source))
                goto out;

out:
        return ret;

So do_migrate_range() will return -EBUSY if the last isolate_lru_page() returns
-EBUSY.

> 
> 
> 
> > Is that behavior good enough? It does need some comment for this
> > non-obvious return value. 
> > 
> > btw, the caller side code can be simplified (no behavior change).
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index dd186c1..606d358 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -848,17 +848,13 @@ repeat:
> >     pfn = scan_lru_pages(start_pfn, end_pfn);
> >     if (pfn) { /* We have page on LRU */
> >             ret = do_migrate_range(pfn, end_pfn);
> > -           if (!ret) {
> > -                   drain = 1;
> > -                   goto repeat;
> > -           } else {
> > -                   if (ret < 0)
> > -                           if (--retry_max == 0)
> > -                                   goto failed_removal;
> > +           if (ret < 0) {
> > +                   if (--retry_max <= 0)
> > +                           goto failed_removal;
> >                     yield();
> > -                   drain = 1;
> > -                   goto repeat;
> >             }
> > +           drain = 1;
> > +           goto repeat;
> >     }
> 
> This changes behavior.

Ah yes!
 
> This "ret" can be > 0 because migrate_page()'s return code is
> "Return: Number of pages not migrated or error code."
> 
> Then, 
> ret < 0  ===> maybe ebusy
> ret > 0  ===> some pages are not migrated. maybe PG_writeback or some
> ret == 0 ===> ok, all condition green. try next chunk soon.
> 
> Then, I added "yield()" and --retrym_max for !ret cases.

You are right, there is the "ret > 0, some pages are not migrated" case.
But I'm not sure it's PG_writeback pages, because migrate_pages() will wait on
writeback after pass 2.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
