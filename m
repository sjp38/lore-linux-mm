Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0263B6B0122
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 14:56:50 -0500 (EST)
Received: by bkty12 with SMTP id y12so4386384bkt.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 11:56:49 -0800 (PST)
Message-ID: <4F3EB0FD.1060501@openvz.org>
Date: Fri, 17 Feb 2012 23:56:45 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock splitting
References: <20120215224221.22050.80605.stgit@zurg> <alpine.LSU.2.00.1202151815180.19722@eggly.anvils> <4F3C8B67.6090500@openvz.org> <alpine.LSU.2.00.1202161235430.2269@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202161235430.2269@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Thu, 16 Feb 2012, Konstantin Khlebnikov wrote:
>> Hugh Dickins wrote:
>>> On Thu, 16 Feb 2012, Konstantin Khlebnikov wrote:
>>>>
>>>> Finally, there appears some new locking primitives for decorating
>>>> lru_lock splitting logic.
>>>> Final patch actually splits zone->lru_lock into small per-book pieces.
>>>
>>> Well done, it looks like you've beaten me by a few days: my per-memcg
>>> per-zone locking patches are now split up and ready, except for the
>>> commit comments and performance numbers to support them.
>>
>> Heh, nice. How do you organize link from page to "book"?
>> My patchset still uses page_cgroup, and I afraid something broken in locking
>> around it.
>
> By page_cgroup, yes.  The locking is not straightforward; but was pretty
> much impossible in the days of PageCgroupAcctLRU, we had to get rid of
> that to move forward.

Hmm, my old rhe6-based code has no extra locking except spited lru-lock
and optimized resource counter. Though it does not account mapped pages for cgroup,
but it is not so easy and seems completely useless in real life.

>
> Given your encouragement below, I'm thinking to post my patchset once
> I've added in the patch comments, in a couple of days.  I won't wait
> to include any performance results, those will have to follow.
>
> So I'd rather work on those comments to the relevant patches,
> than try to go into it now without showing them.
>
>>
>>>
>>> Or perhaps what we've been doing is orthogonal: I've not glanced beyond
>>> your Subjects yet, but those do look very familiar from my own work -
>>> though we're still using "lruvec"s rather than "book"s.
>>
>> I think, good name is always good. "book" sounds much better than
>> "mem_cgroup_zone".
>
> "book" is fun, but I don't find it helpful: I prefer the current, more
> boring "lruvec".  I guess I place a higher value on a book than as just
> a bundle of pages, so hardly see the connection!
>
> If we were designing a new user interface paradigm, then "book" might
> be a great name for an object; but this is all just low-level mechanism.

In my patchset book contains all required information for reclaimer.
So, It not very low-level object, it much more than lru-vector.
Thus, I want to call it with a short single-word name.
It should not has a second meaning in the kernel, maybe "pile" =)
if you want to reserve "book" for something more delicious.

>
> I was a bit disappointed at how much of your patchset is merely renaming.
> I think it would be better if you cut back on that, then if you're really
> keen on the "book" naming, do that in a final "lruvec" to "book" patch
> that people can take or leave as they please.

There only one renaming patch, and it not so big.
Plus my "book", "pages_lru" and "pages_count" totally unique,
there no other things in the kernel with these names.
This is very is handy for grep-ing.

>
> (I was impressed to see that lwn.net already has a "Book review"
> headlining; but then it turned out not to be of your work ;)
>
> And disappointed it wasn't built on linux-next mm, so I had to revert the
> cleanups I've already got in there.  But you may well have been wise to
> post against a more stable upstream tree: linux-next shifts from day to
> day, and is not always good - I did a lot on rc2-next-20120210, that was
> a good tree, but rc3-next-20120210 had a number of issues (especially on
> PowerPC, even reverting Arjan's parallel cpu bringup).  I'll probably
> try moving on to tonight's, but don't know what to expect of it.

I work on top of current Linus tree. I'll rebase it to linux-next.

>
>> Plus I want to split mm and mem-cg as much as possible, like this done in
>> sched-grouping.
>> After my patchset there no links from "book" to "memcg", so now there can
>> exist books of
>> different nature. It would be nice to use this memory management not only for
>> cgroups.
>> For example, what do you think about per-struct-user memory controller,
>> "rt" prio memory group, which never pruned by "normal" prio memory group
>> users.
>> or per-session-id memory auto-grouping =)
>
> I'm not thinking of it at all - and probably not as interested in a forest
> of cgroups as you guys are.  But I don't see "lruvec" as any more tied to
> memcg than "book".
>

Actually, I'm not very interested in a cgroups too, they are very limited and bloated.
Currently here required simple and effective basis for inventing more intelligent
memory management. It must be automatic, and work without hundreds tuning handles.

