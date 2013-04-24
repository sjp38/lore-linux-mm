Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1DE8F6B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 04:11:34 -0400 (EDT)
Date: Wed, 24 Apr 2013 17:11:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Summary of LSF-MM Volatile Ranges Discussion
Message-ID: <20130424081130.GA2978@blaptop>
References: <516EE256.2070303@linaro.org>
 <5175FBEB.4020809@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5175FBEB.4020809@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Rik van Riel <riel@redhat.com>, glommer@parallels.com, mhocko@suse.de

Hello John,

On Mon, Apr 22, 2013 at 08:11:39PM -0700, John Stultz wrote:
> Just wanted to send out this quick summary of the Volatile Ranges
> discussion at LSF-MM.
> 
> Again, this is my recollection and perspective of the discussion,
> and while I'm trying to also provide Minchan's perspective on some
> of the problems as best I can, there likely may be details that were
> misunderstood, or mis-remembered. So if I've gotten anything wrong,
> please step in and reply to correct me. :)

Sure. Thanks for your amazing summary!

> 
> 
> Prior to the discussion, I sent out some background and discussion
> plans which you can read here:
> http://permalink.gmane.org/gmane.linux.kernel.mm/98676
> 
> 
> First of all, we quickly reviewed the generalized use cases and
> proposed interfaces:
> 
> 1) madvise style interface:
> 	mvrange(start_addr, length, mode, flags, &purged)
> 
> 2) fadvise/fallocate style interface:
> 	fvrange(fd, start_off, length, mode, flags, &purged)
> 
> 
> Also noting (per the background summary) the desired semantics for
> volatile ranges on files is that the volatility is shared (just like
> the data is), thus we need to store that volatility off of the
> address_space. Thus only one process needs to mark the open file
> pages as volatile for them to be purged.
> 
> Where as with anonymous memory, we really want to store the
> volatility off of the mm_struct (in some way), and only if all the
> processes that map a page consider it volatile, do purging.
> 
> I tried to quickly describe the issue that as performance is a
> concern, we want the action of marking and umarking of volatile
> ranges to be as fast as possible. This is of particular concern to
> Minchan and his ebizzy test case, as taking the mmap_sem hurts
> performance too much.

FYI, the reason why it's a concern on anon-vrange is I'd like to use
vrange in userspace allocator instead of using madvise(DONTNEED)/munmap.
Userspace allocator should work well in multi-threaded environment
but if we hold mmap_sem in vrange system, its hurt concurrent page fault
when one of thread try to mmap.

> 
> However, this strong performance concern causes some complexity in
> the madvise style interface, as since a volatile range could cross
> both anonymous and file pages.
> 
> Particularly the question of "What happens if a user calls mvrange()
> over MMAP_SHARED file pages?". I think we should push that
> volatility down into the file volatility, but to do this we have to
> walk the vmas and take the mmap_sem, which hurts Minchan's use case
> too drastically.

True. it made the ebizzy performance hurt about 3 times AFAIRC.

> 
> Minchan had earlier proposed having a VOLATILE_ANON | VOLATILE_FILE
> | VOLATILE_BOTH mode flag, where we'd skip traversing the vmas in
> the VOLATILE_ANON case, just adding the range to the process. Where
> as VOLATILE_FILE or VOLATILE_BOTH we'd do the traversing.

Right.

> 
> However, there is still the problem of the case where someone marks
> VOLATILE_ANON on mapped file pages. In this case, I'd expect we'd
> report an error, however, in order to detect the error case, we'd
> have to still traverse the vmas (otherwise we can't know if the
> range covers files or not), which again would be too costly. And to
> me, Minchan's suggestion of not providing an error on this case,
> seemed a bit too unintuitive for a public interface.

Frankly speaking, I am not convinced that we should return error in
such case. Now I think vrange isn't related to vma. User can regard
some ranges of address space to volatile regardless of that it has
already mmaped vmas or not.

> 
> The morning of the discussion, I realized we could instead of
> thinking of volatility only on anonymous and file pages, we could
> instead think of volatility as shared or private, much as file
> mappings are.
> 
> This would allow for the same functional behavior of Minchan's
> VOLATILE_ANON vs VOLATILE_FILE modes, but instead we'd have
> VOLATILE_PRIVATE and VOLATILE_SHARED. And only in the
> VOLATILE_SHARED case would we need to traverse the VMAs in order to
> make sure that any file backed pages had the volatility added to
> their address_space. And private volatility on files would then not
> be considered an error mode, so we could avoid having to do the scan
> to validate the input.
> 
> Minchan seemed to be in agreement with this concept. Though when I
> asked for reactions from the folks in the room, it seemed to be
> mostly tepid agreement mixed maybe with a bit of confusion.

