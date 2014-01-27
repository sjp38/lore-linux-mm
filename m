Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9271F6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:23:40 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so6254518pdj.25
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:23:40 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id eb3si13002510pbd.47.2014.01.27.14.23.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 14:23:39 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id wm4so7214094obc.13
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:23:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 27 Jan 2014 17:23:17 -0500
Message-ID: <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>

Hi Minchan,


On Thu, Jan 2, 2014 at 2:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hey all,
>
> Happy New Year!
>
> I know it's bad timing to send this unfamiliar large patchset for
> review but hope there are some guys with freshed-brain in new year
> all over the world. :)
> And most important thing is that before I dive into lots of testing,
> I'd like to make an agreement on design issues and others
>
> o Syscall interface
> o Not bind with vma split/merge logic to prevent mmap_sem cost and
> o Not bind with vma split/merge logic to avoid vm_area_struct memory
>   footprint.
> o Purging logic - when we trigger purging volatile pages to prevent
>   working set and stop to prevent too excessive purging of volatile
>   pages
> o How to test
>   Currently, we have a patched jemalloc allocator by Jason's help
>   although it's not perfect and more rooms to be enhanced but IMO,
>   it's enough to prove vrange-anonymous. The problem is that
>   lack of benchmark for testing vrange-file side. I hope that
>   Mozilla folks can help.
>
> So its been a while since the last release of the volatile ranges
> patches, again. I and John have been busy with other things.
> Still, we have been slowly chipping away at issues and differences
> trying to get a patchset that we both agree on.
>
> There's still a few issues, but we figured any further polishing of
> the patch series in private would be unproductive and it would be much
> better to send the patches out for review and comment and get some wider
> opinions.
>
> You could get full patchset by git
>
> git clone -b vrange-v10-rc5 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git

Brief comments.

- You should provide jemalloc patch too. Otherwise we cannot
understand what the your mesurement mean.
- Your number only claimed the effectiveness anon vrange, but not file vrange.
- Still, Nobody likes file vrange. At least nobody said explicitly on
the list. I don't ack file vrange part until
  I fully convinced Pros/Cons. You need to persuade other MM guys if
you really think anon vrange is not
  sufficient. (Maybe LSF is the best place)
- I wrote you need to put a mesurement current implementation vs
VMA-based implementation at several
  previous iteration. Because You claimed fast, but no number and you
haven't yet. I guess the reason is
  you don't have any access to large machine. If so, I'll offer it.
Plz collaborate with us.

Unfortunately, I'm very busy and I didn't have a chance to review your
latest patch yet. But I'll finish it until
mm summit. And, I'll show you guys how much this patch improve glibc malloc too.

I and glibc folks agreed we push vrange into glibc malloc.

https://sourceware.org/ml/libc-alpha/2013-12/msg00343.html

Even though, I still dislike some aspect of this patch. I'd like to
discuss and make better design decision
with you.

Thanks.


>
> In v10, there are some notable changes following as
>
> Whats new in v10:
> * Fix several bugs and build break
> * Add shmem_purge_page to correct purging shmem/tmpfs
> * Replace slab shrinker with direct hooked reclaim path
> * Optimize pte scanning by caching previous place
> * Reorder patch and tidy up Cc-list
> * Rebased on v3.12
> * Add vrange-anon test with jemalloc in Dhaval's test suite
>   - https://github.com/volatile-ranges-test/vranges-test
>   so, you could test any application with vrange-patched jemalloc by
>   LD_PRELOAD but please keep in mind that it's just a prototype to
>   prove vrange syscall concept so it has more rooms to optimize.
>   So, please do not compare it with another allocator.
>
> Whats new in v9:
> * Updated to v3.11
> * Added vrange purging logic to purge anonymous pages on
>   swapless systems
> * Added logic to allocate the vroot structure dynamically
>   to avoid added overhead to mm and address_space structures
> * Lots of minor tweaks, changes and cleanups
>
> Still TODO:
> * Sort out better solution for clearing volatility on new mmaps
>         - Minchan has a different approach here
> * Agreement of systemcall interface
> * Better discarding trigger policy to prevent working set evction
> * Review, Review, Review.. Comment.
> * A ton of test
>
> Feedback or thoughts here would be particularly helpful!
>
> Also, thanks to Dhaval for his maintaining and vastly improving
> the volatile ranges test suite, which can be found here:
> [1]     https://github.com/volatile-ranges-test/vranges-test
>
> These patches can also be pulled from git here:
>     git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-v9
>
> We'd really welcome any feedback and comments on the patch series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
