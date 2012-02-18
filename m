Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 385E76B013D
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 04:09:31 -0500 (EST)
Received: by bkty12 with SMTP id y12so4730595bkt.14
        for <linux-mm@kvack.org>; Sat, 18 Feb 2012 01:09:29 -0800 (PST)
Message-ID: <4F3F6AC5.8060908@openvz.org>
Date: Sat, 18 Feb 2012 13:09:25 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock splitting
References: <20120215224221.22050.80605.stgit@zurg>	<20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>	<4F3C9798.7050800@openvz.org>	<20120216172409.5fa18608.kamezawa.hiroyu@jp.fujitsu.com>	<4F3CE243.9050203@openvz.org> <20120217085431.80daa020.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120217085431.80daa020.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 16 Feb 2012 15:02:27 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> KAMEZAWA Hiroyuki wrote:
>>> On Thu, 16 Feb 2012 09:43:52 +0400
>>> Konstantin Khlebnikov<khlebnikov@openvz.org>   wrote:
>>>
>>>> KAMEZAWA Hiroyuki wrote:
>>>>> On Thu, 16 Feb 2012 02:57:04 +0400
>>>>> Konstantin Khlebnikov<khlebnikov@openvz.org>    wrote:
>>>
>>>>>> * optimize page to book translations, move it upper in the call stack,
>>>>>>      replace some struct zone arguments with struct book pointer.
>>>>>>
>>>>>
>>>>> a page->book transrater from patch 2/15
>>>>>
>>>>> +struct book *page_book(struct page *page)
>>>>> +{
>>>>> +	struct mem_cgroup_per_zone *mz;
>>>>> +	struct page_cgroup *pc;
>>>>> +
>>>>> +	if (mem_cgroup_disabled())
>>>>> +		return&page_zone(page)->book;
>>>>> +
>>>>> +	pc = lookup_page_cgroup(page);
>>>>> +	if (!PageCgroupUsed(pc))
>>>>> +		return&page_zone(page)->book;
>>>>> +	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>>>>> +	smp_rmb();
>>>>> +	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
>>>>> +			page_to_nid(page), page_zonenum(page));
>>>>> +	return&mz->book;
>>>>> +}
>>>>>
>>>>> What happens when pc->mem_cgroup is rewritten by move_account() ?
>>>>> Where is the guard for lockless access of this ?
>>>>
>>>> Initially this suppose to be protected with lru_lock, in final patch they are protected with rcu.
>>>
>>> Hmm, VM_BUG_ON(!PageLRU(page)) ?
>>
>> Where?
>>
>
> You said this is guarded by lru_lock. So, page should be on LRU.

Not exactly, in add_page_to_lru_list() it currenly not in lru =)

Plus we can race with lru-isolation, thus this BUG_ON invalid.
All callers must recheck PageLRU() after locking page->book->lru_lock.

My locking uses combination of PageLRU() RCU and small help from memcg code:

page -> book dereference protected with rcu, If we know that page has valid mem_cg pointer
we can pick it, lock, and recheck pointer in loop. If after that PageLRU is set it means we
successfully secured page in its LRU.

PageLRU() versus memcg change stability there guaranteed by spin_unlock_wait(old_book->lru_lock)
in mem_cgroup_move_account() between assigning new pointer and putting page back to new lru.
Otherwise some one can see PageLRU under old lru_lock, while page already putted into new lru under other lru_lock.

If we didn't know about page->book pointer validity (at isolation via pfn in compaction/lumpy reclaim)
we must check PageLRU() first, if it set page->book must be valid. And as usual, after lru locking
PageLRU must be rechecked. Whole operation is under one rcu-lock, it keep all valid pointers.

Plus memcg-destroy after rcu-greace period wait if lru_lock if locked before freeing this structure,
because all lock holder drops rcu-read-lock after securing lru-lock.

This scheme looks pretty simple and complete.

