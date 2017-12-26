Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4D36B0038
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 08:40:53 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id y76so28689140iod.1
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 05:40:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m3si13051065ita.168.2017.12.26.05.40.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Dec 2017 05:40:52 -0800 (PST)
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <5A3F5A4A.1070009@intel.com>
	<5A3F6254.7070306@intel.com>
	<201712252351.FBE81721.HFOtFOJQSOFLVM@I-love.SAKURA.ne.jp>
	<5A41BCC1.5010004@intel.com>
	<201712261938.IFF64061.LtFMOVJFHOSFQO@I-love.SAKURA.ne.jp>
In-Reply-To: <201712261938.IFF64061.LtFMOVJFHOSFQO@I-love.SAKURA.ne.jp>
Message-Id: <201712262240.CJG26093.JQtMOFOSFOVHFL@I-love.SAKURA.ne.jp>
Date: Tue, 26 Dec 2017 22:40:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, willy@infradead.org, mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> On 12/26/2017 06:38 PM, Tetsuo Handa wrote:
> > Wei Wang wrote:
> >> On 12/25/2017 10:51 PM, Tetsuo Handa wrote:
> >>> Wei Wang wrote:
> >>>
> >> What we are doing here is to free the pages that were just allocated in
> >> this round of inflating. Next round will be sometime later when the
> >> balloon work item gets its turn to run. Yes, it will then continue to
> >> inflate.
> >> Here are the two cases that will happen then:
> >> 1) the guest is still under memory pressure, the inflate will fail at
> >> memory allocation, which results in a msleep(200), and then it exists
> >> for another time to run.
> >> 2) the guest isn't under memory pressure any more (e.g. the task which
> >> consumes the huge amount of memory is gone), it will continue to inflate
> >> as normal till the requested size.
> >>
> > How likely does 2) occur? It is not so likely. msleep(200) is enough to spam
> > the guest with puff messages. Next round is starting too quickly.
> 
> I meant one of the two cases, 1) or 2), would happen, rather than 2) 
> happens after 1).
> 
> If 2) doesn't happen, then 1) happens. It will continue to try to 
> inflate round by round. But the memory allocation won't succeed, so 
> there will be no pages to inflate to the host. That is, the inflating is 
> simply a code path to the msleep(200) as long as the guest is under 
> memory pressure.

No. See http://lkml.kernel.org/r/201710181959.ACI05296.JLMVQOOFtHSOFF@I-love.SAKURA.ne.jp .
Did you try how unlikely 2) occurs if once 1) started?

> 
> Back to our code change, it doesn't result in incorrect behavior as 
> explained above.

The guest will be effectively unusable due to spam.

> 
> >> I think what we are doing is a quite sensible behavior, except a small
> >> change I plan to make:
> >>
> >>           while ((page = balloon_page_pop(&pages))) {
> >> -               balloon_page_enqueue(&vb->vb_dev_info, page);
> >>                   if (use_sg) {
> >>                           if (xb_set_page(vb, page, &pfn_min, &pfn_max) <
> >> 0) {
> >>                                   __free_page(page);
> >>                                   continue;
> >>                           }
> >>                   } else {
> >>                           set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >>                   }
> >> +             balloon_page_enqueue(&vb->vb_dev_info, page);
> >>
> >>> Also, as of Linux 4.15, only up to VIRTIO_BALLOON_ARRAY_PFNS_MAX pages (i.e.
> >>> 1MB) are invisible from deflate request. That amount would be an acceptable
> >>> error. But your patch makes more pages being invisible, for pages allocated
> >>> by balloon_page_alloc() without holding balloon_lock are stored into a local
> >>> variable "LIST_HEAD(pages)" (which means that balloon_page_dequeue() with
> >>> balloon_lock held won't be able to find pages not yet queued by
> >>> balloon_page_enqueue()), doesn't it? What if all memory pages were held in
> >>> "LIST_HEAD(pages)" and balloon_page_dequeue() was called before
> >>> balloon_page_enqueue() is called?
> >>>
> >> If we think of the balloon driver just as a regular driver or
> >> application, that will be a pretty nature thing. A regular driver can
> >> eat a huge amount of memory for its own usages, would this amount of
> >> memory be treated as an error as they are invisible to the
> >> balloon_page_enqueue?
> >>
> > No. Memory used by applications which consumed a lot of memory in their
> > mm_struct is reclaimed by the OOM killer/reaper. Drivers try to avoid
> > allocating more memory than they need. If drivers allocate more memory
> > than they need, they have a hook for releasing unused memory (i.e.
> > register_shrinker() or OOM notifier). What I'm saying here is that
> > the hook for releasing unused memory does not work unless memory held in
> > LIST_HEAD(pages) becomes visible to balloon_page_dequeue().
> >
> > If a system has 128GB of memory, and 127GB of memory was stored into
> > LIST_HEAD(pages) upon first fill_balloon() request, and somebody held
> > balloon_lock from OOM notifier path from out_of_memory() before
> > fill_balloon() holds balloon_lock, leak_balloon_sg_oom() finds that
> > no memory can be freed because balloon_page_enqueue() was never called,
> > and allows the caller of out_of_memory() to invoke the OOM killer despite
> > there is 127GB of memory which can be freed if fill_balloon() was able
> > to hold balloon_lock before leak_balloon_sg_oom() holds balloon_lock.
> > I don't think that that amount is an acceptable error.
> 
> I understand you are worried that OOM couldn't get balloon pages while 
> there are some in the local list. This is a debatable issue, and it may 
> lead to a long discussion. If this is considered to be a big issue, we 
> can make the local list to be global in vb, and accessed by oom 
> notifier, this won't affect this patch, and can be achieved with an 
> add-on patch. How about leaving this discussion as a second step outside 
> this series?

No. This is a big issue. Even changing balloon_page_alloc() to exclude
__GFP_DIRECT_RECLAIM might be the better, for we don't want to try so hard.
Reclaiming all reclaimable memory results in hitting OOM notifier path which
after all releases memory reclaimed by a lot of effort. Though I don't know whether
  (GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & ~__GFP_DIRECT_RECLAIM
has undesirable side effect.

>              Balloon has something more that can be improved, and this 
> patch series is already big.

The reason this patch series becomes big is that you are doing a lot of
changes in this series. This series is too optimistic about worst/corner
cases and difficult for me to check. Please always consider the worst case,
and write patches in a way that can survive the worst case.

Please compose this series with patch 1/2 for xbitmap and patch 2/2 for
VIRTIO_BALLOON_F_SG. Nothing more to append. Of course, after we came to
an agreement about whether virtio_balloon should use preload. (We are
waiting for response from Matthew Wilcox, aren't we?) Also, adding some
cond_resched() might be needed. Also, comparing (maybe benchmarking)
Matthew's radix tree implementation and my B+ tree implementation is
another TODO thing before merging this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
