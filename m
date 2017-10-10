Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53C316B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 03:27:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so3092168pfa.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 00:27:36 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h9si8513344pll.316.2017.10.10.00.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 00:27:33 -0700 (PDT)
Message-ID: <59DC76BA.7070202@intel.com>
Date: Tue, 10 Oct 2017 15:28:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com> <1506744354-20979-4-git-send-email-wei.w.wang@intel.com> <20171009181612-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171009181612-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 10/09/2017 11:20 PM, Michael S. Tsirkin wrote:
> On Sat, Sep 30, 2017 at 12:05:52PM +0800, Wei Wang wrote:
>> +static inline void xb_set_page(struct virtio_balloon *vb,
>> +			       struct page *page,
>> +			       unsigned long *pfn_min,
>> +			       unsigned long *pfn_max)
>> +{
>> +	unsigned long pfn = page_to_pfn(page);
>> +
>> +	*pfn_min = min(pfn, *pfn_min);
>> +	*pfn_max = max(pfn, *pfn_max);
>> +	xb_preload(GFP_KERNEL);
>> +	xb_set_bit(&vb->page_xb, pfn);
>> +	xb_preload_end();
>> +}
>> +
> So, this will allocate memory
>
> ...
>
>> @@ -198,9 +327,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>>   	struct page *page;
>>   	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>>   	LIST_HEAD(pages);
>> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
>> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>>   
>> -	/* We can only do one array worth at a time. */
>> -	num = min(num, ARRAY_SIZE(vb->pfns));
>> +	/* Traditionally, we can only do one array worth at a time. */
>> +	if (!use_sg)
>> +		num = min(num, ARRAY_SIZE(vb->pfns));
>>   
>>   	mutex_lock(&vb->balloon_lock);
>>   	/* We can't release more pages than taken */
> And is sometimes called on OOM.
>
>
> I suspect we need to
>
> 1. keep around some memory for leak on oom
>
> 2. for non oom allocate outside locks
>
>

I think maybe we can optimize the existing balloon logic, which could 
remove the big balloon lock:

It would not be necessary to have the inflating and deflating run at the 
same time.
For example, 1st request to inflate 7G RAM, when 1GB has been given to 
the host (so 6G left), the
2nd request to deflate 5G is received. Instead of waiting for the 1st 
request to inflate 6G and then
continuing with the 2nd request to deflate 5G, we can do a diff (6G to 
inflate - 5G to deflate) immediately,
and got 1G to inflate. In this way, all that driver will do is to simply 
inflate another 1G.

Same for the OOM case: when OOM asks for 1G, while inflating 5G is in 
progress, then the driver can
deduct 1G from the amount that needs to inflate, and as a result, it 
will inflate 4G.

In this case, we will never have the inflating and deflating task run at 
the same time, so I think it is
possible to remove the lock, and therefore, we will not have that 
deadlock issue.

What would you guys think?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
