Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6598F6B0038
	for <linux-mm@kvack.org>; Mon, 25 Dec 2017 09:52:16 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id r12so2448183otr.11
        for <linux-mm@kvack.org>; Mon, 25 Dec 2017 06:52:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h3si4437439otb.174.2017.12.25.06.52.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Dec 2017 06:52:14 -0800 (PST)
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
	<20171224032121.GA5273@bombadil.infradead.org>
	<201712241345.DIG21823.SLFOOJtQFOMVFH@I-love.SAKURA.ne.jp>
	<5A3F5A4A.1070009@intel.com>
	<5A3F6254.7070306@intel.com>
In-Reply-To: <5A3F6254.7070306@intel.com>
Message-Id: <201712252351.FBE81721.HFOtFOJQSOFLVM@I-love.SAKURA.ne.jp>
Date: Mon, 25 Dec 2017 23:51:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> >>>> @@ -173,8 +292,15 @@ static unsigned fill_balloon(struct 
> >>>> virtio_balloon *vb, size_t num)
> >>>>         while ((page = balloon_page_pop(&pages))) {
> >>>>           balloon_page_enqueue(&vb->vb_dev_info, page);
> >>>> +        if (use_sg) {
> >>>> +            if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> >>>> +                __free_page(page);
> >>>> +                continue;
> >>>> +            }
> >>>> +        } else {
> >>>> +            set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >>>> +        }
> >>> Is this the right behaviour?
> >> I don't think so. In the worst case, we can set no bit using 
> >> xb_set_page().
> >
> >>
> >>>                                If we can't record the page in the xb,
> >>> wouldn't we rather send it across as a single page?
> >>>
> >> I think that we need to be able to fallback to !use_sg path when OOM.
> >
> > I also have different thoughts:
> >
> > 1) For OOM, we have leak_balloon_sg_oom (oom has nothing to do with 
> > fill_balloon), which does not use xbitmap to record pages, thus no 
> > memory allocation.
> >
> > 2) If the memory is already under pressure, it is pointless to 
> > continue inflating memory to the host. We need to give thanks to the 
> > memory allocation failure reported by xbitmap, which gets us a chance 
> > to release the inflated pages that have been demonstrated to cause the 
> > memory pressure of the guest.
> >
> 
> Forgot to add my conclusion: I think the above behavior is correct.
> 

What is the desired behavior when hitting OOM path during inflate/deflate?
Once inflation started, the inflation logic is called again and again
until the balloon inflates to the requested size. Such situation will
continue wasting CPU resource between inflate-due-to-host's-request versus
deflate-due-to-guest's-OOM. It is pointless but cannot stop doing pointless
thing.

Also, as of Linux 4.15, only up to VIRTIO_BALLOON_ARRAY_PFNS_MAX pages (i.e.
1MB) are invisible from deflate request. That amount would be an acceptable
error. But your patch makes more pages being invisible, for pages allocated
by balloon_page_alloc() without holding balloon_lock are stored into a local
variable "LIST_HEAD(pages)" (which means that balloon_page_dequeue() with
balloon_lock held won't be able to find pages not yet queued by
balloon_page_enqueue()), doesn't it? What if all memory pages were held in
"LIST_HEAD(pages)" and balloon_page_dequeue() was called before
balloon_page_enqueue() is called?

So, I think we need to consider how to handle such situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
