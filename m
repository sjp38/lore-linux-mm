Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B15C66B0089
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 22:57:06 -0400 (EDT)
Date: Mon, 25 Oct 2010 10:57:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-ID: <20101025025703.GA13858@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
 <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 10:40:17AM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 25 Oct 2010 10:47:31 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
> 
> > It's normal for isolate_lru_page() to fail at times. The failures are
> > typically temporal and may well go away when offline_pages() retries
> > the call. So it seems more reasonable to migrate as much as possible
> > to increase the chance of complete success in next retry.
> > 
> > This patch remove page_count() check and remove putback_lru_pages() and
> > call migrate_pages() regardless of not_managed to reduce failure as much
> > as possible.
> > 
> > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> 
> -EBUSY should be returned.

It does return -EBUSY when ALL pages cannot be isolated from LRU (or
is non-LRU pages at all). That means offline_pages() will repeat calls
to do_migrate_range() as fast as possible as long as it can make
progress.

Is that behavior good enough? It does need some comment for this
non-obvious return value. 

btw, the caller side code can be simplified (no behavior change).

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dd186c1..606d358 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -848,17 +848,13 @@ repeat:
 	pfn = scan_lru_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have page on LRU */
 		ret = do_migrate_range(pfn, end_pfn);
-		if (!ret) {
-			drain = 1;
-			goto repeat;
-		} else {
-			if (ret < 0)
-				if (--retry_max == 0)
-					goto failed_removal;
+		if (ret < 0) {
+			if (--retry_max <= 0)
+				goto failed_removal;
 			yield();
-			drain = 1;
-			goto repeat;
 		}
+		drain = 1;
+		goto repeat;
 	}
 	/* drain all zone's lru pagevec, this is asyncronous... */
 	lru_add_drain_all();

Thanks,
Fengguang

> > ---
> >  mm/memory_hotplug.c |   12 ------------
> >  1 files changed, 0 insertions(+), 12 deletions(-)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index a4cfcdc..b64cc9b 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -687,7 +687,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  	unsigned long pfn;
> >  	struct page *page;
> >  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> > -	int not_managed = 0;
> >  	int ret = 0;
> >  	LIST_HEAD(source);
> >  
> > @@ -709,10 +708,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  					    page_is_file_cache(page));
> >  
> >  		} else {
> > -			/* Becasue we don't have big zone->lock. we should
> > -			   check this again here. */
> > -			if (page_count(page))
> > -				not_managed++;
> >  #ifdef CONFIG_DEBUG_VM
> >  			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
> >  			       pfn);
> > @@ -720,13 +715,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  #endif
> >  		}
> >  	}
> > -	ret = -EBUSY;
> > -	if (not_managed) {
> > -		if (!list_empty(&source))
> > -			putback_lru_pages(&source);
> > -		goto out;
> > -	}
> > -	ret = 0;
> >  	if (list_empty(&source))
> >  		goto out;
> >  	/* this function returns # of failed pages */
> > -- 
> > 1.6.3.3
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
