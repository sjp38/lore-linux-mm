Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 34A236B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:12:33 -0500 (EST)
Received: by iacb35 with SMTP id b35so8681053iac.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 05:12:32 -0800 (PST)
Message-ID: <4EEF3836.3040206@gmail.com>
Date: Mon, 19 Dec 2011 21:12:22 +0800
From: "nai.xia" <nai.xia@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: compaction: Determine if dirty pages can be
 migrated without blocking within ->migratepage
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-6-git-send-email-mgorman@suse.de> <20111216152054.f7445e98.akpm@linux-foundation.org> <20111219110551.GJ3487@suse.de>
In-Reply-To: <20111219110551.GJ3487@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2011a1'12ae??19ae?JPY 19:05, Mel Gorman wrote:
> On Fri, Dec 16, 2011 at 03:20:54PM -0800, Andrew Morton wrote:
>> On Wed, 14 Dec 2011 15:41:27 +0000
>> Mel Gorman<mgorman@suse.de>  wrote:
>>
>>> Asynchronous compaction is used when allocating transparent hugepages
>>> to avoid blocking for long periods of time. Due to reports of
>>> stalling, there was a debate on disabling synchronous compaction
>>> but this severely impacted allocation success rates. Part of the
>>> reason was that many dirty pages are skipped in asynchronous compaction
>>> by the following check;
>>>
>>> 	if (PageDirty(page)&&  !sync&&
>>> 		mapping->a_ops->migratepage != migrate_page)
>>> 			rc = -EBUSY;
>>>
>>> This skips over all mapping aops using buffer_migrate_page()
>>> even though it is possible to migrate some of these pages without
>>> blocking. This patch updates the ->migratepage callback with a "sync"
>>> parameter. It is the responsibility of the callback to fail gracefully
>>> if migration would block.
>>>
>>> ...
>>>
>>> @@ -259,6 +309,19 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>>>   	}
>>>
>>>   	/*
>>> +	 * In the async migration case of moving a page with buffers, lock the
>>> +	 * buffers using trylock before the mapping is moved. If the mapping
>>> +	 * was moved, we later failed to lock the buffers and could not move
>>> +	 * the mapping back due to an elevated page count, we would have to
>>> +	 * block waiting on other references to be dropped.
>>> +	 */
>>> +	if (!sync&&  head&&  !buffer_migrate_lock_buffers(head, sync)) {
>>
>> Once it has been established that "sync" is true, I find it clearer to
>> pass in plain old "true" to buffer_migrate_lock_buffers().  Minor point.
>>
>
> Later in the series, sync changes to "mode" to distinguish between
> async, sync-light and sync compaction. At that point, this becomes
>
>          if (mode == MIGRATE_ASYNC&&  head&&
>                          !buffer_migrate_lock_buffers(head, mode)) {
>
> Passing true in here would be fine, but it would just end up being
> changed back later in the series so it can be left alone.
>
>> I hadn't paid a lot of attention to buffer_migrate_page() before.
>> Scary function.  I'm rather worried about its interactions with ext3
>> journal commit which locks buffers then plays with them while leaving
>> the page unlocked.  How vigorously has this been whitebox-tested?
>>
>
> Blackbox testing only AFAIK. This has been tested recently with ext3
> and nothing unusual was reported. The list of events for migration
> looks like
>
> isolate page from LRU
>    migrate_pages
>      unmap_and_move
>        lock_page(src_page)
>        if page under writeback, either bail or wait on writeback
>        try_to_unmap
>        move_to_new_page
>        lock_page(dst_page)
>        buffer_migrate_page
>          migrate_page_move_mapping
>            spin_lock_irq(&mapping->tree_lock)
>            lookup in radix tree
>            check reference counts to make sure no one else has references
>            lock buffers if async mode
>            replace page in radix tree with new page
>            spin_unlock_irq
>          lock buffers if !async mode
>          copy buffers
>          unlock buffers
>        unlock_page(dst_page)
>
> The critical part is that the copying of buffer data is happening with
> both page and buffer locks held and no other references to the page
> exists - it has already been unmapped for example.
>
> Journal commit minimally acquires the buffer lock. If migration is
> in the process of copying the buffers, the buffer lock will prevent
> journal commit starting at the same time buffers are being copied.
>
> block_write_full_page and friends should be taking the buffer lock so
> they should also be ok.
>
> For other accessors, the mapping tree_lock should prevent other users
> looking up the page in the radix tree in the first place while the radix
> tree replacement is taking place.
>
> Racing against try_to_free_buffer should also be a problem.
> According to buffer.c, exclusion from try_to_free_buffer "may
> be obtained by either locking the page or holding the mappings
> private_lock". Migration is holding the page lock.
>
> Taking private_lock would give additional protection but I haven't heard
> or seen a case where it is necessary.
>

Make sure that it has no risk path by path is good. But maybe it's
time to make some explicit locking protocol here. I think the only possible
threat is that we changed buffer head ==> page relationship. Before
buffer_migrate_page()'s existence, the weak assumption of "if a bh is
valid then the page it is pointing to should also be valid, even without
locking" just held, although, like you said above, it seems not really exploited
by someone.

But this weak assumption is not true anymore. So maybe it's good to doc
explicitly like this:

     Anyone who wants to reference a page should either directly get_page or
     if you are going through the buffer heads to the page, you should take
     the buffer lock at least.

If there were really "gremlins" somewhere now or in the future, just burn
them under the supreme holy light of buffer locks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
