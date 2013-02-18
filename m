Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <512203C4.8010608@cn.fujitsu.com>
Date: Mon, 18 Feb 2013 18:34:44 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de>
In-Reply-To: <20130205115722.GF21389@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Mel,

See below.

On 02/05/2013 07:57 PM, Mel Gorman wrote:
> On Mon, Feb 04, 2013 at 04:06:24PM -0800, Andrew Morton wrote:
>> The ifdefs aren't really needed here and I encourage people to omit
>> them.  This keeps the header files looking neater and reduces the
>> chances of things later breaking because we forgot to update some
>> CONFIG_foo logic in a header file.  The downside is that errors will be
>> revealed at link time rather than at compile time, but that's a pretty
>> small cost.
>>
> 
> As an aside, if ifdefs *have* to be used then it often better to have a
> pattern like
> 
> #ifdef CONFIG_MEMORY_HOTREMOVE
> int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
> 		unsigned long start, int nr_pages, int write, int force,
> 		struct page **pages, struct vm_area_struct **vmas);
> #else
> static inline get_user_pages_non_movable(...)
> {
> 	get_user_pages(...)
> }
> #endif
> 
> It eliminates the need for #ifdefs in the C file that calls
> get_user_pages_non_movable().
Thanks for pointing out :)

>>> +
>>> +retry:
>>> +	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
>>> +				vmas);
>>
>> We should handle (ret < 0) here.  At present the function will silently
>> convert an error return into "return 0", which is bad.  The function
>> does appear to otherwise do the right thing if get_user_pages() failed,
>> but only due to good luck.
>>
> 
> A BUG_ON check if we retry more than once wouldn't hurt either. It requires
> a broken implementation of alloc_migrate_target() but someone might "fix"
> it and miss this.
Agree.

> 
> A minor aside, it would be nice if we exited at this point if there was
> no populated ZONE_MOVABLE in the system. There is a movable_zone global
> variable already. If it was forced to be MAX_NR_ZONES before the call to
> find_usable_zone_for_movable() in memory initialisation we should be able
> to make a cheap check for it here.
OK.

>>> +			if (!migrate_pre_flag) {
>>> +				if (migrate_prep())
>>> +					goto put_page;
> 
> CONFIG_MEMORY_HOTREMOVE depends on CONFIG_MIGRATION so this will never
> return failure. You could make this BUG_ON(migrate_prep()), remove this
> goto and the migrate_pre_flag check below becomes redundant.
Sorry, I don't quite catch on this. Without migrate_pre_flag, the BUG_ON() check
will call/check migrate_prep() every time we isolate a single page, do we have
to do so?
I mean that for a group of pages it's sufficient to call migrate_prep() only once.
There are some other migrate-relative codes using this scheme. 
So I get confused, do I miss something or the the performance cost is little? :(

> 
>>> +				migrate_pre_flag = 1;
>>> +			}
>>> +
>>> +			if (!isolate_lru_page(pages[i])) {
>>> +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
>>> +						 page_is_file_cache(pages[i]));
>>> +				list_add_tail(&pages[i]->lru, &pagelist);
>>> +			} else {
>>> +				isolate_err = 1;
>>> +				goto put_page;
>>> +			}
> 
> isolate_lru_page() takes the LRU lock every time. If
> get_user_pages_non_movable is used heavily then you may encounter lock
> contention problems. Batching this lock would be a separate patch and should
> not be necessary yet but you should at least comment on it as a reminder.
Farsighted, should improve it in the future.

> 
> I think that a goto could also have been avoided here if you used break. The
> i == ret check below would be false and it would just fall through.
> Overall the flow would be a bit easier to follow.
Yes, I noticed this before. I thought using goto could save some micro ops
(here is only the i == ret check) though lower the readability but still be clearly. 

Also there are some other place in current kernel facing such performance/readability 
race condition, but it seems that the developers prefer readability, why? While I
think performance is fatal to kernel..

> 
> Why list_add_tail()? I don't think it's wrong but it's unusual to see
> list_add_tail() when list_add() is enough.
Sorry, not intentional, just steal from other codes without thinking more ;-)

