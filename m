Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 498556B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 22:57:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e139so95740621oib.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 19:57:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r185si16558702ior.117.2016.07.28.19.57.00
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 19:57:01 -0700 (PDT)
Date: Fri, 29 Jul 2016 12:01:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction
 failed
Message-ID: <20160729030146.GA31867@js1304-P5Q-DELUXE>
References: <5799AF6A.2070507@huawei.com>
 <20160728072028.GC31860@dhcp22.suse.cz>
 <5799B741.8090506@huawei.com>
 <20160728075856.GE31860@dhcp22.suse.cz>
 <5799C612.1050502@huawei.com>
 <20160728094327.GB1000@dhcp22.suse.cz>
 <5799E394.4060200@huawei.com>
 <CALCETrXB_bXULwezi=YyztFqq_6iigrwRynikYcPUmuEgoWV7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXB_bXULwezi=YyztFqq_6iigrwRynikYcPUmuEgoWV7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Thu, Jul 28, 2016 at 08:07:51AM -0700, Andy Lutomirski wrote:
> On Thu, Jul 28, 2016 at 3:51 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> > On 2016/7/28 17:43, Michal Hocko wrote:
> >
> >> On Thu 28-07-16 16:45:06, Xishi Qiu wrote:
> >>> On 2016/7/28 15:58, Michal Hocko wrote:
> >>>
> >>>> On Thu 28-07-16 15:41:53, Xishi Qiu wrote:
> >>>>> On 2016/7/28 15:20, Michal Hocko wrote:
> >>>>>
> >>>>>> On Thu 28-07-16 15:08:26, Xishi Qiu wrote:
> >>>>>>> Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
> >>>>>>> physical memory during fork a new process.
> >>>>>>>
> >>>>>>> If the system's memory is very small, especially the smart phone, maybe there
> >>>>>>> is only 1G memory. So the free memory is very small and compaction is not
> >>>>>>> always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
> >>>>>>> may be failed for memory fragment.
> >>>>>>
> >>>>>> Well, with the current implementation of the page allocator those
> >>>>>> requests will not fail in most cases. The oom killer would be invoked in
> >>>>>> order to free up some memory.
> >>>>>>
> >>>>>
> >>>>> Hi Michal,
> >>>>>
> >>>>> Yes, it success in most cases, but I did have seen this problem in some
> >>>>> stress-test.
> >>>>>
> >>>>> DMA free:470628kB, but alloc 2 order block failed during fork a new process.
> >>>>> There are so many memory fragments and the large block may be soon taken by
> >>>>> others after compact because of stress-test.
> >>>>>
> >>>>> --- dmesg messages ---
> >>>>> 07-13 08:41:51.341 <4>[309805.658142s][pid:1361,cpu5,sManagerService]sManagerService: page allocation failure: order:2, mode:0x2000d1
> >>>>
> >>>> Yes but this is __GFP_DMA allocation. I guess you have already reported
> >>>> this failure and you've been told that this is quite unexpected for the
> >>>> kernel stack allocation. It is your out-of-tree patch which just makes
> >>>> things worse because DMA restricted allocations are considered "lowmem"
> >>>> and so they do not invoke OOM killer and do not retry like regular
> >>>> GFP_KERNEL allocations.
> >>>
> >>> Hi Michal,
> >>>
> >>> Yes, we add GFP_DMA, but I don't think this is the key for the problem.
> >>
> >> You are restricting the allocation request to a single zone which is
> >> definitely not good. Look at how many larger order pages are available
> >> in the Normal zone.
> >>
> >>> If we do oom-killer, maybe we will get a large block later, but there
> >>> is enough free memory before oom(although most of them are fragments).
> >>
> >> Killing a task is of course the last resort action. It would give you
> >> larger order blocks used for the victims thread.
> >>
> >>> I wonder if we can alloc success without kill any process in this situation.
> >>
> >> Sure it would be preferable to compact that memory but that might be
> >> hard with your restriction in place. Consider that DMA zone would tend
> >> to be less movable than normal zones as users would have to pin it for
> >> DMA. Your DMA is really large so this might turn out to just happen to
> >> work but note that the primary problem here is that you put a zone
> >> restriction for your allocations.
> >>
> >>> Maybe use vmalloc is a good way, but I don't know the influence.
> >>
> >> You can have a look at vmalloc patches posted by Andy. They are not that
> >> trivial.
> >>
> >
> > Hi Michal,
> >
> > Thank you for your comment, could you give me the link?
> >
> 
> I've been keeping it mostly up to date in this branch:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/vmap_stack
> 
> It's currently out of sync due to a bunch of the patches being queued
> elsewhere for the merge window.

Hello, Andy.

I have some questions about it.

IIUC, to turn on HAVE_ARCH_VMAP_STACK on different architecture, there
is nothing to be done in architecture side if the architecture doesn't
support lazily faults in top-level paging entries for the vmalloc
area. Is my understanding is correct?

And, I'd like to know how you search problematic places using kernel
stack for DMA.

One note is that, stack overflow happens at the previous page of the
stack end position if stack grows down, but, guard page is placed at
the next page of the stack begin position. So, this stack overflow
detection depends on the fact that previous vmalloc-ed area is allocated
without VM_NO_GUARD. There isn't many users for this flag so there
would be no problem but just note.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
