Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id ECADA6B008A
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:38:39 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Tue, 2 Oct 2012 18:38:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q92McZHL163800
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 18:38:36 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q92McXiP018004
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 16:38:35 -0600
Message-ID: <506B6CE0.1060800@linaro.org>
Date: Tue, 02 Oct 2012 15:38:24 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org> <20121002173928.2062004e@notabene.brown>
In-Reply-To: <20121002173928.2062004e@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>

On 10/02/2012 12:39 AM, NeilBrown wrote:
> On Fri, 28 Sep 2012 23:16:30 -0400 John Stultz <john.stultz@linaro.org> wrote:
>
>> After Kernel Summit and Plumbers, I wanted to consider all the various
>> side-discussions and try to summarize my current thoughts here along
>> with sending out my current implementation for review.
>>
>> Also: I'm going on four weeks of paternity leave in the very near
>> (but non-deterministic) future. So while I hope I still have time
>> for some discussion, I may have to deal with fussier complaints
>> then yours. :)  In any case, you'll have more time to chew on
>> the idea and come up with amazing suggestions. :)
>   I wonder if you are trying to please everyone and risking pleasing no-one?
>   Well, maybe not quite that extreme, but you can't please all the people all
>   the time.
So while I do agree that I won't be able to please everyone, especially 
when it comes to how this interface is implemented internally, I do want 
to make sure that the userland interface really does make sense and 
isn't limited by my own short-sightedness.  :)

>   For example, allowing sub-page volatile region seems to be above and beyond
>   the call of duty.  You cannot mmap sub-pages, so why should they be volatile?
Although if someone marked a page and a half as volatile, would it be 
reasonable to throw away the second half of that second page? That seems 
unexpected to me. So we're really only marking the whole pages specified 
as volatlie,  similar to how FALLOC_FL_PUNCH_HOLE behaves.

But if it happens that the adjacent range is also a partial page, we can 
coalesce them possibly into an purgable whole page. I think it makes 
sense, especially from a userland point of view and wasn't really 
complicated to add.

>   Similarly the suggestion of using madvise - while tempting - is probably a
>   minority interest and can probably be managed with library code.  I'm glad
>   you haven't pursued it.
For now I see this as a lower priority, but its something I'd like to 
investigate.  As depending on tmpfs has issues since there's no quota 
support, so having a user-writable tmpfs partition mounted is a DoS 
opening, especially on low-memory systems.

>   I think discarding whole ranges at a time is very sensible, and so merging
>   adjacent ranges is best avoided.  If you require page-aligned ranges this
>   becomes trivial - is that right?
True. If we avoid coalescing non-whole page ranges, keeping 
non-overlapping ranges independent is fairly easy.

But it is also easy to avoid coalescing in all cases except when 
multiple sub-page ranges can be coalesced together.

In other words, we mark whole page portions of the range as volatile, 
and keep the sub-page portions separate. So non-page aligned ranges 
would possibly consist of three independent ranges, with the middle one 
as the only one marked volatile. Should those non-whole-page ranges be 
adjacent to other non-whole-page ranges, they could be coalesced. Since 
the coalesced edge ranges would be marked volatile after the full range, 
we would also avoid puriging the edge pages that would invalidate two 
unpurged range.

Alternatively, we can never coalesce and only mark whole pages in single 
ranges as volatile. It doesn't really make it more complex.

But again, these are implementation details.

The main point is I think at the user-interface level, allowing userland 
to provide non-page aligned ranges is valid. What we do with those 
non-page aligned chunks is up to the kernel/implementation, but I think 
we should be conservative and be sure never to purge non-volatile data.

>   I wonder if the oldest page/oldest range issue can be defined way by
>   requiring apps the touch the first page in a range when they touch the range.
>   Then the age of a range is the age of the first page.  Non-initial pages
>   could even be kept off the free list .... though that might confuse NUMA
>   page reclaim if a range had pages from different nodes.
Not sure I followed this. Are you suggesting keeping non-initial ranges 
off the vmscan LRU lists entirely?

Another appraoch that was suggested that sounds similar is touching all 
the pages when we mark them as volatile, so they are all close to each 
other in the active/inactive list. Then when the vmscan 
shrink_lru_list() code runs it would purge the pages together (although 
it might only purge half a range if there wasn't the need for more 
memory).   But again, these page-based solutions have much higher 
algorithmic complexity (O(n) - with respect to pages marked) and overhead.


