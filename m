Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3696B0254
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:57:40 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so199590925pac.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 00:57:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qq4si35415129pbc.157.2015.09.29.00.57.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Sep 2015 00:57:39 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
Message-Id: <201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
Date: Tue, 29 Sep 2015 16:57:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mhocko@kernel.org
Cc: oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

David Rientjes wrote:
> On Fri, 25 Sep 2015, Michal Hocko wrote:
> > > > I am still not sure how you want to implement that kernel thread but I
> > > > am quite skeptical it would be very much useful because all the current
> > > > allocations which end up in the OOM killer path cannot simply back off
> > > > and drop the locks with the current allocator semantic.  So they will
> > > > be sitting on top of unknown pile of locks whether you do an additional
> > > > reclaim (unmap the anon memory) in the direct OOM context or looping
> > > > in the allocator and waiting for kthread/workqueue to do its work. The
> > > > only argument that I can see is the stack usage but I haven't seen stack
> > > > overflows in the OOM path AFAIR.
> > > > 
> > > 
> > > Which locks are you specifically interested in?
> > 
> > Any locks they were holding before they entered the page allocator (e.g.
> > i_mutex is the easiest one to trigger from the userspace but mmap_sem
> > might be involved as well because we are doing kmalloc(GFP_KERNEL) with
> > mmap_sem held for write). Those would be locked until the page allocator
> > returns, which with the current semantic might be _never_.
> > 
> 
> I agree that i_mutex seems to be one of the most common offenders.  
> However, I'm not sure I understand why holding it while trying to allocate 
> infinitely for an order-0 allocation is problematic wrt the proposed 
> kthread.  The kthread itself need only take mmap_sem for read.  If all 
> threads sharing the mm with a victim have been SIGKILL'd, they should get 
> TIF_MEMDIE set when reclaim fails and be able to allocate so that they can 
> drop mmap_sem.  We must ensure that any holder of mmap_sem cannot quickly 
> deplete memory reserves without properly checking for 
> fatal_signal_pending().

Is the story such simple? I think there are factors which disturb memory
allocation with mmap_sem held for writing.

  down_write(&mm->mmap_sem);
  kmalloc(GFP_KERNEL);
  up_write(&mm->mmap_sem);

can involve locks inside __alloc_pages_slowpath().

Say, there are three userspace tasks named P1, P2T1, P2T2 and
one kernel thread named KT1. Only P2T1 and P2T2 shares the same mm.
KT1 is a kernel thread for fs writeback (maybe kswapd?).
I think sequence shown below is possible.

(1) P1 enters into kernel mode via write() syscall.

(2) P1 allocates memory for buffered write.

(3) P2T1 enters into kernel mode and calls kmalloc().

(4) P2T1 arrives at __alloc_pages_may_oom() because there was no
    reclaimable memory. (Memory allocated by P1 is not reclaimable
    as of this moment.)

(5) P1 dirties memory allocated for buffered write.

(6) P2T2 enters into kernel mode and calls kmalloc() with
    mmap_sem held for writing.

(7) KT1 finds dirtied memory.

(8) KT1 holds fs's unkillable lock for fs writeback.

(9) P2T2 is blocked at unkillable lock for fs writeback held by KT1.

(10) P2T1 calls out_of_memory() and the OOM killer chooses P2T1 and sets
     TIF_MEMDIE on both P2T1 and P2T2.

(11) P2T2 got TIF_MEMDIE but is blocked at unkillable lock for fs writeback
     held by KT1.

(12) KT1 is trying to allocate memory for fs writeback. But since P2T1 and
     P2T2 cannot release memory because memory unmapping code cannot hold
     mmap_sem for reading, KT1 waits forever.... OOM livelock completed!

I think sequence shown below is also possible. Say, there are three
userspace tasks named P1, P2, P3 and one kernel thread named KT1.

(1) P1 enters into kernel mode via write() syscall.

(2) P1 allocates memory for buffered write.

(3) P2 enters into kernel mode and holds mmap_sem for writing.

(4) P3 enters into kernel mode and calls kmalloc().

(5) P3 arrives at __alloc_pages_may_oom() because there was no
    reclaimable memory. (Memory allocated by P1 is not reclaimable
    as of this moment.)

(6) P1 dirties memory allocated for buffered write.

(7) KT1 finds dirtied memory.

(8) KT1 holds fs's unkillable lock for fs writeback.

(9) P2 calls kmalloc() and is blocked at unkillable lock for fs writeback
    held by KT1.

(10) P3 calls out_of_memory() and the OOM killer chooses P2 and sets
     TIF_MEMDIE on P2.

(11) P2 got TIF_MEMDIE but is blocked at unkillable lock for fs writeback
     held by KT1.

(12) KT1 is trying to allocate memory for fs writeback. But since P2 cannot
     release memory because memory unmapping code cannot hold mmap_sem for
     reading, KT1 waits forever.... OOM livelock completed!

So, allowing all OOM victim threads to use memory reserves does not guarantee
that a thread which held mmap_sem for writing to make forward progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
