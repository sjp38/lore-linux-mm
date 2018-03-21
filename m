Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2AA6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:37:15 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id e205so4151991qkb.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:37:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a8si2436768qtc.397.2018.03.21.16.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:37:14 -0700 (PDT)
Date: Wed, 21 Mar 2018 19:37:12 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
Message-ID: <20180321233711.GJ3214@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
 <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
 <20180321180342.GE3214@redhat.com>
 <788cf786-edbf-ab43-af0d-abbe9d538757@nvidia.com>
 <20180321224620.GH3214@redhat.com>
 <3f4e78a1-5a88-399d-e134-497229c42707@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3f4e78a1-5a88-399d-e134-497229c42707@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Wed, Mar 21, 2018 at 04:10:32PM -0700, John Hubbard wrote:
> On 03/21/2018 03:46 PM, Jerome Glisse wrote:
> > On Wed, Mar 21, 2018 at 03:16:04PM -0700, John Hubbard wrote:
> >> On 03/21/2018 11:03 AM, Jerome Glisse wrote:
> >>> On Tue, Mar 20, 2018 at 09:14:34PM -0700, John Hubbard wrote:
> >>>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> >>>>> From: Ralph Campbell <rcampbell@nvidia.com>

[...]

> >>> That is just illegal, the release callback is not allowed to trigger
> >>> invalidation all it does is kill all device's threads and stop device
> >>> page fault from happening. So there is no deadlock issues. I can re-
> >>> inforce the comment some more (see [1] for example on what it should
> >>> be).
> >>
> >> That rule is fine, and it is true that the .release callback will not 
> >> directly trigger any invalidations. However, the problem is in letting 
> >> any *existing* outstanding operations finish up. We have to let 
> >> existing operations "drain", in order to meet the requirement that 
> >> everything is done when .release returns.
> >>
> >> For example, if a device driver thread is in the middle of working through
> >> its fault buffer, it will call migrate_vma(), which will in turn unmap
> >> pages. That will cause an hmm_invalidate_range() callback, which tries
> >> to take hmm->mirrors_sems, and we deadlock.
> >>
> >> There's no way to "kill" such a thread while it's in the middle of
> >> migrate_vma(), you have to let it finish up.
> >>
> >>> Also it is illegal for the sync callback to trigger any mmu_notifier
> >>> callback. I thought this was obvious. The sync callback should only
> >>> update device page table and do _nothing else_. No way to make this
> >>> re-entrant.
> >>
> >> That is obvious, yes. I am not trying to say there is any problem with
> >> that rule. It's the "drain outstanding operations during .release", 
> >> above, that is the real problem.
> > 
> > Maybe just relax the release callback wording, it should stop any
> > more processing of fault buffer but not wait for it to finish. In
> > nouveau code i kill thing but i do not wait hence i don't deadlock.
> 
> But you may crash, because that approach allows .release to finish
> up, thus removing the mm entirely, out from under (for example)
> a migrate_vma call--or any other call that refers to the mm.

No you can not crash on mm as it will not vanish before you are done
with it as mm will not be freed before you call hmm_unregister() and
you should not call that from release, nor should you call it before
everything is flush. However vma struct might vanish ... i might have
assume wrongly about the down_write() always happening in exit_mmap()
This might be a solution to force serialization.


> 
> It doesn't seem too hard to avoid the problem, though: maybe we
> can just drop the lock while doing the mirror->ops->release callback.
> There are a few ways to do this, but one example is: 
> 
>     -- take the lock,
>         -- copy the list to a local list, deleting entries as you go,
>     -- drop the lock, 
>     -- iterate through the local list copy and 
>         -- issue the mirror->ops->release callbacks.
> 
> At this point, more items could have been added to the list, so repeat
> the above until the original list is empty. 
> 
> This is subject to a limited starvation case if mirror keep getting 
> registered, but I think we can ignore that, because it only lasts as long as 
> mirrors keep getting added, and then it finishes up.

The down_write is better solution and easier just 2 line of code.

> 
> > 
> > What matter is to stop any further processing. Yes some fault might
> > be in flight but they will serialize on various lock. 
> 
> Those faults in flight could already be at a point where they have taken
> whatever locks they need, so we don't dare let the mm get destroyed while
> such fault handling is in progress.

mm can not vanish until hmm_unregister() is call, vma will vanish before.

> So just do not
> > wait in the release callback, kill thing. I might have a bug where i
> > still fill in GPU page table in nouveau, i will check nouveau code
> > for that.
> 
> Again, we can't "kill" a thread of execution (this would often be an
> interrupt bottom half context, btw) while it is, for example,
> in the middle of migrate_vma.

You should not call migrate from bottom half ! Only call this from work
queue like nouveau.

> 
> I really don't believe there is a safe way to do this without draining
> the existing operations before .release returns, and for that, we'll need to 
> issue the .release callbacks while not holding locks.

down_write on mmap_sem would force serialization. I am not sure we want
to do this change now. It can wait as it is definitly not an issue for
nouveau yet. Taking mmap_sem in write (see oom in exit_mmap()) in release
make me nervous.

Cheers,
Jerome