>   Application to non-tmpfs files seems very unclear and so probably best
>   avoided.
>   If I understand you correctly, then you have suggested both that a volatile
>   range would be a "lazy hole punch" and a "don't let this get written to disk
>   yet" flag.  It cannot really be both.  The former sounds like fallocate,
>   the latter like fadvise.
I don't think I see the exclusivity aspect. If we say "Dear kernel, you 
may punch a hole at this offset in this file whenever you want in the 
future" and then later say "Cancel my earlier hole punching request" 
(which the kernel can say "Sorry, too late")  it has very close 
semantics to what I'm describing with the abstract interface to volatile 
range.  Maybe the only subtlety with the hole-punching oriented 
worldview is that the kernel is smart enough not bother writing out any 
data that could be punched out in the future.

But maybe this is a sufficient subtlety to still warrant avoiding it.

>   I think the later sounds more like the general purpose of volatile ranges,
>   but I also suspect that some journalling filesystems might be uncomfortable
>   providing a guarantee like that.  So I would suggest firmly stating that it
>   is a tmpfs-only feature.  If someone wants something vaguely similar for
>   other filesystems, let them implement it separately.
I mostly agree, as I don't have the context to see how this could be 
useful to other filesystems.  So I'm limiting my functionality to tmpfs. 
However DaveC saw some value in allowing it to be extended to other 
filesystems, and I'm not opposed in seeing the same interface be used if 
the semantics are close enough.

 From Dave's earlier mail:

"Managing large scale disk caches have exactly the same problems of
determining what to evict and/or move to secondary storage when
space is low. Being able to mark ranges of files as "remove this
first" woulxp dbe very advantageous for pro-active mangement of ENOSPC
conditions in the cache...

And being able to do space-demand hole-punching for stuff like
managing VM images would be really cool. For example, the loopback
device uses hole punching to implement TRIM commands, so turning
those into VOLATILE ranges for background dispatch will speed those
operations up immensely and avoid silly same block "TRIM - write -
TRIM - write" cyclic hole-punch/allocation in the backing file.  KVM
could do the same for implementing TRIM on image based block
devices...

There's lots of things that can be done with a generic advisory,
asynchornous hole-punching interface."

Christoph also mentioned the concept would have some usefulness for 
persistent caches and I think xfsutils as well?

To me, it seems the dynamic is: fadvise is too wishy washy for anything 
that deals with persistent data on disk. Its more how the kernel memory 
management should manage file data.  Where as fallocate has stronger 
semantics for the behavior of what happens on disk.  So if this is 
really a tmpfs only feature, fadvise should be ok, but if it were ever 
to be useful for making actual changes to disk, fallocate would be better.

So just from that standpoint, fallocate might be a more flexible 
interface to use, since its really all the same for tmpfs.

But let me know if my read on things here is off.

>   The SIGBUS interface could have some merit if it really reduces overhead.  I
>   worry about app bugs that could result from the non-deterministic
>   behaviour.   A range could get unmapped while it is in use and testing for
>   the case of "get a SIGBUS half way though accessing something" would not
>   be straight forward (SIGBUS on first step of access should be easy).
>   I guess that is up to the app writer, but I have never liked anything about
>   the signal interface and encouraging further use doesn't feel wise.
Initially I didn't like the idea, but have warmed considerably to it. 
Mainly due to the concern that the constant unmark/access/mark pattern 
would be too much overhead, and having a lazy method will be much nicer 
for performance.  But yes, at the cost of additional complexity of 
handling the signal, marking the faulted address range as non-volatile, 
restoring the data and continuing.

The use case for Mozilla is where there are compressed library files on 
disk, which are decompressed into memory to reduce the io. Then the 
entire in-memory library can be marked volatile, and will be re-fetched 
as needed. Basically allowing for filesystem independent disk 
compression (and more importantly for them - reduced io).

Hopefully that provides some extra context. Thanks again for the words 
of wisdom here.  I do agree that at a certain point I will have to 
become less flexible, in order to push something upstream, but since 
interest in this work has been somewhat sporadic, I do want to make sure 
folks have at least a chance to "bend the sapling" this one last time. :)

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