> 
>>> +		}
>>> +	}
>>> +
>>> +	/* All pages are non movable, we are done :) */
>>> +	if (i == ret && list_empty(&pagelist))
>>> +		return ret;
>>> +
>>> +put_page:
>>> +	/* Undo the effects of former get_user_pages(), we won't pin anything */
>>> +	for (i = 0; i < ret; i++)
>>> +		put_page(pages[i]);
>>> +
> 
> release_pages.
> 
> That comment is insufficient. There are non-obvious consequences to this
> logic. We are dropping pins on all pages regardless of what zone they
> are in. If the subsequent migration fails then we end up returning 0
> with no pages pinned. The user-visible effect is that io_setup() fails
> for non-obvious reasons. It will return EAGAIN to userspace which will be
> interpreted as "The specified nr_events exceeds the user's limit of available
> events.". The application will either fail or potentially infinite loop
> if the developer interpreted EAGAIN as "try again" as opposed to "this is
> a permanent failure".
Yes, I missed such things.

> 
> Is that deliberate? Is it really preferable that AIO can fail to setup
> and the application exit just in case we want to hot-remove memory later?
> Should a failed migration generate a WARN_ON at least?
> 
> I would think that it's better to WARN_ON_ONCE if migration fails but pin
> the pages as requested. If a future memory hot-remove operation fails
> then the warning will indicate why but applications will not fail as a
I'm so agree, I will keep the pin state alive and issue a WARN_ON_ONCE message
in such case.

> result. It's a little clumsy but the memory hot-remove failure message
> could list what applications have pinned the pages that cannot be removed
> so the administrator has the option of force-killing the application. It
> is possible to discover what application is pinning a page from userspace
> but it would involve an expensive search with /proc/kpagemap
> 
>>> +	if (migrate_pre_flag && !isolate_err) {
>>> +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
>>> +					false, MIGRATE_SYNC, MR_SYSCALL);
> 
> The conversion of alloc_migrate_target is a bit problematic. It strips
> the __GFP_MOVABLE flag and the consequence of this is that it converts
> those allocation requests to MIGRATE_UNMOVABLE. This potentially is a large
> number of pages, particularly if the number of get_user_pages_non_movable()
> increases for short-lived pins like direct IO.
Sorry, I don't quite understand here neither. If we use the following new 
migration allocation function as you said, the increasing number of 
get_user_pages_non_movable() will also lead to large numbers of MIGRATE_UNMOVABLE
pages. What's the difference, do I miss something?

> 
> One way around this is to add a high_zoneidx parameter to
> __alloc_pages_nodemask and rename it ____alloc_pages_nodemask, create a new
> inline function __alloc_pages_nodemask that passes in gfp_zone(gfp_mask)
> as the high_zoneidx and create a new migration allocation function that
> passes on ZONE_HIGHMEM as high_zoneidx. That would force the allocation to
> happen in a lower zone while still treating the allocation as MIGRATE_MOVABLE


On 02/05/2013 09:32 PM, Mel Gorman wrote:
> Credit to Michal Hocko for bringing this up but with the number of
> other issues I missed that this is also broken with respect to huge page
> handling. hugetlbfs pages will not be on the LRU so the isolation will mess
> up and the migration has to be handled differently.  Ordinarily hugetlbfs
> pages cannot be allocated from ZONE_MOVABLE but it is possible to configure
> it to be allowed via /proc/sys/vm/hugepages_treat_as_movable. If this
> encounters a hugetlbfs page, it'll just blow up.
> 
> The other is that this almost certainly broken for transhuge page
> handling. gup returns the head and tail pages and ordinarily this is ok
> because the caller only cares about the physical address. Migration will
> also split a hugepage if it receives it but you are potentially adding
> tail pages to a list here and then migrating them. The split of the first
> page will get very confused. I'm not exactly sure what the result will be
> but it won't be pretty.
> 
> Was THP enabled when this was tested? Was CONFIG_DEBUG_LIST enabled
> during testing?
Sorry, I hadn't considered THP and hugepage yet, I will deal such cases based on your 
comments later.

thanks a lot for your review :)
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
