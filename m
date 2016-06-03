Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC716B025E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 10:46:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so38627039lfz.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 07:46:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id wn5si3681639wjc.78.2016.06.03.07.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 07:46:02 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so24077949wme.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 07:46:02 -0700 (PDT)
Date: Fri, 3 Jun 2016 16:46:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603144600.GK20676@dhcp22.suse.cz>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160602120857.GA704@swordfish>
 <20160602122109.GM1995@dhcp22.suse.cz>
 <20160603135154.GD29930@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603135154.GD29930@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 03-06-16 15:51:54, Andrea Arcangeli wrote:
> On Thu, Jun 02, 2016 at 02:21:10PM +0200, Michal Hocko wrote:
> > Testing with the patch makes some sense as well, but I would like to
> > hear from Andrea whether the approach is good because I am wondering why
> > he hasn't done that before - it feels so much simpler than the current
> > code.
> 
> The down_write in the exit path comes from __ksm_exit. If you don't
> like it there I'd suggest to also remove it from __ksm_exit.

I see

> This is a proposed cleanup correct?

yes this is a cleanup but also a robustness thing, see below.
 
> The first thing that I can notice is that khugepaged_test_exit() then
> can only be called and provide the expected retval, after
> atomic_inc_not_zero(mm_users). Also note mmget_not_zero() should be
> used instead.

I didn't get used to mmget_not_zero yet, but true a helper would be
better.

[...]

> To me the fewer time we hold the mm_users the better and I don't see
> an obvious runtime improvement coming from this change. It's a bit
> simpler yes, but the down_write in the exit path is well understood,
> ksm does the same thing and it's in a slow path (it only happens if
> the mm that exited is the current one under scan by either ksmd or
> khugepaged, so normally the down_write is not executed in the exit
> path and the "mm" is collected right away both as a mm_users and
> mm_count).

OK, I see your point. I wasn't aware that the mmap_sem is dropped
before the allocation request. Then the original code indeed might
get into exit_mmap earlier wrt. to the patch.

The reason I dislike taking write lock in the __mmput is basically
for the same reason you have pointed out. exit_mmap might be delayed
for an unbounded amount of time. khugepaged resp. ksmd might be well
behaved and release their read lock for costly operations or when they
detect the mm is dead but it is hard to guarantee that all potential
kernel users/drivers are behaving the same way. It is not really trivial
to check whether we have such users (there are 100+ users outside of mm/
as per my quick git grep).

The exit path should be as simple as possible with the amount of
external dependencies reduced to the bare minimum.

> In short I think it's a tradeoff: pros) removes down_write in a slow
> path of the the mm exit which may simplify the code a bit, cons) it
> could increase the latency in freeing memory as result of a task
> exiting or being killed during the khugepaged scan, for example while
> the THP is being allocated. While compaction runs to allocate the THP
> in collapse_huge_page, if the task is killed currently the memory is
> released right away, without waiting for the allocation to succeed or
> fail.

Are those latencies a real problem. The allocation itself shouldn't
really take a long time.

> I don't see a big enough problem with the down_write in a slow path of
> khugepaged_exit to justify the increased latency in releasing memory.

What do you think about the external dependencies mentioned above. Do
you think this is a sufficient argument wrt. occasional higher
latencies?
[...]

> If prefer instead to remove the down_write, you probably could move
> the test_exit before the down_read/write to bail out before taking the
> lock: you don't need the mmap_sem to do test_exit anymore. The only
> reason the text_exit would remain in fact is just to reduce the
> latency of the memory freeing, it then becomes a voluntary preempt
> cond_resched() to release the memory to make a parallel ;), but unable
> to let the kernel free the memory while the THP allocation runs.

OK, I will think about that as well.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
