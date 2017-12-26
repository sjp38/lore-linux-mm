Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9B236B0038
	for <linux-mm@kvack.org>; Mon, 25 Dec 2017 22:04:34 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q12so19044185pli.12
        for <linux-mm@kvack.org>; Mon, 25 Dec 2017 19:04:34 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b4si2180737pgu.714.2017.12.25.19.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Dec 2017 19:04:32 -0800 (PST)
Message-ID: <5A41BCC1.5010004@intel.com>
Date: Tue, 26 Dec 2017 11:06:41 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>	<20171224032121.GA5273@bombadil.infradead.org>	<201712241345.DIG21823.SLFOOJtQFOMVFH@I-love.SAKURA.ne.jp>	<5A3F5A4A.1070009@intel.com>	<5A3F6254.7070306@intel.com> <201712252351.FBE81721.HFOtFOJQSOFLVM@I-love.SAKURA.ne.jp>
In-Reply-To: <201712252351.FBE81721.HFOtFOJQSOFLVM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 12/25/2017 10:51 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
>>>>>> @@ -173,8 +292,15 @@ static unsigned fill_balloon(struct
>>>>>> virtio_balloon *vb, size_t num)
>>>>>>          while ((page = balloon_page_pop(&pages))) {
>>>>>>            balloon_page_enqueue(&vb->vb_dev_info, page);
>>>>>> +        if (use_sg) {
>>>>>> +            if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
>>>>>> +                __free_page(page);
>>>>>> +                continue;
>>>>>> +            }
>>>>>> +        } else {
>>>>>> +            set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>>>>>> +        }
>>>>> Is this the right behaviour?
>>>> I don't think so. In the worst case, we can set no bit using
>>>> xb_set_page().
>>>>>                                 If we can't record the page in the xb,
>>>>> wouldn't we rather send it across as a single page?
>>>>>
>>>> I think that we need to be able to fallback to !use_sg path when OOM.
>>> I also have different thoughts:
>>>
>>> 1) For OOM, we have leak_balloon_sg_oom (oom has nothing to do with
>>> fill_balloon), which does not use xbitmap to record pages, thus no
>>> memory allocation.
>>>
>>> 2) If the memory is already under pressure, it is pointless to
>>> continue inflating memory to the host. We need to give thanks to the
>>> memory allocation failure reported by xbitmap, which gets us a chance
>>> to release the inflated pages that have been demonstrated to cause the
>>> memory pressure of the guest.
>>>
>> Forgot to add my conclusion: I think the above behavior is correct.
>>
> What is the desired behavior when hitting OOM path during inflate/deflate?
> Once inflation started, the inflation logic is called again and again
> until the balloon inflates to the requested size.

The above is true, but I can't agree with the following. Please see below.

> Such situation will
> continue wasting CPU resource between inflate-due-to-host's-request versus
> deflate-due-to-guest's-OOM. It is pointless but cannot stop doing pointless
> thing.

What we are doing here is to free the pages that were just allocated in 
this round of inflating. Next round will be sometime later when the 
balloon work item gets its turn to run. Yes, it will then continue to 
inflate.
Here are the two cases that will happen then:
1) the guest is still under memory pressure, the inflate will fail at 
memory allocation, which results in a msleep(200), and then it exists 
for another time to run.
2) the guest isn't under memory pressure any more (e.g. the task which 
consumes the huge amount of memory is gone), it will continue to inflate 
as normal till the requested size.

I think what we are doing is a quite sensible behavior, except a small 
change I plan to make:

         while ((page = balloon_page_pop(&pages))) {
-               balloon_page_enqueue(&vb->vb_dev_info, page);
                 if (use_sg) {
                         if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 
0) {
                                 __free_page(page);
                                 continue;
                         }
                 } else {
                         set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
                 }
+             balloon_page_enqueue(&vb->vb_dev_info, page);

>
> Also, as of Linux 4.15, only up to VIRTIO_BALLOON_ARRAY_PFNS_MAX pages (i.e.
> 1MB) are invisible from deflate request. That amount would be an acceptable
> error. But your patch makes more pages being invisible, for pages allocated
> by balloon_page_alloc() without holding balloon_lock are stored into a local
> variable "LIST_HEAD(pages)" (which means that balloon_page_dequeue() with
> balloon_lock held won't be able to find pages not yet queued by
> balloon_page_enqueue()), doesn't it? What if all memory pages were held in
> "LIST_HEAD(pages)" and balloon_page_dequeue() was called before
> balloon_page_enqueue() is called?
>

If we think of the balloon driver just as a regular driver or 
application, that will be a pretty nature thing. A regular driver can 
eat a huge amount of memory for its own usages, would this amount of 
memory be treated as an error as they are invisible to the 
balloon_page_enqueue?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
