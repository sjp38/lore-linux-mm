Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id F32816B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 09:51:57 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id k63so45689500qgf.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 06:51:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v64si2408068qkl.262.2016.06.03.06.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 06:51:57 -0700 (PDT)
Date: Fri, 3 Jun 2016 15:51:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160603135154.GD29930@redhat.com>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160602120857.GA704@swordfish>
 <20160602122109.GM1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602122109.GM1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 02, 2016 at 02:21:10PM +0200, Michal Hocko wrote:
> Testing with the patch makes some sense as well, but I would like to
> hear from Andrea whether the approach is good because I am wondering why
> he hasn't done that before - it feels so much simpler than the current
> code.

The down_write in the exit path comes from __ksm_exit. If you don't
like it there I'd suggest to also remove it from __ksm_exit.

This is a proposed cleanup correct?

The first thing that I can notice is that khugepaged_test_exit() then
can only be called and provide the expected retval, after
atomic_inc_not_zero(mm_users). Also note mmget_not_zero() should be
used instead.

However the code still uses khugepaged_test_exit in __khugepage_enter
that won't increase the mm_users, so then the patch relaxes that check
too much, albeit only for a debug check not strictly a bug.

The cons of this change purely that it'll decrease the responsiveness
in releasing the RAM of a killed task a bit.

To me the fewer time we hold the mm_users the better and I don't see
an obvious runtime improvement coming from this change. It's a bit
simpler yes, but the down_write in the exit path is well understood,
ksm does the same thing and it's in a slow path (it only happens if
the mm that exited is the current one under scan by either ksmd or
khugepaged, so normally the down_write is not executed in the exit
path and the "mm" is collected right away both as a mm_users and
mm_count).

In short I think it's a tradeoff: pros) removes down_write in a slow
path of the the mm exit which may simplify the code a bit, cons) it
could increase the latency in freeing memory as result of a task
exiting or being killed during the khugepaged scan, for example while
the THP is being allocated. While compaction runs to allocate the THP
in collapse_huge_page, if the task is killed currently the memory is
released right away, without waiting for the allocation to succeed or
fail.

I don't see a big enough problem with the down_write in a slow path of
khugepaged_exit to justify the increased latency in releasing memory.

I was very happy by Oleg's patch reducing the mm_users holding of
userfaultfd too. That was controlled by userland so it would only be
an issue for non-cooperative usage which isn't upstream yet, and it
was also much wider than this one would become with the patch applied,
but I liked the direction.

If prefer instead to remove the down_write, you probably could move
the test_exit before the down_read/write to bail out before taking the
lock: you don't need the mmap_sem to do test_exit anymore. The only
reason the text_exit would remain in fact is just to reduce the
latency of the memory freeing, it then becomes a voluntary preempt
cond_resched() to release the memory to make a parallel ;), but unable
to let the kernel free the memory while the THP allocation runs.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
