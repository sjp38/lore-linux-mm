Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 1FB136B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 03:57:54 -0400 (EDT)
Date: Mon, 1 Apr 2013 16:57:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130401075750.GD26497@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <514A6282.8020406@linaro.org>
 <20130322060113.GA4802@blaptop>
 <514C8FB0.4060105@linaro.org>
 <20130325084217.GC2348@blaptop>
 <51523C9C.1010806@linaro.org>
 <20130327080328.GE13897@blaptop>
 <51562C3D.3060809@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51562C3D.3060809@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Minchan Kim <minchan.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 29, 2013 at 05:05:17PM -0700, John Stultz wrote:
> On 03/27/2013 01:03 AM, Minchan Kim wrote:
> >On Tue, Mar 26, 2013 at 05:26:04PM -0700, John Stultz wrote:
> >>Sorting out how to handle vrange() calls that cross both anonymous
> >>and file vmas will be interesting, and may have some of the
> >>drawbacks of the vma based approach, but I think it will still be
> >Do you have any specific drawback examples?
> >I'd like to solve it if it is critical and I believe we shouldn't
> >do that for simpler implementation.
> 
> My current thought is that we manage volatile memory on both a
> per-mm (for anonymous memory) and per-address_space (for file
> memory) basis.

First of all, I should have a dumb question because I didn't thought
about tmpfs usecase deeply as you had so I hope this stupid question
opens my eye.

I thought like this

1. vrange system call doesn't care about whether the range is anonymous or not.
2. Discarder(At the moment, kswapd hook or kvranged in the future,
   direct page reclaim) can parse whether a vma could be anonymous or file-backed
3. If a vma which in vrange is anonymous, it could discard a page
   rather than swapping out.
4. If a vma which in vrange is file-backed(ie, tmpfs), it could discard a page
   rather than swappint out. => It would be same effect punch hole.
   
Both 3 and 4 could be handled by rmap so it couldn't discard a page if anyone
mapped a page with non-volatile.

In this scenario, I can't imagine what kind of role per-address_space does.
So, my question is that why we need per-address space vrange management.

If I read you mind, are you considering fd-based system call,
not mmaped-address space approach to replace ashmem?

> 
> The down side, if we manage both file and anonymous volatile ranges
> with the same interface, we may have similar problems to the per-vma
> approach you were trying before. Specifically, if a single range
> covers both anonymous and file memory, we'll have to do a similar
> iterating over the different types of ranges, as we did with your
> earlier vma approach.

As I said earlier, I don't want to care about new range is anonymous
or file-backed on vrange system call context. It's just vrange then
could be handled properly later when memory pressure happens.

>
> This adds some complexity since with the single interval tree method
> in your current patch, we know we only have to allocate one
> additional range per insert/remove. So we can do that right off the
> bat, and return any enomem errors without having made any state
> changes. This is a nice quality to have.
> 
> Where as if we're iterating over different types of ranges, with
> possibly multiple trees (ie: different mmapped files), we don't know
> how many new ranges we may have to allocate, so we could fail half
> way which causes ambiguous results on the marking ranges
> non-volatile (since returning the error leaves the range possibly
> half-unmarked).

Maybe, I can understand your point after seeing your concern with more
concrete example. :)

> 
> 
> I'm still thinking it through, but that's my concern.
> 
> Some ways we can avoid this:
> 1) Require that any vrange() call not cross different types of memory.
> 2) Provide a different vrange call (fvrange?)to be used with file
> backed memory.
> 
> Any other thoughts?
> 
> 
> >>Anyway, that's my current thinkig. You can preview my current attempt here:
> >>http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/vrange-minchan
> >>
> >I saw it roughly and it seems good to me.
> >I will review it in detail if you send formal patch. :)
> Ok. I'm still working on some changes (been slow this week), but
> hope to have more to send your way next week.
> 
> >As you know well, there are several trial to handle memory management
> >in userspace. One of example is lowmemory notifier. Kernel just send
> >signal and user can free pages. Frankly speaking, I don't like that idea.
> >Because there are several factors to limit userspace daemon's bounded
> >reaction and could have false-positive alarm if system has streaming data,
> >mlocked pages or many dirty pages and so on.
> 
> True. However, I think that there are valid use cases lowmemory
> notification (Android's low-memory killer is one, where we're not
> just freeing pages, but killing processes), and I think both
> approaches have valid use.

Yeb. I didn't say userspace memory notifier is useless.
My point is userspace memory notifier could be very fragile by several
reasons so it works well if system has some freed memory, I mean it doesn't
work well if system has big memory pressure. In this case, it would be
better for kernel to reclaim pages rather than depending user's response.

Yeb. Of course, there is a trade-off there.
Kernel doesn't have enough knowledge rather than user space so kernel
would work with sub-optimal pages.
So my suggestion is that plaform can use lowmemory notifier
when system memory pressure is mild but when system memory pressure is
approaching OOM, kernel should reclaim them instantly and before that,
user can give a hint to kernel which range of the address space
is recovery-possible. And it could be another usecases of vrange.

> 
> >Anyway, my point is that I'd like to control page reclaiming in only
> >kernel itself. For it, userspace can register their volatile or
> >reclaimable memory ranges to kernel and define to the threshold.
> >If kernel find memory is below threshold user defined, kernel can
> >reclaim every pages in registered range freely.
> >
> >It means kernel has a ownership of page freeing. It makes system more
> >deterministic and not out-of-control.
> >
> >So vrange system call's semantic is following as.
> >
> >1. vrange for anonymous page -> Discard wthout swapout
> >2. vrange for file-backed page except shmem/tmpfs -> Discard without sync
> >3. vrange for shmem/tmpfs -> hole punching
> I think on non-shmem file backed pages (case #2) hole punching will
> be required as well. Though I'm not totally convinced volatile

What I mean to is let's use vrange system call instead of madvise/fadvise.
so for file-backed pages excpet shmem/tmpfs couldn't be discarded but just
could be reclaimed.

> ranges on non-tmpfs files actually makes sense (I still have yet to
> understand a use case).

1. The fadvise/madvise reclaim pages instantly if memory pressure doesn't happen.
2. It doesn't consider system-wide view but per-process's one
3. System call cost could be increased by range size of the system call.

vrange could recover above problems.

I'm not serious about this usecase but had just out of curiosity for how 
others think about it.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