>>
>>>
>>> Anyway, I should be well-placed to review what you've done, and had
>>> better switch away from my own patches to testing and reviewing yours
>>> now, checking if we've caught anything that you're missing.  Or maybe
>>> it'll be worth posting mine anyway, we'll see: I'll look to yours first.
>>
>> Competition is good. It would be nice to see your patches too, if they are as
>> ready as my.
>
> Thanks, I'll get on with them.
>
> It is very very striking, the extent to which we have done the same:
> with just args in a different order, or my page_relock_lruvec() versus
> your relock_page_book().  As if I'd stolen your patches and then made
> little mods to conceal the traces - I may need Ying to testify in a
> court of law that I didn't, I gave her a copy of what I had on Monday!
>
> (A lot of my cleanups, which converge with yours, were not in the rollup
> I posted on December 5th: they came about as I tried to turn that into a
> palatable series.)
>
> If you move to lruvec, or I to book, then it will be easier for people
> to compare the two.  I expect we'll find rather more difference once I
> get deeper in (but will concentrate on mine for the moment): probably
> when it comes to the locking, which was our whole motivation.
>
>>
>> I already found two bugs in my patchset:
>> in "mm: unify inactive_list_is_low()" NR_ACTIVE_* instead of LRU_ACTIVE_*
>> and in "mm: handle book relocks on lumpy reclaim" I forget locking in
>> isolate_lru_pages()
>> [ but with CONFIG_COMPACTION=y this branch never used, as I guess ]
>
> I included those LRU_ instead of NR_ changes in what I ran up last night;
> but didn't attempt to fix up your isolate_lru_pages() locking, and indeed
> very soon crashed there, after lots of list_del warnings.
>
> Yours are not the only patches I was testing in that tree, I tried to
> gather several other series which I should be reviewing if I ever have
> time: Kamezawa-san's page cgroup diet 6, Xiao Guangrong's 4 prio_tree
> cleanups, your 3 radix_tree changes, your 6 shmem changes, your 4 memcg
> miscellaneous, and then your 15 books.
>
> The tree before your final 15 did well under pressure, until I tried to
> rmdir one of the cgroups afterwards: then it crashed nastily, I'll have
> to bisect into that, probably either Kamezawa's or your memcg changes.
>
> The tree with your final 15 booted up fine, but very soon crashed under
> load: I don't think I'll spend more time on that for now, probably you
> need to work on your locking while I work on my descriptions.

Yeah, I found many bugs. Uptodate version there: there https://github.com/koct9i/linux
I'll send v2 to review after testing.

I invented more clear locking. It does not interacts with memcg magic,
and does not adds overhead, except one spin_unlock_wait(old_book->lru_lock) in mem_cgroup_move_account().

>
> Hugh
>
>>
>>>
>>>> All this code currently *completely untested*, but seems like it already
>>>> can work.
>>>
>>> Oh, perhaps I'm ahead of you after all :)
>>
>> Not exactly, I already wrote the same code more than half-year ago.
>> So, it wasn't absolutely fair competition from the start. =)
>>
>>>
>>>>
>>>> After that, there two options how manage struct book on mem-cgroup
>>>> create/destroy:
>>>> a) [ currently implemented ] allocate and release by rcu.
>>>>      Thus lock_page_book() will be protected with rcu_read_lock().
>>>> b) allocate and never release struct book, reuse them after rcu grace
>>>> period.
>>>>      It allows to avoid some rcu_read_lock()/rcu_read_unlock() calls on
>>>> hot paths.
>>>>
>>>>
>>>> Motivation:
>>>> I wrote the similar memory controller for our rhel6-based
>>>> openvz/virtuozzo kernel,
>>>> including splitted lru-locks and some other [patented LOL] cool stuff.
>>>> [ common descrioption without techical details:
>>>> http://wiki.openvz.org/VSwap ]
>>>> That kernel already in production and rather stable for a long time.
>>>>
>>>> ---
>>>>
>>>> Konstantin Khlebnikov (15):
>>>>         mm: rename struct lruvec into struct book
>>>>         mm: memory bookkeeping core
>>>>         mm: add book->pages_count
>>>>         mm: unify inactive_list_is_low()
>>>>         mm: add book->reclaim_stat
>>>>         mm: kill struct mem_cgroup_zone
>>>>         mm: move page-to-book translation upper
>>>>         mm: introduce book locking primitives
>>>>         mm: handle book relocks on lumpy reclaim
>>>>         mm: handle book relocks in compaction
>>>>         mm: handle book relock in memory controller
>>>>         mm: optimize books in update_page_reclaim_stat()
>>>>         mm: optimize books in pagevec_lru_move_fn()
>>>>         mm: optimize putback for 0-order reclaim
>>>>         mm: split zone->lru_lock
>>>>
>>>>
>>>>    include/linux/memcontrol.h |   52 -------
>>>>    include/linux/mm_inline.h  |  222 ++++++++++++++++++++++++++++-
>>>>    include/linux/mmzone.h     |   26 ++-
>>>>    include/linux/swap.h       |    2
>>>>    init/Kconfig               |    4 +
>>>>    mm/compaction.c            |   35 +++--
>>>>    mm/huge_memory.c           |   10 +
>>>>    mm/memcontrol.c            |  238 ++++++++++---------------------
>>>>    mm/page_alloc.c            |   20 ++-
>>>>    mm/swap.c                  |  128 ++++++-----------
>>>>    mm/vmscan.c                |  334
>>>> +++++++++++++++++++-------------------------
>>>>    11 files changed, 554 insertions(+), 517 deletions(-)
>>>
>>> That's a very familiar list of files to me!
>>>
>>> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
