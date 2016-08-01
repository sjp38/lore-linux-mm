Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59432828E1
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 01:25:56 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so227417620pad.2
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 22:25:56 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g79si33214748pfb.219.2016.07.31.22.25.54
        for <linux-mm@kvack.org>;
        Sun, 31 Jul 2016 22:25:55 -0700 (PDT)
Date: Mon, 1 Aug 2016 14:30:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction
 failed
Message-ID: <20160801053051.GA8623@js1304-P5Q-DELUXE>
References: <5799AF6A.2070507@huawei.com>
 <20160728072028.GC31860@dhcp22.suse.cz>
 <5799B741.8090506@huawei.com>
 <20160728075856.GE31860@dhcp22.suse.cz>
 <5799C612.1050502@huawei.com>
 <20160728094327.GB1000@dhcp22.suse.cz>
 <5799E394.4060200@huawei.com>
 <CALCETrXB_bXULwezi=YyztFqq_6iigrwRynikYcPUmuEgoWV7g@mail.gmail.com>
 <20160729030146.GA31867@js1304-P5Q-DELUXE>
 <CALCETrV++O=ynMKYwdhG-AksnVXX6hBpBxtXfNaa_dhVLMu2Tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrV++O=ynMKYwdhG-AksnVXX6hBpBxtXfNaa_dhVLMu2Tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Fri, Jul 29, 2016 at 12:47:38PM -0700, Andy Lutomirski wrote:
