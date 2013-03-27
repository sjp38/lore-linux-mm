Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 835DA8D0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 04:03:30 -0400 (EDT)
Date: Wed, 27 Mar 2013 17:03:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
Message-ID: <20130327080328.GE13897@blaptop>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
 <514A6282.8020406@linaro.org>
 <20130322060113.GA4802@blaptop>
 <514C8FB0.4060105@linaro.org>
 <20130325084217.GC2348@blaptop>
 <51523C9C.1010806@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51523C9C.1010806@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Minchan Kim <minchan.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Mar 26, 2013 at 05:26:04PM -0700, John Stultz wrote:
> On 03/25/2013 01:42 AM, Minchan Kim wrote:
> >On Fri, Mar 22, 2013 at 10:06:56AM -0700, John Stultz wrote:
> >>So, if I understand you properly, its more an issue of the the
> >>added cost of making the purged range non-volatile, and
> >>re-faulting in the pages if we purge them all, when we didn't
> >>actually have the memory pressure to warrant purging the entire
> >>range? Hrm. Ok, I can sort of see that. So if we do
> >>partial-purging, all the data in the range is invalid - since we
> >>don't know which pages in particular were purged, but the costs
> >>when marking the range non-volatile and the costs of
> >>over-writing the pages with the re-created data will be slightly
> >>cheaper.
> >It could be heavily cheaper with my experiment in this patchset.
> >Allocator could avoid minor fault from 105799867 to 9401.
> >
> >>I guess the other benefit is if you're using the SIGBUS semantics,
> >>you might luck out and not actually touch a purged page. Where as if
> >>the entire range is purged, the process will definitely hit the
> >>SIGBUS if its accessing the volatile data.
> >Yes. I guess that's why Taras liked it.
> >Quote from old version
> >"
> >4) Having a new system call makes it easier for userspace apps to
> >    detect kernels without this functionality.
> >
> >I really like the proposed interface. I like the suggestion of having
> >explicit FULL|PARTIAL_VOLATILE. Why not include PARTIAL_VOLATILE as a
> >required 3rd param in first version with expectation that
> >FULL_VOLATILE will be added later(and returning some not-supported error
> >in meantime)?
> >"
> 
> Thanks again for the clarifications on your though process here!
> 
> I'm currently trying to rework your patches so we can reuse this for
> file data as well as pure anonymous memory. The idea being that we
> add one level of indirection: a vrange_root structure, which manages
> the root of the rb interval tree as well as the lock. This
> vrange_root can then be included in the mm_struct as well as
> address_space structures depending on which type of memory we're
> dealing with. That way most of the same infrastructure can be used
> to manage per-mm volatile ranges as well as per-inode volatile
> ranges.

Yeb.

> 
> Sorting out how to handle vrange() calls that cross both anonymous
> and file vmas will be interesting, and may have some of the
> drawbacks of the vma based approach, but I think it will still be

Do you have any specific drawback examples?
I'd like to solve it if it is critical and I believe we shouldn't
do that for simpler implementation.

> simpler.  To start we may just be able to require that any vrange()
> calls don't cross vma types (possibly using separate syscalls for
> file and anonymous vranges).

I can't parse what's the problem you have a concern.
Why should we have separate syscall?

> 
> Anyway, that's my current thinkig. You can preview my current attempt here:
> http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/vrange-minchan
> 

I saw it roughly and it seems good to me.
I will review it in detail if you send formal patch. :)

Off-topic

Let's think another vrange usecase for file pages.
I'm thinking now it might be useful as hint interface for kernel.
As you know, we already have hint interface, madivse and fadvise.
But they are always heavy because kernel should spend a time
to handle all pages of the range so the cost is increased linearly
as range's size. Another problem is it doesn't consider system global
wide view. One example is that look at below.
Look at the http://permalink.gmane.org/gmane.linux.kernel.mm/95424
There were similar several trial long time ago but rejected because
it could change current behavior if the system call move pages into
inactive list without freeing pages instanlty.

Andrew also suggested it "let's create another advise rather than
replace old advise" for compatibility.

So the what I want is new interface but totally different system call
,vrange. Because I believe hint system call should be very cheap so that
many user can use it frequently. If user don't use it often,
kernel doesn't have any benefit, either.

The vrange system call could be cheap because we can move hot path
overhead to slow path(reclaim path). And we can define new behavior to
vrange so we could implement new idea freely.

I think it's good for system memory handling.
As you know well, there are several trial to handle memory management
in userspace. One of example is lowmemory notifier. Kernel just send
signal and user can free pages. Frankly speaking, I don't like that idea.
Because there are several factors to limit userspace daemon's bounded
reaction and could have false-positive alarm if system has streaming data,
mlocked pages or many dirty pages and so on.

Anyway, my point is that I'd like to control page reclaiming in only
kernel itself. For it, userspace can register their volatile or
reclaimable memory ranges to kernel and define to the threshold.
If kernel find memory is below threshold user defined, kernel can
reclaim every pages in registered range freely.

It means kernel has a ownership of page freeing. It makes system more
deterministic and not out-of-control.

So vrange system call's semantic is following as.

1. vrange for anonymous page -> Discard wthout swapout
2. vrange for file-backed page except shmem/tmpfs -> Discard without sync
3. vrange for shmem/tmpfs -> hole punching

It's just my two cents. ;-)

> Thanks so much again for your moving this work forward!

Thanks for your collaboration!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
