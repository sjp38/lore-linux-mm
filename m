Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 684DA6B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 06:23:57 -0400 (EDT)
Date: Fri, 22 Oct 2010 18:23:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Message-ID: <20101022102351.GA27014@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
 <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
 <20101021142534.GB9709@localhost>
 <AANLkTi=zJV52imMNHEhftsBdyL1-8W30+tpZpY_yaj_s@mail.gmail.com>
 <20101022032244.GA13018@localhost>
 <AANLkTinbKadf9FL1y86yUSzJeLN-M2mAqapGUNuC4gaJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinbKadf9FL1y86yUSzJeLN-M2mAqapGUNuC4gaJ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 04:41:40PM +0800, Bob Liu wrote:
> On Fri, Oct 22, 2010 at 11:22 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Fri, Oct 22, 2010 at 10:48:51AM +0800, Bob Liu wrote:
> >> On Thu, Oct 21, 2010 at 10:25 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> > On Thu, Oct 21, 2010 at 09:28:20PM +0800, Bob Liu wrote:
> >> >> If not_managed is true all pages will be putback to lru, so
> >> >> break the loop earlier to skip other pages isolate.
> >> >
> >> > It's good fix in itself. However it's normal for isolate_lru_page() to
> >> > fail at times (when there are active reclaimers). The failures are
> >> > typically temporal and may well go away when offline_pages() retries
> >> > the call. So it seems more reasonable to migrate as much as possible
> >> > to increase the chance of complete success in next retry.
> >> >
> >>
> >> Hi, Wu
> >>
> >> The original code will try to migrate pages as much as possible except
> >> page_count(page) is true.
> >> If page_count(page) is true, isolate more pages is mean-less, because
> >> all of them will
> >> be put back after the loop.
> >>
> >> Or maybe we can skip the page_count() check? A It seems unreasonable,
> >> if isolate one page failed and
> >> that page was in use why it needs to put back the whole isolated list?
> >
> > My suggestion was to keep the page_count() check and remove
> > putback_lru_pages() and call migrate_pages() regardless of
> > not_managed.
> >
> 
> If not_managed is no more used, page_count() will also meanless.

Ah yes!

> You mean patch like this:

That's it.

I guess the typical usage would be

        for each 128M block
                try to offline it
                if failed
                        break

So it makes sense to avoid failure as much as possible, since the
above process is virtually not revertible -- if we failed at the
10th 128M block, the pages in the first 9 blocks have already been
migrated. It helps little to avoid page migration inside the 10th
block. The best we can do is to ensure success as much as possible
once the memory offline process starts.

And it's nice to reduce some code :)

Thanks,
Fengguang

> ==
> @@ -687,7 +687,6 @@
>  	unsigned long pfn;
>  	struct page *page;
>  	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> -	int not_managed = 0;
>  	int ret = 0;
>  	LIST_HEAD(source);
> 
> @@ -709,10 +708,6 @@
>  					    page_is_file_cache(page));
> 
>  		} else {
> -			/* Becasue we don't have big zone->lock. we should
> -			   check this again here. */
> -			if (page_count(page))
> -				not_managed++;
>  #ifdef CONFIG_DEBUG_VM
>  			printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
>  			       pfn);
> @@ -720,12 +715,6 @@
>  #endif
>  		}
>  	}
> -	ret = -EBUSY;
> -	if (not_managed) {
> -		if (!list_empty(&source))
> -			putback_lru_pages(&source);
> -		goto out;
> -	}
>  	ret = 0;
>  	if (list_empty(&source))
>  		goto out;
> ==
> Thanks,
> 
> > Does that make sense for typical memory hot remove scenarios?
> > That will increase the possibility of success at the cost of some more
> > migrated pages in case memory offline fails.
> >
> > Thanks,
> > Fengguang
> >
> >> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >> >> ---
> >> >> A mm/memory_hotplug.c | A  10 ++++++----
> >> >> A 1 files changed, 6 insertions(+), 4 deletions(-)
> >> >>
> >> >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >> >> index d4e940a..4f72184 100644
> >> >> --- a/mm/memory_hotplug.c
> >> >> +++ b/mm/memory_hotplug.c
> >> >> @@ -709,15 +709,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  page_is_file_cache(page));
> >> >>
> >> >> A  A  A  A  A  A  A  } else {
> >> >> - A  A  A  A  A  A  A  A  A  A  /* Becasue we don't have big zone->lock. we should
> >> >> - A  A  A  A  A  A  A  A  A  A  A  A check this again here. */
> >> >> - A  A  A  A  A  A  A  A  A  A  if (page_count(page))
> >> >> - A  A  A  A  A  A  A  A  A  A  A  A  A  A  not_managed++;
> >> >> A #ifdef CONFIG_DEBUG_VM
> >> >> A  A  A  A  A  A  A  A  A  A  A  printk(KERN_ALERT "removing pfn %lx from LRU failed\n",
> >> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A pfn);
> >> >> A  A  A  A  A  A  A  A  A  A  A  dump_page(page);
> >> >> A #endif
> >> >> + A  A  A  A  A  A  A  A  A  A  /* Becasue we don't have big zone->lock. we should
> >> >> + A  A  A  A  A  A  A  A  A  A  A  A check this again here. */
> >> >> + A  A  A  A  A  A  A  A  A  A  if (page_count(page)) {
> >> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  not_managed++;
> >> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> >> >> + A  A  A  A  A  A  A  A  A  A  }
> >> >> A  A  A  A  A  A  A  }
> >> >> A  A  A  }
> >> >> A  A  A  ret = -EBUSY;
> >> >> --
> -- 
> Regards,
> --Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