I am not strong against your suggestion.
But still, my preference is VOLATILE_[ANON|FILE] rather than
MMAP_[PRIVATE|SHARED] because it's looks straight forward
to me. Anyway, It's nothing really. :)

> 
> One issue raised was the concern that by keeping the
> private/anonymous volatility state separately from the VMAs might
> cause cases where things got "out-of-sync". For instance, if a range
> is marked volatile, then say some pages are unmapped or a hole is
> punched in that range and other pages are mapped in, what are the
> semantics of the resulting volatility? Is the volatility inherited
> to future ranges? The example was given of mlock, where a range can
> be locked, but should any new pages be mapped into that range, the
> new pages are not locked. In other words, only the pages mapped at
> that time are affected by the call to mlock.
> 
> Stumped by this, I agreed that was a fair critique we hadn't
> considered, and that the in current implementation any new mappings
> in an existing volatile range would be considered volatile, and that
> is inconsistent with existing precedent.

Honestly speaking, I did consider it and concluded current sematic is
more sane. For example, someone want to make big range with volatile
although there are not any mapped page in the range at the moment.
Then, he want to make new allocator based on the range with mmap(MMAP_FIXED)
so he can make new vma into the volatile range anytime and kernel can
purge them anytime. I couldn't image concrete exmaple at the moment
but it could give good flexibility to user and It's not bad for vrange
semantic which covers big ranges even mixed by anon + file.

We are creating new system call so we don't have to be tied with
another system call semantic strongly. Yeb. but at least, I hope we
can give some example which is useful in real usecases.

> 
> It was pointed out that we could also make sure that on any
> unmapping or new mapping that we clear the private/anonymous
> volatility, and that might keep things in sync. and still allowing
> for the fast non-vma traversing calls to mark and unmark voltile
> ranges. But we'll have to look into that.
> 
> It was also noted that vmas are specifically designed to manage
> ranges of memory, so it seemed maybe a bit duplicative to have a
> separate tree tracking volatile ranges. And again we discussed the
> performance impact of taking the mmap_sem and traversing the vmas,
> and how avoiding that is particularly important to Minchan's use
> case.
> 
> I also noted that one difficulty with the earlier approach that did
> use vmas was that for volatile ranges on files (ie: shared volatile
> mappings), there are no similar shared vma type structure for files.
> Thus its nice to be able to use the same volatile root structure to
> store volatile ranges on both the private per-process(well,
> per-mm_struct) and shared per-inode/address_space basis. Otherwise
> the code paths for anonymous and file volatility have to be
> significantly different, which would make it more complex to
> understand and maintain.

Fair enough.

> 
> At this point, it was asked if the shared-volatility semantics on
> the shared mapped file is actually desired. And if instead we could
> keep file volatility in the vmas, only purging should every process
> that maps that file agree that the page is volatile.
> 
> The problem with this, as I see it is that it is inconsistent with
> the semantics of shared mapped files. If a file is mapped by
> multiple processes, and zeros are written to that file by one
> processes, all the processes will see this change and they need to
> coordinate access if such a change would be problematic. In the case
> of volatility, when we purge pages, the kernel is in-effect doing
> this on-behalf of the process that marked the range volatile. It
> just is a delayed action and can be canceled (by the process that
> marks it volatile, or by any other process with that range mapped).
> I re-iterated the example of a large circular buffer in a shared
> file, which is initialized as entirely volatile. Then a producer
> process would mark a region after the head as non-volatile, then
> fill it with data. And a consumer process, then consumes data from
> the tail, and mark those consumed ranges as volatile.
> 
> It was pointed out that the same could maybe be done by both
> processes marking the entire range, except what is between the
> current head and tail as volatile each iteration. So while pages
> wouldn't be truly volatile right after they were consumed,
> eventually the producer would run (well, hopefully) and update its
> view of volatility so that it agreed with the consumer with respect
> to those pages.
> 
> I noted that first of all, the shared volatility is needed to match
> the Android ashmem semantics. So there's at least an existing user.
> And that while this method pointed out could be used, I still felt
> it is fairly awkward, and again inconsistent with how shared mapped
> files normally behave. After all, applications could "share" file
> data by coordinating such that they all writing the same data to
> their own private mapping, but that loses much of the usefulness of
> shared mappings (to be fair, I didn't have such a sharp example at
> the time of the discussion, but its the same point I rambled
> around). Thus I feel having shared volatility for file pages is
> similarly useful.

