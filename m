Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DED2D6B009D
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:16:11 -0400 (EDT)
Date: Mon, 25 Oct 2010 11:16:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] do_migrate_range: avoid failure as much as possible
Message-ID: <20101025031608.GA15913@localhost>
References: <1287974851-4064-1-git-send-email-lliubbo@gmail.com>
 <20101025114017.86ee5e54.kamezawa.hiroyu@jp.fujitsu.com>
 <20101025025703.GA13858@localhost>
 <20101025030634.GA15386@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101025030634.GA15386@localhost>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 25, 2010 at 11:06:34AM +0800, Wu Fengguang wrote:
> On Mon, Oct 25, 2010 at 10:57:03AM +0800, Wu Fengguang wrote:
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
> >  	pfn = scan_lru_pages(start_pfn, end_pfn);
> >  	if (pfn) { /* We have page on LRU */
> >  		ret = do_migrate_range(pfn, end_pfn);
> > -		if (!ret) {
> > -			drain = 1;
> > -			goto repeat;
> > -		} else {
> > -			if (ret < 0)
> > -				if (--retry_max == 0)
> > -					goto failed_removal;
> > +		if (ret < 0) {
> > +			if (--retry_max <= 0)
> > +				goto failed_removal;
> >  			yield();
> > -			drain = 1;
> > -			goto repeat;
> >  		}
> > +		drain = 1;
> > +		goto repeat;
> >  	}
> >  	/* drain all zone's lru pagevec, this is asyncronous... */
> >  	lru_add_drain_all();
> 
> And it seems the costly drain operations could be avoided as long as
> it's making progress. What do you think?
> 
> --- linux-next.orig/mm/memory_hotplug.c	2010-10-25 11:04:05.000000000 +0800
> +++ linux-next/mm/memory_hotplug.c	2010-10-25 11:04:22.000000000 +0800
> @@ -852,8 +852,8 @@ repeat:
>  			if (--retry_max <= 0)
>  				goto failed_removal;
>  			yield();
> +			drain = 1;
>  		}
> -		drain = 1;
>  		goto repeat;
>  	}
>  	/* drain all zone's lru pagevec, this is asyncronous... */

This is a more heavy weight patch for the above one-liner change.
I don't have real experiences to understand the requirements for
memory hot remove, so the idea may be way too imaginary.

--- linux-next.orig/mm/memory_hotplug.c	2010-10-25 11:04:05.000000000 +0800
+++ linux-next/mm/memory_hotplug.c	2010-10-25 11:12:07.000000000 +0800
@@ -788,7 +788,7 @@ static int offline_pages(unsigned long s
 {
 	unsigned long pfn, nr_pages, expire;
 	long offlined_pages;
-	int ret, drain, retry_max, node;
+	int ret, retry_max, node;
 	struct zone *zone;
 	struct memory_notify arg;
 
@@ -827,7 +827,6 @@ static int offline_pages(unsigned long s
 
 	pfn = start_pfn;
 	expire = jiffies + timeout;
-	drain = 0;
 	retry_max = 5;
 repeat:
 	/* start memory hot removal */
@@ -838,13 +837,6 @@ repeat:
 	if (signal_pending(current))
 		goto failed_removal;
 	ret = 0;
-	if (drain) {
-		lru_add_drain_all();
-		flush_scheduled_work();
-		cond_resched();
-		drain_all_pages();
-	}
-
 	pfn = scan_lru_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have page on LRU */
 		ret = do_migrate_range(pfn, end_pfn);
@@ -852,15 +844,19 @@ repeat:
 			if (--retry_max <= 0)
 				goto failed_removal;
 			yield();
+			lru_add_drain_all();
+			flush_scheduled_work();
+			cond_resched();
+			drain_all_pages();
 		}
-		drain = 1;
 		goto repeat;
 	}
-	/* drain all zone's lru pagevec, this is asyncronous... */
+
+	/* drain all zone's lru pagevec, this is asynchronous... */
 	lru_add_drain_all();
 	flush_scheduled_work();
 	yield();
-	/* drain pcp pages , this is synchrouns. */
+	/* drain pcp pages , this is asynchronous. */
 	drain_all_pages();
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
@@ -869,7 +865,7 @@ repeat:
 		goto failed_removal;
 	}
 	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
-	/* Ok, all of our target is islaoted.
+	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
