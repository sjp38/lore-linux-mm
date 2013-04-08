Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 295B66B003B
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 20:46:42 -0400 (EDT)
Date: Mon, 8 Apr 2013 09:46:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 0/4] Support vranges on files
Message-ID: <20130408004638.GA6394@blaptop>
References: <1365033144-15156-1-git-send-email-john.stultz@linaro.org>
 <20130404065509.GE7675@blaptop>
 <515DBA70.8010606@linaro.org>
 <20130405075504.GA32126@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130405075504.GA32126@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

Hello John,

As you know, userland people wanted to handle vrange with mmaped
pointer rather than fd-based and see the SIGBUS so I thought more
about semantic of vrange and want to make it very clear and easy.
So I suggest below semantic(Of course, it's not rock solid).

        mvrange(start_addr, lengh, mode, behavior)

It's same with that I suggested lately but different name, just
adding prefix "m". It's per-process model(ie, mm_struct vrange)
so if process is exited, "volatility" isn't valid any more.
It isn't a problem in anonymous but could be in file-vrange so let's
introduce fvrange for covering the problem.

        fvrange(int fd, start_offset, length, mode, behavior)

First of all, let's see mvrange with anonymous and file page POV.

1) anon-mvrange

The page in volaitle range will be purged only if all of processes
marked the range as volatile.

If A process calls mvrange and is forked, vrange could be copied
from parent to child so not-yet-COWed pages could be purged
unless either one of both processes marks NO_VOLATILE explicitly.

Of course, COWed page could be purged easily because there is no link
any more.

2) file-mvrange

A page in volatile range will be purged only if all of processes mapped
the page marked it as volatile AND there is no process mapped the page
as "private". IOW, all of the process mapped the page should map it
with "shared" for purging.

So, all of processes should mark each address range in own process
context if they want to collaborate with shared mapped file and gaurantee
there is no process mapped the range with "private".

Of course, volatility state will be terminated as the process is gone.

3) fvrange

It's same with 2) but volatility state could be persistent in address_space
until someone calls fvrange(NO_VOLATILE).
So it could remove the weakness of 2).
 
What do you think about above semantic?

If you don't have any problem, we could implement it. I think 1) and 2) could
be handled with my base code for anon-vrange handling with tweaking
file-vrange and need your new patches in address_space for handling 3).

