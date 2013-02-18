Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 18 Feb 2013 15:17:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130218151716.GL4365@suse.de>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130204160624.5c20a8a0.akpm@linux-foundation.org>
 <20130205115722.GF21389@suse.de>
 <512203C4.8010608@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <512203C4.8010608@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 18, 2013 at 06:34:44PM +0800, Lin Feng wrote:
> >>> +			if (!migrate_pre_flag) {
> >>> +				if (migrate_prep())
> >>> +					goto put_page;
> > 
> > CONFIG_MEMORY_HOTREMOVE depends on CONFIG_MIGRATION so this will never
> > return failure. You could make this BUG_ON(migrate_prep()), remove this
> > goto and the migrate_pre_flag check below becomes redundant.
> Sorry, I don't quite catch on this. Without migrate_pre_flag, the BUG_ON() check
> will call/check migrate_prep() every time we isolate a single page, do we have
> to do so?

I was referring to the migrate_pre_flag check further down and I'm not
suggesting it be removed from here as you do want to call migrate_prep()
only once. However, as it'll never return failure for any kernel
configuration that allows memory hot-remove, this goto can be
removed and the flow simplified.

> > 
> >>> +				migrate_pre_flag = 1;
> >>> +			}
> >>> +
> >>> +			if (!isolate_lru_page(pages[i])) {
> >>> +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
> >>> +						 page_is_file_cache(pages[i]));
> >>> +				list_add_tail(&pages[i]->lru, &pagelist);
> >>> +			} else {
> >>> +				isolate_err = 1;
> >>> +				goto put_page;
> >>> +			}
> > 
> > isolate_lru_page() takes the LRU lock every time. If
> > get_user_pages_non_movable is used heavily then you may encounter lock
> > contention problems. Batching this lock would be a separate patch and should
> > not be necessary yet but you should at least comment on it as a reminder.
> Farsighted, should improve it in the future.
> 
> > 
> > I think that a goto could also have been avoided here if you used break. The
> > i == ret check below would be false and it would just fall through.
> > Overall the flow would be a bit easier to follow.
> Yes, I noticed this before. I thought using goto could save some micro ops
> (here is only the i == ret check) though lower the readability but still be clearly. 
> 
> Also there are some other place in current kernel facing such performance/readability 
> race condition, but it seems that the developers prefer readability, why? While I
> think performance is fatal to kernel..
> 

Memory hot-remove and page migration are not performance critical paths.
For page migration, the cost will be likely dominated by the page copy but
it's also possible the cost will be dominated by locking. The difference
between a break and goto will not even be measurable.

> > <SNIP>
> >
> > result. It's a little clumsy but the memory hot-remove failure message
> > could list what applications have pinned the pages that cannot be removed
> > so the administrator has the option of force-killing the application. It
> > is possible to discover what application is pinning a page from userspace
> > but it would involve an expensive search with /proc/kpagemap
> > 
> >>> +	if (migrate_pre_flag && !isolate_err) {
> >>> +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
> >>> +					false, MIGRATE_SYNC, MR_SYSCALL);
> > 
> > The conversion of alloc_migrate_target is a bit problematic. It strips
> > the __GFP_MOVABLE flag and the consequence of this is that it converts
> > those allocation requests to MIGRATE_UNMOVABLE. This potentially is a large
> > number of pages, particularly if the number of get_user_pages_non_movable()
> > increases for short-lived pins like direct IO.
>
> Sorry, I don't quite understand here neither. If we use the following new 
> migration allocation function as you said, the increasing number of 
> get_user_pages_non_movable() will also lead to large numbers of MIGRATE_UNMOVABLE
> pages. What's the difference, do I miss something?
> 

The replacement function preserves the __GFP_MOVABLE flag. It cannot use
ZONE_MOVABLE but otherwise the newly allocated page will be grouped with
other movable pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
