Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 092D26B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:46:25 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m15so4066638qke.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:46:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w46si5143279qta.96.2018.03.21.15.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 15:46:24 -0700 (PDT)
Date: Wed, 21 Mar 2018 18:46:21 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 03/15] mm/hmm: HMM should have a callback before MM is
 destroyed v2
Message-ID: <20180321224620.GH3214@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-4-jglisse@redhat.com>
 <d89e417d-c939-4d18-72f5-08b22dc6cff0@nvidia.com>
 <20180321180342.GE3214@redhat.com>
 <788cf786-edbf-ab43-af0d-abbe9d538757@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <788cf786-edbf-ab43-af0d-abbe9d538757@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Wed, Mar 21, 2018 at 03:16:04PM -0700, John Hubbard wrote:
> On 03/21/2018 11:03 AM, Jerome Glisse wrote:
> > On Tue, Mar 20, 2018 at 09:14:34PM -0700, John Hubbard wrote:
> >> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> >>> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> <snip>
> 
> >> Hi Jerome,
> >>
> >> This presents a deadlock problem (details below). As for solution ideas, 
> >> Mark Hairgrove points out that the MMU notifiers had to solve the
> >> same sort of problem, and part of the solution involves "avoid
> >> holding locks when issuing these callbacks". That's not an entire 
> >> solution description, of course, but it seems like a good start.
> >>
> >> Anyway, for the deadlock problem:
> >>
> >> Each of these ->release callbacks potentially has to wait for the 
> >> hmm_invalidate_range() callbacks to finish. That is not shown in any
> >> code directly, but it's because: when a device driver is processing 
> >> the above ->release callback, it has to allow any in-progress operations 
> >> to finish up (as specified clearly in your comment documentation above). 
> >>
> >> Some of those operations will invariably need to do things that result 
> >> in page invalidations, thus triggering the hmm_invalidate_range() callback.
> >> Then, the hmm_invalidate_range() callback tries to acquire the same 
> >> hmm->mirrors_sem lock, thus leading to deadlock:
> >>
> >> hmm_invalidate_range():
> >> // ...
> >> 	down_read(&hmm->mirrors_sem);
> >> 	list_for_each_entry(mirror, &hmm->mirrors, list)
> >> 		mirror->ops->sync_cpu_device_pagetables(mirror, action,
> >> 							start, end);
> >> 	up_read(&hmm->mirrors_sem);
> > 
> > That is just illegal, the release callback is not allowed to trigger
> > invalidation all it does is kill all device's threads and stop device
> > page fault from happening. So there is no deadlock issues. I can re-
> > inforce the comment some more (see [1] for example on what it should
> > be).
> 
> That rule is fine, and it is true that the .release callback will not 
> directly trigger any invalidations. However, the problem is in letting 
> any *existing* outstanding operations finish up. We have to let 
> existing operations "drain", in order to meet the requirement that 
> everything is done when .release returns.
> 
> For example, if a device driver thread is in the middle of working through
> its fault buffer, it will call migrate_vma(), which will in turn unmap
> pages. That will cause an hmm_invalidate_range() callback, which tries
> to take hmm->mirrors_sems, and we deadlock.
> 
> There's no way to "kill" such a thread while it's in the middle of
> migrate_vma(), you have to let it finish up.
>
> > Also it is illegal for the sync callback to trigger any mmu_notifier
> > callback. I thought this was obvious. The sync callback should only
> > update device page table and do _nothing else_. No way to make this
> > re-entrant.
> 
> That is obvious, yes. I am not trying to say there is any problem with
> that rule. It's the "drain outstanding operations during .release", 
> above, that is the real problem.

Maybe just relax the release callback wording, it should stop any
more processing of fault buffer but not wait for it to finish. In
nouveau code i kill thing but i do not wait hence i don't deadlock.

What matter is to stop any further processing. Yes some fault might
be in flight but they will serialize on various lock. So just do not
wait in the release callback, kill thing. I might have a bug where i
still fill in GPU page table in nouveau, i will check nouveau code
for that.

Kill thing should also kill the channel (i don't do that in nouveau
because i am waiting on some channel patchset) but i am not sure if
hardware like it if we kill channel before stoping fault notification.

Cheers,
Jerome
