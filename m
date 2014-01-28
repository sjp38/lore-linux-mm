Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 767F06B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 19:11:14 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so6343165pdj.22
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:11:14 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id k3si13211431pbb.144.2014.01.27.16.11.11
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 16:11:12 -0800 (PST)
Date: Tue, 28 Jan 2014 09:12:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140128001244.GB25066@bbox>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

Hey KOSAKI,

On Mon, Jan 27, 2014 at 05:23:17PM -0500, KOSAKI Motohiro wrote:
> Hi Minchan,
> 
> 
> On Thu, Jan 2, 2014 at 2:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hey all,
> >
> > Happy New Year!
> >
> > I know it's bad timing to send this unfamiliar large patchset for
> > review but hope there are some guys with freshed-brain in new year
> > all over the world. :)
> > And most important thing is that before I dive into lots of testing,
> > I'd like to make an agreement on design issues and others
> >
> > o Syscall interface
> > o Not bind with vma split/merge logic to prevent mmap_sem cost and
> > o Not bind with vma split/merge logic to avoid vm_area_struct memory
> >   footprint.
> > o Purging logic - when we trigger purging volatile pages to prevent
> >   working set and stop to prevent too excessive purging of volatile
> >   pages
> > o How to test
> >   Currently, we have a patched jemalloc allocator by Jason's help
> >   although it's not perfect and more rooms to be enhanced but IMO,
> >   it's enough to prove vrange-anonymous. The problem is that
> >   lack of benchmark for testing vrange-file side. I hope that
> >   Mozilla folks can help.
> >
> > So its been a while since the last release of the volatile ranges
> > patches, again. I and John have been busy with other things.
> > Still, we have been slowly chipping away at issues and differences
> > trying to get a patchset that we both agree on.
> >
> > There's still a few issues, but we figured any further polishing of
> > the patch series in private would be unproductive and it would be much
> > better to send the patches out for review and comment and get some wider
> > opinions.
> >
> > You could get full patchset by git
> >
> > git clone -b vrange-v10-rc5 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git
> 
> Brief comments.
> 
> - You should provide jemalloc patch too. Otherwise we cannot

I did. :) It seems you missed below in this description.
You could see it via following URL in Dhaval's test suite.

https://github.com/volatile-ranges-test/vranges-test/blob/master/0001-Implement-experimental-mvolatile-2-mnovolatile-2-sup.patch

Dhaval: Pz, could you merge patches John sent in your test suite?
        I just pinged you.

But KOSAKI, pz, don't focus on jemalloc's implementaion.
It's not how jemalloc uses volatile ranges efficiently but just
one of example how to use volatile ranges.
I think volatile ranges could be really useful for garbage collection
of custom allocators(ex, In-memory DB, JVM, Dalvik, v8) as well as
general allocators.

> understand what the your mesurement mean.

> - Your number only claimed the effectiveness anon vrange, but not file vrange.

Yes. It's really problem as I said.
>From the beginning, John Stultz wanted to promote vrange-file to replace
android's ashmem and when I heard usecase of vrange-file, it does make sense
to me so that's why I'd like to unify them in a same interface.

But the problem is lack of interesting from others and lack of time to
test/evaluate it. I'm not an expert of userspace so actually I need a bit
help from them who require the feature but at a moment,
but I don't know who really want or/and help it.

Even, Android folks didn't have any interest on vrange-file.
So, we might drop vrange-file part in this patchset if it's really headache.
But let's discuss further because still I believe it's valuable feature to
keep instead of dropping.

I want that drop of vrange-file is really last resort to make forward
progress of vrange-anon.

> - Still, Nobody likes file vrange. At least nobody said explicitly on
> the list. I don't ack file vrange part until
>   I fully convinced Pros/Cons. You need to persuade other MM guys if
> you really think anon vrange is not
>   sufficient. (Maybe LSF is the best place)
> - I wrote you need to put a mesurement current implementation vs
> VMA-based implementation at several
>   previous iteration. Because You claimed fast, but no number and you
> haven't yet. I guess the reason is

I did. :) Look at the number.
https://lkml.org/lkml/2013/10/8/63

The point is we need an mmap_sem's readside lock for vma handling(ex,
merge/split) and it's really bottlenect point for ebizzy which another
thread want to malloc(ie, mmap with new chunk requires mmap_sem's
write-side lock).

Additionally, some of user want to handle vrange fine-granularity(ex,
as worst case, PAGE_SIZE) so VMA handling would be really overhead
for us.

>   you don't have any access to large machine. If so, I'll offer it.
> Plz collaborate with us.

Yes, Yes, Yes. That's what I want and you're really proper person to
collaborate. Pz, ping me if you're ready. :)

> 
> Unfortunately, I'm very busy and I didn't have a chance to review your
> latest patch yet. But I'll finish it until
> mm summit. And, I'll show you guys how much this patch improve glibc malloc too.

Cool! It's really helpful for the work which I believe it's really
helpful feature for the Linux so I never want to drop this feature by just
lack of interesting of other MM guys who are very busy with NUMA/memcg stuff. :(

> 
> I and glibc folks agreed we push vrange into glibc malloc.
> 
> https://sourceware.org/ml/libc-alpha/2013-12/msg00343.html

Thanks for the info and recenlty ChromeOS people is looking into
volatile ranges so it seems there are so many interesting these days
so it would a good chance to make it work.

> 
> Even though, I still dislike some aspect of this patch. I'd like to

That's true I need an many comment from MM commmuity so your input would
be really helpful.

> discuss and make better design decision
> with you.

KOSAKI,
Thanks for the your interest and suggestion for collaborating suggestion.
 
> Thanks.
> 
> 
> >
> > In v10, there are some notable changes following as
> >
> > Whats new in v10:
> > * Fix several bugs and build break
> > * Add shmem_purge_page to correct purging shmem/tmpfs
> > * Replace slab shrinker with direct hooked reclaim path
> > * Optimize pte scanning by caching previous place
> > * Reorder patch and tidy up Cc-list
> > * Rebased on v3.12
> > * Add vrange-anon test with jemalloc in Dhaval's test suite
> >   - https://github.com/volatile-ranges-test/vranges-test
> >   so, you could test any application with vrange-patched jemalloc by
> >   LD_PRELOAD but please keep in mind that it's just a prototype to
> >   prove vrange syscall concept so it has more rooms to optimize.
> >   So, please do not compare it with another allocator.
> >
> > Whats new in v9:
> > * Updated to v3.11
> > * Added vrange purging logic to purge anonymous pages on
> >   swapless systems
> > * Added logic to allocate the vroot structure dynamically
> >   to avoid added overhead to mm and address_space structures
> > * Lots of minor tweaks, changes and cleanups
> >
> > Still TODO:
> > * Sort out better solution for clearing volatility on new mmaps
> >         - Minchan has a different approach here
> > * Agreement of systemcall interface
> > * Better discarding trigger policy to prevent working set evction
> > * Review, Review, Review.. Comment.
> > * A ton of test
> >
> > Feedback or thoughts here would be particularly helpful!
> >
> > Also, thanks to Dhaval for his maintaining and vastly improving
> > the volatile ranges test suite, which can be found here:
> > [1]     https://github.com/volatile-ranges-test/vranges-test
> >
> > These patches can also be pulled from git here:
> >     git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-v9
> >
> > We'd really welcome any feedback and comments on the patch series.
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