> ---------- Forwarded message ----------
> From: "Joonsoo Kim" <iamjoonsoo.kim@lge.com>
> Date: Jul 28, 2016 7:57 PM
> Subject: Re: [RFC] can we use vmalloc to alloc thread stack if compaction failed
> To: "Andy Lutomirski" <luto@kernel.org>
> Cc: "Xishi Qiu" <qiuxishi@huawei.com>, "Michal Hocko"
> <mhocko@kernel.org>, "Tejun Heo" <tj@kernel.org>, "Ingo Molnar"
> <mingo@kernel.org>, "Peter Zijlstra" <peterz@infradead.org>, "LKML"
> <linux-kernel@vger.kernel.org>, "Linux MM" <linux-mm@kvack.org>,
> "Yisheng Xie" <xieyisheng1@huawei.com>
> 
> > On Thu, Jul 28, 2016 at 08:07:51AM -0700, Andy Lutomirski wrote:
> > > On Thu, Jul 28, 2016 at 3:51 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> > > > On 2016/7/28 17:43, Michal Hocko wrote:
> > > >
> > > >> On Thu 28-07-16 16:45:06, Xishi Qiu wrote:
> > > >>> On 2016/7/28 15:58, Michal Hocko wrote:
> > > >>>
> > > >>>> On Thu 28-07-16 15:41:53, Xishi Qiu wrote:
> > > >>>>> On 2016/7/28 15:20, Michal Hocko wrote:
> > > >>>>>
> > > >>>>>> On Thu 28-07-16 15:08:26, Xishi Qiu wrote:
> > > >>>>>>> Usually THREAD_SIZE_ORDER is 2, it means we need to alloc 16kb continuous
> > > >>>>>>> physical memory during fork a new process.
> > > >>>>>>>
> > > >>>>>>> If the system's memory is very small, especially the smart phone, maybe there
> > > >>>>>>> is only 1G memory. So the free memory is very small and compaction is not
> > > >>>>>>> always success in slowpath(__alloc_pages_slowpath), then alloc thread stack
> > > >>>>>>> may be failed for memory fragment.
> > > >>>>>>
> > > >>>>>> Well, with the current implementation of the page allocator those
> > > >>>>>> requests will not fail in most cases. The oom killer would be invoked in
> > > >>>>>> order to free up some memory.
> > > >>>>>>
> > > >>>>>
> > > >>>>> Hi Michal,
> > > >>>>>
> > > >>>>> Yes, it success in most cases, but I did have seen this problem in some
> > > >>>>> stress-test.
> > > >>>>>
> > > >>>>> DMA free:470628kB, but alloc 2 order block failed during fork a new process.
> > > >>>>> There are so many memory fragments and the large block may be soon taken by
> > > >>>>> others after compact because of stress-test.
> > > >>>>>
> > > >>>>> --- dmesg messages ---
> > > >>>>> 07-13 08:41:51.341 <4>[309805.658142s][pid:1361,cpu5,sManagerService]sManagerService: page allocation failure: order:2, mode:0x2000d1
> > > >>>>
> > > >>>> Yes but this is __GFP_DMA allocation. I guess you have already reported
> > > >>>> this failure and you've been told that this is quite unexpected for the
> > > >>>> kernel stack allocation. It is your out-of-tree patch which just makes
> > > >>>> things worse because DMA restricted allocations are considered "lowmem"
> > > >>>> and so they do not invoke OOM killer and do not retry like regular
> > > >>>> GFP_KERNEL allocations.
> > > >>>
> > > >>> Hi Michal,
> > > >>>
> > > >>> Yes, we add GFP_DMA, but I don't think this is the key for the problem.
> > > >>
> > > >> You are restricting the allocation request to a single zone which is
> > > >> definitely not good. Look at how many larger order pages are available
> > > >> in the Normal zone.
> > > >>
> > > >>> If we do oom-killer, maybe we will get a large block later, but there
> > > >>> is enough free memory before oom(although most of them are fragments).
> > > >>
> > > >> Killing a task is of course the last resort action. It would give you
> > > >> larger order blocks used for the victims thread.
> > > >>
> > > >>> I wonder if we can alloc success without kill any process in this situation.
> > > >>
> > > >> Sure it would be preferable to compact that memory but that might be
> > > >> hard with your restriction in place. Consider that DMA zone would tend
> > > >> to be less movable than normal zones as users would have to pin it for
> > > >> DMA. Your DMA is really large so this might turn out to just happen to
> > > >> work but note that the primary problem here is that you put a zone
> > > >> restriction for your allocations.
> > > >>
> > > >>> Maybe use vmalloc is a good way, but I don't know the influence.
> > > >>
> > > >> You can have a look at vmalloc patches posted by Andy. They are not that
> > > >> trivial.
> > > >>
> > > >
> > > > Hi Michal,
> > > >
> > > > Thank you for your comment, could you give me the link?
> > > >
> > >
> > > I've been keeping it mostly up to date in this branch:
> > >
> > > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/vmap_stack
> > >
> > > It's currently out of sync due to a bunch of the patches being queued
> > > elsewhere for the merge window.
> >
> > Hello, Andy.
> >
> > I have some questions about it.
> >
> > IIUC, to turn on HAVE_ARCH_VMAP_STACK on different architecture, there
> > is nothing to be done in architecture side if the architecture doesn't
> > support lazily faults in top-level paging entries for the vmalloc
> > area. Is my understanding is correct?
> >
> 
> There should be nothing fundamental that needs to be done.  On the
> other hand, it might be good to make sure the arch code can print a
> clean stack trace on stack overflow.
> 
> If it's helpful, I just pushed out anew

You mean that you can turn on HAVE_ARCH_VMAP_STACK on the other arch? It
would be helpful. :)

> 
> > And, I'd like to know how you search problematic places using kernel
> > stack for DMA.
> >
> 
> I did some searching for problematic sg_init_buf calls using
> Coccinelle.  I'm not very good at Coccinelle, so I may have missed
> something.

I'm also not familiar with Coccinelle. Could you share your .cocci
script? I can think of following one but there would be a better way.

virtual report

@stack_var depends on report@
type T1;
expression E1, E2;
identifier I1;
@@
(
* T1 I1;
)
...
(
* sg_init_one(E1, &I1, E2)
|
* sg_set_buf(E1, &I1, E2)
)

@stack_arr depends on report@
type T1;
expression E1, E2, E3;
identifier I1;
@@
(
* T1 I1[E1];
)
...
(
* sg_init_one(E2, I1, E3)
|
* sg_set_buf(E2, I1, E3)
)


> For the most part, DMA API debugging should have found the problems
> already.  The ones I found were in drivers that didn't do real DMA:
> crypto users and virtio.

Ah... using stack for DMA API is already prohibited.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
