Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 056C38D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 02:01:34 -0400 (EDT)
Received: by iwl42 with SMTP id 42so11324914iwl.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 23:01:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110323002536.GG5698@random.random>
References: <201103222153.p2MLrD0x029642@imap1.linux-foundation.org>
	<AANLkTi=1krqzHY1mg2T-k52C-VNruWsnXO33qS7BzeL+@mail.gmail.com>
	<20110323002536.GG5698@random.random>
Date: Wed, 23 Mar 2011 15:01:33 +0900
Message-ID: <AANLkTikdhswcngKzksQcxeY5U4Kku6N8Kf5HXqpy0LNK@mail.gmail.com>
Subject: Re: + mm-compaction-use-async-migration-for-__gfp_no_kswapd-and-enforce-no-writeback.patch
 added to -mm tree
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, arthur.marsh@internode.on.net, cladisch@googlemail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

On Wed, Mar 23, 2011 at 9:25 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Minchan,
>
> On Wed, Mar 23, 2011 at 07:58:24AM +0900, Minchan Kim wrote:
>> Hi Andrea,
>>
>> I didn't follow up USB stick freeze issue but the patch's concept
>> looks good to me. But there are some comments about this patch.
>>
>> 1. __GFP_NO_KSWAPD
>>
>> This patch is based on assumption that hugepage allocation have a good
>> fallback and now hugepage allocation uses __GFP_NO_KSWAPD.
>
> Yes, the only goal was to bypass kswapd. We don't want an overwork to
> try to generate those.
>
>> __GFP_NO_KSWAPD's goal is just prevent unnecessary wakeup kswapd and
>> only user is just thp now so I can understand why you use it but how
>> about __GFP_NORETRY?
>>
>> I think __GFP_NORETRY assume caller has a fallback mechanism(ex, SLUB)
>> and he think latency is important in such context.
>
> __GFP_NORETRY sounds the opposite of __GFP_REPEAT. So it gets a bit
> confusing as one would expect if you don't pass __GFP_REPEAT you're
> already in __GFP_NORETRY mode.
>
> OTOH it's like __GFP_NORETRY -> normal -> __GFP_REPEAT, so it wouldn't
> be wrong either. Where __GFP_REPEAT does it best at not failing even
> when the kernel stack allocation would have failed.
>
> Now before thinking further into this, we should probably ask Alex how
> thing goes if we undo the change to page_alloc.c so that
> __GFP_NO_KSWAPD will only affect kswapd like before (so without
> requiring a rename).

Okay. I will look at result.
If the problem happens again with reverted patch of page_alloc.c,
Don't we have to investigate further the problem happens with SLUB or
some driver's big memory allocation which is lower than 2M? We didn't
see the problem allocation under 2M but async migration's history was
short so we can't make sure it.

>
> It's possible that such change wasn't needed. The less things
> __GFP_NO_KSWAPD does and the closer THP allocations are to "default"
> high order allocations the better/simpler. Now that we solved the
> problem we can more easily refine these bits. __GFP_NO_KSWAPD is
> absolutely needed for frequent huge allocations especially with a
> kswapd that doesn't use compaction (and we found compaction in kswapd
> is detrimental even for small order allocations, so __GFP_NO_KSWAPD
> isn't going away too soon, but if we can make it again only specific
> to kswapd it's better). I ideally would like THP allocation not having
> to specify anything and the allocator to work just fine by itself.

Absolutely.

>
> __GFP_REPEAT is a magic needed for hugetlbfs to insist forever to be
> paranoid in trying to increase nr_hugepages with the highest possible
> effort no matter how much swapping or slowdown/hang it generates
> during the "echo". In the same way __GFP_NO_KSWAPD is to avoid
> interference with kswapd that can't use compaction without leading to
> too much wasted CPU yet. But the less stuff these bitflags do, the
> better.

Don't you want to add async migration for low order allocation like SLUB?
If you don't want to do async migration low order allocation, we can
add the check if (gfp_flags & __GFP_RETRY) && (order >= 9 or some
threshold) for async migration?

My point is to avoid implicit hidden meaning of __GFP_NO_KSWAPD
although __GFP_REPEAT already does it.

>
>> 2. LRU churn
>>
>> By this patch, async migration can't migrate dirty page of normal fs.
>> It can move the victim page to head of LRU. I hope we can reduce LRU
>> churning as possible. For it, we can do it when we isolate the LRU
>> pages.
>> If compaction mode is async, we can exclude the dirty pages in
>> isolate_migratepages.
>
> I've no trivial solution for the lru churning but, at least we're not
> making the lru churning any worse with this patch.

If async migration is going on and meet the dirty page, the patch can
return the -EBUSY so the page could put back to head of LRU but the
old migration can be going on although the page is dirty.

>
> I see your point that we could reduce the lru churning further after
> this patch, and that is cleaner if done as an incremental change
> considering it's a new improvement that become possible after the
> patch and it doesn't fix any regression.

Okay.

>
> To reduce it, we'd need to expose the migrate internal details to the
> compaction code. It's not good enough to just check PageDirty
> considering that dirty pages are migrated perfectly even when they're
> not anonymous with a page_mapping != 0, if ->migratepage is
> migrate_page (like for tmpfs/swapcache). So to optimize that, I guess
> we could add a can_migrate_async(page) to the migrate code, to call in
> the compaction loop. It should work.
>

Totally agree with you.
It's another topic and goes next time.

Thanks, Andrea.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
