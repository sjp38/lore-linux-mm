Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F07776B0033
	for <linux-mm@kvack.org>; Sun, 24 Dec 2017 03:14:13 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 61so16298070plz.1
        for <linux-mm@kvack.org>; Sun, 24 Dec 2017 00:14:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b75si19870672pfk.86.2017.12.24.00.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Dec 2017 00:14:12 -0800 (PST)
Message-ID: <5A3F6254.7070306@intel.com>
Date: Sun, 24 Dec 2017 16:16:20 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>	<1513685879-21823-5-git-send-email-wei.w.wang@intel.com>	<20171224032121.GA5273@bombadil.infradead.org> <201712241345.DIG21823.SLFOOJtQFOMVFH@I-love.SAKURA.ne.jp> <5A3F5A4A.1070009@intel.com>
In-Reply-To: <5A3F5A4A.1070009@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 12/24/2017 03:42 PM, Wei Wang wrote:
> On 12/24/2017 12:45 PM, Tetsuo Handa wrote:
>> Matthew Wilcox wrote:
>>>> +    unsigned long pfn = page_to_pfn(page);
>>>> +    int ret;
>>>> +
>>>> +    *pfn_min = min(pfn, *pfn_min);
>>>> +    *pfn_max = max(pfn, *pfn_max);
>>>> +
>>>> +    do {
>>>> +        if (xb_preload(GFP_NOWAIT | __GFP_NOWARN) < 0)
>>>> +            return -ENOMEM;
>>>> +
>>>> +        ret = xb_set_bit(&vb->page_xb, pfn);
>>>> +        xb_preload_end();
>>>> +    } while (unlikely(ret == -EAGAIN));
>>> OK, so you don't need a spinlock because you're under a mutex?  But you
>>> can't allocate memory because you're in the balloon driver, and so a
>>> GFP_KERNEL allocation might recurse into your driver?
>> Right. We can't (directly or indirectly) depend on 
>> __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
>> allocations because the balloon driver needs to handle OOM notifier 
>> callback.
>>
>>> Would GFP_NOIO
>>> do the job?  I'm a little hazy on exactly how the balloon driver works.
>> GFP_NOIO implies __GFP_DIRECT_RECLAIM. In the worst case, it can 
>> lockup due to
>> the too small to fail memory allocation rule. GFP_NOIO | 
>> __GFP_NORETRY would work
>> if there is really a guarantee that GFP_NOIO | __GFP_NORETRY never 
>> depend on
>> __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations, which is too 
>> subtle for me to
>> validate. The direct reclaim dependency is too complicated to validate.
>> I consider that !__GFP_DIRECT_RECLAIM is the future-safe choice.
>
> What's the problem with (or how is it better than) the "GFP_NOWAIT | 
> __GFP_NOWARN" we are using here?
>
>
>>> If you can't preload with anything better than that, I think that
>>> xb_set_bit() should attempt an allocation with GFP_NOWAIT | 
>>> __GFP_NOWARN,
>>> and then you can skip the preload; it has no value for you.
>> Yes, that's why I suggest directly using kzalloc() at xb_set_bit().
>
> It has some possibilities to remove that preload if we also do the 
> bitmap allocation in the xb_set_bit():
>
> bitmap = rcu_dereference_raw(*slot);
> if (!bitmap) {
>     bitmap = this_cpu_xchg(ida_bitmap, NULL);
>     if (!bitmap) {
>         bitmap = kmalloc(sizeof(*bitmap), gfp);
>         if (!bitmap)
>             return -ENOMEM;
>     }
> }
>
> But why not just follow the radix tree implementation style that puts 
> the allocation in preload, which would be invoked with a more relaxed 
> gfp in other use cases?
> Its usage in virtio_balloon is just a little special that we need to 
> put the allocation within the balloon_lock, which doesn't give us the 
> benefit of using a relaxed gfp in preload, but it doesn't prevent us 
> from living with the current APIs (i.e. the preload + xb_set pattern).
> On the other side, if we do it as above, we have more things that need 
> to consider. For example, what if the a use case just want the radix 
> tree implementation style, which means it doesn't want allocation 
> within xb_set(), then would we be troubled with how to avoid the 
> allocation path in that case?
>
> So, I think it is better to stick with the convention by putting the 
> allocation in preload. Breaking the convention should show obvious 
> advantages, IMHO.
>
>
>>
>>>> @@ -173,8 +292,15 @@ static unsigned fill_balloon(struct 
>>>> virtio_balloon *vb, size_t num)
>>>>         while ((page = balloon_page_pop(&pages))) {
>>>>           balloon_page_enqueue(&vb->vb_dev_info, page);
>>>> +        if (use_sg) {
>>>> +            if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
>>>> +                __free_page(page);
>>>> +                continue;
>>>> +            }
>>>> +        } else {
>>>> +            set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>>>> +        }
>>> Is this the right behaviour?
>> I don't think so. In the worst case, we can set no bit using 
>> xb_set_page().
>
>>
>>>                                If we can't record the page in the xb,
>>> wouldn't we rather send it across as a single page?
>>>
>> I think that we need to be able to fallback to !use_sg path when OOM.
>
> I also have different thoughts:
>
> 1) For OOM, we have leak_balloon_sg_oom (oom has nothing to do with 
> fill_balloon), which does not use xbitmap to record pages, thus no 
> memory allocation.
>
> 2) If the memory is already under pressure, it is pointless to 
> continue inflating memory to the host. We need to give thanks to the 
> memory allocation failure reported by xbitmap, which gets us a chance 
> to release the inflated pages that have been demonstrated to cause the 
> memory pressure of the guest.
>

Forgot to add my conclusion: I think the above behavior is correct.

Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