Agreed.

> 
> It was also asked about the volatility semantics would be for
> non-mapped files, given the fvrange() interface could be used there.
> In that case, I don't have a strong opinion. If mvrange can create
> shared volatile ranges on mmaped files, I'm fine leaving fvrange()
> out. There may be an in-kerenl equivalent of fvrange() to make it
> easier to support Android's ashmem, but volatility on non-mmapped
> files doesn't seem like it would be too useful to me. But I'd
> probably want to go with what would be least surprising to users.
> 
> It was hard to gauge the overall reaction in the room at this point.
> There was some assorted nodding by various folks who seemed to be
> following along and positive of the basic approach. There were also
> some less positive confused squinting that had me worried.
> 
> With time running low, Minchan reminded me that the shrinker was on
> the to-be-discussed list. Basically earlier versions of my patch
> used a shrinker to trigger range purging, and this was critiqued
> because shrinkers were numa-unaware, and might cause bad behavior
> where we might purge lots of ranges on a node that isn't under any
> memory pressure if one node is under pressure.  However, using
> normal LRU page eviction doesn't work for volatile ranges, as with
> swapless systems, we don't LRU age/evict anonymous memory.
> 
> Minchan's patch currently does two approaches, where it can use the
> normal LRU eviction to trigger purging, but it also uses a shrinker
> to force anonymous pages onto a page list which can then be evicted
> in vmscan. This allows purging of anonymous pages when swapless, but

Exactly speaking, not shrinker but uses kswapd hook. But I have a plan
to move it from kswapd to new kvrangd because kswapd is very fragile
these days so I'd like to keep kvranged until kswapd is very stable,
otherwise, we might maintain vranged without unifying with kswapd.

> also allows the normal eviction process to work.
> 
> This brought up lots of discussion around what the ideal method
> would be. Since because the marking and unmarking of pages as
> volatile has to be done quickly, so we cannot iterate over pages at
> mark/unmark time creating a new list. Aging and evicting all
> anonymous memory on swapless systems also seems wasteful.
> 
> Ideally, I think we'd purge pages from volatile ranges in the global
> LRU eviction order. This would hopefully avoid purging data when we
> see lots of single-use streaming data.
> 
> Minchan however seems to feel volatile data should be purged earlier
> then other pages, since they're a source of easily free-able memory
> (I've also argued for this in the past, but have since changed my
> mind). So he'd like a way to pruge pages earlier, and unfortunately
> the shrinker runs later then he'd like.

Why I consider that volatile pages are top candidate to reclaim is
if we don't support vrange system call, maybe users are likely to use
munmap or madvise(DONTNEED) instead of vrange. It means the pages
in the range were already freed if we don't give new vrange system call
so they were freed earlier other than pages like streaming data.

But I agree streaming data is more useless than volatile pages.
I will consider this part more and others really want to handle
volatile pages by normal LRU order, I can do it easily.

Another idea is if we makes sure some pages is really useless,
we can make new LRU list(aka, ezReclaimLRU) and put the pages
into the LRU list when some advise system call happens. Then,
reclaimer peek ezReclaimLRU list prio to purging volatile pages
and reclaim them first.

> 
> It was noted that there are now patches to make the shrinkers numa
> aware, so the older complains might be solvable. But still the issue
> of shrinkers having their own eviction logic separate from the
> global LRU is less then ideal to me.
> 
> It was past time, and there didn't seem to be much consensus or
> resolution on this issue, so we had to leave it there. That said,
> the volatile purging logic is up to the kernel, and can be tweaked
> as needed in the future, where as the basic interface semantics were
> more important to hash out, and I think I got mostly nodding on the
> majority of the interface issues.
> 
> Hopefully with the next patch iteration, we'll have things cleaned
> up a bit more and better unified between Minchn's and my approaches
> so further details can be concretely worked out on the list. It was
> also requested that a manpage document be provided with the next
> patch set, which I'll make a point to provide.

I think currently most important thing is how we define vrange sematic.
Expecially, the part "out-of-sync", we need agreement by top prioity.

> 
> Thanks so much to Minchan, Kosaki-san, Hugh, Michel, Johannes, Greg,
> Michal, Glauber, and everyone else for providing an active
> discussion and great feedback despite my likely over-caffeinated
> verbal wanderings.

John, I am looking forward to seeing our progression.
Thanks a million, again!


> 
> Thanks again,
> -john
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
