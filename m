Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBE106B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:09:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n82so9842063oig.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:09:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 37si4961024oto.164.2017.10.10.04.09.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 04:09:25 -0700 (PDT)
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
	<1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
	<20171009181612-mutt-send-email-mst@kernel.org>
	<59DC76BA.7070202@intel.com>
In-Reply-To: <59DC76BA.7070202@intel.com>
Message-Id: <201710102008.FIG57851.QFJLMtVOFOHFOS@I-love.SAKURA.ne.jp>
Date: Tue, 10 Oct 2017 20:08:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, mst@redhat.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Wei Wang wrote:
> On 10/09/2017 11:20 PM, Michael S. Tsirkin wrote:
> > On Sat, Sep 30, 2017 at 12:05:52PM +0800, Wei Wang wrote:
> >> +static inline void xb_set_page(struct virtio_balloon *vb,
> >> +			       struct page *page,
> >> +			       unsigned long *pfn_min,
> >> +			       unsigned long *pfn_max)
> >> +{
> >> +	unsigned long pfn = page_to_pfn(page);
> >> +
> >> +	*pfn_min = min(pfn, *pfn_min);
> >> +	*pfn_max = max(pfn, *pfn_max);
> >> +	xb_preload(GFP_KERNEL);
> >> +	xb_set_bit(&vb->page_xb, pfn);
> >> +	xb_preload_end();
> >> +}
> >> +
> > So, this will allocate memory
> >
> > ...
> >
> >> @@ -198,9 +327,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> >>   	struct page *page;
> >>   	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> >>   	LIST_HEAD(pages);
> >> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
> >> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
> >>   
> >> -	/* We can only do one array worth at a time. */
> >> -	num = min(num, ARRAY_SIZE(vb->pfns));
> >> +	/* Traditionally, we can only do one array worth at a time. */
> >> +	if (!use_sg)
> >> +		num = min(num, ARRAY_SIZE(vb->pfns));
> >>   
> >>   	mutex_lock(&vb->balloon_lock);
> >>   	/* We can't release more pages than taken */
> > And is sometimes called on OOM.
> >
> >
> > I suspect we need to
> >
> > 1. keep around some memory for leak on oom
> >
> > 2. for non oom allocate outside locks
> >
> >
> 
> I think maybe we can optimize the existing balloon logic, which could 
> remove the big balloon lock:
> 
> It would not be necessary to have the inflating and deflating run at the 
> same time.
> For example, 1st request to inflate 7G RAM, when 1GB has been given to 
> the host (so 6G left), the
> 2nd request to deflate 5G is received. Instead of waiting for the 1st 
> request to inflate 6G and then
> continuing with the 2nd request to deflate 5G, we can do a diff (6G to 
> inflate - 5G to deflate) immediately,
> and got 1G to inflate. In this way, all that driver will do is to simply 
> inflate another 1G.
> 
> Same for the OOM case: when OOM asks for 1G, while inflating 5G is in 
> progress, then the driver can
> deduct 1G from the amount that needs to inflate, and as a result, it 
> will inflate 4G.
> 
> In this case, we will never have the inflating and deflating task run at 
> the same time, so I think it is
> possible to remove the lock, and therefore, we will not have that 
> deadlock issue.
> 
> What would you guys think?

What is balloon_lock at virtballoon_migratepage() for?

  e22504296d4f64fb "virtio_balloon: introduce migration primitives to balloon pages"
  f68b992bbb474641 "virtio_balloon: fix race by fill and leak"

And even if we could remove balloon_lock, you still cannot use
__GFP_DIRECT_RECLAIM at xb_set_page(). I think you will need to use
"whether it is safe to wait" flag from
"[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()" .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