>
>
>
>>>
>>> move_account() overwrites pc->mem_cgroup with isolating page from LRU.
>>> but it doesn't take lru_lock.
>>
>> There three kinds of lock_page_book() users:
>> 1) caller want to catch page in LRU, it will lock either old or new book and
>>      recheck PageLRU() after locking, if page not it in LRU it don't touch anything.
>>      some of these functions has stable reference to page, some of them not.
>>    [ There actually exist small race, I knew about it, just forget to pick this chunk from old code. See below. ]
>> 2) page is isolated by caller, it want to put it back. book link is stable. no problems.
>> 3) page-release functions. page-counter is zero. no references -- no problems.
>>
>> race for 1)
>>
>> catcher					switcher
>>
>> 					# isolate
>> 					old_book = lock_page_book(page)
>> 					ClearPageLRU(page)
>> 					unlock_book(old_book)				
>> 					# charge
>> old_book = lock_page_book(page)		
>> 					# switch
>> 					page->book = new_book
>> 					# putback
>> 					lock_book(new_book)
>> 					SetPageLRU(page)
>> 					unlock_book(new_book)
>> if (PageLRU(page))
>> 	oops, page actually in new_book
>> unlock_book(old_book)
>>
>>
>> I'll protect "switch" phase with old_book lru-lock:
>>
> In linex-next, pc->mem_cgroup is modified only when Page is on LRU.

I hope, page is isolated before this modification? =)

>
> When we need to touch "book", if !PageLRU() ?

Never, but at isolation via-pfn we need check it carefully.

>
>
>> lock_book(old_book)
>> page->book = new_book
>> unlock_book(old_book)
>>
>> The other option is recheck in "catcher" page book after PageLRU()
>> maybe there exists some other variants.
>>
>>> BTW, what amount of perfomance benefit ?
>>
>> It depends, but usually lru_lock is very-very hot.
>> This lock splitting can be used without cgroups and containers,
>> now huge zones can be easily sliced into arbitrary pieces, for example one book per 256Mb.
>>
> I personally think reducing lock by pagevec works enough well.
> So, want to see perforamance on real machine with real apps.

I separate locking primitives into small set of static-inline functions,
thus we can switch locking scheme by config option. This works without extra overhead,
if there only one lock per zone some static-inline functions becomes lockless or empty.

There other problem with current per-cpu page vectors: after lru-lock splitting they will
drop and retake different locks more frequently.

Thus for optimal scalability these vectors should be splited too, or replaced with something.
For example, lru_add_pvecs can be replaced with per-book (lruvec) singly-linked list for pending
inserts with cmpxchg-based atomic splice-insert. In combination with pfn-based zone-book interleaving
(last patch at my github) it may be really faster than small percpu page vectors.
Adding page into this pending list actually does not require even elevating its refcount,
if it drop to zero and page still in pending list put_page can just commit this list into lru.

>
>
>>
>> According to my experience, one of complicated thing there is how to postpone "book" destroying
>> if some its pages are isolated. For example lumpy reclaim and memory compaction isolates pages
>> from several books. And they wants to put them back. Currently this can be broken, if someone removes
>> cgroup in wrong moment. There appears funny races with three players: catcher, switcher and destroyer.
>
> Thank you for pointing out. Hmm... it can happen ? Currently, at cgroup destroying,
> force_empty() works
>
>    1. find a page from LRU
>    2. remove it from LRU
>    3. move it or reclaim it (you said "switcher")
>    4. if res.usage != 0 goto 1.
>
> I think "4" will finally keep cgroup from being destroyed.

Ok, seems so.

>
>
>> This can be fixed with some extra reference-counting or some other sleepable synchronizing.
>> In my rhel6-based implementation I uses extra reference-counting, and it looks ugly. So I want to invent something better.
>> Other option is just never release books, reuse them after rcu grace period for rcu-list iterating.
>>
>
> Another reference counting is very very bad.

Ack)

>
>
>
> Thanks,
> -Kame
>
>
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