On Fri, Apr 05, 2013 at 04:55:04PM +0900, Minchan Kim wrote:
> Hi John,
> 
> On Thu, Apr 04, 2013 at 10:37:52AM -0700, John Stultz wrote:
> > On 04/03/2013 11:55 PM, Minchan Kim wrote:
> > >On Wed, Apr 03, 2013 at 04:52:19PM -0700, John Stultz wrote:
> > >>Next we introduce a parallel fvrange() syscall for creating
> > >>volatile ranges directly against files.
> > >Okay. It seems you want to replace ashmem interface with fvrange.
> > >I dobut we have to eat a slot for system call. Can't we add "int fd"
> > >in vrange systemcall without inventing new wheel?
> > 
> > Sure, that would be doable. I just added the new syscall to make the
> > differences in functionality clear.
> > Once the subtleties are understood, we can condense things down if
> > we think its best.
> 
> Fair enough.
> 
> > 
> > 
> > >>And finally, we change the range pruging logic to be able to
> > >>handle both anonymous and file volatile ranges.
> > >Okay. Then, what's the semantic file-vrange?
> > >
> > >There is a file F. Process A mapped some part of file into his
> > >address space. Then, Process B calls fvrange same part.
> > >As I looked over your code, it purges the range although process B
> > >is using now. Right? Is it your intention? Maybe isn't.
> > 
> > Not sure if you're example has a type-o and you meant "process A is
> > using it"?  If so, yes. The point is the volatility is shared and
> > consistent across all users of the file, in the same way the data in
> > the file is shared. If process B punched a hole in the file, process
> > A would see the effect immediately. With volatile ranges, the hole
> > punching is just delayed and possibly done later by the kernel, in
> > effect on behalf of process B, so the behavior is the same.
> > 
> > Consider the case where we could have two processes mmap a tmpfs
> > file in order to create a circular buffer shared between them. You
> > could then have a producer/consumer relationship with two processes
> > where any data not between the head & tail offsets were marked
> > volatile. The producer would mark tail+size non-volatile, write the
> > data, and update the tail offset. The consumer would read data from
> > the head offset, mark the just-read range as volatile, and update
> > the offset.
> > 
> > In this example, the producer would be the only process to mark data
> > non-volatile, while the consumer would be the only one marking
> > ranges volatile. Thus the state of volatility would need to be an
> > attribute of the file, not the process, in the same way the shared
> > data is.
> > 
> > Is that clear?
> 
> Yes, I got your point that you meant shared mapping.
> Let's enumerate more examples.
> 
> 1. Process A mapped FILE A with MAP_SHARED
>    Process B mapped FILE A with MAP_SHARED
>    Process C calls fvrange
>    Discard all pages of process A and B -> Make sense to me.
> 
> 2. Process A mapped FILE A with MAP_PRIVATE and is using it with read-only
>    Process B mapped FILE A with MAP_PRIVATE and is using it with write-only
>    Process C calls fvrange
> 
>    What does it happens? I expect process A lost all pages while process B
>    keeps COWed pages.
> 
> 3. Process A mapped FILE A with MAP_PRIVATE and is using it with read/write
>    Process C calls fvrange
> 
>    Some pages non-COWed in process A are lost while some pages COWed are kept.
>    Mixing.
> 
> Above all are your intention?
> It would be very clear if you should have wrote down semantic you intent
> about private mapped file and shared mapped file. ;-)
> 
> > 
> > 
> > 
> > >Let's define fvrange's semantic same with anon-vrange.
> > >If there is a process using range with non-volatile, at least,
> > >we shouldn't purge at all.
> > 
> > So this I'm not in agreement with.
> 
> I got your point.
> 
> > 
> > Anonymous pages are for the most part not shared, except via COW.
> > And for the COW case, yes, I agree, we shouldn't purge those pages.
> > 
> > Similarly (and I have yet to handle this in the code), for private
> > mapped files, those pages shouldn't be purged either (or purging
> > them shouldn't affect the private mapped pages - not sure which
> > direction to go here).
> 
> Yeb. It's questionable.
> It seems fallocate for punch hole removes non-COWed pages although
> they are mapped privately if I didn't miss something to read code.
> If I was right, it looks very strange to me. COWed pages remain
> in memory while NOT-YET-COWed pages are discarded. :(
> Ho, Hmm.
> 
> > 
> > But for shared mapped files, we need to keep the volatility state
> > shared as well.
> > 
> > 
> > >>Now there are some quirks still to be resolved with the approach
> > >>used here. The biggest one being the vrange() call can't be used to
> > >>create volatile ranges against mmapped files. Instead only the
> > >Why?
> > 
> > As explained above, the volatility is shared like the data. The
> > current vrange() code creates per-mm volatile ranges, which aren't
> > shared.
> 
> Strictly speaking, we can do it by only per-mm volatile range, I think.
> But the concern if we choose the approach is that what you mention in
> below is we have to iterate all process's mm_sturct to check in system
> call context. Of course, I don't like it and too bad design.
> 
> > 
> > 
> > >
> > >>fvrange() can be used to create file backed volatile ranges.
> > >I could't understand your point. It would be better to explain
> > >my thought firstly then, you could point out something I am missing
> > >now. Look below.
> > >
> > >>This could be overcome by iterating across all the process VMAs to
> > >>determine if they're anonymous or file based, and if file-based,
> > >>create a VMA sized volatile range on the mapping pointed to by the
> > >>VMA.
> > >It needs just when we start to discard pages. Simply, it is related
> > >to reclaim path, NOT system call path so it's not a problem.
> > 
> > The reason we can't defer this to only the reclaim path is if
> > volatile ranges on shared mappings are stored in the mm_struct, if
> > process A sets up a volatile range on a shared mapping, but stores
> > the volatility in its own mm, then process B wants to clear the
> > volatility on the range, process B would have to iterate over all
> > processes that have those file vmas mapped and change them.
> 
> Right. I think iterating all of relevant vmas isn't big cost
> in normal situation but it could be rather bigger when the memory
> pressure is severe, especially for file-backed pages because it's
> not even read/write lock.
> I'd like to minimize the system call overhead if possible.
> 
> > 
> > Additionally if process A sets up a volatile range on a shared
> > mapped file, then quits, the volatility state dies with that
> > process.
> 
> Yes, so don't you want to use vrange system call for mmaped-file
> range at the moment?
> 
> > 
> > Either way, its not just a simple matter of handling data on your
> > own mm_struct. That's fine for the process' own anonymous memory,
> > but doesn't work for shared file mappings.
> 
> Agreed.
> 
> > 
> > 
> > >
> > >>But this would have downsides, as Minchan has been clear that he wants
> > >>to optmize the vrange() calls so that it is very cheap to create and
> > >>destroy volatile ranges. Having simple per-process ranges be created
> > >>means we don't have to iterate across the vmas in the range to
> > >>determine if they're anonymous or file backed. Instead the current
> > >>vrange() code just creates per process ranges (which may or may not
> > >>cover mmapped file data), but will only purge anonymous pages in
> > >>that range. This keeps the vrange() call cheap.
> > >Right.
> > >
> > >>Additionally, just creating or destroying a single range is very
> > >>simple to do, and requires a fixed amount of memory known up front.
> > >>Thus we can allocate needed data prior to making any modifications.
> > >>
> > >>But If we were to create a range that crosses anonymous and file
> > >>backed pages, it must create or destroy multiple per-process or
> > >>per-file ranges. This could require an unknown number of allocations,
> > >This is a part I can fail to parse your opinion.
> > 
> > So if we were in the vrange() code to iterate over all the VMAs in
> > the range, creating VMA sizes ranges on either the mm_struct or the
> > backing address_space where appropriate, its possible that we could
> > hit an ENOMEM half way through the operation. This would leaving the
> > range in an inconsistent state: partially marked, and potentially
> > causing us to lose the purged state on the subranges.
> > 
> > 
> > 
> > >
> > >>opening the possibility of getting an ENOMEM half-way through the
> > >>operation, leaving the volatile range partially created or destroyed.
> > >>
> > >>So to keep this simple for this first pass, for now we have two
> > >>syscalls for two types of volatile ranges.
> > >
> > >My idea is following as
> > >
> > >         vrange(fd, start, len, mode, behavior)
> > >
> > >A) fd = 0
> > 
> > Well we'd probably need to use -1 or something that would be an
> > invalid fd here.
> > 
> > And really, I think having separate interfaces might be good, just
> > as there are separate madvise() and fadvise() calls (and when all
> > this is done, we may need to re-visit the new syscall vs new
> > madvise/fadvise flags decision).
> 
> It does make sense in this phase where we are still RFC.
> 
> > 
> > >
> > >1) system call context - vrange system call registers new vrange
> > >    in mm_struct.
> > >2) Add new vrange into LRU
> > >3) reclaim context - walk with rmap to confirm all processes make
> > >    the range with volatile -> discard
> > >
> > >B) fd = 1
> > The fd would just need to be valid right, not 1.
> > 
> > >1) system call context - vrange system call registers new vrange
> > >    in address_space
> > >2) Add new vrange into LRU
> > >3) reclaim context - walk with rmap to confirm all processes make
> > >    the range with volatile -> discard
> > >
> > >What's the problem in this logic?
> > 
> > The problem is only if in the first case, the volatile range being
> > created crosses over both anonymous and shared file mmap pages. In
> > that case we have to create appropriate sub-ranges on the mm_struct,
> > and sub-ranges on the address_space of the mmaped file.
> > 
> > This isn't impossible to do, but again, the handling of errors
> > mid-way through creating subranges is problematic (there may be yet
> > a way around it, I just haven't thought of it yet).
> 
> Fair enough.
> 
> > 
> > 
> > Thus with my patches, I simplified the problem a bit by partitioning
> > it into two separate problems and two separate interfaces: Volatile
> > ranges that are created by the vrange() call won't affect mmaped
> > pages, only anonymous pages. We may create a range that covers them,
> > but the volatility isn't shared with other processes and the purging
> > logic still skips file pages. If you want to to create a volatile
> > range on file pages, you have to use fvrange().
> 
> Okay, I got your intention by this paragraph.
> You don't want to handle file pages with vrange() and want to use
> fvrange for file pages. I don't oppose it but please write down
> why we did like you explained to me on above.
> It would make reviewers happier.
> 
> > 
> > Of course, my patchset has its own inconsistencies too, since if a
> > range is marked non-volatile that covers a mmapped file that has
> > been marked volatile, that volatility would persist. So I probably
> > should return an error if the vrange call covers any mmapped files.
> 
> Hmm, if you intend to separate anon and file with vrange and fvrange's
> separate data structure, it's no problem?
> 
> > 
> > 
> > Also, to be clear, I'm not saying that we *have* to partition these
> > operations into two separate behaviors, but I think having two
> > separate behaviors at first helps makes clear the subtleties of the
> > differences between them.
> 
> I got your point and I am thinking about that more.
> 
> > 
> > 
> > Let me know if any of this helps your understanding. :)
> 
> Thank you very much. John!
> 
> Looking forward to seeing you in SF.
> 
> > 
> > thanks
> > -john
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim
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
